#!/usr/bin/env bash

# stops Pulp services

kubectl delete -f resources/worker.yaml
kubectl delete -f resources/resource_manager.yaml
kubectl delete -f resources/httpd.yaml
kubectl delete -f resources/celerybeat.yaml
