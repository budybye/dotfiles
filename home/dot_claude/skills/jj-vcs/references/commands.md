# Git → jj Detailed Command Mapping

## Repository Operations

| Purpose                 | Git                           | jj                               |
| ----------------------- | ----------------------------- | -------------------------------- |
| New Repository          | `git init`                    | `jj git init [--no-colocate]`    |
| Clone                   | `git clone <src> <dst>`       | `jj git clone <src> <dst>`       |
| Add Remote              | `git remote add <name> <url>` | `jj git remote add <name> <url>` |
| Fetch                   | `git fetch`                   | `jj git fetch`                   |
| Push (All)              | `git push --all`              | `jj git push --all`              |
| Push (Single)           | `git push origin <branch>`    | `jj git push --bookmark <name>`  |
| Push with Auto-Bookmark | -                             | `jj git push --change <rev>`     |

## Status and Inspection

| Purpose                | Git                               | jj                        |
| ---------------------- | --------------------------------- | ------------------------- |
| Show Status            | `git status`                      | `jj st`                   |
| Diff Current Changes   | `git diff HEAD`                   | `jj diff`                 |
| Diff Specific Revision | `git diff <rev>^ <rev>`           | `jj diff -r <rev>`        |
| Diff Between Two Revs  | `git diff A B`                    | `jj diff --from A --to B` |
| Show Commit Details    | `git show <rev>`                  | `jj show <rev>`           |
| Log (Ancestors)        | `git log --oneline --graph`       | `jj log -r ::@`           |
| Log (All)              | `git log --oneline --graph --all` | `jj log -r 'all()'`       |
| Log (Excluding main)   | `git log --branches --not main`   | `jj log`                  |
| Blame                  | `git blame <file>`                | `jj file annotate <path>` |
| List Files             | `git ls-files`                    | `jj file list`            |
| Root Directory         | `git rev-parse --show-toplevel`   | `jj workspace root`       |

## Commit Operations

| Purpose               | Git                                               | jj                            |
| --------------------- | ------------------------------------------------- | ----------------------------- |
| Commit                | `git commit -am "msg"`                            | `jj commit -m "msg"`          |
| Edit Description (@)  | -                                                 | `jj describe`                 |
| Edit Desc (Parent)    | `git commit --amend --only`                       | `jj describe @-`              |
| Edit Desc (Any)       | -                                                 | `jj describe <rev>`           |
| Start New Change      | `git checkout -b topic main`                      | `jj new main`                 |
| Squash to Parent      | `git commit --amend -a`                           | `jj squash`                   |
| Partial Squash        | `git add -p && git commit --amend`                | `jj squash -i`                |
| Squash to Ancestor    | `git commit --fixup=X && git rebase --autosquash` | `jj squash --into X`          |
| Split Change          | `git commit -p`                                   | `jj split`                    |
| Split Any Commit      | -                                                 | `jj split -r <rev>`           |
| Interactive Diff Edit | -                                                 | `jj diffedit -r <rev>`        |
| Cherry-pick           | `git cherry-pick <src>`                           | `jj duplicate <src> -o <dst>` |
| Revert                | `git revert <rev>`                                | `jj revert -r <rev> -B @`     |

## Branches / Bookmarks

| Purpose         | Git                            | jj                                                     |
| --------------- | ------------------------------ | ------------------------------------------------------ |
| List            | `git branch`                   | `jj bookmark list`                                     |
| Create          | `git branch <name>`            | `jj bookmark create <name>`                            |
| Move Forward    | `git branch -f <name> <rev>`   | `jj bookmark move <name> --to <rev>`                   |
| Move Backward   | `git branch -f <name> <rev>`   | `jj bookmark move <name> --to <rev> --allow-backwards` |
| Delete          | `git branch -d <name>`         | `jj bookmark delete <name>`                            |
| Remote Tracking | `git branch --set-upstream-to` | `jj bookmark track <name>@<remote>`                    |

## Rebase / Organization

| Purpose                     | Git                      | jj                          |
| --------------------------- | ------------------------ | --------------------------- |
| Rebase (with Descendants)   | `git rebase --onto B A^` | `jj rebase -s A -d B`       |
| Rebase (with Bookmark)      | `git rebase B A`         | `jj rebase -b A -d B`       |
| Reorder (A-B-C-D → A-C-B-D) | `git rebase -i A`        | `jj rebase -r C --before B` |
| Merge                       | `git merge A`            | `jj new @ A`                |

## Recovery / Undo

| Purpose                    | Git                      | jj                    |
| -------------------------- | ------------------------ | --------------------- |
| Discard Changes            | `git reset --hard`       | `jj abandon`          |
| Clear Changes (Reset)      | `git reset --hard`       | `jj restore`          |
| Restore Specific Files     | `git restore <paths>`    | `jj restore <paths>`  |
| Discard Parent (Keep Diff) | `git reset --soft HEAD~` | `jj squash --from @-` |
| Undo Last Operation        | -                        | `jj undo`             |
| Operation Log              | -                        | `jj op log`           |
| Revert to Operation        | -                        | `jj op revert`        |

## Stash Equivalents

| Purpose         | Git             | jj                       |
| --------------- | --------------- | ------------------------ |
| Temporary Stash | `git stash`     | `jj new @-`              |
| Restore Stashed | `git stash pop` | `jj edit <original_rev>` |

## Conflict Resolution

| Purpose           | Git                                       | jj                                            |
| ----------------- | ----------------------------------------- | --------------------------------------------- |
| Resolve Conflicts | `git add <file> && git rebase --continue` | Edit files directly (operation isn't blocked) |

## Useful Revset Expressions

```bash
# All local bookmarks (not on remote)
jj log -r 'bookmarks() && ~remote_bookmarks()'

# My bookmarks
jj log -r 'mine() && bookmarks() && ~remote_bookmarks()'

# My remote bookmarks
jj log -r 'remote_bookmarks() && mine()'

# Diff from main (for pre-push check)
jj log -r 'remote_bookmarks()..@'

# All revisions
jj log -r 'all()'
```
