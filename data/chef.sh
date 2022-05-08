#!/bin/bash

function redefine_chef_data()
{
  export chef_repo_path="$(dirname $(dirname $initialize_install_dir))"
  debug_log "initialize_install_dir (1)= $initialize_install_dir"
  export chef_path="$(dirname "$chef_repo_path")"
  debug_log "Redefine Chef data: $chef_repo_path | $project_name"

  export chef_environment="$environment"
  export chef_run_list="role[$initial_role]"
  export cookbook_path="$chef_repo_path/cookbooks"
  export libraries_path="$chef_repo_path/libraries"
  export resources_path="$chef_repo_path/resources"
  export data_bags_path="$chef_repo_path/data_bags"
  export environment_path="$chef_repo_path/environments"
  export role_path="$chef_repo_path/roles"
  export scripts_dir="$chef_repo_path/scripts"
  export nodes_dir="$chef_repo_path/nodes"
  export policy_group_dir="$chef_repo_path/policy_group"
  export policy_dir="$chef_repo_path/policies"
  export scripts_dir="$chef_repo_path/scripts"

  export checksum_path="$chef_repo_path/checksums"
  export file_backup_path="$chef_repo_path/backup"
  export file_cache_path="$chef_repo_path/cache"
  export download_path="$chef_repo_path/download"
  export log_path="$chef_repo_path/logs"
  export berks_vendor="$chef_repo_path/berks_vendor"

  export solo_file="$chef_repo_path/solo.rb"
  # export chef_run_list='recipe[infraClass::genericinfo]'
}
export -f redefine_chef_data
