#!/bin/sh

echo "Creating file: templates/api/docs.html.ep"

echo ". Header"
echo -e "%layout 'default';\n%title 'API Docs';\n" >templates/api/docs.html.ep

echo ". pod2html API"
pod2html --infile lib/BookKeeping/Controller/API.pm --outfile templates/api/docs.html.ep

[ -f pod2htmd.tmp ] && rm -f pod2htmd.tmp
