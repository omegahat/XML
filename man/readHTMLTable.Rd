\name{readHTMLTable}
\alias{readHTMLTable}
\alias{readHTMLTable,character-method}
\alias{readHTMLTable,HTMLInternalDocument-method}
\alias{readHTMLTable,XMLInternalElementNode-method}
\alias{coerce,character,FormattedInteger-method}
\alias{coerce,character,FormattedNumber-method}
\alias{coerce,character,Percent-method}
\alias{coerce,character,Currency-method}
\alias{FormattedInteger-class}
\alias{FormattedNumber-class}
\alias{Percent-class}
\title{Read data from one or more HTML tables}
\description{
 This function and its methods provide somewhat robust methods for
 extracting data from HTML tables in an HTML document.
 One can read all the tables in a document given by filename or URL,
 or having already parsed the document via \code{\link{htmlParse}}.
 Alternatively, one can specify an individual \code{<table>}
 node in the document.

 The methods attempt to do some heuristic computations to determine
 the header labels for the columns, the name of the table, etc.
}
% xmlName(node) == "table" && ("thead" \%in\% names(node) || length(getNodeSet(node, "./tr[1]/th")) > 0)
\usage{
readHTMLTable(doc, header = NA,
              colClasses = NULL, skip.rows = integer(), trim = TRUE,
              elFun = xmlValue, as.data.frame = TRUE, which = integer(),
               ...)
}
\arguments{
  \item{doc}{the HTML document which can be a file name or a URL
    or an already parsed \code{HTMLInternalDocument}, or
    an HTML node of class \code{XMLInternalElementNode},
    or a character vector containing the HTML content to parse and process.}
  \item{header}{either a logical value indicating whether the table has
    column labels, e.g. the first row or a \code{thead}, or alternatively
    a character vector giving the names to use for the resulting columns.
   This can be a logical vector and the individual values will be used
   in turn for the different tables. This allows the caller to control
   whether individual tables are processed as having column names.
   Alternatively, one can read a specific table via the \code{which}
   parameter and control how that is processed with a single scalar logical.
  }
  \item{colClasses}{either a list or a vector that gives the names of
    the data types for the different columns in the table, or
    alternatively a function used to convert the string values to the
    appropriate type.  A value of \code{NULL} means that we should drop
    that column from the result.
    Note that currently the conversion occurs before the
    vectors are converted to a data frame (if \code{as.data.frame} is
    \code{TRUE}).
    As a result, to ensure that character vectors remain as characters
    and not factors, use \code{stringsAsFactors = FALSE}.
    This typically applies only to an individual table and so for the
    method applied to a \code{XMLInternalElementNode} object.

    In addition to the usual "integer", "numeric", "logical", "character", etc.
    names of R data types, one can use
    "FormattedInteger", "FormattedNumber" and "Percent" to specify that
    format of the values are numbers possibly with commas (,) separating
    groups of digits or a number followed by a percent sign (\%).
    This mechanism allows one to introduce new classes and specify these
    as targets in \code{colClasses}.
   }
  \item{skip.rows}{an integer vector indicating which rows to ignore.}
  \item{trim}{a logical value indicating whether to remove leading and
 trailing white space from the content cells.}
  \item{elFun}{a function which, if specified, is called when converting
     each cell. Currently, only the node is specified. In the future, we might 
     additionally pass the index of the column so that the function has
    some context, e.g. whether the value is a row label or a regular
    value, or if the caller knows the type of columns.
  }
  \item{as.data.frame}{a logical value indicating whether to turn the
    resluting table(s) into data frames or leave them as matrices.
  }
  \item{which}{an integer vector identifying which tables to return from
    within the document. This applies to the method for the document, not
     individual tables.}
   \item{\dots}{currently additional parameters that are passed on to
     \code{\link{as.data.frame}} if \code{as.data.frame} is \code{TRUE}.
    We may change this to use these as additional arguments for calls to
 \code{elFun}.}
}
\value{
  If the document (either by name or parsed tree) is specified,
  the return vale is a list of data frames or matrices.
  If a single HTML node is provided
}
\references{
HTML4.0 specification  
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{htmlParse}}
  \code{\link{getNodeSet}}
  \code{\link{xpathSApply}}    
}
\examples{
# u = "http://en.wikipedia.org/wiki/World_population"
 u = "http://en.wikipedia.org/wiki/List_of_countries_by_population"
 
 tables = readHTMLTable(u)
 names(tables)

 tables[[2]]
  # Print the table. Note that the values are all characters
  # not numbers. Also the column names have a preceding X since
  # R doesn't allow the variable names to start with digits.
 tmp = tables[[2]]


   # Let's just read the second table directly by itself.
 doc = htmlParse(u)
 tableNodes = getNodeSet(doc, "//table")
 tb = readHTMLTable(tableNodes[[2]])

  # Let's try to adapt the values on the fly.
  # We'll create a function that turns a th/td node into a val
 tryAsInteger = function(node) {
                  val = xmlValue(node)
                  ans = as.integer(gsub(",", "", val))
                  if(is.na(ans))
                      val
                  else
                      ans
                }

 tb = readHTMLTable(tableNodes[[2]], elFun = tryAsInteger)

 tb = readHTMLTable(tableNodes[[2]], elFun = tryAsInteger,
                       colClasses = c("character", rep("integer", 9)))


  zz = readHTMLTable("http://www.inflationdata.com/Inflation/Consumer_Price_Index/HistoricalCPI.aspx")
  if(any(i <- sapply(zz, function(x) if(is.null(x)) 0 else ncol(x)) == 14)) {  # guard against the structure of the page changing.
    zz = zz[[which(i)[1]]]  # 4th table
        # convert columns to numeric.  Could use colClasses in the call to readHTMLTable()
    zz[-1] = lapply(zz[-1], function(x) as.numeric(gsub(".* ", "", as.character(x))))
    matplot(1:12, t(zz[-c(1, 14)]), type = "l")
  }


# From Marsh Feldman on R-help
doc <- "http://www.nber.org/cycles/cyclesmain.html"
     # The  main table is the second one because it's embedded in the page table.
table <- getNodeSet(htmlParse(doc),"//table") [[2]]   
xt <- readHTMLTable(table,
                    header = c("peak","trough","contraction",
                               "expansion","trough2trough","peak2peak"),
                    colClasses = c("character","character","character",
                                   "character","character","character"),
                    trim = TRUE, stringsAsFactors = FALSE
                   )


if(FALSE) {
 # Here is a totally different way of reading tables from HTML documents.
 # The data are formatted using a PRE and so can be read via read.table
 u = "http://tidesonline.nos.noaa.gov/data_read.shtml?station_info=9414290+San+Francisco,+CA"
 h = htmlParse(u)
 p = getNodeSet(h, "//pre")
 con = textConnection(xmlValue(p[[2]]))
 tides = read.table(con)
}


if(require(RCurl) && url.exists("http://www.omegahat.org/RCurl/testPassword/table.html")) {
  tt =  getURL("http://www.omegahat.org/RCurl/testPassword/table.html",  userpwd = "bob:duncantl")
  readHTMLTable(tt)
}
}
\keyword{IO}
\keyword{data}

