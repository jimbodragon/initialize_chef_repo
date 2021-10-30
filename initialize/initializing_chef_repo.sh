#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$current_dir/source_project.sh"

git_clone_main_project
cd ..
chef_generate repo -r $git_main_project_name
cd $git_main_project_name

create_directory scripts
create_directory libraries
create_directory resources

sed -i 's|# !cookbooks/chef_workstation|# !cookbooks/chef_workstation

cookbooks/example
data_bags/example
environments/example
roles/example
libraries/example
resources/example
roles/example
cookbooks/README.md
data_bags/README.md
environments/README.md
roles/README.md
environments/example.json
roles/example.json
checksums
backup
cache
logs|g' .gitignore

git add *
git commit -m 'Initializing repo'

$current_dir/git_clone_project.sh
cd $chef_repo
commit_and_push "Adding submodules"
