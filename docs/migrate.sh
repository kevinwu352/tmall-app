#!/bin/zsh

fr=/Users/kevin/Documents/trunk/tmall-app/Modules/ModCommon/ModCommon
to=/Users/kevin/Documents/projs/humanity/hpauth/modc

function iterate() {

  for file in $1/*; do
    if [ -f $file ]; then
      dest=$to${file/$fr/""}
      if [ -f $dest ]; then
        echo "[copy] ${file}"
        cp -f $file $dest
      else
        echo "[    ] ${file}"
      fi
    fi
    if [ -d $file ]; then
      dest=$to${file/$fr/""}
      if [ -d $dest ]; then
        echo "[goin] ${file}"
        iterate $file
      else
        echo "[    ] ${file}"
      fi
    fi
  done
}

iterate $fr $to

# echo "Press any key to continue..."
# read var
