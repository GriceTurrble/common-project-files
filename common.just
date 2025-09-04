# Common Just recipes used across my projects.
# Usage: see https://github.com/griceturrble/common-project-files
# Just docs: https://just.systems/man/en/


# Setup all common tooling
[group("commons")]
bootstrap-commons:
    just bootstrap-precommit


# Run pre-commit install. Useful as a mixin for other recipes.
[group("commons")]
bootstrap-precommit:
    pre-commit install


# Run pre-commit 'hook' against all files (default all hooks)
[group("commons")]
lint hook="":
    pre-commit run {{ hook }} --all-files


# The result should be `\\[ \\]`, but we need to escape those slashes again here to make it work:
GREP_TARGET := "\\\\[gone\\\\]"

# Prunes local branches deleted from remote.
[group("commons")]
prune-dead-branches:
    @echo "{{ GREEN }}>> Removing dead branches...{{ NORMAL }}"
    @git fetch --prune
    @git branch -v | grep "{{ GREP_TARGET }}" | awk '{print $1}' | xargs -I{} git branch -D {}


# Remove all local tags and re-fetch tags from the remote. Tags removed from remote will now be gone.
[group("commons")]
prune-tags:
    @echo "{{ GREEN }}>> Cleaning up tags not present on remote...{{ NORMAL }}"
    git tag -l | xargs git tag -d
    git fetch --tags


# Run all git "prune-" commands above
[group("commons")]
prune: prune-dead-branches prune-tags


# Diff this project against its latest release
[group("commons")]
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

# Show list of current issues in this repo
[group("commons")]
issues:
    GH_PAGER= gh issue list


# Show list of current issues in this repo
[group("commons")]
project-issues:
    gh project item-list 2 --owner "@me"


# Show list of current issues in this repo
[group("commons")]
project:
    gh project view 2 --owner "@me" --web

GH_SECRETS_FILE := "~/.gh_common_secrets"

# Update common secrets. Depends on a local file, ~/.gh_common_secrets
[group("commons")]
update-common-secrets:
    gh secret set -f {{GH_SECRETS_FILE}}
