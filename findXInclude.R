library(XML)
doc = xmlParse("book.xml")
rc = getNodeSet(doc, "//r:code | //r:function", "r")

x = findXInclude(rc[[161]])

# But this should be in ParseXML.xml at line 923.
# So the line number is correct, but the file name is incorrect.
