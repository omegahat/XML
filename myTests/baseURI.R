library(XML)
doc = xmlParse("base.xml")
ans = getNodeSet(doc, "//p[contains(base-uri(.), 'base.xml')]")
ans1 = getNodeSet(doc, "//p[contains(base-uri(.), 'baseInclude')]")
