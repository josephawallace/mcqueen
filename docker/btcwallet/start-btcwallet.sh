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
# user override it durin container start.
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

# Set default variables if needed.
RPC_HOST=$(set_default "$RPC_HOST" "localhost")
RPC_PORT=$(set_default "$RPC_PORT" "18556")
RPC_USER=$(set_default "$RPC_USER" "devuser")
RPC_PASS=$(set_default "$RPC_PASS" "devpass")
NETWORK=$(set_default "$NETWORK" "simnet")

PARAMS=""
if [ "$NETWORK" != "mainnet" ]; then
    PARAMS=$(echo $PARAMS "--$NETWORK")
fi

PARAMS=$(echo $PARAMS \
    "--rpclisten=0.0.0.0" \
    "--cafile=/rpc/rpc.cert" \
    "--rpccert=/rpc/rpc.cert" \
    "--rpckey=/rpc/rpc.key" \
    "--username=$RPC_USER" \
    "--password=$RPC_PASS" \
    "--walletpass=$WALLET_PASS" \
    "--appdata=/root/.btcwallet" \
    "--debuglevel=$DEBUG" \
    "$@"
)

exec btcwallet $PARAMS
