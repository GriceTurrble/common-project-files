## Common Just recipes used across my projects.
## See README for usage details.

# Setup all common tooling
[group("commons")]
bootstrap-commons:
    just bootstrap-precommit


# Run pre-commit install. Useful as a mixin for other recipes.
[group("precommit")]
bootstrap-precommit:
    pre-commit install


# Run pre-commit 'hook' against all files (default all hooks)
[group("precommit")]
lint hook="":
    pre-commit run {{ hook }} --all-files


# The result should be `\\[ \\]`, but we need to escape those slashes again here to make it work:
GREP_TARGET := "\\\\[gone\\\\]"

# Prunes local branches deleted from remote.
[group("git")]
prune-dead-branches:
    @echo "{{ GREEN }}>> Removing dead branches...{{ NORMAL }}"
    @git fetch --prune
    @git branch -v | grep "{{ GREP_TARGET }}" | awk '{print $1}' | xargs -I{} git branch -D {}


# Remove all local tags and re-fetch tags from the remote. Tags removed from remote will now be gone.
[group("git")]
prune-tags:
    @echo "{{ GREEN }}>> Cleaning up tags not present on remote...{{ NORMAL }}"
    git tag -l | xargs git tag -d
    git fetch --tags


# Run all git "prune-" commands above
[group("git")]
prune: prune-dead-branches prune-tags


# Diff this project against its latest release
[group("releases")]
@release-diff:
    git fetch --tags --prune
    LATEST_TAG=`gh release list \
        --exclude-drafts \
        --exclude-pre-releases \
        --limit 1 \
        --json tagName \
        --jq ".[0].tagName"` \
    && git log \
        --pretty=format:"* %Cgreen%h%Creset %s" \
        ${LATEST_TAG}..HEAD

alias reldiff := release-diff
