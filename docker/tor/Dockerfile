FROM alpine:latest

RUN apk --update --no-cache add bash tor
RUN mkdir /root/.tor && touch /etc/tor/torrc

COPY start-tor.sh .
RUN chmod +x start-tor.sh

# ORPort, DirPort, SocksPort, ObfsproxyPort, MeekPort
EXPOSE 9001 9030 9050 54444 7002