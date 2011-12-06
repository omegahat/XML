library(XML)

url <- paste("http://www.nsf.gov/awardsearch/progSearch.do?ProgFoaCode=&Search=Search&ProgEleCode=1320&BooleanRef=false&RestrictExpired=on&ProgOrganization=&page=2&SearchType=progSearch&BooleanElement=false&ProgProgram=&ProgRefCode=&QueryText=&d-49653-p=", 3, "&ProgOfficer=", sep = "")

replicate(100, htmlParse(url))
