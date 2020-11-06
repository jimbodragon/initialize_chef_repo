#!/bin/bash

export git_fork_upstream_name='chef-public-cookbook'
export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
export initialize_chef_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
