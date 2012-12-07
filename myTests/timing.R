library(XML)

f = "~/jstatsoft.xml"

if(!file.exists(f))
  stop("Can't find file ", f)

  # Basic time

basic.time = t(replicate(50, system.time(xmlTreeParse(f))))


  # Compare this with a function that just returns the node it self
  # So we measure the cost of a function call for each node.
function.time = t(replicate(50, system.time(xmlTreeParse(f, handlers = list(startElement = function(x) x)))))


hashTree.time = t(replicate(50, system.time({tt = xmlHashTree(); xmlTreeParse(f, handlers = tt[[".addNode"]])})))

# median(hashTree.time[,1])/median(function.time[,1])
# Result is a factor of 25.

 # This is the very basic, slow tree.
 # When testing, we might want to use gcinfo(TRUE) to see how often we get
 # the garbage collector kicking in.
tt = XML:::xmlFlatTree()
flatTree.time = system.time(xmlTreeParse(f, handlers = tt[[".addNode"]]))

 # This is the one that preallocates space.
tt = XML:::xmlFlatListTree()
flatExpandingTree.time = system.time({xmlTreeParse(f, handlers = tt[[".addNode"]]); tt[[".tidy"]]})


