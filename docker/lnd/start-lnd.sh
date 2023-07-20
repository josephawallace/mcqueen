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

# Set default variables if needed.
RPC_HOST=$(set_default "$RPC_HOST" "localhost")
RPC_USER=$(set_default "$RPC_USER" "devuser")
RPC_PASS=$(set_default "$RPC_PASS" "devpass")
DEBUG=$(set_default "$DEBUG" "debug")
NETWORK=$(set_default "$NETWORK" "mainnet")

exec lnd \
    "--lnddir=/root/.lnd" \
    "--tlscertpath=/rpc/rpc.cert" \
    "--tlskeypath=/rpc/rpc.key" \
    "--bitcoin.active" \
    "--bitcoin.$NETWORK" \
    "--bitcoin.node=btcd" \
    "--btcd.rpccert=/rpc/rpc.cert" \
    "--btcd.rpchost=$RPC_HOST" \
    "--btcd.rpcuser=$RPC_USER" \
    "--btcd.rpcpass=$RPC_PASS" \
    "--rpclisten=0.0.0.0:$LND_RPC_PORT" \
    "--listen=0.0.0.0:$LND_P2P_PORT" \
    "--tor.active" \
    "--tor.v3" \
    "--debuglevel=$DEBUG" \
    "$@"
