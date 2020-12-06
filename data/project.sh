#!/bin/bash
if [ "$project_name" == "" ]
then
  export project_name="installation_of_initialize_chef_repo"
fi

function redefine_project_data()
{
  export git_branch="master"
  export environment="production"
  export git_main_project_name='jimbodragon_chef_repo'
  export git_org='jimbodragon'
  export git_baseurl='github.com'
  export git_user='git'
  export http_git="https://raw.githubusercontent.com"

  export initialize_script_name="initialize_chef_repo"
  export initial_role="zentyal_chef_infra"
  export initial_workstation_cookbook="chef_workstation_initialize"

  export is_require_git_clone=0

  export jump_in_second=3
  export max_min=3
  export max_hour=0
  export initial_current_dir="$(pwd)"
  export default_chef_path="/usr/local/chef/repo"
  export install_file_name="install.sh"
}
export -f redefine_project_data
