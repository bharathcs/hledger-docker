#!/bin/bash

chown -R hledger:hledger /data
chmod -R u+rwX,g+rwX,o=  /data

# Change user to hledger
su hledger

# needed to run parameters CMD
$@
