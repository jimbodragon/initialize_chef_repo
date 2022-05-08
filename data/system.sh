#!/bin/bash

function redefine_system_data()
{
  debug_log "Redefine system data: $chef_repo_path | $project_name"
  export os="$(lsb_release -id | grep -i distributor | cut -d ':' -f 2 | tr -d '[:blank:]')"
  export os_version="$(lsb_release -r | cut -d ':' -f 2 | tr -d '[:blank:]')"
  export chef_workstation_version="$(chef -v | grep Workstation | cut -d ':' -f 2 | tr -d '[:blank:]')"
  export chef_client_version="$(chef -v | grep Workstation | cut -d ':' -f 2 | tr -d '[:blank:]')"
  export chef_version="$chef_client_version"
  export downloaded_chef_file="$download_path/chef_install.deb"
}
export -f redefine_system_data
