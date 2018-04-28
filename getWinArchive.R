version="2.9.8"

message("Looking for libxml2 binary libraries and headers")

d = file.path("archive", sprintf("libxml2-%s", version))
if(!file.exists(d)) {

  if(!file.exists("archive"))
     dir.create("archive")

   message("Downloading libxml2 libraries and headers from RWinLib")
   download.file("https://github.com/rwinlib/libxml2/archive/v2.9.8.zip", "archive/libxml2.zip")
   setwd("archive")
   system("unzip libxml2.zip")
} else {
   message("Using previously downloaded libxml2 archive in ", d)
}

