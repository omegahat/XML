#
# Provided by Kurt Hornik to illustrate the (lack of) encoding of strings
# in R from a UTF-8 document.
#

require("XML")

r <- xmlTreeParse("iso_639_3.xml", encoding = "UTF-8")
r <- xmlRoot(r)
r <- split(r, names(r))
r$text <- r$comment <- NULL

r <- r[["iso_639_3_entry"]]
r <- lapply(r, xmlAttrs)
names(r) <- NULL
##
a <- c("id", "scope", "type", "name", "part1_code", "part2_code")
names(a) <- a
r <- lapply(a, function(e) unlist(lapply(r, "[", e), use.names = FALSE))
r <- as.data.frame(r, quote = "", stringsAsFactors = FALSE)

table(Encoding(r$name))

r$name[7680]
#[1] "Zapotec, Güilá"


