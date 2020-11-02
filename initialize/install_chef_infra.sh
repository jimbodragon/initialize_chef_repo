#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

chef_path="/var/$(basename $0 | awk -F '.sh' '{print \$1}')"
cookbook_path='$chef_path/cookbooks'
checksum_path='$chef_path/checksums'
data_bag_path='$chef_path/data_bags'
environment_path='$chef_path/environments'
file_backup_path='$chef_path/backup'
file_cache_path='$chef_path/cache'
role_path='$chef_path/roles'

cd $cookbook_path
git_clone_main_project


cat << EOS > solo.rb
checksum_path '$checksum_path'
cookbook_path [
               '$cookbook_path'
              ]
data_bag_path '$data_bag_path'
environment 'production'
environment_path '$environment_path'
file_backup_path '$file_backup_path'
file_cache_path '$file_cache_path'
json_attribs nil
lockfile nil
log_level :info
log_location STDOUT
node_name 'install_chef_infra'
#recipe_url 'http://path/to/remote/cookbook'
rest_timeout 300
role_path '$role_path'
#sandbox_path 'path_to_folder'
solo true
syntax_check_cache_path
umask 0022
verbose_logging nil
EOS

chef-solo -c solo.rb -r 'recipe[infra_chef]'
