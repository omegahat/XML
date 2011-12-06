This chapter works for R, S-Plus 5 and S-Plus 6.

This uses either or both of the libxml and expat
libraries for performing the parsing. (We might
add support for using Xerces from the Apache project
in the future.)

There is now a configuration script that works for both R and S-Plus.
It determines that appropriate parameters for the compilation and
installation and performs the initialization steps.  One customizes
the installation by specifying values for the different options.
You can find out what these options are via the command
  ./configure --help

The current options are
  --with-splus      indicates that we are compiling for use with S-Plus rather than
                    R. To specify a specific instance of S-Plus, give the name of the
                    executable with which to start S-Plus, e.g.
                        --with-splus=/usr/local/bin/Splus5
  --with-libxml     use libxml as a parser (on by default)
  --with-libxml2    allows one to explicitly control whether version 1 or 2 of libxml
                    is used. This is computed internally, by default.
  --with-expat      use Jim Clark's expat SAX-based parser for event parser (off by default).



Having configured the package, you can then compile and install it.

Type 
    make
which compiles the C code and sources the S code.
    make install



Patching libxml
===============

The libxml parsing library has a routine named attribute() and so does
Splus 5 and 6. This causes major problems when running the XML chapter
within S-Plus. You need to change the name of the attribute() routine
within the SAX.c file of the libxml distribution. The patch contained
in libxml/PATCH.attribute within this package's distribution does this.

The makefile in libxml/ can be used to apply the patch also (depending on
the version of libxml against which it is being applied).
Simply invoke make as follows
      gmake libxmlpatch

What the patch does is to rename the attribute routine definition and
both references to it in the file SAX.c. These three locations are the
only references to attribute. (One could potentially just make it a
static routine.)



