#!/bin/sh

# Sub functions

get_dir(){
  dir=$1
  if [ -z $dir ]
  then 
    dir="."
  fi
}

get_all_pdfs(){
  local dir=$1
  pdf_paths=""
  for path in `find $dir -print`
  do 
    local ext="${path##*.}"
    if [ "$ext" = "pdf" ]
    then 
      pdf_paths+="$path\n"  
    fi
  done
}

compress_pdfs(){
  local pdf_paths=$1
  local num_of_pdfs=`printf $pdf_paths | wc -l`
  local pdf_paths=`printf $pdf_paths`

  local i=1
  for path in $pdf_paths
  do 
    printf "[$i/$num_of_pdfs] $path\n"
    ps2pdf "$path" "$path" 
    local i=$((i+1))
  done
}

# Body

IFS_original=$IFS
IFS=$'\n'

get_dir $1
get_all_pdfs $dir
compress_pdfs $pdf_paths

IFS=$IFS_original
