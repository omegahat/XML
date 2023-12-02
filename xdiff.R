# Yes - Should compare build of package from git repos and the CRAN package.
#

#
# In /tmp
# git clone
# R CMD build XML
# mkdir Mine
# cd Mine
# tar zxf ../XML_....tar.gz
#
# mkdir CRAN
# cd CRAN
# tar zxf ~/Downloads/XML_...tar.gz
#
#
# Won't look at d1,f1, ... as they are the git repos.

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
ndiff = sapply(check, length)

nn = table(ndiff)
sum(as.integer(names(nn)) * nn)


cat(paste(common[ndiff > 0], ndiff[ndiff > 0]) , sep = "\n", file  = "~/GitWorkingArea/XML/CranGitFileDiffs")

# CRAN toString.R
# git  toString.S

