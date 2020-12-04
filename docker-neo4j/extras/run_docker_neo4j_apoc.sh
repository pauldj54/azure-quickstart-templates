# * curl, unzip and jq being installed
# * having a valid bloom license file


NEO4J_VERSION=4.1.3

# Create neo4j group and user

sudo groupadd -r neo4j

sudo useradd -r -s /sbin/nologin neo4j

sudo usermod -a -G neo4j neo4j

cd /datadisk/plugins

curl -L -C - -O -J "https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.1.0.4/apoc-4.1.0.4-all.jar"

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