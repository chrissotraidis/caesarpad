#!/usr/bin/env bash

caesarpad_select_simulator() {
    local devices
    devices="$(xcrun simctl list devices available)"

    if [[ -n "${SIMULATOR_UDID:-}" ]]; then
        if ! grep -Fq "($SIMULATOR_UDID)" <<<"$devices"; then
            echo "SIMULATOR_UDID is not an available Simulator: $SIMULATOR_UDID" >&2
            return 1
        fi
    else
        SIMULATOR_UDID="$(
            sed -nE '/^[[:space:]]+iPad.*\(Booted\)/{
                s/.*\(([0-9A-Fa-f-]{36})\).*/\1/
                p
                q
            }' <<<"$devices"
        )"
        if [[ -z "$SIMULATOR_UDID" ]]; then
            SIMULATOR_UDID="$(
                sed -nE '/^[[:space:]]+iPad/{
                    s/.*\(([0-9A-Fa-f-]{36})\).*/\1/
                    p
                    q
                }' <<<"$devices"
            )"
        fi
    fi

    if [[ -z "$SIMULATOR_UDID" ]]; then
        echo "No available iPad Simulator was found. Install one in Xcode Settings > Components." >&2
        return 1
    fi

    export SIMULATOR_UDID
    echo "Using iPad Simulator $SIMULATOR_UDID"
}
