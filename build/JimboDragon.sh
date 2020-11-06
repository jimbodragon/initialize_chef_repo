#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/initialize.sh

. $initialize_dir/start_ubuntu_chef_server.sh
