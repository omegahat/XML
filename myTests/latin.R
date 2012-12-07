library(XML)
x = htmlParse("http://www.omegahat.org/RSXML/encoding/foo.htm")
v = xmlValue(xmlRoot(x)[["body"]][["p"]])

v
Encoding(v)

u = "http://www.omegahat.org/RSXML/encoding/latin.txt"
a = readLines(u)
b = readLines(u, encoding = "latin1")
a
b

Encoding(a) = "latin1"

