# This returns 42 entries and they are garbage.
d = xmlParse(system.file("exampleData", "job.xml", package = "XML"))
d["//namespace::*"]


