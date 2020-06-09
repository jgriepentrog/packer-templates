#!/bin/bash
# Assumes we're running on the image already

set -o pipefail

personal-boxes/ubuntu-budgie-dev/build.sh
personal-boxes/ubuntu-budgie-dev/phys.sh
personal-boxes/ubuntu-budgie-dev/config.sh
