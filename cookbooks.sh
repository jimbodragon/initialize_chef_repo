#!/bin/bash

cookbooks=(
'name=infraClass type=libraries'
'name=infra_chef type=cookbooks'
'name=virtualbox-install type=cookbooks'
'name=chef-ingredient type=cookbooks fork_from_public=git@github.com:chef-cookbooks/chef-ingredient.git'
)
