#!/usr/bin/env bash
set -euo pipefail

SCAFFOLD_REPO="git@github.com:0xemc/agentic-project-template.git"
TEMPLATE_URL="https://raw.githubusercontent.com/0xemc/templates/main/feature-based-development.md"

usage() {
  cat <<EOF
Usage: $(basename "$0") <repo-url|new> <project-name>

  repo-url      Git URL of the project to wire into main/
  new           Initialise a fresh empty repo in main/
  project-name  Container directory name (created in current directory)

Examples:
  $(basename "$0") git@github.com:you/my-app.git my-app
  $(basename "$0") new my-new-app
EOF
  exit 1
}

[[ $# -lt 2 ]] && usage

REPO_ARG="$1"
PROJECT_NAME="$2"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"

[[ -e "$PROJECT_DIR" ]] && { echo "error: $PROJECT_DIR already exists" >&2; exit 1; }

# Clone scaffold and strip git history
echo "→ cloning scaffold"
git clone --depth 1 "$SCAFFOLD_REPO" "$PROJECT_DIR"
rm -rf "$PROJECT_DIR/.git"

# Fetch architecture template
echo "→ fetching feature-based-development.md"
curl -fsSL "$TEMPLATE_URL" -o "$PROJECT_DIR/templates/feature-based-development.md"
rm -f "$PROJECT_DIR/templates/.gitkeep"

# Inject project name
sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$PROJECT_DIR/CLAUDE.md"

# Wire the actual project into main/
if [[ "$REPO_ARG" == "new" ]]; then
  echo "→ initialising new repo in main/"
  git init "$PROJECT_DIR/main"
  git -C "$PROJECT_DIR/main" commit --allow-empty -m "chore: initial commit"
else
  echo "→ cloning $REPO_ARG into main/"
  git clone "$REPO_ARG" "$PROJECT_DIR/main"
fi

echo ""
echo "✓ $PROJECT_DIR"
echo "  main/      → ${REPO_ARG/new/local repo}"
echo "  worktrees/ → agent creates feature branches here"
