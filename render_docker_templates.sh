#!/usr/bin/env bash
#
# SPDX-License-Identifier: MPL-2.0
#

set -e

cd "$(dirname "$0")"

# Start from an empty output directory so versions removed from releases.yaml are deleted
rm -rf dockerfiles

# Render Dockerfiles
gomplate -V -c .=releases.yaml -f templates/Dockerfile.tpl

# Render compose files
gomplate -V -c .=releases.yaml -f templates/compose.yaml.tpl

# Copy the entrypoint script into each rendered version directory
for dir in dockerfiles/*/; do
  cp -p templates/entrypoint.sh "$dir"
done
