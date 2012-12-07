getRelativeURL =
  #
  #  takes the name of a file/URL and a baseURL and 
  # figures out the URL for the new file given by u.
  # This handles the case where the file/URL is relative to the
  # the baseURL or if it is a fully qualified file or URL.

  #
  #  getRelativeURL("/foo", "http://www.omegahat.org")
  #  getRelativeURL("/foo", "http://www.omegahat.org/")
  #  getRelativeURL("foo", "http://www.omegahat.org/")
  #  getRelativeURL("http://www.foo.org", "http://www.omegahat.org/")
  #
  # XXX test - baseURL with /path/ and u as /other/path. Looks okay. See
  # ParsingStrategies example for kaggle.
  #
  # XXX not working for ../...
  #  fails
  #    getRelativeURL("../foo", "http://www.omegahat.org/a/b.html")
  # should be http://www.omegahat.org/foo
  # or at least http://www.omegahat.org/a/../foo
function(u, baseURL, sep = "/", addBase = TRUE)  
{
   if(length(u) > 1)
     return(sapply(u, getRelativeURL, baseURL, sep))
   
   pu = parseURI(u)
   #XXX Need to strip the path in baseURL if pu$path starts with /
   if(pu$scheme == "" && addBase) {
      b = parseURI(baseURL)
      b$path = ""
      b = as(b, "character")
      sprintf("%s%s%s", b, if(grepl("^/", pu$path)) "" else sep, u)
   } else
      u
}

xmlElementSummaryHandlers =
  #
  #  Functions for the event parser that we can use
  #  to count the occurrences of each tag and the attributes
function(file = character(), countAttributes = TRUE)
{
    # Collect a list of attributes for each element.
  tags = list()
    # frequency table for the element names
  counts = integer()
  
  start =
    function(name, attrs, ...) {

      if(name == "xi:include") {
          # need to handle the xpointer piece
          # and the relative path names - done with getRelativeURL
        href = getRelativeURL(attrs['href'], dirname(file), sep = .Platform$file.sep)
        xmlElementSummary(href, funs)
      }
      
      if(!countAttributes) 
        tags[[name]] <<-  unique(c(names(attrs), tags[[name]]))
      else {
        x = tags[[name]]
        i = match(names(attrs), names(x))
        if(any(!is.na(i)))
          x[i[!is.na(i)]] = x[i[!is.na(i)]] + 1
        if(any(is.na(i))) 
          x[names(attrs)[is.na(i)]] = 1
        tags[[name]] <<- x
      }
      
      counts[name] <<- if(is.na(counts[name])) 1 else counts[name] + 1
    }

  funs =
   list(.startElement = start, 
        .getEntity = function(x, ...) "xxx",
        .getParameterEntity = function(x, ...) "xxx",
        result = function() list(nodeCounts = sort(counts, decreasing = TRUE), attributes = tags))
}

xmlElementSummary =
function(url, handlers = xmlElementSummaryHandlers(url))
{
  handlers
  if(file.exists(url) && file.info(url)[1, "isdir"])
      url = list.files(url, pattern = "\\.xml$", full.names = TRUE)

  if(length(url) > 1)
     lapply(url, xmlElementSummary, handlers)
  else
     xmlEventParse(url, handlers, replaceEntities = FALSE)

  handlers$result()
}
