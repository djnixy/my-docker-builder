#!/bin/bash
set -e

# Optional: remove the runner if it was previously registered (useful for clean startup)
if [ -d "./_work" ]; then
  ./config.sh remove --unattended --token "$RUNNER_TOKEN" || true
fi

# Configure the runner
./config.sh \
  --unattended \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$(hostname)" \
  --labels "$RUNNER_LABELS" \
  --work "_work"

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token "$RUNNER_TOKEN"
}
trap cleanup EXIT

# Start the runner
./run.sh
