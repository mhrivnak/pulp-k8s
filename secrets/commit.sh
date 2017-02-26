#!/usr/bin/env bash

# The RSA keys tend to be needed everywhere server.conf is needed, so that's
# the only reason they're all in the same secret.
cat full-server.conf | egrep -v '^#.*' | egrep -v '^$' > server.conf
kubectl create secret generic pulp-config --from-file=server.conf --from-file=certs/rsa.key --from-file=certs/rsa_pub.key
rm server.conf

pushd certs > /dev/null
# httpd.* gets used by httpd to serve TLS connections. auth-ca.* gets used to
# create user authentication certificates, as returned by the login API.
kubectl create secret generic httpd-certs --from-file=httpd.key --from-file=httpd.crt --from-file=auth-ca.crt --from-file=auth-ca.key
kubectl create secret generic mongodb-cert --from-file=mongodb.pem
kubectl create secret generic client-cert --from-file=client.pem --from-file=client.crt --from-file=client.key
popd > /dev/null
kubectl create secret generic qpiddb --from-file=qpiddb/nss

# Ok fine, technically this one isn't a secret. But otherwise it behaves the
# same, so it's convenient to manage with the secrets.
kubectl create configmap pulp-ca --from-file=certs/ca.crt
