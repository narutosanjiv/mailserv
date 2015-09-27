# Mailserv for the last OpenBSD release - under active development

To install (from a fresh OpenBSD 5.7) :

```sh
export PKG_PATH=http://ftp2.fr.openbsd.org/pub/OpenBSD/5.7/packages/$(machine)
pkg_add git   
cd /var && git clone https://github.com/wesley974/mailserv.git
sh ./mailserv/install/install.sh
```
