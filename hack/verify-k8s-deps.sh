#!/usr/bin/env bash
# Copyright The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

cd "$(dirname "$0")/.."

# Find the version of the first versioned k8s.io/* dep in the top-level go.mod
version=$(grep -E '^\s+k8s\.io/\S+\s+v0\.[1-9]' go.mod | head -1 | awk '{print $2}')
if [[ -z "$version" ]]; then
  echo "No versioned k8s.io/* dependency found in go.mod" >&2
  exit 1
fi

echo "Detected k8s.io dep version: ${version}"
hack/update-k8s-deps.sh "$version"

if ! git diff --quiet; then
  echo "ERROR: git diff is not clean after running update-k8s-deps.sh" >&2
  git diff
  exit 1
fi
