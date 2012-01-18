library(RGCCTranslationUnit)
tu = parseTU("libxml2.c.001t.tu")

enums = getEnumerations(tu)
renums = lapply(enums, resolveType, tu)

parseErrors = renums$xmlParserErrors@values
domainErrors = renums$xmlErrorDomain@values
names(domainErrors) = gsub("XML_FROM_", "", names(domainErrors))

con = file("../Src/XMLRErrorInfo.R", "w")

cat("XMLParseErrors <-\n", file = con)
dput(parseErrors, con)
cat("\n\n\nXMLDomainErrors <-\n" , file = con)
dput(domainErrors, con)

close(con)
