#!/usr/bin/env python3
"""Validate immutable sources; fetch only missing archives; export complete source."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tarfile
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parent.parent
LOCK = json.loads((ROOT / 'sources.lock.json').read_text())

def git(root, *args):
    return subprocess.check_output(['git', '-C', str(root), *args], text=True).strip()

def inventory(root, excluded=()):
    result = {}
    for folder, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d != '.git' and str((Path(folder) / d).relative_to(root)) not in excluded)
        for name in sorted(files + [d for d in dirs if (Path(folder) / d).is_symlink()]):
            p = Path(folder) / name
            if name in ('.git', '.caesarpad-source') or str(p.relative_to(root)) in excluded:
                continue
            result[str(p.relative_to(root))] = [stat.S_IMODE(p.lstat().st_mode),
                'link:' + os.readlink(p) if p.is_symlink() else hashlib.sha256(p.read_bytes()).hexdigest()]
    return result

def verify_files(root, expected):
    actual = inventory(root)
    differences = [p for p in actual.keys() | expected.keys() if actual.get(p) != expected.get(p)]
    if differences:
        raise RuntimeError(f'{root}: source contents/modes differ: {sorted(differences)[:8]}; preserve edits and restore separately')

def check(fetch=False):
    exported = ROOT / 'SOURCE_MANIFEST.json'
    if not (ROOT / '.git').exists():
        if not exported.exists():
            raise RuntimeError('Use a recursive Git clone or the complete source archive (not GitHub automatic ZIP)')
        manifest = json.loads(exported.read_text())
        actual = inventory(ROOT, ('build', 'artifacts', 'SOURCE_MANIFEST.json'))
        if actual != manifest['files']:
            raise RuntimeError('Source archive has modified, missing or extra input files')
        provenance = manifest['provenance'].copy()
        provenance['toolchain'] = subprocess.check_output(['xcodebuild', '-version'], text=True).strip()
        provenance['cmake'] = subprocess.check_output(['cmake', '--version'], text=True).splitlines()[0]
        return provenance
    for item in LOCK['git']:
        p = ROOT / item['path']
        if not (p / '.git').exists() or git(p, 'rev-parse', 'HEAD') != item['commit']:
            raise RuntimeError(f"Missing/mismatched {item['path']}; use git submodule update --init --recursive in a clean checkout")
        parent = max([ROOT] + [ROOT / x['path'] for x in LOCK['git'] if p != ROOT / x['path'] and (ROOT / x['path']) in p.parents], key=lambda x: len(x.parts))
        entry = git(parent, 'ls-files', '--stage', str(p.relative_to(parent))).split()
        if len(entry) < 2 or entry[0] != '160000' or entry[1] != item['commit']:
            raise RuntimeError(f"Lock/gitlink mismatch: {item['path']}")
        if git(p, 'status' , '--porcelain', '--untracked-files=all'):
            raise RuntimeError(f"Dirty dependency: {item['path']}; preserve changes, do not reset automatically")
    for item in LOCK['archives']:
        p = ROOT / item['path']
        expected = json.loads((ROOT / item['manifest']).read_text())
        if not p.exists() and fetch:
            with tempfile.TemporaryDirectory(prefix='caesarpad-download-') as tmp:
                archive = Path(tmp) / 'source.tar.gz'
                urllib.request.urlretrieve(item['url'], archive)
                if hashlib.sha256(archive.read_bytes()).hexdigest() != item['sha256']:
                    raise RuntimeError('Source archive checksum mismatch')
                unpack = Path(tmp) / 'unpack'
                unpack.mkdir()
                # Pinned trusted release contains framework symlinks; retain their exact targets.
                with tarfile.open(archive) as tar:
                    tar.extractall(unpack)
                entries = list(unpack.iterdir())
                if len(entries) != 1:
                    raise RuntimeError('Unexpected archive layout')
                verify_files(entries[0], expected)
                p.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(entries[0]), p)
        verify_files(p, expected)
    return {'app_commit': git(ROOT, 'rev-parse', 'HEAD'), 'sources': LOCK,
            'toolchain': subprocess.check_output(['xcodebuild', '-version'], text=True).strip(),
            'cmake': subprocess.check_output(['cmake', '--version'], text=True).splitlines()[0]}

def require_clean():
    if (ROOT / '.git').exists() and git(ROOT, 'status', '--porcelain', '--untracked-files=all'):
        raise RuntimeError('Commit intended app changes before packaging/stamping/exporting source')

def export_source(output, provenance):
    require_clean()
    if not (ROOT / '.git').exists():
        raise RuntimeError('Export from the clean Git checkout')
    with tempfile.TemporaryDirectory(prefix='caesarpad-source-') as tmp:
        stage = Path(tmp) / 'CaesarPad-source'
        stage.mkdir()
        for rel in [''] + [x['path'] for x in LOCK['git']]:
            target = stage / rel
            target.mkdir(parents=True, exist_ok=True)
            data = subprocess.check_output(['git', '-C', str(ROOT / rel), 'archive', 'HEAD'])
            with tarfile.open(fileobj=io.BytesIO(data)) as tar:
                tar.extractall(target)
        for item in LOCK['archives']:
            shutil.copytree(ROOT / item['path'], stage / item['path'], symlinks=True,
                            ignore=shutil.ignore_patterns('.caesarpad-source'))
        manifest = {'provenance': provenance, 'files': inventory(stage)}
        (stage / 'SOURCE_MANIFEST.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')
        output = Path(output).resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        with tarfile.open(output, 'w:gz') as tar:
            tar.add(stage, arcname=stage.name)
        output.with_name(output.name + '.sha256').write_text(hashlib.sha256(output.read_bytes()).hexdigest() + '  ' + output.name + '\n')
        print(f'Complete source: {output}')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fetch', action='store_true')
    parser.add_argument('--stamp', type=Path)
    parser.add_argument('--archive', type=Path)
    parser.add_argument('--verify-stamp', type=Path)
    args = parser.parse_args()
    try:
        provenance = check(args.fetch)
        if args.stamp or args.archive or args.verify_stamp:
            require_clean()
        if args.stamp:
            args.stamp.write_text(json.dumps(provenance, indent=2) + '\n')
        if args.verify_stamp and json.loads(args.verify_stamp.read_text()) != provenance:
            raise RuntimeError('App provenance differs from current sources/toolchain; rebuild before packaging')
        if args.archive:
            export_source(args.archive, provenance)
        print('PASS: immutable source graph and archive contents')
    except (RuntimeError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f'ERROR: {error}\n')
