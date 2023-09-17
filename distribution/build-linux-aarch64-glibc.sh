#!/usr/bin/env bash
set -ex                                                   # Be verbose and exit immediately on error instead of trying to continue

buildTag="elm-linux-aarch64-glibc"

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$scriptDir/.."                                        # Move into the project root

                                                          # Build in Docker
docker build --platform linux/arm64 \
  -t $buildTag \
  -f distribution/docker/aarch64-glibc.dockerfile .

mkdir -p distribution/dist                                # Ensure the dist directory is present


bin=distribution/dist/$buildTag                           # Copy built binary to dist
docker run --rm --entrypoint cat $buildTag /elm/elm > $bin
chmod a+x $bin
