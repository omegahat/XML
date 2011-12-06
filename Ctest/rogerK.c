#include <libxml/HTMLparser.h>
#include <stdio.h>

int 
main(int argc, char *argv[])
{
    const char *name = "http://www.nsf.gov/awardsearch/progSearch.do?ProgFoaCode=&Search=Search&ProgEleCode=1320&BooleanRef=false&RestrictExpired=on&ProgOrganization=&page=2&SearchType=progSearch&BooleanElement=false&ProgProgram=&ProgRefCode=&QueryText=&d-49653-p=3&ProgOfficer=";
    char *encoding = NULL;
    htmlDocPtr doc;
    int i, numRepeats = 100;

    for(i = 0; i < numRepeats; i++) {
	doc = htmlParseFile(name, encoding);
	fprintf(stderr, "Finished %d\n", i+1);
    }


    return(0);
}
