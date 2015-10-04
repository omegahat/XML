library(XML)
doc = xmlParse("<doc><a>This</a><a>this</a><a>bob</a></doc>")
ans = getNodeSet(doc, "//a[contains(lower-case(.), 'this')]")
ans = getNodeSet(doc, "//a[contains(lower-case(string(.)), 'this')]")

doc = xmlParse("<doc><a>This and that</a><a>this and the other</a><a>bob</a></doc>")
ans = getNodeSet(doc, "//a[matches(., '[Tt]his')]")


doc = xmlParse("<doc><a>This and that</a><a>this and the other</a><a>bob</a></doc>")
ans = getNodeSet(doc, "//a[ends-with(., 'at')]")

docName(doc) = "bob"
ans = getNodeSet(doc, "//a[base-uri() = '<buffer>']")

doc = xmlParse('<doc><p age="-10"/><p age="12"/><p age="-7"/><p age="3"/></doc>')
getNodeSet(doc, "//p[abs(@age) < 8]")
#getNodeSet(doc, "//p/abs(@age)")




doc = xmlParse('<doc><p age="10"/><p age="12"/><p age="7"/></doc>')
getNodeSet(doc, "//p[@age  = min(//p/@age)]")
getNodeSet(doc, "//p[@age  = max(//p/@age)]")


doc = xmlParse("<doc><a>This and that</a><a>this and the other</a><a>bob</a></doc>")
replace =
function(input, pattern, replacement, flags = "")
{
   gsub(pattern, replacement, input)
}
getNodeSet(doc, "//a[contains(replace(string(.), 'other', 'that'), 'that')]", xpathFuns = list("replace"))







