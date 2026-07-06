#!/bin/bash
# resolve-version.sh TOOL VERSION
#
# Echoes the resolved release version for TOOL. If VERSION is anything other
# than "latest" it is echoed back unchanged (pinned versions pass through).
# Otherwise the latest release is looked up via the tool's release API and
# cached in ${CACHE_DIR} for one hour so repeated builds don't hammer the API.
set -euo pipefail

TOOL="${1:?usage: resolve-version.sh TOOL VERSION}"
VERSION="${2:?usage: resolve-version.sh TOOL VERSION}"

CURL="${CURL:-curl -fsSL}"
CACHE_DIR="${CACHE_DIR:-/var/cache/github-api}"

if [[ "${VERSION}" != "latest" ]]; then
  echo "${VERSION}"
  exit 0
fi

mkdir -p "${CACHE_DIR}"
CACHE_FILE="${CACHE_DIR}/${TOOL}-version"
if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then
  cat "${CACHE_FILE}"
  exit 0
fi

case "${TOOL}" in
  aws-cli)
    # aws/aws-cli publishes git tags but no GitHub Release objects, so resolve
    # the highest v2 tag rather than querying the releases endpoint.
    VERSION=$(${CURL} "https://api.github.com/repos/aws/aws-cli/tags?per_page=100" | jq -r '.[].name' | grep -E '^2\.' | sort -V | tail -1) ;;
  cfn-lint)
    VERSION=$(${CURL} "https://pypi.org/pypi/cfn-lint/json" | jq -r .info.version) ;;
  rain)
    VERSION=$(${CURL} "https://api.github.com/repos/aws-cloudformation/rain/releases/latest" | jq -r .tag_name) ;;
  cfn-guard)
    VERSION=$(${CURL} "https://api.github.com/repos/aws-cloudformation/cloudformation-guard/releases/latest" | jq -r .tag_name) ;;
  *)
    echo "resolve-version.sh: unknown tool '${TOOL}'" >&2
    exit 1 ;;
esac

if [[ -z "${VERSION}" ]] || [[ "${VERSION}" == "null" ]]; then
  echo "resolve-version.sh: failed to resolve latest version for '${TOOL}'" >&2
  exit 1
fi

echo "${VERSION}" > "${CACHE_FILE}"
echo "${VERSION}"
