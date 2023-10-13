from ubuntu/nginx
MAINTAINER c.driskill@f5.com

# Install additional packages
RUN apt-get update
RUN apt-get install -y apt-utils vim curl wget jq bind9-dnsutils libterm-readline-gnu-perl iputils-ping net-tools tcpdump supervisor tinydns gpg

# Kubectl
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearm > /etc/apt/trusted.gpg.d/kubernetes.gpg
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install kubectl

# Home directory environment
COPY ./files/bashrc         /root/.bashrc
COPY ./files/bash_aliases   /root/.bash_aliases
COPY ./files/bash_functions /root/.bash_functions

# Nginx customizations
RUN mkdir /etc/nginx/certs
COPY --chown=www-data:www-data ./files/nginx.conf     /etc/nginx
COPY --chown=www-data:www-data ./files/000-default    /etc/nginx/sites-enabled/default
COPY --chown=www-data:www-data ./files/*.html         /var/www/html
COPY --chown=www-data:www-data ./files/cert.pem       /etc/nginx/certs

# Add tinydns users
RUN useradd -r gtinydns
RUN useradd -r gtinylog

# Copy tinydns configuration files
COPY --chown=root:root ./tinydns /etc/tinydns
COPY --chmod=755 ./files/start_tinydns.bash     /

# Supervisord config file
# This will start nginx and call the script that start the tinydns processes
COPY --chown=root:root ./files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

#CMD ["/usr/sbin/nginx"]

