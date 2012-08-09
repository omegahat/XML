#include "SUtils.h"

/*
 Utilities for the S facilities for parsing XML text.

 * See Copyright for the license status of this software.

 */

#include "RSCommon.h"

/* 

   We need this to get the definition for the symbolic constant FUN_CALL which is the type of the
   vector we need to allocate to create an invokable/evaluable function call.
   This is not what one would consider robust, but it is available in both S4 and Splus5. 

*/
#include "y.tab.h"

USER_OBJECT_
RS_XML(invokeFunction)(USER_OBJECT_ fun, USER_OBJECT_ opArgs, USER_OBJECT_ data)
{
 S_EVALUATOR
 s_object *ans = S_void;
 s_object *call, **args;
 int i;
 int numArgs;

  numArgs = GET_LENGTH(opArgs);

  call = alcvec(FUN_CALL, numArgs + 1 + (data ? 1 : 0), S_evaluator);
  args = RECURSIVE_DATA(call);

  args[0] = fun;
  for(i = 0;  i < numArgs ; i++) {
    args[i+1] = RECURSIVE_DATA(opArgs)[i];
  }
  if(data)
	  args[numArgs + 1] = data;

  incr_ref_count(call, FALSE, Local_data, S_evaluator);
  ans = eval(call, S_evaluator);
  decr_ref_count(call, FALSE, Local_data, S_evaluator);

  return(ans);
}


USER_OBJECT_
RS_XML(findFunction)(const char *opName, USER_OBJECT_ _userObject) 
{ 
  int i, n;
  USER_OBJECT_ fun = NULL;

  /* lookup function in  */
  USER_OBJECT_ names = GET_NAMES(_userObject);
  n = GET_LENGTH(names);

  for (i = 0; i < n; i++) {
      if(!strcmp(opName, CHAR_DEREF(CHARACTER_DATA(names)[i]))) {
          fun = RECURSIVE_DATA(_userObject)[i];
          break;
      }
  }
  return(fun);
}

int
isFunction(USER_OBJECT_ obj)
{
    return( IS(obj, s_function_class) || TYPEOF(obj) == CLOSXP);
}
