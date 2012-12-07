#include <libxml/tree.h>
#include <string.h>

void
testAddChild(int *len)
{
    xmlNodePtr n, txt1, txt2;
    n = xmlNewNode(NULL, "bob");

    txt1 = xmlNewText("foo");
    txt2 = xmlNewText("bar");
    xmlAddChild(n, txt1);
    xmlAddChild(n, txt2);

    strlen(n->name);
    *len = strlen(n->children->content);
}
