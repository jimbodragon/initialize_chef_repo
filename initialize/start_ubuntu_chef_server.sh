#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $current_dir/../functions/initialize.sh

### Install chef to start chef-solo

os='ubuntu'
os_version='18.04'
chef_workstation_version='20.10.168'
chef_client_version='16.6.14'
chef_version=$chef_client_version
download_file='/tmp/chef_install.deb'

install_git

# Chef workstation
wget -O $download_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb
dpkg -i $download_file

$initialize_dir/install_chef_infra.sh
