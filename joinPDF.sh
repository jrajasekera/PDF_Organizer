#!/bin/bash

files=""
for var in "$@"
do
    #echo "$var"
    files+=" $var"
done

echo "Joining PDFs: $files"

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=finished.pdf  $files
