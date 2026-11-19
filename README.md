# Dot Files

The setup here is such that these never need to be moved from the directory they are cloned into. The script `unpack.sh` creates soft links to its contents in an input directory. First clone recursively:

```
git clone --recurse-submodules <URL> <PATH>
```

Then, to create soft links in root directory on a Mac:

```
./unpack.sh content ~/
```

This keeps things neat. The script never overwrites existing files, so it is safe to re-run.

## Layout

Everything in this repository should be useful on every machine.

`.config`, `.cargo`, and `.ssh` are created as real directories in `~`, with only their tracked children linked. Anything else tools write there (caches, keys, credentials, app state) stays out of the repo.

Per-machine config goes in untracked files that are sourced only if present:

- `~/.zshrc.local`, sourced by `.zshrc`
- `~/.ssh/config.local`, included by `.ssh/config`

## Migrating from whole-directory links

Older checkouts linked `~/.config`, `~/.cargo`, and `~/.ssh` straight into the repo. To convert one of them (here `.config`), move the untracked children out and re-link:

```
mkdir ~/.config.new
# mv any untracked entries from content/.config into ~/.config.new (see `git status`)
rm ~/.config && mv ~/.config.new ~/.config
./unpack.sh content ~/
```
