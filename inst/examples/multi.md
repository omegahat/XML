For multi.xml

multi.xml
 + B.xml
    + C.xml
 + Y.xml
    + B.xml
	   + C.xml
    + A.xml
	   + B.xml
	     + C.xml
 + other (xpointer)



```r
library(XML)
m = xmlParse("multi.xml")
invisible(fixDocXIncludes(m))
getNodeLocation(getNodeSet(m, "//C"))
```
