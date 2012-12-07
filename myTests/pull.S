library(XML)

f = 
function(fileName = "/tmp/philosophy.xml")
{
  if(!is(fileName, "connection"))
    con = file(fileName, "r")
  else
    con = fileName

  if(!isOpen(con)) {
     open(con, "r")
   }


  ctr = 0
  function(len) {
     ctr <<- ctr + 1
     cat("Line", ctr, "\n")
     val = readLines(con, n = 1)
     if(length(val) == 0)
        return(val)
     paste(val, "\n", sep = "")
  }
}  

tagCounter = 
function()
{
  nameCounts = numeric()

  start =
    function(name, ...) {
        nameCounts[name] <<- 1 + ifelse(name %in% names(nameCounts), nameCounts[name], 0)
    }
  list(startElement = start,
       counts = function() nameCounts)
}  

if(FALSE) {
 tt = tagCounter()
 xmlEventParse(f(), handlers = tt)

 tt = tagCounter() 
 xmlEventParse(file("/tmp/philosophy.xml"), handlers = tt) 
}
