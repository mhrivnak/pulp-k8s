#!/usr/bin/env bash

set -e

chown qpidd:qpidd /var/lib/qpidd 

exec runuser -u qpidd -- qpidd --config=/etc/qpid/qpidd.conf
