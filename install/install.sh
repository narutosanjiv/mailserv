#!/bin/sh
# Last changes : 2015/09/28, Wesley MOUEDINE ASSABY
# Contact me :  wesley at mouedine dot net
# MISSING PARTS : RUBY ON RAILS APPS

TEMPLATES=/var/mailserv/install/templates

export PKG_PATH=http://ftp2.fr.openbsd.org/pub/OpenBSD/5.7/packages/$(machine)/

function DoTheJob {

mkdir -p /var/db/spamassassin
mkdir -p /etc/awstats
mkdir -p /var/mailserv/mail
mkdir -p /usr/local/share/mailserv

install $TEMPLATES/fs/bin/* /usr/local/bin/
install $TEMPLATES/fs/sbin/* /usr/local/sbin/
install $TEMPLATES/fs/mailserv/* /usr/local/share/mailserv

echo " -- Step 1 - install packages"
pkg_add lynx ImageMagick mariadb-server gtar-1.28p0 gsed clamav postfix-2.11.4-mysql \
    p5-Mail-SpamAssassin dovecot-mysql dovecot-pigeonhole sqlgrey nginx-1.7.10 php-5.5.22 \
    php-mysql-5.5.22 php-pdo_mysql-5.5.22 php-fpm-5.5.22 php-zip-5.5.22 php-mcrypt-5.5.22 \
    php-intl-5.5.22 php-pspell-5.5.22 ruby-rrd-1.4.9 ruby21-highline-1.6.21 ruby21-mysql-2.9.1 \
    node god xcache

echo " -- Step 2 - link python"
ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
ln -sf /usr/local/bin/python2.7-2to3 /usr/local/bin/2to3
ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config
ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc

echo " -- Step 3 - stop and disable unwanted services"
/usr/sbin/rcctl stop smtpd
/usr/sbin/rcctl disable smtpd
/usr/sbin/rcctl stop sndiod
/usr/sbin/rcctl disable sndiod

echo " -- Step 4 - enable and start ntpd"
/usr/sbin/rcctl enable ntpd
/usr/sbin/rcctl set ntpd flags -s
/usr/bin/install -m 644 /etc/examples/ntpd.conf /etc
/usr/sbin/rcctl start ntpd

echo " -- Step 5 - setup Mariadb-Server"
/usr/local/bin/mysql_install_db > /dev/null 2>&1
install -m 644 $TEMPLATES/my.cnf /etc

/usr/sbin/rcctl enable mysqld
/usr/sbin/rcctl start mysqld

echo " -- Step 6 - setup php"
ln -sf /etc/php-5.5.sample/intl.ini /etc/php-5.5/intl.ini
ln -sf /etc/php-5.5.sample/mcrypt.ini /etc/php-5.5/mcrypt.ini
ln -sf /etc/php-5.5.sample/mysql.ini /etc/php-5.5/mysql.ini
ln -sf /etc/php-5.5.sample/pdo_mysql.ini /etc/php-5.5/pdo_mysql.ini
ln -sf /etc/php-5.5.sample/pspell.ini /etc/php-5.5/pspell.ini
ln -sf /etc/php-5.5.sample/zip.ini /etc/php-5.5/zip.ini
ln -fs /etc/php-5.5.sample/xcache.ini /etc/php-5.5/xcache.ini
ln -sf /usr/local/bin/php-5.5 /usr/local/bin/php
install -m 644 $TEMPLATES/php-fpm.conf /etc/
/usr/sbin/rcctl enable php_fpm
/usr/sbin/rcctl start php_fpm

echo " -- Step 7 - setup postfix"
/usr/local/sbin/postfix-enable

install -m 644 $TEMPLATES/postfix/main.cf /etc/postfix
install -m 644 $TEMPLATES/postfix/master.cf /etc/postfix
install -m 644 $TEMPLATES/postfix/header_checks.pcre /etc/postfix
install -m 644 $TEMPLATES/postfix/milter_header_checks /etc/postfix
cp -r $TEMPLATES/postfix/sql /etc/postfix/
chmod -R 755 /etc/postfix/sql

/usr/sbin/rcctl enable postfix
/usr/sbin/rcctl start postfix

echo " -- Step 8 - setup spamassassin"
install -m 644 $TEMPLATES/spamassassin_local.cf /etc/mail/spamassassin/local.cf

/usr/sbin/rcctl enable spamassassin
/usr/sbin/rcctl start spamassassin

/usr/local/bin/sa-update -v

echo " --Step 9 - setup clamav"
install -m 644 $TEMPLATES/clam* /etc
install -m 644 $TEMPLATES/freshclam.conf /etc

if [ ! -f /var/db/clamav/main.cld ]; then
touch /var/log/clamd.log 2> /dev/null
chown _clamav:_clamav /var/log/clamd.log
touch /var/log/clam-update.log 2> /dev/null
chown _clamav:_clamav /var/log/clam-update.log
touch /var/log/freshclam.log 2> /dev/null
chown _clamav:_clamav /var/log/freshclam.log
mkdir -p /var/db/clamav
chown -R _clamav:_clamav /var/db/clamav
/usr/local/bin/freshclam --no-warnings
fi

/usr/sbin/rcctl enable clamd
/usr/sbin/rcctl enable freshclam
/usr/sbin/rcctl start clamd
/usr/sbin/rcctl start freshclam

echo " -- Step 10 - create certificates"
/usr/bin/openssl genrsa -out /etc/ssl/private/server.key 2048 2>/dev/null
/usr/bin/openssl req -new -key /etc/ssl/private/server.key \
    -out /tmp/server.csr -subj "/CN=`hostname`" 2>/dev/null
/usr/bin/openssl x509 -req -days 1095 -in /tmp/server.csr \
    -signkey /etc/ssl/private/server.key -out /etc/ssl/server.crt 2>/dev/null
rm -f /tmp/server.csr

echo " -- Step 11 - setup dovecot"
install -m 644 $TEMPLATES/dovecot.conf /etc/dovecot
install -m 644 $TEMPLATES/dovecot-sql.conf /etc/dovecot

/usr/sbin/rcctl enable dovecot
/usr/sbin/rcctl start dovecot

echo " -- Step 12 - setup sqlgrey"
install -m 644 $TEMPLATES/sqlgrey.conf /etc/sqlgrey
/usr/local/bin/mysqladmin create sqlgrey
/usr/local/bin/mysql -e "grant all privileges on sqlgrey.* to 'sqlgrey'@'localhost' identified by 'sqlgrey';"
/usr/sbin/rcctl enable sqlgrey
/usr/sbin/rcctl start sqlgrey && sleep 2
/usr/local/bin/mysql sqlgrey -e "alter table connect add id int primary key auto_increment first;"
touch /etc/sqlgrey/clients_fqdn_whitelist.local 2> /dev/null
touch /etc/sqlgrey/clients_ip_whitelist.local 2> /dev/null

echo " -- Step 13 - set permissions and log files"
useradd -g =uid -u 901 -s /bin/ksh -d /var/mailserv _mailserv
echo "_mailserv   ALL=(ALL) NOPASSWD: SETENV: ALL" >> /etc/sudoers

cd /var/mailserv/admin && chown -R _mailserv:_mailserv log db public tmp
cd /var/mailserv/admin/public && chown _mailserv:_mailserv javascripts stylesheets
cd /var/mailserv/account && chown -R _mailserv:_mailserv log public tmp
cd /var/mailserv/account/public && chown _mailserv:_mailserv javascripts stylesheets

touch /var/log/imap 2> /dev/null
chgrp _dovecot /usr/local/libexec/dovecot/dovecot-lda
chmod 4750 /usr/local/libexec/dovecot/dovecot-lda

touch /var/log/imap_webmin 2> /dev/null
touch /var/log/maillog_webmin 2> /dev/null
touch /var/log/messages_webmin.log 2> /dev/null

chmod 644 /var/log/imap_webmin
chmod 644 /var/log/maillog_webmin
chmod 644 /var/log/messages_webmin.log

echo " -- Step 14 - setup packet filter"
touch /etc/badhosts 2> /dev/null
install -m 644 $TEMPLATES/pf.conf /etc
/sbin/pfctl -f /etc/pf.conf

echo " -- Step 15 - setup ruby"
ln -sf /usr/local/bin/ruby21 /usr/local/bin/ruby
ln -sf /usr/local/bin/erb21 /usr/local/bin/erb
ln -sf /usr/local/bin/irb21 /usr/local/bin/irb
ln -sf /usr/local/bin/rdoc21 /usr/local/bin/rdoc
ln -sf /usr/local/bin/ri21 /usr/local/bin/ri
ln -sf /usr/local/bin/rake21 /usr/local/bin/rake
ln -sf /usr/local/bin/gem21 /usr/local/bin/gem
ln -sf /usr/local/bin/testrb21 /usr/local/bin/testrb

/usr/local/bin/gem install rails -V
ln -sf /usr/local/bin/rails21 /usr/local/bin/rails

/usr/local/bin/gem install bundler -V
ln -sf /usr/local/bin/bundle21 /usr/local/bin/bundle
ln -sf /usr/local/bin/bundler21 /usr/local/bin/bundler

/usr/local/bin/gem install fastercsv -V

echo " -- Step 16 - setup god"
mkdir -p /etc/god
install -m 644 $TEMPLATES/fs/god/* /etc/god

echo " -- Step 17 - tune system"
install -m 644 $TEMPLATES/*syslog.conf /etc
install -m 644 $TEMPLATES/login.conf /etc
install -m 644 $TEMPLATES/rrdmon.conf /etc
install -m 644 $TEMPLATES/daily.local /etc
install -m 644 $TEMPLATES/monthly.local /etc
install -m 600 $TEMPLATES/crontab_root /var/cron/tabs/root

/usr/local/bin/ruby -pi -e '$_.gsub!(/\/var\/spool\/mqueue/, "Mail queue")' /etc/daily

echo "root: |/usr/local/share/mailserv/sysmail.rb" >> /etc/mail/aliases
/usr/bin/newaliases >/dev/null 2>&1

echo " -- Step 18 - setup roundcube"
/var/mailserv/scripts/install_roundcube
/usr/local/bin/mysqladmin create webmail
/usr/local/bin/mysql webmail < /var/www/roundcubemail/SQL/mysql.initial.sql
/usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"
cp /var/mailserv/admin/public/favicon.ico /var/www/roundcubemail/

echo " -- Step 19 - nginx"
install -m 644 $TEMPLATES/nginx.conf /etc/nginx/
/usr/sbin/rcctl enable nginx
/usr/sbin/rcctl set nginx flags -u
/usr/sbin/rcctl start nginx

echo " -- Step 20 - setup awstats"
/var/mailserv/scripts/install_awstats

################################ NEED TO BE CORRECTED ################################
exit 0

/usr/local/bin/rake -s -f /var/mailserv/admin/Rakefile system:update_hostname RAILS_ENV=production

echo " -- Step 21 - create databases"
/usr/local/bin/mysql -e "grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';"
/usr/local/bin/mysql -e "grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';"
cd /var/mailserv/admin && /usr/local/bin/rake -s db:setup RAILS_ENV=production
cd /var/mailserv/admin && /usr/local/bin/rake -s db:migrate RAILS_ENV=production
/usr/local/bin/mysql mail < /var/mailserv/install/templates/sql/mail.sql
/usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql
/usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb
}

function SetAdmin {
rake -s -f /var/mailserv/admin/Rakefile  mailserv:add_admin
}

DoTheJob
# SetAdmin
