#!/usr/bin/env bash

# starts Pulp services

kubectl create -f resources/celerybeat.yaml
kubectl create -f resources/httpd.yaml
kubectl create -f resources/worker.yaml
kubectl create -f resources/resource_manager.yaml
