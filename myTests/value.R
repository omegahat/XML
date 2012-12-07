ti = xmlParse("data/job.xml")
tt = as(xmlParse("data/job.xml"), "XMLHashTree")
tp = xmlTreeParse("data/job.xml")


xmlValue(xmlRoot(ti)[[1]][[1]][["Update"]])

xmlValue(xmlRoot(tt)[[1]][[1]][["Update"]])

xmlValue(xmlRoot(tp)[[1]][[1]][["Update"]])
