#! /bin/bash

# define a working folder
WORKING_FOLDER=~/work/neweden/e2E/techstackselection/build/archive

# identify source zipfile
SOURCE_ZIP=$WORKING_FOLDER/Archive_20210129_112018_31186.zip
# expand zip in working folder

# build file list to process below
# define output script location/name
FILE_LIST=$WORKING_FOLDER/archivelist

# expand source zip file
mkdir $WORKING_FOLDER/files && cd $WORKING_FOLDER/files && unzip $SOURCE_ZIP

# build file list
cd $WORKING_FOLDER/files && find . > $FILE_LIST

cd $WORKING_FOLDER

# build folder structure
cat $FILE_LIST \
	| cut -d "/" -f 2 | sort | uniq \
	| sed -e 's/Private Firm Documents/Clients/' \
	| sed -e 's/_/\//g' \
	| awk '{printf "mkdir -p \"%s\"\n", $0}' \
	> makedirs.sh

# remove underscores (_) from file name
#  replace with dash (-)
#  this prevents us from losing our minds when
#  we expand the file names into folder structure
# remove the folders so we only have files left
# build the command that moves files into appropriate 
#   place in the structure
#   start with the place
awk -F'/' 'NF!=2' $FILE_LIST \
	| awk '{gsub(/_/,"-",$NF)} 1' \
	| awk 'BEGIN{FS="_"} 
	{printf "mv '\''./files/%s'\'' '\''./Clients/", $0}
	{ for (i=2; i<=NF-1; i++) {
		printf "%s/", $i}
	}
	{printf "%s'\''\n",$NF}' > movefiles.sh
