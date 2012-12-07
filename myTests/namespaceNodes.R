foo = newXMLNode("r:foo", namespaceDefinitions = c(r = "http://www.r-project.org"))


WordXMLNamespaces = c(
      r = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',  
      w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
      v = 'urn:schemas-microsoft-com:vml'
  )

height = width = 100
id = 10
style = "abc"
img = "image.jpeg"

system.time(
replicate(1000, {
 style = paste(c("width", "height"), c(width, height), sep = ":", collapse = ";")
 img = newXMLNode("w:pict", namespaceDefinitions = WordXMLNamespaces)
 sh = newXMLNode("v:shape", attrs = c(id = id, type = "#_x0000_t75", style = style), parent = img)
 x = newXMLNode("v:imageData", attrs = c('r:id' = id), parent = sh)
}))
