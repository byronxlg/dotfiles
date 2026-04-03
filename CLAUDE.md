## Dotfiles

This repo is managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory (`.config`, `.claude`, etc.) maps to `$HOME`.

### Stow usage

Always use `--no-folding` to create individual symlinks instead of symlinking entire directories:

```sh
stow . --no-folding
```

This prevents stow from replacing a real directory in `$HOME` with a symlink to the dotfiles directory, which would cause non-dotfile contents to appear in the repo.
