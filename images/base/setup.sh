#!/bin/bash

rsync -a /var/lib/pulp/ /mnt/vlp/
chown apache:apache /mnt/vlp/*
