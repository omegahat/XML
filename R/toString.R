toString.XMLNode <-
function(x, ...)
{
  # .tempXMLOutput = ""  # Put here for codetools to detect the variable locally.
  con <- textConnection(".tempXMLOutput", "w", local = TRUE)
  on.exit(close(con))
  sink(con)
  print(x)
  sink()
  paste(textConnectionValue(con), collapse="\n")
}
