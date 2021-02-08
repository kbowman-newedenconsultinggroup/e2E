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
	> $WORKING_FOLDER/makedirs.sh


# We have to deal with bad characters in file names
#   the export process uses underscores "_" as
#     folder delineation, so we'll have to remove
#     those from any file names
#   in addition, normal "bad" characters are allowed
#     as part of path, so, we'll have to do a bunch
#     of escaping
#     (note, at some point this would all be
#	easier in python....)

# let's deal with the standard special characters
sed -i 's#\([]\!\(\)\#\%\@\*\$\&\ \=[]\)#\\\1#g' $FILE_LIST

# and single quote
sed -i 's/\x27/\'\\\''/g' $FILE_LIST

# remove underscores (_) from file name
#  replace with dash (-)
#  this prevents us from losing our minds when
#  we expand the file names into folder structure
cat $FILE_LIST \
	| awk 'BEGIN{FS="/"}
	{if($3 ~ /_/) {
		printf "mv ./files/%s ./files/%s/%s/", $0,$1,$2
		gsub(/_/,"-",$3)
		printf "%s\n",$3
	}
	else {next}
	}' > $WORKING_FOLDER/removeunderscores.sh

exit

bash $WORKING_FOLDER/removeunderscores.sh

# rebuild file list since we changed
#   the names of some of our files
cd $WORKING_FOLDER/files && find . > $FILE_LIST

# build command to move everything to new location
#   first, remove lines that don't contain any files
#     we have already used these linese above
#     to make the folders
#   then, build the command that moves files into appropriate 
#     place in the structure - replacing the _ with /
awk -F'/' 'NF!=2' $FILE_LIST \
	| awk 'BEGIN{FS="_"} 
	{printf "mv '\''./files/%s'\'' '\''./Clients/", $0}
	{ for (i=2; i<=NF; i++) {
		printf "%s/", $i}
	}
	{printf '\''\n"}' > $WORKING_FOLDER/movefiles.sh
