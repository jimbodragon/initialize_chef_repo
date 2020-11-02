#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

### Install chef to start chef-solo

os='ubuntu'
os_version='18.04'
chef_version='20.10.168'
download_file='/tmp/chef_workstation_install.deb'

install_git

wget -O $download_file https://packages.chef.io/files/stable/chef-workstation/$chef_version/$os/$os_version/chef-workstation_$chef_version-1_amd64.deb
dpkg -i $download_file

$current_dir/install_chef_infra.sh
