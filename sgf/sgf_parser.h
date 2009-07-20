/**
 * Copyright (c) 2009 Jason Foreman
 */

#ifndef SGF_PARSER_H_
#define SGF_PARSER_H_

#include <sys/types.h>

struct sgf_parser;
struct sgf_token;

typedef void *(*sgf_begin_tree_handler)(struct sgf_parser *p);
typedef void  (*sgf_end_tree_handler)(struct sgf_parser *p, void *tree);
typedef void *(*sgf_begin_node_handler)(struct sgf_parser *p);
typedef void  (*sgf_end_node_handler)(struct sgf_parser *p, void *node);
typedef void *(*sgf_property_handler)(struct sgf_parser *p, const char *name, size_t name_length);
typedef void  (*sgf_property_push_value)(struct sgf_parser *p, void *prop);
typedef void  (*sgf_property_data_handler)(struct sgf_parser *p, const char *data, size_t length);

typedef struct sgf_parser
{
    // TODO all but the callbacks should be internal only

    // Ragel variables
    int cs;
    const char *ts;
    const char *te;
    int act;
    size_t off;
    size_t left;

    // Lemon parser instance
    void *y;

    // state
    void *cur_tree;
    void *cur_node;
    void *cur_prop;

    // callback methods
    sgf_begin_tree_handler begin_tree;
    sgf_end_tree_handler end_tree;
    sgf_begin_node_handler begin_node;
    sgf_end_node_handler end_node;
    sgf_property_handler property;
    sgf_property_push_value property_push_value;
    sgf_property_data_handler property_data;
    
    // user data
    void *context;

} sgf_parser;

typedef struct sgf_token
{
    int ID;
    size_t length;
    const char *data;
} sgf_token;

int sgf_parser_init(sgf_parser *parser);
int sgf_parser_finish(sgf_parser *parser);
size_t sgf_parser_execute(sgf_parser *parser, const char *buffer, size_t length, off_t offset);

#endif
