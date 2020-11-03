#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $current_dir/../functions/generals.sh

chef_path="/var/$(basename "${BASH_SOURCE[0]}" | awk -F '.sh' '{print $1}')"
chef_repo_path="$chef_path/$git_main_project_name"
cookbook_path="$chef_repo_path/cookbooks"
libraries_path="$chef_repo_path/libraries"
resources_path="$chef_repo_path/resources"
data_bag_path="$chef_repo_path/data_bags"
environment_path="$chef_repo_path/environments"
role_path="$chef_repo_path/roles"

checksum_path="$chef_repo_path/checksums"
file_backup_path="$chef_repo_path/backup"
file_cache_path="$chef_repo_path/cache"
log_path="$chef_repo_path/logs"
berks_vendor="$chef_repo_path/berks_vendor"

solo_file="$chef_repo_path/solo.rb"

mkdir $chef_path
cd $chef_path
git_clone_main_project
source $current_dir/../functions/generals.sh
mkdir $cookbook_path
mkdir $libraries_path
mkdir $resources_path
mkdir $data_bag_path
mkdir $environment_path
mkdir $role_path
mkdir $checksum_path
mkdir $file_backup_path
mkdir $file_cache_path
mkdir $log_path
mkdir $berks_vendor

cat << EOS > $solo_file
checksum_path '$checksum_path'
cookbook_path [
               '$cookbook_path',
               '$libraries_path',
               '$resources_path',
               '$berks_vendor'
              ]
data_bag_path '$data_bag_path'
environment '$chef_environment'
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

for cookbook in $(ls $cookbook_path)
do
  cd $cookbook_path/$cookbook
  berks vendor $berks_vendor
done

for library in $(ls $cookbook_path)
do
  cd $libraries_path/$library
  berks vendor $berks_vendor
done

for resource in $(ls $resources_path)
do
  cd $resources_path/$resource
  berks vendor $berks_vendor
done

chef-solo --chef-license 'accept' --config $solo_file --override-runlist $chef_run_list --log_level info --logfile $log_path/chef_solo.log --lockfile $chef_repo_path/chef-solo.lock
