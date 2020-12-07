#!/bin/bash

function redefine_general_data()
{
  export git_fork_upstream_name='origin_fork'
  echo "Redefine general data: $chef_repo_path/$project_name"
}
export -f redefine_general_data
