# Or should we look at R CMD build gitRepos
# and then compare.

d1 = "XML"
d2 = "CRAN/XML"
d3 = "Mine/XML"

f1 = list.files(d1, full = TRUE, recursive = TRUE)
f1 = f1[!grepl(".git/", f1)]
f1 = f1[!grepl(".o$", f1)]
f1 = f1[!grepl("~$", f1)]

tmp = list.files(d1, full = TRUE)
d1.dirs = tmp[file.info(tmp)$isdir]
tmp = list.files(d2, full = TRUE)
d2.dirs = tmp[file.info(tmp)$isdir]
tmp = list.files(d3, full = TRUE)
d3.dirs = tmp[file.info(tmp)$isdir]

f2 = list.files(d2, full = TRUE, recursive = TRUE)
f3 = list.files(d3, full = TRUE, recursive = TRUE)

f1 = gsub("^[^/]+/", "", f1)
f2 = gsub(paste0("^", d2, "/"), "", f2)
f3 = gsub(paste0("^", d3, "/"), "", f3)
# f2 = gsub("^[^/]+/[^/]+/", "", f2)

extra.dirs = setdiff(basename(d3.dirs), basename(d2.dirs))
rx = sprintf("^(%s)/", paste(extra.dirs, collapse = "|"))
#f1 = f1[!grepl(rx, f1)]
f3 = f3[!grepl(rx, f3)]

common = intersect(f3, f2)
in.git = setdiff(f3, f2)
in.cran = setdiff(f2, f3)


diffs = lapply(common, function(f) system2('diff', c("--ignore-space-change", shQuote(file.path("Mine/XML", f)), shQuote(file.path("CRAN/XML", f))), stdout = TRUE))
names(diffs) = common
ndiff = sapply(diffs, length)

check = diffs[ndiff > 0]


nn = table(sapply(check, length))
sum(as.integer(names(nn)) * nn)

# CRAN toString.R
# git  toString.S

