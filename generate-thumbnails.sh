#!/usr/bin/env bash

readme="examples/README.md"

urlencode_grouped_case () {
  string=$1; format=; set --
  while
    literal=${string%%[!-._~0-9A-Za-z]*}
    case "$literal" in
      ?*)
        format=$format%s
        set -- "$@" "$literal"
        string=${string#$literal};;
    esac
    case "$string" in
      "") false;;
    esac
  do
    tail=${string#?}
    head=${string%$tail}
    format=$format%%%02x
    set -- "$@" "'$head"
    string=$tail
  done
  printf "$format\\n" "$@"
}

{ echo "# Example Index"; echo; } > "$readme"
for model in examples/*.scad
do
  filename=$(basename "$model")
  modelname="${filename%.*}"

  echo "********************"
  echo "${modelname}"
  echo "Generating thumbnail"
  openscad -o "thumbnails/$modelname.png" --imgsize=640,480 "examples/$filename"
  echo

  echo "Generating stl for"
  openscad -o "examples/$modelname.stl" "examples/$filename"
  echo

  echo "Adding to $readme"
  {
    echo "### $modelname"
    echo "![$modelname](../thumbnails/$(urlencode_grouped_case "$modelname.png"))"
    echo 
  } >> "$readme"
  echo
done
