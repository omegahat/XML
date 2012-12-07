#include <libxml/parser.h>

int
main(int argc, char *argv[])
{
    char *filename = "test.xml";
    xmlDocPtr doc;

    if(argc > 1)
	filename = argv[1];

    xmlSubstituteEntitiesDefault(1);   

    doc = xmlParseFile(filename);

    return(doc == NULL);
}
