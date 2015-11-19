#!/bin/sh
# Last changes : 2015/11/18, Wesley MOUEDINE ASSABY
# Contact me at  milo974 at gmail dot com
# The RubyOnRails app (web admin) : under active development by joshsoftware - www.joshsoftware.com

TEMPLATES=/var/mailserv/install/templates

export PKG_PATH=http://ftp2.fr.openbsd.org/pub/OpenBSD/5.8/packages/$(machine)/

function DoTheJob {

mkdir -p /var/db/spamassassin
mkdir -p /etc/awstats
mkdir -p /var/mailserv/mail
mkdir -p /usr/local/share/mailserv

install $TEMPLATES/fs/bin/* /usr/local/bin/
install $TEMPLATES/fs/sbin/* /usr/local/sbin/
install $TEMPLATES/fs/mailserv/* /usr/local/share/mailserv

echo " -- Step 1 - install packages"

pkg_add awstats roundcubemail ImageMagick mariadb-server php-mysql-5.6.11 php-pdo_mysql-5.6.11 php-fpm-5.6.11p0 \
    php-intl-5.6.11 xcache gtar-1.28p1 clamav postfix-3.0.2-mysql p5-Mail-SpamAssassin nginx-1.9.3p3 \
    dovecot-mysql dovecot-pigeonhole sqlgrey ruby-2.2.2p0 sudo-1.8.14.3 p5-libwww


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

echo " -- Step 4 - set ntpd"
/usr/sbin/rcctl set ntpd flags -s
/usr/sbin/rcctl restart ntpd

echo " -- Step 5 - setup Mariadb-Server"
/usr/local/bin/mysql_install_db > /dev/null 2>&1
mv /etc/my.cnf /etc/examples/
sed '/\[mysqld\]/ a\
    bind-address    = 127.0.0.1
    ' /etc/examples/my.cnf > /etc/my.cnf
/usr/sbin/rcctl enable mysqld
/usr/sbin/rcctl start mysqld

echo " -- Step 6 - setup php"
ln -sf /etc/php-5.6.sample/intl.ini /etc/php-5.6/intl.ini
ln -sf /etc/php-5.6.sample/mcrypt.ini /etc/php-5.6/mcrypt.ini
ln -sf /etc/php-5.6.sample/mysql.ini /etc/php-5.6/mysql.ini
ln -sf /etc/php-5.6.sample/pdo_mysql.ini /etc/php-5.6/pdo_mysql.ini
ln -sf /etc/php-5.6.sample/pspell.ini /etc/php-5.6/pspell.ini
ln -sf /etc/php-5.6.sample/zip.ini /etc/php-5.6/zip.ini
ln -fs /etc/php-5.6.sample/xcache.ini /etc/php-5.6/xcache.ini
ln -sf /usr/local/bin/php-5.6 /usr/local/bin/php
echo "allow_url_fopen = On" >> /etc/php-5.6.ini
install -m 644 $TEMPLATES/php-fpm.conf /etc
/usr/sbin/rcctl enable php_fpm
/usr/sbin/rcctl start php_fpm

echo " -- Step 7 - setup postfix"
/usr/local/sbin/postfix-enable
mkdir -p /etc/postfix/sql
install -m 644 $TEMPLATES/postfix/sql/* /etc/postfix/sql/
install -m 644 $TEMPLATES/postfix/* /etc/postfix
/usr/sbin/rcctl enable postfix
/usr/sbin/rcctl start postfix

echo " -- Step 8 - setup spamassassin"
install -m 644 $TEMPLATES/spamassassin_local.cf /etc/mail/spamassassin/local.cf
/usr/sbin/rcctl enable spamassassin
/usr/sbin/rcctl start spamassassin
/usr/local/bin/sa-update -v

echo " --Step 9 - setup clamav"
install -m 644 $TEMPLATES/*clam* /etc 2> /dev/null

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

/usr/sbin/rcctl enable freshclam
/usr/sbin/rcctl enable clamd
/usr/sbin/rcctl enable clamav_milter
/usr/sbin/rcctl start freshclam
/usr/sbin/rcctl start clamd
/usr/sbin/rcctl start clamav_milter

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
touch /var/log/imap 2> /dev/null
chgrp _dovecot /usr/local/libexec/dovecot/dovecot-lda
chmod 4750 /usr/local/libexec/dovecot/dovecot-lda
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
ln -sf /usr/local/bin/ruby22 /usr/local/bin/ruby
ln -sf /usr/local/bin/erb22 /usr/local/bin/erb
ln -sf /usr/local/bin/irb22 /usr/local/bin/irb
ln -sf /usr/local/bin/rdoc22 /usr/local/bin/rdoc
ln -sf /usr/local/bin/ri22 /usr/local/bin/ri
ln -sf /usr/local/bin/rake22 /usr/local/bin/rake
ln -sf /usr/local/bin/gem22 /usr/local/bin/gem

/usr/local/bin/gem install bundler
ln -sf /usr/local/bin/bundle22 /usr/local/bin/bundle
ln -sf /usr/local/bin/bundler22 /usr/local/bin/bundler

echo " -- Step 16 - tune system"
install -m 644 $TEMPLATES/*syslog.conf /etc
install -m 644 $TEMPLATES/login.conf /etc
install -m 644 $TEMPLATES/daily.local /etc
# install -m 600 $TEMPLATES/crontab_root /var/cron/tabs/root
/usr/local/bin/ruby -pi -e '$_.gsub!(/\/var\/spool\/mqueue/, "Mail queue")' /etc/daily
echo "root: |/usr/local/share/mailserv/sysmail.rb" >> /etc/mail/aliases
/usr/bin/newaliases >/dev/null 2>&1

echo " -- Step 17 - setup roundcube"
/usr/local/bin/mysqladmin create webmail
/usr/local/bin/mysql webmail < /var/www/roundcubemail/SQL/mysql.initial.sql
/usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"
cp /var/mailserv/admin/public/favicon.ico /var/www/roundcubemail

echo " -- Step 18 - setup nginx"
install -m 644 $TEMPLATES/nginx.conf /etc/nginx/
/usr/sbin/rcctl enable nginx
/usr/sbin/rcctl set nginx flags -u
/usr/sbin/rcctl start nginx

#echo " -- Step 19 - rake task"
#/usr/local/bin/rake -s -f /var/mailserv/admin/Rakefile system:update_hostname RAILS_ENV=production

#echo " -- Step 20 - setup awstats"
#/var/mailserv/scripts/install_awstats

echo " -- Step 19 - create databases"
/usr/local/bin/mysql -e "grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';"
/usr/local/bin/mysql -e "grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';"

# cd /var/mailserv/admin && /usr/local/bin/rake -s db:setup RAILS_ENV=production
# cd /var/mailserv/admin && /usr/local/bin/rake -s db:migrate RAILS_ENV=production
# /usr/local/bin/mysql mail < /var/mailserv/install/templates/sql/mail.sql
# /usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql
# /usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb


}

function SetAdmin {
# rake -s -f /var/mailserv/admin/Rakefile  mailserv:add_admin
}

DoTheJob
# SetAdmin
