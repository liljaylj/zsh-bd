bd () {
  # example:
  #   $PWD == /home/arash/abc ==> $num_folders_we_are_in == 3
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local dest="./"

  # First try to find a folder with matching name (could potentially be a number)
  # Get parents (in reverse order)
  local parents
  local i
  for i in {$num_folders_we_are_in..2}
  do
    parents=($parents "$(echo $PWD | cut -d'/' -f$i)")
  done
  parents=($parents "/")
  local arg=$1
  if (($#<1))
  then
    if type fzf &> /dev/null
    then
      IFS=$'\n'
      arg="$(fzf <<< $parents)"
      result=$?
      if [ $result > 0 ]
      then
        return $result
      fi
    else
      cd ..
      return
    fi
  fi

  # Build dest and 'cd' to it
  local parent
  foreach parent (${parents})
  do
    dest+="../"
    if [[ $arg == $parent ]]
    then
      cd $dest
      return 0
    fi
  done

  # If the user provided an integer, go up as many times as asked
  dest="./"
  if [[ "$arg" = <-> ]]
  then
    if [[ $arg -gt $num_folders_we_are_in ]]
    then
      print -- "bd: Error: Can not go up $arg times (not enough parent directories)"
      return 1
    fi
    for i in {1..$arg}
    do
      dest+="../"
    done
    cd $dest
    return 0
  fi

  # If the above methods fail
  print -- "bd: Error: No parent directory named '$arg'"
  return 1
}
_bd () {
  # Get parents (in reverse order)
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local i
  for i in {$num_folders_we_are_in..2}
  do
    reply=($reply "`echo $PWD | cut -d'/' -f$i`")
  done
  reply=($reply "/")
}
compctl -V directories -K _bd bd
