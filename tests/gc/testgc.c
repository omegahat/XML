#include "Rinternals.h"

typedef struct {
    int ctr; 
} A;

A a;

void
R_decrement_a(SEXP r)
{
  A *tmp = (A *)  R_ExternalPtrAddr(r);
  if(tmp) {
      tmp->ctr--;
      R_ClearExternalPtr(r);
  }
}


SEXP
R_getA()
{
   SEXP ans;
   a.ctr++;
   PROTECT(ans = R_MakeExternalPtr(&a, Rf_install("A"), R_NilValue));
   R_RegisterCFinalizer(ans, R_decrement_a);
   UNPROTECT(1);
   return(ans);
}

SEXP
R_getACount()
{
    return(ScalarInteger(a.ctr));
}
