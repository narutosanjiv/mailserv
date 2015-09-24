# Mailserv for the last OpenBSD release : 

To install (from a fresh OpenBSD 5.7):<br>
<code>export PKG_PATH=http://ftp2.fr.openbsd.org/pub/OpenBSD/5.7/packages/$(machine)/</code>  
<code>pkg_add git</code>    
<code>cd /var && git clone https://github.com/wesley974/mailserv.git</code>  
<code>sh ./mailserv/install/install.sh</code>
