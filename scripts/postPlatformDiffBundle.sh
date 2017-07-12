

if [ $# -ne 1 ]
then
	echo "Usage:"
	echo "postPlatformDiffBundle.sh  version_number"
	echo ""
	echo "Example:"
	echo "postPlatformDiffBundle.sh 18"
	echo ""
	
	exit 1
fi


newVersion=$1


# first, check for all platforms
# don't proceed unless we can proceed for all
for platform in linux mac win; do
	dbzFileName=${newVersion}_inc_${platform}.dbz

	dbzFilePath=~/diffBundles/$dbzFileName

	if [ ! -e $dbzFilePath ]
	then
		echo "File doesn't exist at $dbzFilePath"
		exit 1
	fi
	urlFilePath=~/diffBundles/${newVersion}_inc_${platform}_urls.txt

	if [ -e $urlFilePath ]
	then
		echo "URL file already exists $urlFilePath"
		exit 1
	fi
done 




for platform in linux mac win; do


	dbzFileName=${newVersion}_inc_${platform}.dbz
	echo "New bundle name:  $dbzFileName"

	dbzFilePath=~/diffBundles/$dbzFileName


	urlFilePath=~/diffBundles/${newVersion}_inc_${platform}_urls.txt



	echo -n "" > $urlFilePath


    # feed file through grep to add newlines at the end of each line
    # otherwise, read skips the last line if it doesn't end with newline

    # send this new .dbz to all the download servers
	while read user server
	do
		echo ""
		echo "Sending $dbzFileName to $server"
		scp $dbzFilePath $user@$server:downloads/
		
		echo "Adding url for $server to mirror list for this .dbz"
		
		echo "http://$server/downloads/$dbzFileName" > $urlFilePath
		
	done <  <( grep "" ~/diffBundles/remoteServerList.ini )
	
done




echo ""
echo "Using rsync to push non-diff binary bundles too."


~/checkout/OneLife/scripts/pushDownloadsAndDiffsToMirrors.sh



echo ""
echo "Telling reflector about latest version."


echo -n "<?php \$version=$newVersion; ?>" > ~/www/reflector/requiredVersion.php
