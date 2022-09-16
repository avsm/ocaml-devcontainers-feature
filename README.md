# Dev Container Features: OCaml

This repo provides a [dev container](https://containers.dev/implementors/features-distribution) feature for thea [OCaml](https://ocaml.org) programming language.

## Contents

### `ocaml`

The `ocaml` feature installs an OCaml compiler and common tools in a Debian Bullseye-based development environment.

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.  Each feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`. 

```
├── src
│   ├── ocaml
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
...
```

An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time.  Implementing tools are also free to process attributes under the `customizations` property as desired.
