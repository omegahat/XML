doc = xmlInternalTreeParse("~/Projects/org/omegahat/XML/RS/tests/xpathNS.xml")
getNodeSet(doc, "//r:func")

 # Fails because it tries to make the namespace prefix r refer to the the default name space which is
 # actually http://www.omegahat.org and so get no match.
getNodeSet(doc, "//r:func", "r")


if(FALSE) {
doc = xmlInternalTreeParse("~/eutils.wsdl")
root = xmlRoot(doc)
xpathApply(root, "//xs:schema")

 # Fails because it tries to make xs the default name space which is
 # actually
xpathApply(root, "//xs:schema", namespaces = "xs")
}
