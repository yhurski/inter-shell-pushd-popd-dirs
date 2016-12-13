#!/bin/bash
#title           :
#description     :
#author          :Yury <hi1sailor[at]gmail.com>
#date            :20161129
#version         :0.1
#usage           :
#bash_version    :4.3.30(1)-release
#==============================================================================
declare -r _pushd=pushd
declare -r _popd=popd
declare -r _dirs=dirs

trap "exit" SIGQUIT

pushd ()
{
  if [[ $# -eq 0 ]]
  then
    echo "No directory provided."
    return 1
  fi

  if [[ ! -f $(get_queue_filename) ]]
  then
    get_queue_filename | xargs touch
  fi

  echo "$(readlink -f $@)" >> get_queue_filename

  return
}

popd ()
{
  if [[ ! -f get_queue_filename ]]
  then
    echo "No pipeline found."
    return 1
  fi

  first_dir=$(tail -n 1 /tmp/pushdfifo | xargs readlink -f)

  head -n -1 get_queue_filename > get_queue_filename

  if [[ -d "$first_dir" ]]
  then
    cd $first_dir
  else
    echo $first_dir
    echo "Unknown directory on top of the stack."
    return 1
  fi

  return
}

dirs ()
{
  tac get_queue_filename
}

get_queue_filename ()
{
  username=`whoami`
  eid=`id -u`
  filename=$(echo $username$eid | md5sum)

  echo '/tmp/'$filename
}


unset -f get_queue_filename
