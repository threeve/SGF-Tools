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
 
#include <stdlib.h>

#include "sgf_parser.h"
#include "sgfparse.h"

// Lemon-generated methods
extern void *SGFParserAlloc(void *(*)(size_t));
extern void SGFParserFree(void *, void (*)(void*));
extern void SGFParser(void *, int, sgf_token*, sgf_parser *);

sgf_token *sgf_token_create(int id, size_t length, const char *data)
{
    sgf_token *token = (sgf_token*)calloc(1, sizeof(sgf_token));
    token->ID = id;
    token->length = length;
    token->data = data;
    return token;
}

#define TK(T, L, D) do { \
    sgf_token *tk = sgf_token_create(TK_##T, L, D); \
    SGFParser(p->y, TK_##T, tk, p); } while (0);

#define BUF(S, E) if (p->property_data) p->property_data(p, S, E);

%%{
    machine sgf;

    access p->;
    variable p data;

    property_id= [A-Z] [A-Z]?;
    escape = '\\' any;
    value = (any - '\\' - ']') | escape;

    property_value := |*
        # ideally value+, but that could require an infinite buffer...
        value{1,512} => { BUF(p->ts, p->te-p->ts); };
        ']' => { 
            TK(PROPERTYVALUE, 0, 0);
            fhold; fgoto main;
            };
    *|;

    main := |*
        '(' => { TK(BEGINTREE, 0, 0); };
        ')' => { TK(ENDTREE, 0, 0); };
        ';' => { TK(NODE, 0, 0); };
        property_id => { TK(PROPERTYID, p->te - p->ts, p->ts); };
        '[' => { TK(BEGINVALUE, 0, 0); fgoto property_value; };
        ']' => { TK(ENDVALUE, 0, 0); };
        '\r'? '\n';
        '\t';
        ' ';

    *|;

    write data;

}%%

int sgf_parser_init(sgf_parser *p)
{
    %% write init;

    // TODO init lemon parser
    p->y = SGFParserAlloc(malloc);

    return 1;
}

int sgf_parser_stop(sgf_parser *p)
{
    return p->cs == %%{ write first_final; }%%;
}

int sgf_parser_finish(sgf_parser *p)
{
    // indicate EOF
    p->left = 0; p->off = 0; p->ts = 0; p->te = 0;
    sgf_parser_execute(p, NULL, 0, 0);

    // TODO cleanup/leftovers
    if (p->cs == %%{ write first_final; }%%)
    {
        SGFParser(p->y, 0, 0, p);
    }

    SGFParserFree(p->y, free);
    return 0;
}

size_t sgf_parser_execute(sgf_parser *p, const char *data, size_t length, off_t offset)
{
    size_t result = 0;
    data += offset;
    const char *pe = data + length;
    const char *eof = 0; // TODO is this right?
    if (!length)
        eof = pe;


    if (p->off || p->left)
    {
        p->ts = data;
        p->te = p->ts + p->off;
        data += p->left;
    }

    // EXEC
    %% write exec;

    if (p->ts)
    {
        p->off = p->te - p->ts;
        p->left = pe - p->ts;
        result = length - p->left;
    }
    else
    {
        p->off = 0;
        p->left = 0;
        result = length;
    }

    return result;
}

