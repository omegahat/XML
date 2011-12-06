# This illustrates collecting the text in XML nodes using
# xmlEventParse().  The key thing to remember is that
# our text handler function may be called several times for a single
# block of text within an XML node.  That is the XML parser may
# pass chunks/subsets of the text within a node to our function as
# it reads in blocks.   It does not have to pass all the text in
# one go.

# We use the global environment here to simplify the example.
# It is not a good idea to use global variables in this way. Instead,
# use a closure, i.e. functions with their own 
#

# We collect the blocks of text within a node in txt.
# When we encounter the end of the XML element, we
# put the current value of txt into textElements and reset it.

# The number of elements in txt and hence in each element of textElements
# at the end illustrates how many times our text handler was called for each node.
# i.e.  sapply(textElements, length)
#

textElements = list()
txt = character()

xmlEventParse("trim.xml",
               handlers = list(text = function(x) {
                                         cat(nchar(x), "\n")
                                         txt <<- c(txt, x)
                                       },
                                endElement = function(name) {
                                   if(length(txt))
                                     textElements[[length(textElements) + 1 ]] <<- txt
                                     names(textElements)[length(textElements)] <<- name
                                     txt <<- character()
                                     
                                }),
               trim = FALSE)
