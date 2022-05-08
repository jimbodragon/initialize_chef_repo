#!/bin/bash
if [ "$project_name" == "" ]
then
  export project_name="installation_of_initialize_chef_repo"
fi

function redefine_project_data()
{
  debug_log "Redefine project data: $chef_repo_path | $project_name"
  export git_branch="master"
  export environment="production"
  export git_main_project_name="installation_of_initialize_chef_repo"
  export git_org="installation_of_initialize_chef_repo"
  export git_baseurl='github.com'
  export git_user='git'
  export http_git="https://raw.githubusercontent.com"

  export initialize_git_org="JimboDragonGit"
  export initialize_script_name="initialize_chef_repo"
  export initial_role="$project_name"
  export initial_workstation_cookbook="infra_chef"
  export initial_recipe="ubuntu"
  export additionnal_environments="$additionnal_environments"

  export is_require_git_clone=0

  export jump_in_second=3
  export max_min=5
  export max_hour=0
  export max_day=0
  export initial_current_dir="/root"
  export default_chef_path="/usr/local/chef/repo"
  export install_file_name="install.sh"
}
export -f redefine_project_data
