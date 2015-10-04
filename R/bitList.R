bitlist =
  # Taken from RAutoGenRuntime
function(...)
{
  x = unlist(list(...))
  if(length(x) == 1)
    return(x)

  ans = x[1]
  for(i in 2:length(x)) {
    ans = bitops::bitOr(ans, x[i])
  }
  ans
}
