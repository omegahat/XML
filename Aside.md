I have [forked libxml2](https://gitlab.gnome.org/duncantl/libxml2/-/tree/master) to introduce 2 very small but important changes related
to XInclude and the sentinel nodes that surround the included content.
This allows us to identify the original document source of each node.

I install this into ~/local and then prepend $HOME/local/lib to LDFLAGS in ~/.R/Makevars
