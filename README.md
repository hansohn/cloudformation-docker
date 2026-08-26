<div align="center">
  <h1>cloudformation-docker</h1>
  <p>CloudFormation tooling Docker image</p>
  <p>
    <!-- Build Status -->
    <a href="https://actions-badge.atrox.dev/hansohn/cloudformation-docker/goto?ref=main"><img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhansohn%2Fcloudformation-docker%2Fbadge%3Fref%3Dmain&style=for-the-badge"></a>
    <!-- Github Tag -->
    <a href="https://gitHub.com/hansohn/cloudformation-docker/tags/"><img src="https://img.shields.io/github/tag/hansohn/cloudformation-docker.svg?style=for-the-badge"></a>
    <!-- Docker Pulls -->
    <a href="https://hub.docker.com/r/hansohn/cloudformation"><img src="https://img.shields.io/docker/pulls/hansohn/cloudformation.svg?style=for-the-badge"></a>
    <!-- Docker Image Size -->
    <a href="https://hub.docker.com/r/hansohn/cloudformation"><img src="https://img.shields.io/docker/image-size/hansohn/cloudformation/latest.svg?style=for-the-badge"></a>
    <!-- License -->
    <a href="https://github.com/hansohn/cloudformation-docker/blob/main/LICENSE"><img src="https://img.shields.io/github/license/hansohn/cloudformation-docker.svg?style=for-the-badge"></a>
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
image version tracks the pinned AWS CLI release. `cfn-guard` is arch-guarded —
bundled on `amd64`/`arm64` and skipped on architectures without a published
binary so multi-arch builds stay green.

## Tags

Image tags follow the pinned `AWSCLI_VERSION` in the `Dockerfile`. The other
bundled tools (`cfn-lint`, `rain`, `cfn-guard`) are pinned independently, so a
bump to one of those does not move the version — it republishes the existing
tags with the newer tool inside.

```
# tag formats (for a pinned AWS CLI version of e.g. 2.36.31)
hansohn/cloudformation:latest    the currently published release
hansohn/cloudformation:2         the 2.x.x line
hansohn/cloudformation:2.36      the 2.36.x line
hansohn/cloudformation:2.36.31   the exact version
```

For reproducibility, pin by digest (`hansohn/cloudformation@sha256:...`); every
image ships provenance attestations and an SBOM bound to that digest.

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

## Extending

Additional CloudFormation tooling can be layered in the `Dockerfile` following
the same pinned-ARG + Renovate pattern — e.g. [`cfn-nag`][cfn-nag] (security
linting).

## Related Images

This image is one of a family of infrastructure-tooling images built from
the same Makefile, workflow and Renovate pattern. `terraform-docker` and
`cloudformation-docker` each build directly from Debian; the four
cloud-specific Terraform images layer on top of `hansohn/terraform`.

| Provider | Repo | Image |
| :------: | ---- | ----- |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" alt="Terraform" width="20" height="20"> | [terraform-docker](https://github.com/hansohn/terraform-docker) | [`hansohn/terraform`](https://hub.docker.com/r/hansohn/terraform) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/amazonwebservices/amazonwebservices-plain-wordmark.svg" alt="AWS" width="20" height="20"> | [terraform-aws-docker](https://github.com/hansohn/terraform-aws-docker) | [`hansohn/terraform-aws`](https://hub.docker.com/r/hansohn/terraform-aws) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/azure/azure-original.svg" alt="Azure" width="20" height="20"> | [terraform-azure-docker](https://github.com/hansohn/terraform-azure-docker) | [`hansohn/terraform-azure`](https://hub.docker.com/r/hansohn/terraform-azure) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/digitalocean/digitalocean-original.svg" alt="DigitalOcean" width="20" height="20"> | [terraform-digitalocean-docker](https://github.com/hansohn/terraform-digitalocean-docker) | [`hansohn/terraform-digitalocean`](https://hub.docker.com/r/hansohn/terraform-digitalocean) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/googlecloud/googlecloud-original.svg" alt="Google Cloud" width="20" height="20"> | [terraform-google-docker](https://github.com/hansohn/terraform-google-docker) | [`hansohn/terraform-google`](https://hub.docker.com/r/hansohn/terraform-google) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/amazonwebservices/amazonwebservices-plain-wordmark.svg" alt="AWS" width="20" height="20"> | [cloudformation-docker](https://github.com/hansohn/cloudformation-docker) | [`hansohn/cloudformation`](https://hub.docker.com/r/hansohn/cloudformation) |

## License

Apache 2.0 — see [LICENSE](LICENSE).

<!-- MARKDOWN LINKS & IMAGES -->
[terraform-aws]: https://github.com/hansohn/terraform-aws-docker
[rain]: https://github.com/aws-cloudformation/rain
[cfn-guard]: https://github.com/aws-cloudformation/cloudformation-guard
[cfn-nag]: https://github.com/stelligent/cfn_nag
