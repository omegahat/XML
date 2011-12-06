
\name{catalogLoad}
\alias{catalogLoad}
\alias{catalogClearTable}
\alias{catalogAdd}
\alias{catalogDump}

\title{Manipulate XML catalog contents}

\description{
   These functions allow the R user to programmatically control the 
   XML catalog table used in the XML parsing tools in the
   C-level libxml2 library and hence in R packages that use these, e.g.
   the XML and Sxslt packages.
   Catalogs are consulted whenever an external document needs to be loaded.
   XML catalogs allow one to influence how such a document is loaded
   by mapping document identifiers to 
   alternative locations, for example to refer to locally 
   available versions.
   They support mapping URI prefixes to local file directories/files,
   resolving both SYSTEM and PUBLIC identifiers used in DOCTYPE declarations at the 
   top of an XML/HTML document, and delegating resolution to other catalog files.
    Catalogs are written using an XML format.
 
   Catalogs allow resources used in XInclude nodes and XSL templates
   to refer to generic network URLs and have these be mapped to local files
   and so avoid potentially slow network retrieval. 
   Catalog files are written in XML 
   We might have a catalog file that contains the XML
   In the XDynDocs package, we  refer to OmegahatXSL files and 
    DocBook XSL files have a catalog file of the form 

   
   


   The functions provided here allow the R programmer to 
    empty the current contents of the global catalog table and so 
    start from scratch (
     \code{catalogClearTable}
   ), 
    load the contents of a catalog file into the global catalog table (
     \code{catalogLoad}
   ),
    and to add individual entries programmatically without the need for a catalog table.

   In addition to controlling the catalogs via these functions, we can 
   use \code{\link{catalogResolve}} to use the catalog
   to resolve the name of a resource and map it to a local resource.

   \code{catalogDump} allows us to retrieve an XML document representing the current
  contents of the in-memory catalog .
  
   More information can be found at
   \url{http://xmlsoft.org/catalog.html}
   and \url{http://www.sagehill.net/docbookxsl/Catalogs.html}
   among many resources and the specification for the catalog format at
    \url{http://www.oasis-open.org/committees/entity/spec-2001-08-06.html}.
   }

\usage{
catalogLoad(fileNames)
catalogClearTable()
catalogAdd(orig, replace, type = "rewriteURI")
catalogDump(fileName = tempfile(), asText = TRUE)
}

\arguments{
   \item{orig}{a character vector of identifiers, e.g. URIs, that are to be mapped to a different 
       name via the catalog.
       This can be a named character vector where the names are the original URIs and the values are the 
       corresponding rewritten values.
        }
   \item{replace}{a character vector of the rewritten or resolved values for the
        identifiers given in orig. Often this omitted and the 
         original-rewrite pairs are given as a named vector via orig.
   }
   \item{type}{a character vector with the same length as
      orig (or recycled to have the same length) which specifies
       the type of the resources in the elements of orig.
        Valid values are rewriteURI, rewriteSystem, system, public.
    }
   \item{fileNames}{a character vector giving the names of the 
       catalog files to load.}
  \item{fileName}{the name of the file in which to place the contents of the current catalog}
  \item{asText}{a logical value which indicates whether to write the catalog
   as a character string if \code{filename} is not specified.}
}

\value{
    These functions are used for their side effects on the global
    catalog table maintained in C by libxml2. Their return values are
    logical values/vectors indicating whether the particular operation
     were successful or not.
   }

\references{
     This provides an R-like interface to a small subset of the catalog API
     made available in libxml2.
   }

\seealso{
    
     \code{\link{catalogResolve}}
    
    
     XInclude, XSL and import/include directives.
    
    
     In addition to these functions, there is an un-exported, undocumented
     function named \code{catalogDump} that can be used to 
     get the contents of the (first) catalog table.
    
   }

\examples{
  
          # Add a rewrite rule
     # 
     # 	
          catalogAdd(c("http://www.omegahat.org/XML" = system.file("XML", package = "XML")))
          catalogAdd("http://www.omegahat.org/XML", system.file("XML", package = "XML"))
          catalogAdd("http://www.r-project.org/doc/", paste(R.home(), "doc", "", sep = .Platform$file.sep))
	
          # 
     #          This shows how we can load a catalog and then resolve a system identifier 
     #           that it maps.
     # 	
          catalogLoad(system.file("exampleData", "catalog.xml", package = "XML"))

	  catalogResolve("docbook4.4.dtd", "system")
	  catalogResolve("-//OASIS//DTD DocBook XML V4.4//EN", "public")
	
   
}

\keyword{IO}
