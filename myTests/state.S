library(XML)

genHandler =
function()
{
   ctr = 0
   list(startElement = function(...) {
                             ctr <<- ctr + 1
                       },
        value = function() ctr)
}  

f = system.file("exampleData", "charts.svg", package = "XML")

system.time({h = genHandler(); xmlEventParse(f, handlers = h); ctr = h$value()})

system.time(ctr <- xmlEventParse(f, list(startElement = function(name, atts, .state) { .state = .state + 1}), state = 0))



genHandler =
function()
{
   elementNames = list()
   list(startElement = function(name, attrs) {
                           elementNames[[length(elementNames) + 1]] <<- attrs
                       },
         value = function() elementNames)
}  

f = system.file("exampleData", "charts.svg", package = "XML")

system.time({h = genHandler(); xmlEventParse(f, handlers = h); ctr = h$value()})

system.time(ctr <- xmlEventParse(f, list(startElement = function(name, atts, .state) { .state[[length(.state)+1]] = atts; .state}), state = list()))

