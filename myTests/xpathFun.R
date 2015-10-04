library(XML)
doc = xmlParse("<doc><a>This and that</a></doc>")
doit =
function(a, b, c, d, ...)
{
   browser()
   TRUE
}

#ans = getNodeSet(doc, "//a[doit()]", xpathFuns = list("doit"))
ans = getNodeSet(doc, "//a[doit('[Tt]his', position(), true(), false(), 'tt')]", xpathFuns = list("doit"))
# string(.)



