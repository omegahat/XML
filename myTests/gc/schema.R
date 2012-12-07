library(XML)
gctorture()
xsd = xmlTreeParse(system.file("exampleData", "author.xsd", package = "XML"), isSchema =TRUE, useInternal = TRUE)
doc = xmlInternalTreeParse(system.file("exampleData", "author.xml",  package = "XML"))
xmlSchemaValidate(xsd, doc)

xmlSchemaValidate(xsd, system.file("exampleData", "author2.xml",  package = "XML"))
