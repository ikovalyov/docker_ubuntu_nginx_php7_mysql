FROM ubuntu

#nginx
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y apt-utils sudo nano curl wget libpcre3 libpcre3-dev libssl-dev make libcurl4-openssl-dev libmcrypt-dev libxml2-dev libjpeg-dev libfreetype6-dev libmysqlclient-dev libt1-dev libgmp-dev libpspell-dev libicu-dev librecode-dev libjpeg62 \
	psmisc telnet mysql-client mysql-server git npm net-tools
#RUN mkdir install && wget http://nginx.org/download/nginx-1.6.0.tar.gz && tar xfz nginx-1.6.0.tar.gz
RUN NGINX_DEB_ARCHIVE="http://nginx.org/download/nginx-1.6.0.tar.gz" && wget -P /tmp $NGINX_DEB_ARCHIVE && tar xzPf /tmp/nginx-1.6.0.tar.gz -C /tmp/
WORKDIR /tmp/nginx-1.6.0
RUN ./configure --user=nginx --group=nginx --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-http_ssl_module --with-pcre --with-debug &&\
    make && make install && useradd -d /etc/nginx/ -s /sbin/nologin nginx && mkdir -p /srv/www/html && mkdir /etc/nginx/logs/
COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /

#php7
#WORKDIR /usr/local/php7
#RUN wget http://repos.zend.com/zend-server/early-access/php7/php-7.0-latest-DEB-x86_64.tar.gz && tar zxPf php-7.0-latest-DEB-x86_64.tar.gz
RUN PHP7_DEB_ARCHIVE="http://repos.zend.com/zend-server/early-access/php7/php-7.0-latest-DEB-x86_64.tar.gz" && wget -P /usr/local/php7 $PHP7_DEB_ARCHIVE && tar xzPf /usr/local/php7/php-7*.tar.gz
RUN echo 'export PATH="$PATH:/usr/local/php7/bin"' >> /etc/bash.bashrc
#WORKDIR /usr/local/php7
COPY php-fpm.conf /usr/local/php7/etc/php-fpm.conf
COPY php7-fpm /etc/init.d/php7-fpm
COPY php7-fpm-checkconf /usr/local/lib/php7-fpm-checkconf
#RUN chmod a+x /etc/init.d/php7-fpm && chmod a+x /usr/local/lib/php7-fpm-checkconf && update-rc.d php7-fpm defaults

#mysql
#RUN apt-get update
#RUN apt-get -y install mysql-client mysql-server
RUN service mysql start && sleep 5 && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" && mysql -e "FLUSH PRIVILEGES" && sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

#composer & npm
RUN curl -s https://getcomposer.org/installer | /usr/local/php7/bin/php && sudo mv composer.phar /usr/local/bin/composer

#mongodb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
RUN apt-get update && apt-get install -y mongodb-org
RUN mkdir -p /data/db

RUN apt-get -y install gettext libgettextpo-dev supervisor 

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#COPY start.sh /home/docker/start.sh
#RUN chmod a+x /home/docker/start.sh

EXPOSE 3306 80 443 27017

CMD ["/usr/bin/supervisord", "-n"]

#CMD /home/docker/start.sh