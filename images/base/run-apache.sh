#!/bin/bash

# borrowed affectionately from https://github.com/fedora-cloud/Fedora-Dockerfiles/blob/master/apache/run-apache.sh

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/httpd -D FOREGROUND
