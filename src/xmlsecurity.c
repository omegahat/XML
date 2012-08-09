#ifdef HAVE_LIBXMLSEC
#include <xmlsec/xmlsec.h>
#include <xmlsec/app.h>
#include <xmlsec/crypto.h>

#include "Rinternals.h"

void
R_xmlSecCryptoInit(int *els)
{
    int status;

    els[0] = status = xmlSecCryptoInit();
    if(status != 0)
	return;

    els[1] = status = xmlSecCryptoAppInit(NULL);
    if(status != 0)
	return;

    els[2] = status = xmlSecCryptoInit();
}

SEXP
R_xmlSecCryptoShutdown()
{
    int status;
    status = xmlSecCryptoShutdown();
    return(ScalarInteger(status));
}
#else
static int foo;
#endif
