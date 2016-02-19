FROM ubuntu:trusty
MAINTAINER Stephen Johnson <steve@smj10j.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
# Install php & mysql
# Download ngx_pagespeed
# Download nginx
# Build nginx
# Cleanup
#
RUN apt-get update -qq \
	&& apt-get install -yqq python-software-properties software-properties-common build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libxslt1-dev libperl-dev wget ca-certificates logrotate language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/mysql-5.6 && LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6 && apt-get update -qq 
RUN apt-get install -yqq php5-fpm php5-memcached php5-mysql php5-curl 
RUN apt-get install -yqq mysql-server

RUN (wget -qO - https://github.com/pagespeed/ngx_pagespeed/archive/v1.9.32.3-beta.tar.gz | tar zxf - -C /tmp) \
	&& (wget -qO - https://dl.google.com/dl/page-speed/psol/1.9.32.3.tar.gz | tar zxf - -C /tmp/ngx_pagespeed-1.9.32.3-beta/) \
	&& (wget -qO - http://nginx.org/download/nginx-1.7.11.tar.gz | tar zxf - -C /tmp)
RUN cd /tmp/nginx-1.7.11 \
	&& ./configure --add-module=/tmp/ngx_pagespeed-1.9.32.3-beta --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --lock-path=/var/lock/nginx.lock --pid-path=/var/run/ngi_module --with-http_gzip_static_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-pcre --with-ipv6 --with-http_spdy_module --with-mail --with-mail_ssl_module --with-sha1=/usr/include/openssl --with-md5=/usr/include/openssl \
	&& make install \
	&& rm -Rf /tmp/*

RUN apt-get purge -yqq wget build-essential \
	&& apt-get autoremove -yqq \
	&& apt-get clean


EXPOSE 80 443

VOLUME ["/etc/nginx", "/usr/share/nginx/www", "/var/lib/mysql"]
WORKDIR /etc/nginx

# Configure nginx
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/lib/nginx
RUN mkdir -p /var/ngx_pagespeed_cache
RUN chmod 777 /var/ngx_pagespeed_cache
RUN chmod 755 /var/log/nginx
RUN chmod 755 /var/lib/nginx
COPY my.cnf /etc/mysql/my.cnf
COPY www.conf /etc/php5/fpm/pool.d/www.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY sites-enabled /etc/nginx/sites-enabled
COPY run.sh /root/run.sh

ENTRYPOINT ["/root/run.sh"]

