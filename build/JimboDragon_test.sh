#!/bin/bash
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/initialize.sh"
#new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone" "$install_file_name"
source $(new_chef_infra "JimboDragon" "$git_branch" "test" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_path" "$initial_current_dir" "$initial_role" "$initial_workstation_cookbook" "$default_chef_path" "$is_require_git_clone" "$install_file_name")
chef_import_submodule
execute_chef_solo "$project_name"
