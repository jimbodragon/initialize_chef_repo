#!/bin/bash

function redefine_general_data()
{
  export git_fork_upstream_name='origin_fork'
}
export -f redefine_general_data
