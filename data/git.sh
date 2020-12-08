#!/bin/bash

#name (Mandatory) = Name of the repo
#type (Mandatory) = libraries cookbooks resources scripts databag environment roles nodes generators
#git_url (Optional) = Change to this git url
#fork_from_public (Optional) = Use for creating an upstream (check with git remote -v)


function redefine_git_data()
{
  # export git_repos=(
  # "name=infraClass type=libraries fork_from_public==git@github.com:jimbodragon/infraClass.git git_url=git@github.com:jimbodragon/infraClass.git"
  # "name=infra_chef type=cookbooks fork_from_public==git@github.com:jimbodragon/infra_chef.git git_url=git@github.com:jimbodragon/infra_chef.git"
  # "name=virtualbox type=cookbooks fork_from_public==git@github.com:jimbodragon/virtualbox.git git_url=git@github.com:jimbodragon/virtualbox.git"
  # "name=chef-ingredient type=cookbooks fork_from_public==git@github.com:jimbodragon/chef-ingredient.git git_url=git@github.com:chef-cookbooks/chef-ingredient.git"
  # "name=initialize_chef_repo type=scripts fork_from_public==git@github.com:jimbodragon/initialize_chef_repo.git git_url=git@github.com:jimbodragon/initialize_chef_repo.git"
  # "name=chef_workstation_initialize type=cookbooks fork_from_public==git@github.com:jimbodragon/chef_workstation_initialize.git git_url=git@github.com:jimbodragon/chef_workstation_initialize.git"
  # )
  export git_repos=()
  debug_log "Redefine git data: $chef_repo_path | $project_name"
}
export -f redefine_git_data
