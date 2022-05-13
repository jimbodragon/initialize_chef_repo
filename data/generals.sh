#!/bin/bash

function redefine_general_data()
{
  export git_fork_upstream_name='origin_fork'
  export initialize_chef_repo_lockfile="$initialize_install_dir/$project_name.lock"
  debug_log "Redefine general data: $chef_repo_path | $project_name"
}
export -f redefine_general_data
