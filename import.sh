#! /bin/bash

INPUT_FILE=./sskc

# Check for underscores in filenames!
#cat $INPUT_FILE | awk 'BEGIN{IFS="/"} {printf $NF}'

# build folder structure
cat $INPUT_FILE \
	| cut -d "/" -f 2 | sort | uniq \
	| sed -e 's/Private Firm Documents/Clients/' \
	| sed -e 's/_/\//g' \
	| awk '{printf "mkdir -p \"%s\"\n", $0}'

# remove underscores (_) from file name
#  replace with dash (-)
#  this prevents us from losing our minds when
#  we expand the file names into folder structure
awk -F "/" '{gsub(/_/, "-", $NF)} 1' $INPUT_FILE
	
# move files into appropriate place in the structure
cat $INPUT_FILE \
	| awk 'BEGIN{FS="_"} 
	# change first field to our Clients folder
	{printf "mv \"%s\" \"./Clients/", $0}
	{ for (i=2; i<=NF-1; i++) {
		printf "%s/", $i}
	}

# append file name to the end
	{printf "%s\"\n",$NF}'


