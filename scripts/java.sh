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

case $JAVA_VERSION in
    6)
        java_dists="wheezy"
        ;;
    7)
        java_dists="jessie wheezy"
        ;;
    8)
        java_dists="stretch"
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: JAVA_VERSION=$JAVA_VERSION"
        exit 1
        ;;
esac
dockerfile_packages="$dockerfile_packages openjdk-$JAVA_VERSION-jre-headless"
java_short="jdk$JAVA_VERSION"
