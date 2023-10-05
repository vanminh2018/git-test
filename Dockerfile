FROM debian:10

RUN apt update

RUN set -x \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& apt install locales -y \
	&& locale-gen en_US.UTF-8

RUN set -x \
	&& apt -y install vim wget git nano dbus sudo nginx curl dialog \
	qrencode net-tools lsb-release sqlite3 haveged ghostscript \
	libtiff5-dev libtiff-tools at tftpd ssl-cert gnupg2 software-properties-common supervisor

RUN set -x \
	&& apt -y install apt-transport-https ca-certificates

RUN set -x \
	&& apt -y install php7.3 php7.3-cli php7.3-common php7.3-curl \
	php7.3-pgsql php7.3-sqlite3 php7.3-odbc php7.3-xml php7.3-imap php7.3-fpm php7.3-gd \
	&& mkdir -p /run/php

RUN set -x \
	&& wget http://packages.irontec.com/public.key -q -O - | apt-key add - \
	&& echo "deb http://packages.irontec.com/debian $(lsb_release -sc) main" > \
	/etc/apt/sources.list.d/irontec.list \
	&& apt update && apt -y install sngrep

RUN set -x \
	&& TOKEN=pat_YVgiPzBMJeTdYPsU3iLEt7dG \
	&& apt-get update && apt-get install -yq gnupg2 wget lsb-release \
	&& wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg \
	https://freeswitch.signalwire.com/repo/deb/debian-unstable/signalwire-freeswitch-repo.gpg \
	&& echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf \
	&& chmod 600 /etc/apt/auth.conf \
	&& echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] \
	https://freeswitch.signalwire.com/repo/deb/debian-unstable/ `lsb_release -sc` main" \
	> /etc/apt/sources.list.d/freeswitch.list \
	&& echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] \
	https://freeswitch.signalwire.com/repo/deb/debian-unstable/ `lsb_release -sc` main" \
	>> /etc/apt/sources.list.d/freeswitch.list \
	&& apt-get update && apt-get install -y freeswitch-meta-all

RUN set -x \
	&& mkdir -p /etc/fusionpbx \
	&& mkdir -p /var/www/fusionpbx \
	&& mkdir -p /var/cache/fusionpbx \
	&& git clone -b 4.4 https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx

RUN set -x \
	&& mv /etc/freeswitch /etc/freeswitch.orig \
	&& mkdir /etc/freeswitch \
	&& cp -R /var/www/fusionpbx/resources/templates/conf/* /etc/freeswitch

RUN set -x \
	&& mkdir -p /usr/share/freeswitch/sounds/music/default \
	&& mv /usr/share/freeswitch/sounds/music/*000/ /usr/share/freeswitch/sounds/music/default/

RUN set -x \
	&& sed 's#post_max_size = .*#post_max_size = 80M#g' -i /etc/php/7.3/fpm/php.ini \
	&& sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i /etc/php/7.3/fpm/php.ini \
	&& sed 's#max_execution_time = .*#max_execution_time = 120#g' -i /etc/php/7.3/fpm/php.ini \
	&& sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i /etc/php/7.3/fpm/php.ini

RUN set -x \
	&& mkdir -p /etc/nginx/ssl \
	&& cd /etc/nginx/sites-available \
	&& wget https://raw.githubusercontent.com/powerpbx/fusionpbx-install.sh/master/debian/resources/nginx/fusionpbx \
	&& sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.3-fpm.sock;#g' \
	&& ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx \
	&& rm -f /etc/nginx/sites-enabled/default \
	&& ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key \
	&& ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt \
	&& mkdir -p /var/www/letsencrypt/

RUN set -x \
	&& chown -R www-data. /etc/freeswitch /etc/fusionpbx /var/cache/fusionpbx /var/lib/freeswitch \
	/var/log/freeswitch /usr/share/freeswitch /var/www/fusionpbx /var/run/freeswitch \
	&& find /etc/freeswitch -type d -exec chmod 755 {} \; \
	&& find /etc/fusionpbx -type d -exec chmod 755 {} \; \
	&& find /var/cache/fusionpbx -type d -exec chmod 755 {} \; \
	&& find /var/lib/freeswitch -type d -exec chmod 755 {} \; \
	&& find /var/log/freeswitch -type d -exec chmod 755 {} \; \
	&& find /usr/share/freeswitch -type d -exec chmod 755 {} \; \
	&& find /var/www -type d -exec chmod 755 {} \; \
	&& find /etc/freeswitch -type f -exec chmod 664 {} \; \
	&& find /etc/fusionpbx -type f -exec chmod 664 {} \; \
	&& find /var/lib/freeswitch -type f -exec chmod 664 {} \; \
	&& find /var/log/freeswitch -type f -exec chmod 664 {} \; \
	&& find /usr/share/freeswitch -type f -exec chmod 664 {} \; \
	&& find /var/www -type f -exec chmod 664 {} \; \
	&& chmod -R 755 /var/www/fusionpbx/secure

RUN rm -rf /var/cache/apt/archives /var/lib/apt/lists

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# VOLUME ["/etc/freeswitch", "/etc/fusionpbx", "/var/lib/freeswitch", "/usr/share/freeswitch", "/var/www/fusionpbx"]
CMD /usr/bin/supervisord -n
