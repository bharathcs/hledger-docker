#!/bin/bash

echo "Building..."
docker build -t hledger-docker-test-full --quiet ..
echo "
"

echo "compose up (in progress)"
docker compose up -d
echo "Waiting (10 seconds)"
sleep 10
echo "

--- testing hledger bin container ---"
echo "
==>  CMD1: hledger --version"
(docker exec hledger-bal-try /bin/hledger --version) \
  | sed 's/,.\+//' # remove the platform specific information

echo "
==>  CMD2: hledger reg"
docker exec hledger-bal-try /bin/hledger reg

echo "
==>  CMD3: hledger bal"
docker exec hledger-bal-try /bin/hledger bal

echo "
==>  LOG:"
docker logs hledger-bal-try
echo "

--- testing hledger web container ---"
echo "
==>  LOG:"
docker logs hledger-web-try

docker compose down
