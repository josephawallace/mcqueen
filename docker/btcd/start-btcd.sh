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
RPC_USER=$(set_default "$RPC_USER" "devuser")
RPC_PASS=$(set_default "$RPC_PASS" "devpass")
DEBUG=$(set_default "$DEBUG" "info")
NETWORK=$(set_default "$NETWORK" "mainnet")

PARAMS=""
if [ "$NETWORK" != "mainnet" ]; then
   PARAMS="--$NETWORK"
fi

if [[ -n "$MINING_ADDRESS" ]]; then
    PARAMS="$PARAMS --miningaddr=$MINING_ADDRESS"
fi

PARAMS=$(echo $PARAMS \
    "--debuglevel=$DEBUG" \
    "--rpcuser=$RPC_USER" \
    "--rpcpass=$RPC_PASS" \
    "--datadir=/root/.btcd/data" \
    "--logdir=/root/.btcd/logs" \
    "--rpccert=/rpc/rpc.cert" \
    "--rpckey=/rpc/rpc.key" \
    "--rpclisten=0.0.0.0" \
    "--onion=127.0.0.1:9050" \
    "--externalip=$BTCD_ONION_ADDRESS" \
    "--txindex" \
    "$@"
)

exec btcd $PARAMS
