//
//  SGFImporter.h
//  SGFImporter
//
//  Created by Jason Foreman on 7/19/09.
//  Copyright 2009 Breeding Pine Trees. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SGFImporter : NSObject
{
    NSStringEncoding _textEncoding;
    NSMutableData *_data;
    NSMutableDictionary *_attributes;
    NSString *_currentProperty;
}

@property (assign) NSStringEncoding textEncoding;
@property (retain) NSMutableData *data;
@property (retain) NSMutableDictionary *attributes;
@property (copy) NSString *currentProperty;

- (id)initWithAttributeDictionary:(NSMutableDictionary*)attributes;

- (BOOL)importFileAtPath:(NSString*)path;

@end
