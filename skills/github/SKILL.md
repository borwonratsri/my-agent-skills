---
name: github
description: Work with GitHub through the official gh CLI — pull requests (view, diff, checks, review, create, merge), issues, GitHub Actions runs and logs, releases, repos, code and issue search, and the raw REST/GraphQL API via gh api. Use when the user shares a github.com URL or an owner/repo reference, asks about a PR, issue, release, or repository on GitHub, references a project or codebase not present in the local workspace, wants CI on GitHub Actions debugged, or wants anything else done on GitHub. Don't use for Piper/Critique CLs, Gerrit, GitLab, or Bitbucket.
---

# GitHub

All GitHub work goes through `gh`, the official GitHub CLI. It handles auth,
pagination, and JSON output, so never scrape github.com HTML.

> **GitHub writes are visible to other people.** Comments, reviews, merges,
> labels, new issues, releases, and workflow runs notify watchers and usually
> cannot be taken back. **Never** run those write commands unless the user asked
> for that specific action, and say what you are about to do before you run it.
> Reading is always fine.

## Setup and Authentication

**1. Check.** Run `auth status` to verify that you are logged in:

-   **On a remote agent** (`command -v agy-plugin-proxy` prints a path, or when
    `<path/to/this/skill>/scripts/gh` is absent because only `SKILL.md` was
    materialized to `~/.gemini/jetski/skills/github/`), this plugin's launcher
    script is already on `PATH` at `/opt/antigravity/bin/gh` (symlinked to
    `/opt/antigravity/plugins/github/skills/github/scripts/gh`). Run `gh`
    directly:

    ```bash
    gh auth status
    ```

    Never download or install a separate `gh` binary (for example into `/tmp`),
    as a raw `gh` binary skips the launcher that exports `GH_TOKEN` and
    configures `git`.

-   **On desktop,** run `<path/to/this/skill>/scripts/gh` (or `gh.cmd` on
    Windows), which installs `gh` on first use if needed and uses the connected
    account:

    ```bash
    <path/to/this/skill>/scripts/gh auth status
    ```

    ```powershell
    # Windows (PowerShell)
    & "<path\to\this\skill>\scripts\gh.cmd" auth status
    ```

    Invoke `gh` through `<path/to/this/skill>/scripts/gh ...` (or `gh.cmd` on
    Windows) so a bare system `gh` does not skip the connected account. The
    examples below write `gh` for brevity.

**2. If you are not logged in,** ask the user to sign in to **GitHub** in
Antigravity (Customizations → GitHub → Accounts), then confirm with
`auth status`. Don't run `gh auth login`.

-   If it worked earlier and now fails with `HTTP 401` or says GitHub needs
    sign-in, ask the user to sign in again the same way, and pass along any
    sign-in link the error includes.
-   Never ask the user to paste a token into the chat, and never print, echo, or
    log `GH_TOKEN` or the output of `gh auth token`.
-   `gh` refuses every command, including public reads, until it has a
    credential. Don't work around it by scraping github.com.

**3. Git over HTTPS (clone, push).** Before cloning, check whether the repo is
already checked out in the workspace (remote agents often start with it
pre-cloned); if so, work in that checkout.

-   **On a remote agent** (`command -v agy-plugin-proxy` prints a path), each
    run of this script configures git: it points git's GitHub credential helper
    at this script and, if unset, sets `user.name` and `user.email` from the
    connected account. If git fails, run `auth status` through it again. Don't
    run `gh auth setup-git` there: it points git at a `gh` without the connected
    account's token. The remote credential can list the repositories covered by
    the user's **Antigravity for GitHub** app installation (including private
    ones) with `gh repo list` and read or clone public repositories, but it is
    scoped so you can only read, clone, or edit **private** repositories that
    are attached to the project (`<project_resources>`). If a repository the
    user mentions is missing from `gh repo list` or the project repository
    picker (or returns `HTTP 404`), ask the user to grant the **Antigravity for
    GitHub** app access to it at
    `https://github.com/apps/antigravity-for-github/installations/new` and then
    add it to the project (or create a project and add it if not in a project).
    To contribute to a public repository on a remote agent, call the
    `fork_github_repository` tool (not `gh repo fork`) to fork it on the user's
    behalf and attach the fork to the project's resources. To create a new
    repository on a remote agent, call the `create_github_repository` tool (not
    `gh repo create`) so the new repository is created on the user's behalf and
    attached to the project's resources. To remove an old fork or repository
    from the project's resources (for example, after a pull request from a fork
    has been merged), call the `detach_github_repository` tool. All three tools
    require the conversation to be in a project; if not in a project, ask the
    user to create one first.
-   **Otherwise,** for now, signing in to GitHub in Antigravity covers `gh`
    commands but not `git` clone, fetch, or push. Run plain `git` outside the
    command sandbox, so git uses the user's own credentials. Don't use
    `gh repo clone`, `gh pr checkout`, or `gh auth setup-git`: they send git
    through the signed-in account, and the failed request signs it out. If git
    asks for credentials, ask the user to set up git access to GitHub. If
    `git commit` asks who you are, ask the user which name and email to use and
    set them with `git config --global`.

## Contributing a change

Inside a checkout:

```bash
git checkout -b my-branch
git commit -am "..."
git push -u origin my-branch
gh pr create --base main --head my-branch --title "..." --body "..."
```

Push to a feature branch and open a pull request; don't push to `main` or
`master` unless the user asks. A sandbox may block such pushes (`HTTP 403`)
unless the user has enabled the **Turbo** permission preset or granted
`git.update` on `main`. On a remote agent (where the checkout lives inside an
ephemeral VM), when the user asks to fix a bug or implement a change, once the
diff is complete and verified, either open the PR directly (if the prompt is an
end-to-end task) or proactively ask if they'd like you to push the branch and
open a PR as the completion step.

If you lack push access to the repo, on a remote agent call the
`fork_github_repository` tool to fork it on the user's behalf and attach the
fork to the project's resources, then add the fork as a git remote and push to
it (and once the pull request is merged, you can call `detach_github_repository`
if the user wants to remove the fork from the project's resources); otherwise
run `gh repo fork --remote` first and push to the fork.

For a small edit to a single file, you can skip git entirely and use the
Contents API (the file `sha` is required when updating an existing file):

```bash
BASE_SHA=$(gh api repos/o/r/git/ref/heads/main --jq .object.sha)
gh api -X POST repos/o/r/git/refs -f ref=refs/heads/my-branch -f sha="$BASE_SHA"
FILE_SHA=$(gh api "repos/o/r/contents/path/to/file?ref=my-branch" --jq .sha)
gh api -X PUT repos/o/r/contents/path/to/file -f branch=my-branch \
  -f message="..." -f sha="$FILE_SHA" -f content="$(base64 -w0 < new_file)"
gh pr create -R o/r --base main --head my-branch --title "..." --body "..."
```

## Conventions

-   **Name the repo explicitly** with `-R owner/repo` unless you are inside a
    checkout of it. Most commands also take a full URL instead of a number: `gh
    pr view https://github.com/o/r/pull/123`.
-   **Use structured output:** `--json field1,field2 --jq '<expr>'`. Running a
    command with `--json` and no fields lists the available fields.
-   **Pass `--limit N`** on list commands, and supply every flag a write command
    needs (`--title`, `--body`, ...). The launcher disables prompts and the
    pager, so a missing flag fails instead of hanging. Never use `--web`.
-   **Keep output small.** Diffs and logs can be huge: list files first
    (`--name-only`), use `--log-failed`, and bound output with `head`/`tail`.
-   After a write, report the resulting URL back to the user.

## Pull requests

```bash
gh pr list -R o/r --state open --limit 20 \
  --json number,title,author,isDraft,reviewDecision,updatedAt
gh pr list -R o/r --search "review-requested:@me" --json number,title,url
gh pr view 123 -R o/r --json title,body,author,state,baseRefName,headRefName,files,reviews,comments,statusCheckRollup
gh pr diff 123 -R o/r --name-only        # file list first
gh pr diff 123 -R o/r | head -500        # then the patch, bounded
gh pr checks 123 -R o/r                  # CI status per check
```

Line-level review comments are only available through the API:

```bash
gh api repos/o/r/pulls/123/comments --paginate \
  --jq '.[] | {path, line, user: .user.login, body}'
```

Creating a PR (see *Contributing a change* above) and other PR writes (comment,
review, merge, edit, and close only when asked):

```bash
gh pr create -R o/r --base main --head my-branch --title "..." --body "..." [--draft] [--reviewer u1,u2]
gh pr comment 123 -R o/r --body "..."
gh pr review 123 -R o/r --approve | --request-changes --body "..." | --comment --body "..."
gh pr merge 123 -R o/r --squash|--merge|--rebase [--delete-branch] [--auto]
gh pr edit 123 -R o/r --add-label bug --add-reviewer u1
gh pr close 123 -R o/r    # also: reopen, ready
gh pr checkout 123        # local branch from a PR (remote agents; see Setup step 3)
```

## Issues

```bash
gh issue list -R o/r --state open --label bug --limit 30 --json number,title,labels,assignees,updatedAt
gh issue view 42 -R o/r --json title,body,state,author,labels,comments
```

Writes (only when asked):

```bash
gh issue create -R o/r --title "..." --body "..." [--label x] [--assignee @me]
gh issue comment 42 -R o/r --body "..."
gh issue edit 42 -R o/r --add-label triage
gh issue close 42 -R o/r [--reason "not planned"]
```

## GitHub Actions

To debug a failing PR: `gh pr checks` → find the failing run ID (from the check
link, or `gh run list --branch <headRefName>`) → read only the failed steps.

```bash
gh run list -R o/r --limit 10 --json databaseId,workflowName,headBranch,status,conclusion,event,createdAt
gh run list -R o/r --branch my-branch --workflow ci.yml
gh run view <run-id> -R o/r --json jobs --jq '.jobs[] | {databaseId, name, conclusion}'
gh run view <run-id> -R o/r --log-failed | tail -200
gh run view <run-id> -R o/r --job <job-id> --log | tail -300
gh workflow list -R o/r
```

Writes (only when asked): `gh run rerun <run-id> -R o/r [--failed]`, `gh run
cancel <run-id> -R o/r`, `gh workflow run ci.yml -R o/r --ref main [-f
key=val]`. `gh run watch` blocks until the run finishes; run it in the
background.

## Repositories and releases

```bash
gh repo view o/r --json name,description,defaultBranchRef,stargazerCount,licenseInfo,pushedAt
gh repo list <owner> --limit 50 --json name,description,isPrivate
gh repo clone o/r [dir] -- --depth=1    # remote agents; see Setup step 3
gh release list -R o/r --limit 10
gh release view v1.2.3 -R o/r --json tagName,name,body,assets
gh release download v1.2.3 -R o/r --pattern '*.tar.gz' --dir /tmp/dl
```

On a remote agent, `gh repo list` only returns repositories covered by the
user's **Antigravity for GitHub** app installation; if a project or repository
the user refers to is not in the workspace or in `gh repo list`, let them know
it may be a repository they haven't granted the **Antigravity for GitHub** app
access to at `https://github.com/apps/antigravity-for-github/installations/new`
and ask them to grant access there and add it to the project.

Read one file without cloning:

```bash
gh api "repos/o/r/contents/path/to/file?ref=main" --jq .content | base64 -d
```

Writes (only when asked): `gh release create`, `gh repo create` (or the
`create_github_repository` tool on a remote agent), `gh repo fork` (or the
`fork_github_repository` tool on a remote agent), `detach_github_repository` (on
a remote agent, to remove a repository or fork from the project's resources),
`gh gist create`.

## Search

```bash
gh search repos "topic:cli language:go" --sort stars --limit 10 --json fullName,description,stargazersCount
gh search issues "memory leak" --repo o/r --state open --json number,title,url
gh search prs --author @me --state open --json repository,number,title,url
gh search code "func NewClient" --repo o/r --json path,url    # needs auth
```

## Raw API

Use `gh api` for anything without a dedicated command. `-f` sends strings, `-F`
sends typed values (numbers, booleans, `@file`). Any method other than GET is a
write.

```bash
gh api repos/o/r/issues --paginate --jq '.[].title'
gh api graphql -F owner=o -F name=r -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      pullRequests(states: OPEN, first: 10) { nodes { number title } }
    }
  }'
gh api rate_limit --jq .resources.core
```

## Troubleshooting

*   `HTTP 401`, or "not logged in": See Setup step 2.
*   `HTTP 404` on a repo you expect to exist (or a repo the user mentions that
    is missing from `gh repo list`): It is private and the credential lacks
    access. On a remote agent, the credential only has metadata and access for
    repositories covered by the user's **Antigravity for GitHub** app
    installation, and can only read, clone, or edit private repositories that
    are attached to the project (`<project_resources>`): ask the user to make
    sure the **Antigravity for GitHub** app
    (`https://github.com/apps/antigravity-for-github/installations/new`) has
    access to the repository on GitHub and to add the repository to the project
    (or create a project and add it if not in a project). Otherwise, ask the
    user to check the repo name and their access.
*   `HTTP 403` with a rate-limit message: Check `gh api rate_limit`; wait, or
    log in (Setup step 2).
*   `HTTP 403` ("not allowed by policy") when pushing to `main` or `master` or
    accessing another repo: Push to a feature branch and open a PR with
    `gh pr create`, or ask the user to attach the repository to the project (or
    create a project and attach it if not in a project) / grant `git.update` on
    `main`.
*   `HTTP 403` ("Resource not accessible by integration", or "Permission to
    owner/repo.git denied") on a remote agent: To contribute to a public
    repository you lack push access to, call `fork_github_repository` to fork it
    on the user's behalf and attach the fork to the project's resources; to
    create a new repository, call `create_github_repository`. If `owner/repo` is
    an existing repository that is not attached to the project, ask the user to
    add it to the project (if in a project) or create a project and add it (if
    not in a project). Otherwise, ask the user to install or configure the
    **Antigravity for GitHub** app
    (`https://github.com/apps/antigravity-for-github/installations/new`) on the
    account that owns `owner/repo` with access to that repository.
*   `HTTP 403` mentioning "OAuth App access restrictions" or SAML: The
    organization hasn't approved Antigravity. Ask the user to request access, or
    authorize single sign-on, for that organization at
    `https://github.com/settings/connections/applications/Ov23liFbuFlLyZd0AkZf`,
    or to ask an organization owner to approve it.
*   `git push` fails with "could not read Username for 'https://github.com'", or
    `git commit` fails with "Please tell me who you are": See Setup step 3.
*   "none of the git remotes ... point to a known GitHub host": Pass `-R
    owner/repo`.
*   A write command fails asking for input: Supply the missing flag (`--title`,
    `--body`, `--base`, ...).
*   GitHub Enterprise host: Pass `--hostname` or set `GH_HOST`; the user must
    authenticate to that host.
