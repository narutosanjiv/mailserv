# Mailserv for OpenBSD 5.7 - under active development

To install (from a fresh OpenBSD 5.7) :

<pre>
export PKG_PATH=http://ftp2.fr.openbsd.org/pub/OpenBSD/5.7/packages/$(machine)/
pkg_add git   
cd /var && git clone https://github.com/wesley974/mailserv.git
sh ./mailserv/install/install.sh
</pre>
