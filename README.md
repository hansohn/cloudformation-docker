<div align="center">
  <h3>cloudformation-docker</h3>
  <p>CloudFormation tooling Docker image</p>
  <p>
    <!-- Build Status -->
    <a href="https://actions-badge.atrox.dev/hansohn/cloudformation-docker/goto?ref=main">
      <img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhansohn%2Fcloudformation-docker%2Fbadge%3Fref%3Dmain&style=for-the-badge">
    </a>
    <!-- Github Tag -->
    <a href="https://gitHub.com/hansohn/cloudformation-docker/tags/">
      <img src="https://img.shields.io/github/tag/hansohn/cloudformation-docker.svg?style=for-the-badge">
    </a>
    <!-- Docker Pulls -->
    <a href="https://hub.docker.com/r/hansohn/cloudformation">
      <img src="https://img.shields.io/docker/pulls/hansohn/cloudformation.svg?style=for-the-badge">
    </a>
    <!-- Docker Image Size -->
    <a href="https://hub.docker.com/r/hansohn/cloudformation">
      <img src="https://img.shields.io/docker/image-size/hansohn/cloudformation/latest.svg?style=for-the-badge">
    </a>
    <!-- License -->
    <a href="https://github.com/hansohn/cloudformation-docker/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/hansohn/cloudformation-docker.svg?style=for-the-badge">
    </a>
  </p>
</div>

## Description

A small, multi-arch Docker image with the tooling needed to lint, validate, and
deploy AWS CloudFormation — the CloudFormation counterpart to
[`terraform-aws`][terraform-aws]. Use it for local development (`make dev`) and
in CI (e.g. the `aws-account-bootstrap` seed repo).

## What's Included

| Tool | Purpose |
| ---- | ------- |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/) | Deploy stacks/StackSets, `validate-template` |
| [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) | Lint CloudFormation templates |
| [rain][rain] | CloudFormation CLI + formatter (`rain fmt`, `rain deploy`) |
| [cfn-guard][cfn-guard] | Policy-as-code validation (`cfn-guard validate`) |
| `git`, `jq`, `bash`, `vim` | Everyday tooling for scripts and CI |

The AWS CLI is PGP-verified against the AWS CLI Team key at build time; the
image version tracks the pinned `cfn-lint` release. `cfn-guard` is arch-guarded —
bundled on `amd64`/`arm64` and skipped on architectures without a published
binary so multi-arch builds stay green.

## Tags

```
hansohn/cloudformation:latest    the currently published release
hansohn/cloudformation:1         the 1.x.x line
hansohn/cloudformation:1.22      the 1.22.x line
hansohn/cloudformation:1.22.0    the exact version
```

## Usage

```bash
# lint a template
docker run --rm -v "$(pwd)":/w -w /w hansohn/cloudformation:latest \
  cfn-lint templates/*.yaml

# validate against the CloudFormation API (needs creds)
docker run --rm -v "$(pwd)":/w -w /w -v ~/.aws:/root/.aws \
  hansohn/cloudformation:latest \
  aws cloudformation validate-template --template-body file://templates/account-seed.yaml

# interactive shell
docker run -it --rm -v "$(pwd)":/w -w /w hansohn/cloudformation:latest bash
```

## Build

Versions default to the pins in the `Dockerfile` (managed by Renovate); override
on the command line for ad-hoc builds.

```bash
make docker/build                       # build for the local platform
make docker/run                         # build then drop into a shell
CFN_LINT_VERSION=1.20.0 make docker/build
DOCKER_PLATFORMS=linux/amd64,linux/arm64 make docker/build
```

Run `make help` for all targets.

## Publishing

Images are automatically:

- **Built and linted** on every push, including `main` (multi-platform, without publishing)
- **Published** when a version tag is pushed
- **Refreshed** every Monday at 7am UTC, rebuilding `main` so merged dependency updates and base-image security patches reach Docker Hub

Pushes to `main` are built for verification but not published. Merged
dependency updates ship on the next weekly refresh, or immediately if you cut
a release tag.

## Extending

Additional CloudFormation tooling can be layered in the `Dockerfile` following
the same pinned-ARG + Renovate pattern — e.g. [`cfn-nag`][cfn-nag] (security
linting).

## License

Apache 2.0 — see [LICENSE](LICENSE).

<!-- MARKDOWN LINKS & IMAGES -->
[terraform-aws]: https://github.com/hansohn/terraform-aws-docker
[rain]: https://github.com/aws-cloudformation/rain
[cfn-guard]: https://github.com/aws-cloudformation/cloudformation-guard
[cfn-nag]: https://github.com/stelligent/cfn_nag
