// The MIT License
//
// Copyright (c) 2009 SGF Tools Developers
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
%include {
// The MIT License
//
// Copyright (c) 2009 SGF Tools Developers
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include "sgf_parser.h"
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
}

%name SGFParser
%token_type { sgf_token * }
%token_prefix TK_
%extra_argument { sgf_parser *p }

%parse_accept {
}

%type begintree { void* }
%type beginnode { void* }
%type propertylist { void* }
%type property { void* }
%type propertyid { void* }
%type propertyvalue { void* }

sgf ::= collection.

collection ::= gametree. {
}
collection ::= collection gametree. {
}

gametree ::= begintree(T) sequence ENDTREE. {
    if (p->end_tree)
        p->end_tree(p, T);
}
gametree ::= begintree(T) sequence collection ENDTREE. {
    if (p->end_tree)
        p->end_tree(p, T);
}

begintree(T) ::= BEGINTREE. {
    if (p->begin_tree)
        T = p->begin_tree(p);
}

sequence ::= node. {
}
sequence ::= sequence node. {
}

node ::= beginnode(N). {
    if (p->end_node)
        p->end_node(p, N);
}
node ::= beginnode(N) propertylist. {
    if (p->end_node)
        p->end_node(p, N);
}

beginnode(N) ::= NODE. {
    if (p->begin_node)
        N = p->begin_node(p);
}

propertylist ::= property. {
}
propertylist ::= propertylist property. {
}

property ::= propertyid propertyvalues. {
    //p->cur_prop = NULL;
}

propertyid(P) ::= PROPERTYID(I). {
    if (p->property)
        P = p->cur_prop = p->property(p, I->data, I->length);
}

propertyvalues ::= propertyvalue. {
}
propertyvalues ::= propertyvalues propertyvalue. {
}

propertyvalue ::= BEGINVALUE PROPERTYVALUE ENDVALUE. {
    if (p->property_push_value)
        p->property_push_value(p, p->cur_prop);
}

