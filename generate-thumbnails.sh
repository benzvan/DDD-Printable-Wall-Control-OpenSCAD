#!/usr/bin/env sh

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

echo "# Example Index" > "$readme"
echo "" >> "$readme"
for model in examples/*.scad
do
  filename=$(basename "$model")
  modelname="${filename%.*}"

  echo "Generating thumbnail for $modelname"
  openscad -o "thumbnails/$modelname.png" --imgsize=640,480 "examples/$filename"

  echo "Generating stl for $modelname"
  openscad -o "examples/$modelname.stl" "examples/$filename"

  echo "Adding $modelname to $readme"
  echo "### $modelname" >> "$readme"
  echo "![$modelname](../thumbnails/$(urlencode_grouped_case "$modelname.png"))" >> "$readme"
  echo "" >> "$readme"
done
