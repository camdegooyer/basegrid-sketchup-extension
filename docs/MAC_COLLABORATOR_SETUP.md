# HQ BuildGrid — Mac setup

You have been invited to collaborate on the HQ BuildGrid repository with write access.

- Repository: https://github.com/camdegooyer/HQ-BuildGrid
- Pending invitations: https://github.com/settings/repositories
- GitHub CLI: https://cli.github.com/
- GitHub CLI quickstart: https://docs.github.com/en/github-cli/github-cli/quickstart

## 1. Accept the invitation

Sign in to GitHub as **DPerrem**, open the pending invitations link above, and accept the invitation to **camdegooyer/HQ-BuildGrid**.

## 2. Open Terminal on the Mac

Open **Applications → Utilities → Terminal**.

Check that Git is available:

```sh
git --version
```

If macOS offers to install the Command Line Developer Tools, accept the installation and run the command again afterward.

## 3. Install and sign in to GitHub CLI

If Homebrew is already installed:

```sh
brew install gh
```

Otherwise, use the installer instructions at https://cli.github.com/.

Then authenticate:

```sh
gh auth login
```

Choose:

1. **GitHub.com**
2. **HTTPS**
3. **Login with a web browser**
4. Allow GitHub CLI to authenticate Git when prompted

## 4. Create a development folder and clone the repository

```sh
mkdir -p ~/Developer
cd ~/Developer
gh repo clone camdegooyer/HQ-BuildGrid
cd HQ-BuildGrid
git status
open .
```

The repository will be located at:

```text
~/Developer/HQ-BuildGrid
```

To return to it later:

```sh
cd ~/Developer/HQ-BuildGrid
```

You can also open Terminal at an existing Finder folder using **right-click → Services → New Terminal at Folder**.

## 5. Read the project instructions

Before changing anything, read:

- `AGENTS.md`
- `docs/DECISIONS.md`
- `README.md`

This is a fresh-start project. Make one small, complete change at a time and do not import earlier SketchOB or BuildGrid code unless Cam explicitly approves it.

## 6. Start a change safely

Update the local copy and create a branch:

```sh
git switch main
git pull --ff-only
git switch -c dperrem/short-description
```

Replace `short-description` with a brief name for the task.

After making and testing the change:

```sh
git status
git add path/to/changed-file
git commit -m "Describe the completed change"
git push -u origin HEAD
```

GitHub will print a link for opening a pull request. Open that link and request review before merging.

## Getting help

If a command fails, copy the command and its complete Terminal output when asking for help. Do not share passwords, access tokens, private keys, or the contents of credential files.

