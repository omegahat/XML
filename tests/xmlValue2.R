library(XML)
x <- '<OMA>
   <OMS cd="arith1" name="plus"/>
   <OMV name="x"/>
   <OMI>2</OMI>
  </OMA>'

v <- xmlTreeParse(x, asText = TRUE)
r <- xmlRoot(v)
xmlValue(r)  # "2"

xmlValue(r, recursive = FALSE) # character(0)

v <- xmlParse(x, asText = TRUE)
r <- xmlRoot(v)
xmlValue(r)   # "2"
xmlValue(r, recursive = FALSE)  # character()
