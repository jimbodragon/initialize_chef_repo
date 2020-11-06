#!/bin/bash

export chef_environment='development'
export chef_run_list='role[zentyal_chef_infra]'
export cookbook_path="$chef_repo_path/cookbooks"
export libraries_path="$chef_repo_path/libraries"
export resources_path="$chef_repo_path/resources"
export data_bag_path="$chef_repo_path/data_bags"
export environment_path="$chef_repo_path/environments"
export role_path="$chef_repo_path/roles"

export checksum_path="$chef_repo_path/checksums"
export file_backup_path="$chef_repo_path/backup"
export file_cache_path="$chef_repo_path/cache"
export log_path="$chef_repo_path/logs"
export berks_vendor="$chef_repo_path/berks_vendor"

export solo_file="$chef_repo_path/solo.rb"
# export chef_run_list='recipe[infraClass::genericinfo]'
