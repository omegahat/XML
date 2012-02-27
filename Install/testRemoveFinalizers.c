#include <Rdefines.h>

void
foo()
{
 void *p = NULL;
 R_RemoveExtPtrWeakRef_direct(p);
}

