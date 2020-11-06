#!/bin/bash

export git_main_project_name='jimbodragon_chef_repo'
export git_org='jimbodragon'
export git_baseurl='github.com'
export git_user='git'
export git_fork_upstream_name='chef-public-cookbook'
#export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}/.." )" >/dev/null 2>&1 && pwd )"
export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
export initialize_chef_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
export functions_dir="$initialize_chef_dir/functions"
export initialize_dir="$initialize_chef_dir/initialize"
export git_repos_file="$initialize_chef_dir/git_repos.sh"
