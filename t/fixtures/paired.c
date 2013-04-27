#include <stdlib.h>

/* this is a comment
 * spanning not two
 * but three lines */
tEntry *find(tEntry **ht, uint32_t val)
{
    /*a short comment*/
    tEntry *te;
    unsigned int hi; /* end-of-line comment */

    /* this */ is invalid */
    hi = UCHASH(val, SIZE);

    /* this is a one-line */
    /* style comment */
    for (te = ht[hi]; te != NULL; te = te->nextEntry)
        if (te->val == val)
            /*   	*/
            return te;

    /*   this comment /* has /* 
     * many start /* leaders */

    return NULL;
    /**/

}
