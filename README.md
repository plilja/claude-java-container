# claude-java-container

A Podman container for Java development with Claude Code CLI. The container includes Java 25, Maven, and a firewall that restricts outbound network access to only the services needed.

## Prerequisites

- [Podman](https://podman.io/)
- A Claude Pro/Max/Teams/Enterprise account

## Usage

Navigate to your project and start the container:

```bash
cd ~/projects/my-java-app
~/workspace/claude-java-container/start.sh
```

Or pass the project path directly:

```bash
~/workspace/claude-java-container/start.sh ~/projects/my-java-app
```

To rebuild the image:

```bash
~/workspace/claude-java-container/start.sh --rebuild
```

## What's included

- Java 25 (Eclipse Temurin)
- Maven 3.9
- Claude Code CLI
- GitHub CLI (`gh`)
- Firewall restricting outbound traffic to allowed services only

## Authentication

The container reuses your existing Claude authentication from the host by mounting `~/.claude` and `~/.claude.json`. Log in on the host with `claude` before using the container.

## Firewall

The container starts with an iptables firewall that blocks all outbound traffic except:

- Anthropic APIs (`api.anthropic.com`, `claude.ai`)
- GitHub
- Maven Central (`repo1.maven.org`, `repo.maven.apache.org`)
- Sentry and Statsig (used internally by Claude)
- Claude installer CDN

To allow additional domains, add them to `init-firewall.sh` and rebuild with `--rebuild`.

## Running Claude

Once inside the container, start Claude with:

```bash
claude
```

Common commands like `mvn`, `gradle`, `java`, `javac`, `find`, `grep`, and web fetches are pre-approved via managed settings baked into the image. Git commits and pushes will still prompt for confirmation.
