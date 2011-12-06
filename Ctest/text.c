#include <libxml/tree.h>
int
main(int argc, char *argv[])
{
    xmlNodePtr kid, node;

    node = xmlNewNode(NULL, "top");

    kid = xmlNewText("foo");
    xmlAddChild(node, kid);
    kid = xmlNewText("bar");
    xmlAddChild(node, kid);

    return(0);
}
