#!/bin/sh
## Copyright 2017 Mathieu Parent <math.parent@gmail.com>
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

set -e

family="$1"

. "$PWD/src/families/$family.sh"

dockerimage_path="$(echo "$dockerfile_path" | sed s@/Dockerfile@.tar.xz@)"

if [ "$dockerimage_path" = "$dockerfile_path" ]; then
  echo "ERROR: Unable to set dockerimage_path from dockerfile_path=$dockerfile_path"
  exit 1
fi
cat "$dockerimage_path" | unxz | docker load
