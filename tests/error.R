xmlTreeParse("<doc><a> & < <?pi > </doc>")

tryCatch(xmlTreeParse("<doc> <a> </doc>", asText = TRUE), error = function(e) print(class(e)))

tryCatch(xmlTreeParse("<doc> <a> </doc>", asText = TRUE),
                      error = function(e) print(class(e)))



