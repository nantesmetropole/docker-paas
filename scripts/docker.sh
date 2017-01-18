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

. "$PWD/scripts/common.sh"

docker_short=latest

dockerfile_path=docker/$docker_short/Dockerfile
docker_tag=nantesmetropole/docker:$docker_short

dockerfile_generate_before_run() {
    cp -a templates/docker/etc "$(dirname "$dockerfile_path")/"
    cat <<EOF >> "$dockerfile_path"
COPY etc/ /etc/

EOF
}

dockerfile_generate_run_pre() {
    cat <<EOF >> "$dockerfile_path"
    apt-get update && \\
    apt-get install -y \\
        apt-transport-https \\
        ca-certificates && \\
    echo "deb https://apt.dockerproject.org/repo debian-$DIST main" > /etc/apt/sources.list.d/docker.list && \\
EOF
}

dockerfile_packages="$dockerfile_packages docker-engine"
