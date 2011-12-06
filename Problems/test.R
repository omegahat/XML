library(XML)
library(caTools)
MakeSpektrumEntry <- function(){
  p <- base64decode(.GlobalEnv$peaks, "double", endian = "big", size=4)
  np <- length(p)%/%2
  dim(p) <- c(2, np)
  mass <- p[1, ]
  intensity <- p[2, ]
  relmass <- mass - precursorMz
  subSetter <- relmass > -25 & relmass < 5
  if(sum(subSetter) > 0){
    .GlobalEnv$mass <- c(.GlobalEnv$mass,mass[subSetter])
    .GlobalEnv$intensity <- c(.GlobalEnv$intensity,intensity[subSetter])
  }
}

mass <- c()
intensiyt <- c()
fileName <- paste("test",".mzXML",sep="")
ms2Scan <- FALSE
fetchPrecMz <- FALSE
fetchPeaks <- FALSE
scanDone <- FALSE
scanNum <- NA
precursorMz <- ""
peaks <- ""
xmlEventParse(fileName,
  handlers=list(
    startElement=function(name, attrs){
      if(name == "scan"){
	if(.GlobalEnv$ms2Scan == TRUE & .GlobalEnv$scanDone == TRUE){
	  cat(.GlobalEnv$scanNum,"\n")
	  MakeSpektrumEntry()
	}
	.GlobalEnv$scanDone <- FALSE
	.GlobalEnv$fetchPrecMz <- FALSE
	.GlobalEnv$fetchPeaks <- FALSE
	.GlobalEnv$ms2Scan <- FALSE
	if(attrs[["msLevel"]] == "2"){
	  .GlobalEnv$ms2Scan <- TRUE
	  .GlobalEnv$scanNum <- as.integer(attrs[["num"]])
	}
      } else if(name == "precursorMz" & .GlobalEnv$ms2Scan == TRUE){
	.GlobalEnv$fetchPrecMz <- TRUE
      } else if(name == "peaks" & .GlobalEnv$ms2Scan == TRUE){
	.GlobalEnv$fetchPeaks <- TRUE
      }
    },
    text=function(text){
      if(.GlobalEnv$fetchPrecMz == TRUE){
	.GlobalEnv$precursorMz <- as.numeric(text)
	.GlobalEnv$fetchPrecMz <- FALSE
      } else if(.GlobalEnv$fetchPeaks == TRUE){
	.GlobalEnv$peaks <- text
	.GlobalEnv$fetchPeaks <- FALSE
	.GlobalEnv$scanDone <- TRUE
      }
    }
  ),
  trim=FALSE
)

