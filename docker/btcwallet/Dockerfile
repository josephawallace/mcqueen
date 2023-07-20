FROM golang:1.20.4-alpine as builder

LABEL maintainer="Joseph A. Wallace <joe@milque.com>"

# Install build dependencies such as git and glide.
RUN apk add --no-cache git gcc musl-dev

WORKDIR $GOPATH/src/github.com/btcsuite/btcwallet

# Grab and install the latest version of of btcwallet and all related dependencies.
RUN git clone https://github.com/btcsuite/btcwallet.git . \
    && GO111MODULE=on go install -v ./ ./cmd/...

# Start a new image
FROM alpine as final

# Expose mainnet ports (rpc)
EXPOSE 8332

# Expose testnet ports (rpc)
EXPOSE 18332

# Expose simnet ports (rpc)
EXPOSE 18554

# Expose segnet ports (rpc)
EXPOSE 28900

# Copy the compiled binaries from the builder image.
COPY --from=builder /go/bin/btcwallet /bin/
COPY --from=builder /go/bin/dropwtxmgr /bin/
COPY --from=builder /go/bin/sweepaccount /bin/

COPY "start-btcwallet.sh" .
RUN chmod +x "start-btcwallet.sh"

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
&& chmod +x start-btcwallet.sh
