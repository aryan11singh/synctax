#!/bin/sh
# Builds the sandbox images. Run from services/executor.
set -eu
tag="${SANDBOX_IMAGE_TAG:-1}"
for language in python cpp java node analysis; do
  docker build --pull -t "synctax/sandbox-$language:$tag" "images/$language"
done
