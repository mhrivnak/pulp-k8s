FROM pulp/base

EXPOSE 80 443

RUN rm /etc/pki/tls/certs/localhost.crt && ln -s /var/run/secrets/pulp/httpd-cert/httpd.crt /etc/pki/tls/certs/localhost.crt
RUN rm /etc/pki/tls/private/localhost.key && ln -s /var/run/secrets/pulp/httpd-cert/httpd.key /etc/pki/tls/private/localhost.key

RUN rm /etc/pki/pulp/ca.crt && ln -s /var/run/secrets/pulp/httpd-cert/auth-ca.crt /etc/pki/pulp/ca.crt
RUN rm /etc/pki/pulp/ca.key && ln -s /var/run/secrets/pulp/httpd-cert/auth-ca.key /etc/pki/pulp/ca.key

RUN mkdir -p /var/run/secrets/pulp/httpd-cert && chmod 700 /var/run/secrets/pulp/httpd-cert && chown apache /var/run/secrets/pulp/httpd-cert
