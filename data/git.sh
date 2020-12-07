#!/bin/bash

#name (Mandatory) = Name of the repo
#type (Mandatory) = libraries cookbooks resources scripts databag environment roles nodes generators
#git_url (Optional) = Change to this git url
#fork_from_public (Optional) = Use for creating an upstream (check with git remote -v)


function redefine_git_data()
{
  export git_repos=(
  "name=infraClass type=libraries git_url=git@github.com:jimbodragon/infraClass.git"
  "name=infra_chef type=cookbooks git_url=git@github.com:jimbodragon/infra_chef.git"
  "name=virtualbox type=cookbooks git_url=git@github.com:jimbodragon/virtualbox.git"
  "name=chef-ingredient type=cookbooks git_url=git@github.com:chef-cookbooks/chef-ingredient.git"
  "name=initialize_chef_repo type=scripts git_url=git@github.com:jimbodragon/initialize_chef_repo.git"
  "name=chef_workstation_initialize type=cookbooks git_url=git@github.com:jimbodragon/chef_workstation_initialize.git"
  )
  log "Redefine git data: $chef_repo_path | $project_name"
}
export -f redefine_git_data
