library(RGCCTranslationUnit)
tu = parseTU("libxml2.c.001t.tu")
e = getEnumerations(tu)
p = resolveType(e$xmlParserOption, tu)
