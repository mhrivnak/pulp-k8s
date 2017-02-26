What Is This
============

This repository contains almost everything you need to have a production-quality
deployment of Pulp on Kubernetes. You provide a running k8s cluster plus
shared storage.

TLS with client certificate authentication is used among the services. A
self-signed CA and all required certificates are created and distributed
automatically.

This is highly experimental and not yet officially supported. If there is interest,
and if others can help get these materials tested and improved, it could become
a fully supported and recommended deployment model by the
[Pulp Project](http://pulpproject.org/).


Getting Started
===============

To start quickly with a demo-quality single-node kubernetes cluster, try
[minikube](https://kubernetes.io/docs/getting-started-guides/minikube/). When
you have a running cluster, proceed.

Storage
-------

Create storage for pulp, qpidd, and mongodb. Before creating these resources,
adjust each `PersistentVolume` to match the storage you can provide. The
defaults only work on a single-node deployment (such as minikube).

    kubectl create -f resources/vlp.yaml
    kubectl create -f resources/vlq.yaml
    kubectl create -f resources/vlm.yaml


Secrets
-------

### server.conf

Edit `secrets/full-server.conf` to your liking. Defaults will work, but
consider such settings as the initial admin password. For settings that are
already populated with non-default values, those values are likely important to
integration with other k8s resources. It's wise to understand the current value
before changing it.


### Certificates

This script creates a self-signed CA, and all of the certificates needed by the
various pulp services.

    ./make-certs.sh

If you prefer to provide your own certificates, pause here and replace what was
generated. Most of the output is in the `certs` directory, but `qpidd` requires
an NSS database found in the `qpidd` directory.

### RSA Key Pair

Just run the script to generate the pair.

    ./pulp-gen-key-pair

### Commit

Done! Now run the provided script to "commit" the secrets into k8s.

    ./commit.sh

At any time you can stop services, run `delete.sh` to remove the secrets from
k8s, modify values as you like, and then re-commit with `commit.sh`. Then start
everything back up.


Supporting Services
-------------------

MongoDB and Qpid are ready to be started. They must remain singletons, so do
not scale beyond 1 pod each.

    kubectl -f resources/mongo.yaml
    kubectl -f resources/qpid.yaml


Setup
-----

Almost done. We need two setup steps.

The first time you deploy, run the `setup` pod to establish the correct
filesystem layout on your shared storage.

    kubectl -f resources/setup.yaml

Watch for the `setup` pod to finish by running this command:

    kubectl get pods -a

Every time you deploy a new version of Pulp, including the first deployment,
run `pulp-manage-db`. Make sure that no Pulp services are running.

    kubectl -f resources/manage.yaml

As above, watch for completion with this command:

    kubectl get pods -a


Start Pulp
----------

This script is a shortcut for creating the Pulp resources. Before creating
them, feel free to adjust the number of replicas of each `Deployment` resource.
For anything more serious than a demo, I would start with 4-8 workers, and 2 of
each other Pulp service.

    ./up.sh


Access Pulp
-----------

This deployment uses the most recent Fedora release in the container images.
For now, it is up to you to run your own machine with the same version of
Fedora, or otherwise install `pulp-admin` of the same version that matches the
images.

Since I use Fedora on my laptop anyway, this document will proceed with that.

Start by [installing pulp-admin](http://docs.pulpproject.org/user-guide/installation/f24+.html#admin-client).

Create the file `~/.pulp/admin.conf` with these contents, adjusted for wherever
you have this git repository checked out.

    [server]
    host = pulpapi
    port = 30443
    ca_path = /home/mhrivnak/git/pulp-k8s/secrets/certs/ca.crt

Find the external IP address for one or more nodes in your cluster. If using
minikube:

    minikube ip

Edit your `/etc/hosts` file so the name `pulpapi` resolved to those addresses.
Or use a DNS service if you have one handy.

    sudo echo 192.168.42.149 pulpapi >> /etc/hosts 

Cross your fingers, and then clumsily type:

    pulp-admin status

Assuming the status looks good, you are now free to log in and use Pulp as
normal.


Scaling
-------

Need more workers? No problem.

    kubectl scale --replicas=16 deployment/worker

Finished a batch of work and ready to scale back? Just as easy.

    kubectl scale --replicas=4 deployment/worker

For maximum fun, I like to run this in another terminal while scaling workers:

    watch -n 1 pulp-admin status


Limitations
-----------

### Load Balancing

Kubernetes does not yet have a great story around load balancing or highly
available access to services that want to terminate their own TLS. Pulp is
currently suited to running TCP from the client all the way to the `httpd`
process for that very purpose.

The new [Ingress](https://kubernetes.io/docs/user-guide/ingress/) resource type
appears to be targeting layer 7, so it is not useful in this case.

For now we are using the
[NodePort](https://kubernetes.io/docs/user-guide/services/#type-nodeport)
feature of the `Service` resource, which limits us by default to a range of
ports above 30000.

Please suggest ideas if you have them.

### On-Demand Support Not Deployed

This does not yet include support for [Alternate Download
Policies](http://docs.pulpproject.org/user-guide/deferred-download.html).
I think it would be straight-forward to add. We just need to:

- install the streamer on the base image
- create a new image that runs squid
- create `Deployment` resources for both the streamer and squid

### REST API Coupled With Content Serving

For simplicity, I made one `httpd` pod template that does everything. This
includes serving the REST API and serving published content. Those are very
different roles with different characteristics, and httpd already runs them in
different processes.

It would be better to make a separate pod template for each. That may require
substantial modification of Pulp's default httpd configuration, which is the
main reason I avoided it so far.
