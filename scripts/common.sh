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

dockerfile_path=''
dockerfile_from=nantesmetropole/debian:$DIST
dockerfile_packages=''

case $DIST in
    wheezy|jessie|stretch)
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: DIST=$DIST"
        exit 1
        ;;
esac

case $ONBUILD in
    yes)
        onbuild_short="-onbuild"
        ;;
    '')
        onbuild_short=""
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: ONBUILD=$ONBUILD"
        exit 1
        ;;
esac

dockerfile_generate_line() {
        echo "$@" >> "$dockerfile_path"
}

dockerfile_generate() {
    local var
    for var in path from packages; do
        if [ -z "$(eval echo  \$dockerfile_$var)" ]; then
            echo "ERROR: Mandatory variable is not defined: dockerfile_$var" >&2
            exit 1
        fi
    done
    mkdir -p "$(dirname "$dockerfile_path")"
    cat <<EOF > "$dockerfile_path"
FROM $dockerfile_from

EOF
    dockerfile_generate_before_run
    cat <<EOF >> "$dockerfile_path"
RUN \\
EOF
    dockerfile_generate_run_pre
    cat <<EOF >> "$dockerfile_path"
    apt-get update && \\
    apt-get install -y \\
EOF
    for p in $(echo $dockerfile_packages | tr " " "\n" | sort) ; do
        dockerfile_generate_line "        $p \\"
    done
    dockerfile_generate_line "    && rm -rf /var/lib/apt/lists/* && \\"
    dockerfile_generate_run_cont
    if [ -n "$onbuild_short" ]; then
        dockerfile_generate_onbuild
    fi
}

dockerfile_generate_before_run() {
   echo -n
}

dockerfile_generate_run_pre() {
   echo -n
}

dockerfile_generate_run_cont() {
   dockerfile_generate_line "        echo Done"
}

dockerfile_generate_onbuild() {
    echo -n
}
