
function knife_exec()
{
 log "knife_exec is not implemented"
}
export -f knife_exec

function create_databag()
{
  if [ "$3" == "" ]
    editor="/bin/nano"
  else
    editor="$3"
  fi
  knife data bag create $1 $2 --local-mode --editor $editor
}
export -f create_databag

function create_encrypted_databag()
{
  if [ "$6" == "" ]
    editor="/bin/nano"
  else
    editor="$6"
  fi
  knife data bag create $1 $2 --local-mode --editor $editor --secret "$(show_databag_item $3 $4 $5 )"
}
export -f create_databag

function show_databag_item()
{
  if [ "$4" == "" ]
    editor="/bin/nano"
  else
    editor="$4"
  fi
  knife data bag show $1 $2 --local-mode --format json --editor $editor | jq .$3 | cut -d '"' -f 2
}
export -f show_databag
