ARG DEBIAN_VERSION=bookworm-slim


# builder
FROM debian:${DEBIAN_VERSION} AS builder
ARG DEBIAN_FRONTEND=noninteractive
# renovate: datasource=github-tags depName=aws/aws-cli
ARG AWSCLI_VERSION=2.35.15
# AWS CLI installer packages are PGP-signed by the AWS CLI Team key. Trust is
# pinned to this fingerprint; the current public key (with up-to-date expiry) is
# fetched from a keyserver at build time so extensions don't require a rebuild.
ARG AWSCLI_GPG_FINGERPRINT=FB5DB77FD5C118B80511ADA8A6310ACC4672475C
ENV CURL='curl -fsSL'
ENV CACHE_DIR='/var/cache/github-api'
COPY scripts/resolve-version.sh /opt/build/resolve-version
RUN apt-get update && apt-get install --no-install-recommends -y \
      ca-certificates \
      curl \
      dirmngr \
      gnupg \
      jq \
      unzip \
  && mkdir -p ${CACHE_DIR} \
  && rm -rf /var/lib/apt/lists/*

# awscli
RUN --mount=type=cache,target=/var/cache/github-api \
    --mount=type=cache,target=/var/cache/downloads \
    /bin/bash -c 'set -e; \
  AWSCLI_VERSION=$(/opt/build/resolve-version aws-cli "${AWSCLI_VERSION}"); \
  ARCH=$(uname -m); \
  ZIP="/var/cache/downloads/awscli-${AWSCLI_VERSION}-${ARCH}.zip"; \
  SIG="/var/cache/downloads/awscli-${AWSCLI_VERSION}-${ARCH}.zip.sig"; \
  if [[ ! -f "${ZIP}" ]]; then \
  ${CURL} https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWSCLI_VERSION}.zip -o "${ZIP}"; \
  fi; \
  if [[ ! -f "${SIG}" ]]; then \
  ${CURL} https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWSCLI_VERSION}.zip.sig -o "${SIG}"; \
  fi; \
  export GNUPGHOME="$(mktemp -d)"; \
  for ks in keyserver.ubuntu.com keys.openpgp.org pgp.mit.edu; do \
  gpg --batch --keyserver "hkps://${ks}" --recv-keys "${AWSCLI_GPG_FINGERPRINT}" && break; \
  done; \
  gpg --batch --verify "${SIG}" "${ZIP}"; \
  gpgconf --kill all || true; \
  rm -rf "${GNUPGHOME}"; \
  unzip -q -o "${ZIP}" -d /tmp; \
  /tmp/aws/install --bin-dir /aws-cli-bin/ --install-dir /usr/local/aws-cli \
  && /aws-cli-bin/aws --version'


# main
FROM debian:${DEBIAN_VERSION} AS main
ARG DEBIAN_FRONTEND=noninteractive
# renovate: datasource=pypi depName=cfn-lint
ARG CFN_LINT_VERSION=1.22.0
# awscli renders help output through groff/less; python3 hosts cfn-lint.
RUN apt-get update && apt-get install --no-install-recommends -y \
      bash \
      ca-certificates \
      curl \
      git \
      groff \
      jq \
      less \
      python3 \
      python3-venv \
      unzip \
      vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /aws-cli-bin/ /usr/local/bin/
COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/

# cfn-lint (isolated venv; avoids Debian's externally-managed pip restriction)
ENV CFN_LINT_HOME=/opt/cfn-lint
ENV PATH="${CFN_LINT_HOME}/bin:${PATH}"
RUN python3 -m venv "${CFN_LINT_HOME}" \
  && if [ "${CFN_LINT_VERSION}" = "latest" ]; then \
       "${CFN_LINT_HOME}/bin/pip" install --no-cache-dir --upgrade cfn-lint; \
     else \
       "${CFN_LINT_HOME}/bin/pip" install --no-cache-dir "cfn-lint==${CFN_LINT_VERSION}"; \
     fi \
  && printf '\ncomplete -C /usr/local/bin/aws_completer aws\n' >> /root/.bashrc \
  && aws --version \
  && cfn-lint --version

ENTRYPOINT []
