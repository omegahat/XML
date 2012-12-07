test<-function(){
	sep=""
	xmlText <-""
	xmlText <-paste(xmlText,"<spectrum id=\"3257\">",sep=sep)
	xmlText <-paste(xmlText,"<mzArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<data>Monday</data>",sep=sep)
	xmlText <-paste(xmlText,"</mzArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<intenArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<data>Tuesday</data>",sep=sep)
	xmlText <-paste(xmlText,"</intenArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"</spectrum>",sep=sep)
	xmlText <-paste(xmlText,"<spectrum id=\"3259\">",sep=sep)
	xmlText <-paste(xmlText,"<mzArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<data>Wednesday</data>",sep=sep)
	xmlText <-paste(xmlText,"</mzArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<intenArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"<data>Thursday</data>",sep=sep)
	xmlText <-paste(xmlText,"</intenArrayBinary>",sep=sep)
	xmlText <-paste(xmlText,"</spectrum>",sep=sep)

	xmlEventParse(xmlText, asText=TRUE,
                      handlers = list(text = function(x, ...) {
                                                 cat(nchar(x),x, "\n")
                                             }))
      	return(invisible(NULL))
}

