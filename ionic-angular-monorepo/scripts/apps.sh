#!/bin/sh
# Runs one deterministic step on every standalone Ionic app of the monorepo.
# An app is a top-level directory containing ionic.config.json and package.json.
# Usage (from the repository root): sh .aep/recipe/scripts/apps.sh install|build|lint|test
set -u
step="${1:?usage: apps.sh install|build|lint|test}"
case "$step" in
  install|build|lint|test) ;;
  *) echo "apps.sh: unknown step '$step'" >&2; exit 2 ;;
esac

status=0
apps=0
for dir in */; do
  dir="${dir%/}"
  [ -f "$dir/ionic.config.json" ] && [ -f "$dir/package.json" ] || continue
  apps=$((apps + 1))

  # Dependencies are installed only when missing or older than the lockfile.
  if [ ! -f "$dir/node_modules/.package-lock.json" ] || [ "$dir/package-lock.json" -nt "$dir/node_modules/.package-lock.json" ]; then
    echo "== $dir: npm ci"
    if ! (cd "$dir" && npm ci --no-audit --no-fund); then
      status=1
      continue
    fi
  fi

  # The app's own npm scripts are not used: some of them stamp tracked files.
  case "$step" in
    install) ;;
    build) echo "== $dir: ng build"; (cd "$dir" && npx --no-install ng build) || status=1 ;;
    lint) echo "== $dir: ng lint"; (cd "$dir" && npx --no-install ng lint) || status=1 ;;
    test)
      # An app without unit tests has nothing to run; e2e suites are not unit tests.
      if [ -z "$(find "$dir/src" -name '*.spec.ts' -print -quit 2>/dev/null)" ]; then
        echo "== $dir: no unit tests (src/**/*.spec.ts), skipped"
      else
        echo "== $dir: ng test"; (cd "$dir" && npx --no-install ng test --watch=false) || status=1
      fi
      ;;
  esac
done

echo "== $step: $apps app(s), exit $status"
exit "$status"
