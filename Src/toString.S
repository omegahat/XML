toString.XMLNode <-
function(x, ...)
{
  .tempXMLOutput = ""  # Put here for codetools to detect the variable locally.
  con <- textConnection(".tempXMLOutput", "w", local = TRUE)
  sink(con)
  print(x)
  sink()
  close(con)
  paste(.tempXMLOutput, collapse="\n")
}  
