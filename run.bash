#!/bin/bash
bq query --format sparse -n 999999999 --nouse_legacy_sql 'SELECT repo_name,path,id FROM `bigquery-public-data.github_repos.files` WHERE path LIKE "%.sol"' | grep .sol | perl -MFile::Basename -ne 'chomp;@F=split / +/;print qq(mkdir -p "./src/$F[1]/).File::Basename::dirname($F[2]).qq(";wget -O "./src/$F[1]/$F[2]" -q "https://raw.githubusercontent.com/$F[1]/master/$F[2]";echo "$F[1]/$F[2]";\n);' | sort 
git add src
git commit -m 'update solidity sources via bigquery-public-data.github_repos.files'
git push origin master
