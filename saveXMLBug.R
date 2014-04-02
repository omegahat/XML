library("XML")
concepts <- c("español", "português")
info <- c("info about español", "info about português")

doc <- newXMLDoc()
root <- newXMLNode("tips", doc = doc)
for (i in 1:length(concepts)) {
  cur.concept <- concepts[i]
  cur.info <- info[i]
  cur.tip <- newXMLNode("tip", attrs = c(id = i), parent = root)
  newXMLNode("h1", cur.concept, parent = cur.tip)
  newXMLNode("p", cur.info, parent = cur.tip)
}

# accented vowels don't come through correctly, but the indents are correct:
cat(saveXML(doc, indent = TRUE, encoding = "UTF-8"))
saveXML(doc, indent = TRUE, encoding = "UTF-8", file = "/tmp/bob.xml")

cat(saveXML(doc, indent = TRUE, encoding = "UTF-8"), file = "/tmp/bob1.xml")
