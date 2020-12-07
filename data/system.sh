#!/bin/bash

function redefine_system_data()
{
  echo "Redefine system data: $chef_repo_path | $project_name"
  export os='ubuntu'
  export os_version='18.04'
  export chef_workstation_version='20.10.168'
  export chef_client_version='16.6.14'
  export chef_version=$chef_client_version
  export downloaded_chef_file='/tmp/chef_install.deb'
}
export -f redefine_system_data
