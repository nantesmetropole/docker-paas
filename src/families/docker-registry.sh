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

. "$PWD/src/families/common.sh"

docker_short=latest

dockerfile_path=docker-registry/$docker_short/Dockerfile
docker_tag=nantesmetropole/docker-registry:$docker_short

dockerfile_packages="$dockerfile_packages docker-registry"

dockerfile_generate_run_cont() {
    cat <<EOF >> "$dockerfile_path"
        echo Done

USER docker-registry

EXPOSE 5000

VOLUME ["/var/lib/docker-registry"]

ENTRYPOINT ["/usr/bin/docker-registry"]

CMD ["serve", "/etc/docker/registry/config.yml"]
EOF
}
