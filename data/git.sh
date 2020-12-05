#!/bin/bash

#name (Mandatory) = Name of the repo
#type (Mandatory) = libraries cookbooks resources scripts databag environment roles nodes generators
#git_url (Optional) = Change to this git url
#fork_from_public (Optional) = Use for creating an upstream (check with git remote -v)

export git_repos=(
'name=infraClass type=libraries'
'name=infra_chef type=cookbooks'
'name=virtualbox type=cookbooks'
'name=chef-ingredient type=cookbooks fork_from_public=git@github.com:chef-cookbooks/chef-ingredient.git'
'name=initialize_chef_repo type=scripts'
'name=chef_generator type=generators'
'name=JimboDragon type=scripts fork_from_public=git@github.com:jimbodragon/initialize_chef_repo.git'
)
