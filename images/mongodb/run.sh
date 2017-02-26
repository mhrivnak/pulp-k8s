#!/usr/bin/env bash

set -e

chown mongodb:mongodb /var/lib/mongodb

exec runuser -u mongodb -- /usr/bin/mongod --quiet --config /etc/mongodb.conf run
