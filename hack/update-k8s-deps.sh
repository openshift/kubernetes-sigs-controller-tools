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

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new-version>" >&2
  exit 1
fi

new_version="$1"

cd "$(dirname "$0")/.."

find . -name go.mod -print0 | while IFS= read -r -d '' gomod; do
  dir="$(dirname "$gomod")"
  # Extract k8s.io/* deps with a real version
  deps=$(grep -E '(^\s+|^require\s+)k8s\.io/\S+\s+v0\.[1-9]' "$gomod" | grep -oE 'k8s\.io/\S+' || true)
  if [[ -z "$deps" ]]; then
    continue
  fi
  echo "Updating deps in ${dir}/go.mod"
  for dep in $deps; do
    echo "  ${dep}@${new_version}"
    (cd "$dir" && go get "${dep}@${new_version}" && go mod tidy)
  done
  (cd "$dir" && go mod tidy)
done
