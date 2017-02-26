#!/usr/bin/env bash

CERTS=certs
ORG=pulp
TMP="$(mktemp -d)"

mkdir -p certs

##### Create self-signed CA for user cert auth

# create CA key
openssl genrsa -out certs/auth-ca.key 4096 #&> /dev/null

# create signing request
openssl req \
  -new \
  -key certs/auth-ca.key \
  -out ${TMP}/auth-ca.req \
  -subj "/CN=pulpca/O=$ORG" #&> /dev/null

# create a self-signed CA certificate
openssl x509 \
  -req \
  -days 7035 \
  -sha256 \
  -extensions ca  \
  -signkey certs/auth-ca.key \
  -in ${TMP}/auth-ca.req \
  -out certs/auth-ca.crt #&> /dev/null


##### Create self-signed CA for services

# create CA key
openssl genrsa -out certs/ca.key 4096 #&> /dev/null

# create signing request
openssl req \
  -new \
  -key certs/ca.key \
  -out ${TMP}/ca.req \
  -subj "/CN=pulpca/O=$ORG" #&> /dev/null

# create a self-signed CA certificate
openssl x509 \
  -req \
  -days 7035 \
  -sha256 \
  -extensions ca  \
  -signkey certs/ca.key \
  -in ${TMP}/ca.req \
  -out certs/ca.crt #&> /dev/null


##### Create httpd cert

# create key
openssl genrsa -out certs/httpd.key 4096 #&> /dev/null

# create signing request
openssl req \
  -new \
  -key certs/httpd.key \
  -out ${TMP}/httpd.req \
  -subj "/CN=pulpapi/O=$ORG" #&> /dev/null

# create a signed certificate
openssl x509 \
  -req \
  -CA certs/ca.crt \
  -CAkey certs/ca.key \
  -CAcreateserial \
  -in ${TMP}/httpd.req \
  -out certs/httpd.crt #&> /dev/null


##### Create mongodb cert

# create key
openssl genrsa -out certs/mongodb.key 4096 #&> /dev/null

# create signing request
openssl req \
  -new \
  -key certs/mongodb.key \
  -out ${TMP}/mongodb.req \
  -subj "/CN=mongodb/O=$ORG" #&> /dev/null

# create a signed certificate
openssl x509 \
  -req \
  -CA certs/ca.crt \
  -CAkey certs/ca.key \
  -CAcreateserial \
  -in ${TMP}/mongodb.req \
  -out certs/mongodb.crt #&> /dev/null

cat certs/mongodb.key certs/mongodb.crt > certs/mongodb.pem


##### Create generic client cert

# create key
openssl genrsa -out certs/client.key 4096 #&> /dev/null

# create signing request
openssl req \
  -new \
  -key certs/client.key \
  -out ${TMP}/client.req \
  -subj "/CN=pulp-service-client/O=$ORG" #&> /dev/null

# create a signed certificate
openssl x509 \
  -req \
  -CA certs/ca.crt \
  -CAkey certs/ca.key \
  -CAcreateserial \
  -in ${TMP}/client.req \
  -out certs/client.crt #&> /dev/null

cat certs/client.key certs/client.crt > certs/client.pem

##### Create qpid cert and DB

./pulp-qpid-ssl-cfg


# clean
rm ${TMP}/*.req
rmdir ${TMP}
