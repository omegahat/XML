xmlEventParse(system.file("exampleData", "mathml.xml", package = "XML"),
               handlers = list(comment = function(x){cat("In comment\n")},
                               startElement = function(name, attrs) cat("generic startElement", name, "\n"),
                               endElement = function(name)  cat("generic endElement", name, "\n"),
                               msup = function(name, attrs) cat("start <msup>\n"),
                               "/msup" = function(name) cat("end of <msup>\n"),
                               "/mi" = function(name) cat("end of <mi>\n")))
