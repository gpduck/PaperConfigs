#!/bin/sh

if [ ! -f /server/eula.txt ]
then
    echo 'eula=true' > /server/eula.txt
fi

if [ ! -f /server/ops.json ]
then
    uuid=`wget -O - -q https://minecraft-api.com/api/uuid/$OP`
    if [ "$uuid" = "Player not found !" ]
    then
        echo "OP user id not found for '$OP'."
        exit 1
    fi
    echo "[ { \"uuid\": \"${uuid:0:8}-${uuid:8:4}-${uuid:12:4}-${uuid:16:4}-${uuid:20}\", \"name\": \"$OP\", \"level\": 4, \"bypassesPlayerLimit\": true}]" > /server/ops.json
fi

if [ ! -f /server/server.properties ]
then
    cp /paper/server.properties /server/
fi

java -Xms2G -Xmx2G -jar /paper/paper.jar --nogui --server-name $SERVER_NAME --plugins /paper/plugins