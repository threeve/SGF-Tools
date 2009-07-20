//
//  SGFImporter.m
//  SGFImporter
//
//  Created by Jason Foreman on 7/19/09.
//  Copyright 2009 Breeding Pine Trees. All rights reserved.
//

#import "SGFImporter.h"

#include "sgf_parser.h"


@interface SGFImporter ()
- (void)doProperty:(NSString*)propertyName;
- (void)doPushValue;
- (void)doData:(const char *)data length:(size_t)length;
@end


void *do_property(sgf_parser *p, const char *name, size_t length)
{
    SGFImporter *imp = p->context;
    [imp doProperty:[NSString stringWithCString:name length:length]];
    return NULL;
}

void do_push_value(sgf_parser *p, void *prop)
{
    SGFImporter *imp = p->context;
    [imp doPushValue];
}

void do_data(sgf_parser *p, const char *data, size_t length)
{
    SGFImporter *imp = p->context;
    [imp doData:data length:length];
}


@implementation SGFImporter

@synthesize data = _data;
@synthesize textEncoding = _textEncoding;
@synthesize attributes = _attributes;
@synthesize currentProperty = _currentProperty;


- (id)initWithAttributeDictionary:(NSMutableDictionary*)attributes;
{
    if ((self = [super init]))
    {
        self.attributes = attributes;
        self.textEncoding = NSISOLatin1StringEncoding;
        self.data = [NSMutableData data];
    }
    return self;
}

- (void)dealloc;
{
    self.attributes = nil;
    self.data = nil;
    self.currentProperty = nil;
    [super dealloc];
}

- (BOOL)importFileAtPath:(NSString*)path;
{
    NSData *data = [NSData dataWithContentsOfFile:(NSString*)path];
   
    if (!data)
        return NO;

    sgf_parser parser = { 0 };
    parser.property = do_property;              /*sgf_property_handler property;*/
    parser.property_push_value = do_push_value; /*sgf_property_push_value property_push_value;*/
    parser.property_data = do_data;             /*sgf_property_data_handler property_data;*/
    parser.context = self;
    sgf_parser *p = &parser;
    sgf_parser_init(p);
    sgf_parser_execute(p, [data bytes], [data length], 0);
    sgf_parser_finish(p);

    return YES;
}

- (void)doProperty:(NSString*)propertyName;
{
    self.currentProperty = propertyName;
}

- (void)doPushValue;
{
    NSString *value = [[[NSString alloc] initWithData:self.data encoding:self.textEncoding] autorelease];
    if ([@"US" isEqualToString:self.currentProperty])
    {
        [self.attributes setObject:[NSArray arrayWithObject:value] forKey:(NSString*)kMDItemAuthors];
    }
    else if ([@"CA" isEqualToString:self.currentProperty])
    {
        if ([@"UTF-8" isEqualToString:value])
            self.textEncoding = NSUTF8StringEncoding;
        // TODO other encodings
    }
    else if ([@"AP" isEqualToString:self.currentProperty])
    {
        [self.attributes setObject:value forKey:(NSString*)kMDItemCreator];
    }
    else if ([@"CP" isEqualToString:self.currentProperty])
    {
        [self.attributes setObject:value forKey:(NSString*)kMDItemCopyright];
    }
    else if ([@"GN" isEqualToString:self.currentProperty])
    {
        [self.attributes setObject:value forKey:(NSString*)kMDItemTitle];
    }
    else if ([@"GC" isEqualToString:self.currentProperty])
    {
        [self.attributes setObject:value forKey:(NSString*)kMDItemDescription];
    }
    else if ([@"PW" isEqualToString:self.currentProperty]
             || [@"PB" isEqualToString:self.currentProperty]
             || [@"RE" isEqualToString:self.currentProperty]
             || [@"EV" isEqualToString:self.currentProperty]
             || [@"C" isEqualToString:self.currentProperty]
        )
    {
        NSMutableString *textContent = [self.attributes objectForKey:(NSString*)kMDItemTextContent];
        if (!textContent)
        {
            textContent = [NSMutableString string];
            [self.attributes setObject:textContent forKey:(NSString*)kMDItemTextContent];
        }
        else
        {
            [textContent appendString:@" "];
        }
        value = [value stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [textContent appendString:value];
    }

    [self.data setLength:0];
}

- (void)doData:(const char *)data length:(size_t)length;
{
    [self.data appendBytes:data length:length];
}

@end
