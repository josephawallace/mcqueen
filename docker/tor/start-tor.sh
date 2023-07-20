#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit.
error() {
    echo "$1" > /dev/stderr
    exit 0
}

# return is used within bash function in order to return the value.
return() {
    echo "$1"
}

# set_default function gives the ability to move the setting of default
# env variable from docker file to the script thereby giving the ability to the
# user override it during container start.
set_default() {
    # docker initialized env variables with blank string and we can't just
    # use -z flag as usually.
    BLANK_STRING='""'

    VARIABLE="$1"
    DEFAULT="$2"

    if [[ -z "$VARIABLE" || "$VARIABLE" == "$BLANK_STRING" ]]; then

        if [ -z "$DEFAULT" ]; then
            error "You should specify default variable"
        else
            VARIABLE="$DEFAULT"
        fi
    fi

   return "$VARIABLE"
}

cat > /etc/tor/torrc << EOF
RunAsDaemon 0
Log notice stdout
Log notice file /root/.tor/notices.log
DataDirectory /root/.tor/data
ControlPort 9051

HiddenServiceDir /root/.tor/btcd-mainnet
HiddenServicePort 8333 127.0.0.1:8333

HiddenServiceDir /root/.tor/btcd-testnet
HiddenServicePort 18333 127.0.0.1:18333

HiddenServiceDir /root/.tor/btcd-simnet
HiddenServicePort 18555 127.0.0.1:18555

HiddenServiceDir /root/.tor/btcd-segnet
HiddenServicePort 28901 127.0.0.1:28901

$ADDITIONAL_VARIABLES
EOF

exec tor -f /etc/tor/torrc "$@"
