FROM golang:1.20.4-alpine as builder

LABEL maintainer="Joseph A. Wallace <joe@milque.com>"

RUN apk add --no-cache git gcc musl-dev

WORKDIR $GOPATH/src/github.com/btcsuite/btcd

ARG BTCD_VERSION=v0.23.4

RUN git clone https://github.com/btcsuite/btcd.git . \
    && git checkout $BTCD_VERSION \
    && go install -v . ./cmd/...

FROM alpine as final

# Expose mainnet ports (server, rpc)
EXPOSE 8333 8334

# Expose testnet ports (server, rpc)
EXPOSE 18333 18334

# Expose simnet ports (server, rpc)
EXPOSE 18555 18556

# Expose segnet ports (server, rpc)
EXPOSE 28901 28902

# Copy the compiled binaries from the builder image.
COPY --from=builder /go/bin/addblock /bin/
COPY --from=builder /go/bin/btcctl /bin/
COPY --from=builder /go/bin/btcd /bin/
COPY --from=builder /go/bin/findcheckpoint /bin/
COPY --from=builder /go/bin/gencerts /bin/

COPY "start-btcctl.sh" .
COPY "start-btcd.sh" .

RUN apk add --no-cache \
    bash \
    ca-certificates \
&&  mkdir "/rpc" "/root/.btcd" "/root/.btcctl" \
&&  touch "/root/.btcd/btcd.conf" \
&&  chmod +x start-btcctl.sh \
&&  chmod +x start-btcd.sh
