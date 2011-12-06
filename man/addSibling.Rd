
\name{getSibling}
\alias{getSibling}
\alias{addSibling}

\title{Manipulate sibling XML nodes}

\description{ 
     These functions allow us to both access the sibling node
     to the left or right of a given node and so walk the chain
     of siblings, and also to insert a new sibling
   }

\usage{
getSibling(node, after = TRUE, ...)
addSibling(node, ..., kids = list(...), after = NA)
}

\arguments{
   \item{node}{the internal XML node (XMLInternalNode) 
             whose siblings are of interest}
   \item{\dots}{the XML nodes to add as siblings or children to node.}
   \item{kids}{a list containing the XML nodes to add as siblings.
     This is equivalent to ... but used when we already have the
      nodes in a list rather than as individual objects. This is used in programmatic
      calls to 
     \code{addSibling}
    rather interactive use where we more commonly have
      the individual node objects.
    }
   \item{after}{a logical value indicating whether to retrieve or add the 
      nodes to the right (\code{TRUE}) or to the left (\code{FALSE}) of this sibling.
   }
   }

\value{
    
     \code{getSibling}
    returns an object of class
      XMLInternalNode (or some derived S3 class, e.g. XMLInternalTextNode)
    
    
     \code{addSibling}
    returns a list whose elements are the newly added
     XML (internal) nodes.
   }

\seealso{
     \code{\link{xmlChildren}},
     \code{\link{addChildren}}
      \code{\link{removeNodes}}
      \code{\link{replaceNodes}}
   }

\examples{
  
          # Reading Apple's iTunes files
     # 
     #           Here we read  a "censored" "database" of songs from Apple's  iTune application
     #           which is stored in a property list.  The format is quite generic and 
     #            the fields for each song are given in the form
     #           
     #             <key>Artist</key><string>Person's name</string>
     # 	  
     #           So to find the names of the artists for all the songs, we want to 
     #           find all the <key>Artist<key> nodes and then get their next sibling
     #           which has the actual value.
     #         
     #           More information can be found in .
     # 	
           fileName = system.file("exampleData", "iTunes.plist", package = "XML")

           doc = xmlParse(fileName)
           nodes = getNodeSet(doc, "//key[text() = 'Artist']")
           sapply(nodes, function(x)  xmlValue(getSibling(x)))
	

      f = system.file("exampleData", "simple.xml", package = "XML")
      tt = as(xmlParse(f), "XMLHashTree") 

       tt

      e = getSibling(xmlRoot(tt)[[1]])
        # and back to the first one again by going backwards along the sibling list.
      getSibling(e, after = FALSE)


         # This also works for multiple top-level "root" nodes
      f = system.file("exampleData", "job.xml", package = "XML")
      tt = as(xmlParse(f), "XMLHashTree")
       x = xmlRoot(tt, skip = FALSE)
       getSibling(x)
       getSibling(getSibling(x), after = FALSE)
}

\keyword{IO}
