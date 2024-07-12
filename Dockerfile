ARG HASKELL_IMG=haskell:buster-slim
ARG HASKELL_RESOLVER=nightly
ARG HLEDGER_PACKAGES='hledger-1.34,hledger-web-1.34,hledger-ui-1.34,hledger-interest-1.6.6'
ARG HLEDGER_GID=3913
ARG HLEDGER_UID=3913

FROM $HASKELL_IMG AS hs

# Pulling ARG from previous stage of build
ARG HASKELL_RESOLVER
ARG HLEDGER_PACKAGES
ARG HLEDGER_GID
ARG HLEDGER_UID

ENV LC_ALL=C.UTF-8
RUN stack setup --resolver="$HASKELL_RESOLVER" --install-ghc

COPY ./install-helper.sh /bin/install-helper.sh
RUN /bin/install-helper.sh "$HASKELL_RESOLVER" "$HLEDGER_PACKAGES"
RUN ls /root/.local/bin/hledger*

FROM debian:buster-slim
LABEL maintainer="Bharath Sudheer bharath.sudheer@gmail.com"

# Pulling ARG from previous stage of build
ARG HLEDGER_GID
ARG HLEDGER_UID

RUN apt-get update && apt-get install --yes libgmp10 libtinfo6 && rm -rf /var/lib/apt/lists

# Set up hledger group and hledger user (non-root)
RUN groupadd --gid $HLEDGER_GID hledger
RUN useradd --no-create-home -g hledger --uid $HLEDGER_UID hledger

# Cache for web
RUN mkdir /.cache && chmod 0777 /.cache

# Copy hledger binaries
COPY --from=hs /root/.local/bin/hledger* /bin/
RUN ls /bin/hledger* 

ENV LC_ALL=C.UTF-8
EXPOSE 5000 5001

COPY start.sh /start.sh

# Drops from root to non-root hledger user in the start script
# Also fixes permissions in /data to hledger:hledger rwx rwx r--
ENTRYPOINT ["/start.sh"]
