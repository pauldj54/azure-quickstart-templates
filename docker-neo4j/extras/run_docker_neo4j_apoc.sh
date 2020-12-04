# * curl, unzip and jq being installed
# * having a valid bloom license file


NEO4J_VERSION=4.1.3

# Create neo4j user with no login

sudo useradd -M neo4j
sudo usermod -L neo4j

# Create data directory
sudo mkdir -p /datadisk/neo4j/data 
sudo chown -R neo4j /datadisk/neo4j/data
sudo chgrp -R neo4j /datadisk/neo4j/data
# Create import directory
sudo mkdir -p /datadisk/neo4j/import
sudo chown -R neo4j /datadisk/neo4j/import
sudo chgrp -R neo4j /datadisk/neo4j/import
# Create plugins directory
sudo mkdir -p /datadisk/neo4j/plugins
sudo chown -R neo4j /datadisk/neo4j/plugins
sudo chgrp -R neo4j /datadisk/neo4j/plugins

#Group gets write permissions here
sudo chmod -R u+rwX,g+rwX,o+wrx /datadisk/neo4j/plugins # N.b. if you make external changes to the plugins dir you must restart neo4j before it will pickup new plugins

# Create a logs group for all things log related
sudo groupadd logs

# add neo4j to logs group
sudo usermod -a -G logs neo4j
sudo mkdir -p /datadisk/logs/neo4j
sudo chown -R root /datadisk/logs/neo4j
sudo chgrp -R logs /datadisk/logs/neo4j
sudo chmod -R u+rwX,g+rwX,o+wrx /datadisk/logs

# if docker does not run as root user
docker_user=neo4j
sudo usermod -a -G logs "${docker_user}"
sudo usermod -a -G neo4j "${docker_user}"

# add neo4j user to docker group
sudo usermod -aG docker neo4j

cd /datadisk/neo4j/plugins

curl -L -C - -O -J "https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.1.0.4/apoc-4.1.0.4-all.jar"

cd ..

# pull docker image for neo4j
docker pull neo4j:4.1.3

# run docker image
#groups=( $( id --real --groups neo4j ) )
sudo su - neo4j

docker run \
-d \
-e NEO4J_apoc_import_file_enabled=true \
-e NEO4J_apoc_export_file_enabled=true \
-e NEO4J_dbms_security_procedures_unrestricted=apoc.\\\* \
-e NEO4J_AUTH=neo4j/C9rctBr08k0er \
-v "$PWD/plugins":/plugins \
-p 7474:7474 \
-p 7687:7687 \
-v "$PWD/data":/data \
-v "$PWD/import":/var/lib/neo4j/import \
-v "/datadisk/logs/neo4j":/logs \
--user="$(id -u neo4j):$(id -g neo4j)" \
--name=neo4j \
neo4j:4.1.3

