#!/usr/bin/bash

# initting components
ENTRIES=$(fgrep -Hr . -e @imp 2>/dev/null | awk 'BEGIN{FS="//";}  {print $1}'| xargs realpath | tr -d ':')
APP_FILE=$(find . -name "*Application.java" | head -n 1)
PACKAGE_NAME=$(cat $APP_FILE | head -n 1 | tr -d ";" | awk '{print $2}')
PERL_SCRIPT_HOME="${SPRIMP_HOME}/javimp";

for e in $ENTRIES; do

	# separating components
	filename=$(echo ${e} | awk 'BEGIN{FS="@"}{print $1}')
	last_package=$(echo $filename | awk 'BEGIN{FS="/"}{JACK=NF-1; print $JACK}')

	# remember where we used to be
	current_dir=$(pwd)

	# using that perl script i wrote to show middle finger to eclipse 8-)
	cd $PERL_SCRIPT_HOME;
	./index.pl $e

	# putting package statement 
	echo "package $PACKAGE_NAME.$last_package;" > $filename.imp.pack
	echo >> $filename.imp.pack
	cat $filename.imp >> $filename.imp.pack

	# cleaning up
	rm $filename.imp
	cd $current_dir
	mv $filename.imp.pack $filename

done
