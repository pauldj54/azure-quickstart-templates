# * curl, unzip and jq being installed
# * having a valid bloom license file


NEO4J_VERSION=4.1.3

APOC_VERSIONS_JSON=https://raw.githubusercontent.com/neo4j-contrib/neo4j-apoc-procedures/master/versions.json
# Curl command below returns error and therefore the APO_VERSIONS_JSON was downloaded manually. 
# To find the mapping to the apoc version visit the link above

[ -d plugins ] || mkdir plugins
[ -d plugins ] || mkdir data

cd plugins

# download apoc if not yet there.
# note: we need to follow redirects and want to use orig filename
# gotcha: if you have a non-matching version of apoc, this will *not* fail.
#if ! ls apoc-*-all.jar 1> /dev/null 2>&1; then
#       # resolve correct apoc version
#       APOC_URL=`curl -s $APOC_VERSIONS_JSON | jq -r ".[] | select (.neo4j == \"$NEO4J_VERSION\") | [.jar] | first"`
#       #echo $APOC_URL
curl -L -C - -O -J "https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.1.0.4/apoc-4.1.0.4-all.jar"
#fi


cd ..

docker run \
-d \
-e NEO4J_apoc_import_file_enabled=true \
-e NEO4J_apoc_export_file_enabled=true \
-e NEO4J_dbms_security_procedures_unrestricted=apoc.\\\* \
-v "$PWD/plugins":/plugins \
-p 7474:7474 \
-p 7687:7687 \
-v "$PWD/data":/data \
-v "$PWD/import":/var/lib/neo4j/import \
--user="$(id -u neo4j):$(id -g neo4j)" \
--name=neo4j-sgaa \
neo4j:${NEO4J_VERSION}