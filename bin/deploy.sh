
#!/bin/bash -e

DIR=dist
BASEDIR="$(realpath "$(dirname "$0")/..")"

if [[ -z "$1" ]]; then
	VERSION=$(cat $BASEDIR/VERSION)
else
	VERSION=$1
fi

cd $BASEDIR

echo "Uploading to Nexus kms_utils.sh version $VERSION"
curl -u stratio:$NEXUSPASS --upload-file bundle.json http://qa-pre.int.stratio.com:8081/repository/paas/testmake/bundle.json
