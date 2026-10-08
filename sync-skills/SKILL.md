---
name: sync-skills
description: Update the installed skills from the AntonioSegoviaExposito/Skills repository. Use when the user asks to sync, pull, refresh or update the skills from the repo, or says the skills changed in the repository.
---

Run this from this skill's directory. It downloads the repository with `gh` and extracts it over the parent folder, the one that holds the installed skills, leaving out `README.md` and `.gitignore`:

```bash
gh api repos/AntonioSegoviaExposito/Skills/tarball | tar -xzf - -C .. --strip-components 1 --exclude README.md --exclude .gitignore
```

Files from the repository overwrite the installed ones. Everything the repository does not have stays as it is: other skills and local config such as `scripts/env`. Skills or files deleted from the repository are not removed from the installed folder.

If the command fails, report the error and stop. Otherwise tell the user the skills are updated; agents may need a new session to load the changes.
