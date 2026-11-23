---
name: sync-skills
description: Update the installed skills from the AntonioSegoviaExposito/Skills repository. Use when the user asks to sync, pull, refresh or update the skills from the repo, or says the skills changed in the repository.
---

Run this from this skill's directory. It downloads the repository tarball into a temporary directory and mirrors it into the parent folder (`..`) with `rsync --delete`, leaving out `README.md`, `.gitignore`, and local untracked config such as `scripts/env`:

```bash
TMP_DIR=$(mktemp -d) && trap 'rm -rf "$TMP_DIR"' EXIT && gh api repos/AntonioSegoviaExposito/Skills/tarball | tar -xzf - -C "$TMP_DIR" --strip-components 1 && rsync -a --delete --exclude=README.md --exclude=.gitignore --exclude='scripts/env' "$TMP_DIR"/ ../
```

Files from the repository overwrite the installed ones, and any skills or files deleted from the repository are also removed locally. Local config matching `scripts/env` is preserved.

If the command fails, report the error and stop. Otherwise tell the user the skills are updated; agents may need a new session to load the changes.
