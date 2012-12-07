
doc = xmlTreeParse("<a>some text<!-- a comment --><?R processing instruction?></a>", asText = TRUE)

all(class(xmlRoot(doc)) == extends("XMLNode"))

all(class(xmlRoot(doc)[[1]]) == extends("XMLTextNode"))

all(class(xmlRoot(doc)[[2]]) == extends("XMLCommentNode"))

all(class(xmlRoot(doc)[[3]]) == extends("XMLProcessingInstruction"))


