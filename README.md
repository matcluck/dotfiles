# dotfiles

Personal dotfiles.

## Setup

```bash
./setup.sh
```

Detects the distro and installs packages + symlinks configs. VMware guests are detected automatically and get extra tooling.

## Local overrides

Anything host-, site-, or job-specific belongs outside this repo. The shipped configs source the following files when present:

- `~/.config/tmux/local.conf` – sourced from `tmux/tmux.conf`

Drop site/personal tweaks (custom status segments, work-only key bindings, etc.) into the matching local file. Anything not listed above does not have a hook yet – add one alongside the override and document it here.

