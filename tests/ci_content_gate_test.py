"""Keep the existing IPA/source downloads behind the shared content check."""
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CIContentGateTests(unittest.TestCase):
    def test_every_uploaded_payload_is_checked_before_upload(self):
        workflow = (ROOT / '.github/workflows/ios-build.yml').read_text()
        gate = workflow[workflow.index('- name: Audit public app and source payloads'):
                        workflow.index('- uses: actions/upload-artifact@')]
        self.assertIn('python3 -B -m padmint audit', gate)
        self.assertIn('"$GITHUB_WORKSPACE"/build/release/*.ipa', gate)
        self.assertIn('"$GITHUB_WORKSPACE"/build/release/*-source.tar.gz', gate)
        self.assertNotIn('continue-on-error', gate)
        self.assertNotIn('||', gate)
        self.assertNotIn('if:', gate)

    def test_auditor_is_pinned_and_downloads_remain(self):
        workflow = (ROOT / '.github/workflows/ios-build.yml').read_text()
        self.assertRegex(workflow, re.compile(
            r'repository: chrissotraidis/padmint\s+'
            r'ref: f0efbb738cac934559e986143343dc8720a6fb1d\s+'
            r'path: \.ci-padmint\s+'
            r'persist-credentials: false'))
        self.assertIn('working-directory: .ci-padmint', workflow)
        for retained in ('scripts/check-repo-safety.sh', 'scripts/test-touch.sh',
                         'scripts/build-device.sh', 'scripts/package-ios.sh',
                         'build/release/*.ipa*', 'build/release/*-source.tar.gz*',
                         'needs: build', '--verify-tag', '--prerelease'):
            self.assertIn(retained, workflow)

    def test_gate_contract_runs_before_the_build(self):
        workflow = (ROOT / '.github/workflows/ios-build.yml').read_text()
        self.assertLess(workflow.index('python3 -B tests/ci_content_gate_test.py'),
                        workflow.index('scripts/build-device.sh'))


if __name__ == '__main__':
    unittest.main()
