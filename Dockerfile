FROM ubuntu
VOLUME /data
RUN apt-get update && apt-get install -y apt-utils sudo nano curl wget libpcre3 libpcre3-dev libssl-dev make libcurl4-openssl-dev libmcrypt-dev libxml2-dev libjpeg-dev libfreetype6-dev libmysqlclient-dev libt1-dev libgmp-dev libpspell-dev libicu-dev librecode-dev libjpeg62 \
	psmisc telnet
WORKDIR /root
RUN mkdir install && wget http://nginx.org/download/nginx-1.6.0.tar.gz && tar xfz nginx-1.6.0.tar.gz
WORKDIR /root/nginx-1.6.0
RUN ./configure --user=nginx --group=nginx --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-http_ssl_module --with-pcre --with-debug
RUN sudo make && sudo make install && useradd -d /etc/nginx/ -s /sbin/nologin nginx && apt-get install net-tools
RUN mkdir -p /srv/www/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
RUN mkdir /etc/nginx/logs/
WORKDIR /usr/local/php7
RUN wget http://repos.zend.com/zend-server/early-access/php7/php-7.0-latest-DEB-x86_64.tar.gz && tar zxPf php-7.0-latest-DEB-x86_64.tar.gz
RUN echo 'export PATH="$PATH:/usr/local/php7/bin"' >> /etc/bash.bashrc
WORKDIR /usr/local/php7
COPY php-fpm.conf /usr/local/php7/etc/php-fpm.conf
COPY php7-fpm /etc/init.d/php7-fpm
RUN chmod a+x /etc/init.d/php7-fpm
COPY php7-fpm-checkconf /usr/local/lib/php7-fpm-checkconf
RUN chmod a+x /usr/local/lib/php7-fpm-checkconf && update-rc.d php7-fpm defaults

RUN apt-get update
RUN apt-get -y install mysql-client mysql-server
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
EXPOSE 3306


COPY start.sh /home/docker/start.sh
RUN chmod a+x /home/docker/start.sh
CMD /home/docker/start.sh