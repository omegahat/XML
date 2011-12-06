library(XML)
url <- 'http://www.szitic.com/docc/jz-lmzq.html'
xml <- htmlTreeParse(url, useInternal=TRUE) # ,encoding="gb2312")
