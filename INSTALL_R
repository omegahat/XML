This is an R package. You should have installed this in one of 
the directories referenced by the environment variable R_LIBS
or .lib.loc.


Compile this with a command of the form

  make  CC=gcc LIBEXPAT=... LIBXML=... R_HOME=/wherever_R_distribution

specifying values for either or both of LIBXML and LIBEXPAT
as the directories where each was installed.
On Solaris, you can specify CC=cc.

This assumes that certain shared libraries are built:
 a)  $LIBXML/libxml.so for the libxml distribution,

 b)  libxmlparse.so and libxmltok.so in $LIBEXPAT/lib 
    for the expat distribution.

You can compile with either or both of these distributions.
The makefiles in the subdirectories expat/ and libxml/ of this one
can be used to create the corresponding one. To install these
makefiles into the appropriate distribution, you can use the make
targets expat and libxml, e.g.  

       make expat LIBEXPAT=/dir/subdir/...

The compiler defaults to gcc. R_HOME defaults to ../..

All of this requires GNU make.

For more details, see http://www.omegahat.org/download/xml/


Duncan Temple Lang  (Dec 4 1999)
