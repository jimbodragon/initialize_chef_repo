current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$current_dir/source_project.sh"

git_clone_main_project
#new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_path" "$initial_role" "$initial_workstation_cookbook" "$default_chef_path" "$is_require_git_clone" "$install_file_name"
log "source $(new_chef_infra $project_name "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_path" "$initial_role" "$initial_workstation_cookbook" "$default_chef_path" "$is_require_git_clone" "$install_file_name")"

chef_import_submodule

git add *
git commit -m 'Initializing repo'

cd $chef_repo
commit_and_push "Adding submodules"
