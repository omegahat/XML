if(FALSE) {
  # URL changed and the format of the data is now
  # via <li> elements.
  
  u = "http://weather.sfgate.com/auto/sfgate/geo/precip/index.html"
                                        # header as a logical vector
 tt = tryCatch(readHTMLTable(u,
                               header = c(FALSE, FALSE, TRUE, FALSE, FALSE)),
                "XML_IO_LOAD_ERROR"= function(err, ...) {
                                         cat("cannot connect to sfgate.com\n")
                                         NULL
                                     })

   #
 tt = tryCatch(readHTMLTable(u,
                               which = 3, header = TRUE),
                "XML_IO_LOAD_ERROR"= function(err, ...) {
                                         cat("cannot connect to sfgate.com\n")
                                         NULL
                                     })
}
