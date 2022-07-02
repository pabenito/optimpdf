#!/bin/sh

# Sub functions

count_lines(){
  return `printf "$1" | wc --lines`
}

get_dir(){
  dir=$1
  
  if [ -z $dir ]
  then 
    dir="."
  fi
  
  if [ ! -d $dir ]
  then 
    printf "Error: The specified directory '$dir' does not exist\n" >&2
    exit 1
  fi
}

get_all_pdfs(){
  local dir=$1
  pdf_paths=""
  printf "Searching PDFs...\n"

  for path in `find $dir -print`
  do 
    local ext="${path##*.}"
    if [ "$ext" = "pdf" ]
    then 
      pdf_paths+="$path\n"  
    fi
  done
 
  count_lines $pdf_paths
  local num_of_pdfs=$?
  if [ $num_of_pdfs -le 0 ]
  then
    printf "There are no PDFs in the specified directory '$dir'\n"
    exit 0
  fi
}

compress_pdfs(){
  local pdf_paths=$1
  local num_of_pdfs=$(count_lines $pdf_paths)
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
