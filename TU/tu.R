
#
# R CMD INSTALL --configure-args='--with-in-perl=no --with-modules="IO Fcntl Socket POSIX"' RSPerl
# source ~/Rpackage/RSPerl/scripts.csh
#
#

library(RGCCTranslationUnit)
tu = parseTU("libxml2.c.001t.tu")
enums = getEnumerations(tu)
names(enums)

xmlEnums = grep("^xml", names(enums), value = TRUE)
enumDefs = lapply(xmlEnums, function(x) resolveType(enums[[x]], tu))
names(enumDefs) = xmlEnums

# XXX Guesses xmlEntityType as a bitwise and not a regular enumeration.
#   Probably fixed now, but is still heuristic.
# writeCode(enumDefs$xmlEntityType, "r")
# writeCode(enumDefs$xmlParserErrors, "r")

errorEnums = enumDefs[grep("Error", xmlEnums)]

con = file("../Src/xmlErrorEnums.R", "w")
cat("# Machine generated file. See org/omegahat/XML/RS/TU/tu.R\n", file = con)
cat("#", date(), "\n", file = con)
invisible(sapply(names(errorEnums), function(id) { cat(id, "<-", file = con) ; dput(errorEnums[[id]]@values, con); TRUE}))
close(con)



