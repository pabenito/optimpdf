#!/bin/sh 

usage(){
  command=$1
  printf "$command [OPTION] [INPUT]*\n\n"
  printf "[OPTION]:\n\t[-h]\tShow help.\n\t[-k]\tKeep original PDFs.\n\t[-r]\tSearch recursively for PDFs/\n"
  printf "[INPUT]: There are some posible inputs\n\t[PDF]\tA single PDF.\n\t[Pattern]\tA pattern matching some PDFs, i.e. team*\n\t[Directory]\tA directory. If not specified the directory is the working directory.\n"
}

optimize_pdf(){
  local path=$1
  local keep_original=$2
  
  local ext="${path##*.}"
  local path_without_ext=${path%.*}
  local path_original="${path_without_ext}_original.pdf"

  cp $path $path_original 
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dColorpdfDownsampleType=/Bicubic -dColorpdfResolution=144 -dGraypdfDownsampleType=/Bicubic -dGraypdfResolution=144 -dMonopdfDownsampleType=/Bicubic -dMonopdfResolution=144 -sOutputFile=$path $path_original 

  if [ $keep_original = "false" ]
  then 
    rm $path_original
  fi
}

count_lines(){
  return `printf "$1" | wc --lines`
}

is_pdf(){
  local path=$1
  local ext="${path##*.}"
  if ! [ -z $path ] && [ -f $path ] && [ $ext = "pdf" ]
  then return 0
  else return 1
  fi
}

check_dir_exists(){
  dir=$1
  if [ ! -d $dir ]
  then 
    printf "Error: The specified directory '$dir' does not exist\n" >&2
    exit 1
  fi
}

get_all_pdfs(){
  local dir=$1
  local recursively=$2

  local pdf_paths=""
  local element_paths=""
  
  IFS_original=$IFS
  IFS=$'\n'

  if [ $recursively = "true" ]
  then 
    element_paths=`find $dir -print`
  else 
    element_paths=`ls -1 $dir`
  fi
  
  for element in $element_paths 
  do
    if is_pdf $element
    then 
      pdf_paths+="$element\n"  
    fi 
  done

  IFS=$IFS_original 

  count_lines $pdf_paths
  local num_of_pdfs=$?
  if [ $num_of_pdfs -le 0 ]
  then
    printf "There are no pdfs in the specified directory '$dir'\n"
    exit 0
  fi

  retval=$pdf_paths
}

optimize_pdfs(){
  local pdf_paths=$1
  local keep_original=$2
  
  count_lines $pdf_paths
  local num_of_pdfs=$?
  local pdf_paths=`printf $pdf_paths`

  IFS_original=$IFS
  IFS=$'\n'
  
  local i=1
  for path in $pdf_paths
  do 
    printf "[$i/$num_of_pdfs] $path\n"
    optimize_pdf $path $keep_original
    local i=$((i+1))
  done
  
  IFS=$IFS_original
}

# Body

selfpath=`realpath $0`
selfdir=`dirname $selfpath`
selffile=`basename $0`
selfname=${selffile%.*}

recursively="false"
keep_original="false"

while getopts "hrk" arg; do
  case $arg in
    h) # Display help.
      usage $selfname
      exit 0
      ;;
    r) # Keep original pdf 
      recursively="true"
      shift # It is supposed to be the first / second argument
      ;;
    k) # Keep original pdf 
      keep_original="true"
      shift # It is supposed to be the first / second argument
      ;;
  esac
done

printf "Searching PDFs...\n"

if [ $# -eq 0 ] # Recursively in the working directory
then 
  get_all_pdfs . $recursively # Return paths in $retval
  optimize_pdfs $retval $keep_original
else
  pdf_paths=""
  for input in $*
  do  # Multiple arguments or pattern
    if is_pdf $input  
    then 
      pdf_paths="$pdf_paths$input\n"
    else 
      check_dir_exists $input
      get_all_pdfs $input $recursively # Return paths in $retval
      pdf_paths="$pdf_paths$retval\n"
    fi
  done 
  optimize_pdfs $pdf_paths $keep_original 
fi 
