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

/*
 Version History:
 1.2:	First release that implemented "all" properties/attrs.
 
 1.2.1: Within an hour of releasing 1.2 I found a bug in the DT code that
		caused the importer to crash on incomplete dates, this ver
		fixes that.
 
 1.2.2:	Added Year Played attr because for many old games only this part of
		the date is known. In contrast to the Date Played attr this one is
		a plain CFNumber.
 
		Further improved the handling of DT prop to Date Played attr conv.
 
		Replaced call to deprecated stringWithCString:length: in do_property()
		(I hate seeing warnings for a good build)
 
		Added Winner & Loser attrs derrived from the RE PW PB props as
		suggested by Anders.
 
		Fixed memory leaks in do_property() & appendString:forKey:
 */

#import "SGFImporter.h"

#include "sgf_parser.h"


NSString *gameName[] = {
	@"Go", @"Othello", @"Chess", @"omoku+Renju", @"Nine Men's Morris",
	@"Backgammon", @"Chinese Chess", @"Shogi", @"Lines of Action", @"Ataxx",
	@"Hex", @"Jungle", @"Neutron", @"Philosopher's Football", @"Quadrature", 
	@"Trax", @"Tantrix", @"Amazons", @"Octi", @"Gess", 
	@"Twixt", @"Zertz", @"Plateau", @"Yinsh", @"Punct", 
	@"Gobblet", @"Hive", @"Exxit", @"Hnefatal", @"Kuba", 
	@"Tripples", @"Chase", @"Tumbling Down", @"Sahara", @"Byte", 
	@"Focus", @"Dvonn", @"Tamsk", @"Gipf", @"Kropki"
};

static int MAX_GAMENAME = (sizeof(gameName)/sizeof(NSString *));



@interface SGFImporter ()
- (void)doProperty:(NSString*)propertyName;
- (void)doPushValue;
- (void)doData:(const char *)data length:(size_t)length;
@end


void *do_property(sgf_parser *p, const char *name, size_t length)
{
    SGFImporter *imp = p->context;
	
	// we really need to think carefully about how to properly handle 
	// different encodings
	NSString *property = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    [imp doProperty:[property substringToIndex:length]];
	[property release];
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

- (void) setNumberOnce:(NSString *)value forKey:(NSString *)key
{	// only stores the first value for key
	if (![self.attributes objectForKey:key])
	{
		[self.attributes setObject:[NSNumber numberWithDouble:[value doubleValue]] forKey:key];
	}
}

- (void) setStringOnce:(NSString *)value forKey:(NSString *)key
{	// only stores the first value for key
	if (![self.attributes objectForKey:key])
	{
		[self.attributes setObject:value forKey:key];
	}
}

- (void) appendString:(NSString *)value forKey:(NSString *)key
{
	NSMutableString *text = [self.attributes objectForKey:key];
	
	if (!text)
	{
		NSMutableString *newval = [[NSMutableString alloc] initWithString:value];
		[self.attributes setObject:newval forKey:key];
		[newval release];
	}
	else
	{
		[text appendFormat:@" %@", value];
	}
}

- (void) addString:(NSString *)value toArrayforKey:(NSString *)key
{
	NSMutableArray *array = [self.attributes objectForKey:key];
	
	if (!array)
	{
		[self.attributes setObject:[NSMutableArray arrayWithObject:value] forKey:key];
	}
	else
	{
		[array addObject:value];
	}
}

- (void) determineWinnerAndLoser
{
	// If the Winner attr hasn't already been set, then
	// if the Result, White Player, and Black Player 
	// fields have all been set then determine &
	// store the Winner & Loser attrs
	
	if (![self.attributes objectForKey:@"com_breedingpinetrees_sgf_winner"])
	{
		NSMutableString *result = [self.attributes objectForKey:@"com_breedingpinetrees_sgf_result"];
		NSMutableString *white = [self.attributes objectForKey:@"com_breedingpinetrees_sgf_white"];
		NSMutableString *black = [self.attributes objectForKey:@"com_breedingpinetrees_sgf_black"];
		
		if (result && white && black && ([result length] >= 2))
		{
			NSString *winner, *loser;
			if (NSOrderedSame == [result compare:@"W+" options:NSCaseInsensitiveSearch range:NSMakeRange(0,2)])
			{
				winner = white;
				loser = black;
			}
			else 
			{
				winner = black;
				loser = white;
			}
			
			[self.attributes setObject:[NSString stringWithString:winner] forKey:@"com_breedingpinetrees_sgf_winner"];
			[self.attributes setObject:[NSString stringWithString:loser] forKey:@"com_breedingpinetrees_sgf_loser"];
		}
	}
}

- (void) doPushValue;
{
    NSString *value = [[[NSString alloc] initWithData:self.data encoding:self.textEncoding] autorelease];
	
    if ([@"US" isEqualToString:self.currentProperty])
    {
		[self addString:value toArrayforKey:(NSString*)kMDItemAuthors];
    }
    else if ([@"CA" isEqualToString:self.currentProperty])
    {
        if ([@"UTF-8" isEqualToString:value])
            self.textEncoding = NSUTF8StringEncoding;
        // TODO other encodings
    }
    else if ([@"FF" isEqualToString:self.currentProperty])
    {
        [self setStringOnce:value forKey:(NSString*)kMDItemVersion];
    }
    else if ([@"AP" isEqualToString:self.currentProperty])
    {
        [self setStringOnce:value forKey:(NSString*)kMDItemCreator];
    }
    else if ([@"CP" isEqualToString:self.currentProperty])
    {
        [self setStringOnce:value forKey:(NSString*)kMDItemCopyright];
    }
    else if ([@"GN" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemTitle];
    }
    else if ([@"GC" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemDescription];
    }
	else if ([@"RE" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemHeadline];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_result"];
		[self determineWinnerAndLoser];
    }
	else if ([@"EV" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemCoverage];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_event"];
    }
	else if ([@"PC" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemNamedLocation];
    }
    else if ([@"PW" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemParticipants];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_white"];
		[self determineWinnerAndLoser];
	}
    else if ([@"PB" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemParticipants];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_black"];
		[self determineWinnerAndLoser];
	}
    else if ([@"WR" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_whiterank"];
	}
    else if ([@"BR" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_blackrank"];
	}
    else if ([@"BT" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemParticipants];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_blackteam"];
	}
    else if ([@"WT" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemParticipants];
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_whiteteam"];
	}
    else if ([@"AN" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemContributors];
	}
    else if ([@"SO" isEqualToString:self.currentProperty])
	{ 
		[self addString:value toArrayforKey:(NSString*)kMDItemPublishers];
	}
	else if ([@"C" isEqualToString:self.currentProperty] || [@"N" isEqualToString:self.currentProperty])
    {
        value = [value stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
		
        [self appendString:value forKey:(NSString*)kMDItemTextContent];
    }
	else if ([@"DT" isEqualToString:self.currentProperty])
    {
        [self appendString:value forKey:(NSString*)kMDItemTextContent];
		if (![self.attributes objectForKey:@"com_breedingpinetrees_sgf_dateplayed"])
		{
			value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			value = [value stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
			value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			value = [[value componentsSeparatedByCharactersInSet:
					  [NSCharacterSet characterSetWithCharactersInString:@" ,~"]] objectAtIndex:0];
			if ([value length] == 10)  // "1980-01-01"
			{   // NSDate dateWithString is very picky! must have exact format or bombs.  :(
				value = [NSString stringWithFormat:@"%@ 12:00:00 +0000", value];
				[self.attributes setObject:[NSDate dateWithString:value] forKey:@"com_breedingpinetrees_sgf_dateplayed"];
			}
			
			if ([value length] >= 4)  // "1980"
			{
				[self setNumberOnce:[value substringToIndex:4] forKey:@"com_breedingpinetrees_sgf_yearplayed"];
			}
		}
    }
    else if ([@"ON" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_opening"];
	}
    else if ([@"OT" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_overtime"];
	}
    else if ([@"RO" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_round"];
	}
    else if ([@"RU" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_ruleset"];
	}
    else if ([@"OH" isEqualToString:self.currentProperty])
	{ 
        [self setStringOnce:value forKey:@"com_breedingpinetrees_sgf_oldhandicap"];
	}
	else if ([@"TM" isEqualToString:self.currentProperty])
    {
        [self setNumberOnce:value forKey:(NSString*)kMDItemDurationSeconds];
    }
    else if ([@"HA" isEqualToString:self.currentProperty])
	{ 
        [self setNumberOnce:value forKey:@"com_breedingpinetrees_sgf_handicap"];
	}
    else if ([@"KM" isEqualToString:self.currentProperty])
	{ 
        [self setNumberOnce:value forKey:@"com_breedingpinetrees_sgf_komi"];
	}
    else if ([@"SZ" isEqualToString:self.currentProperty])
	{ 
        [self setNumberOnce:value forKey:@"com_breedingpinetrees_sgf_size"];
	}
	else if ([@"GM" isEqualToString:self.currentProperty])
    {
		if (![self.attributes objectForKey:@"com_breedingpinetrees_sgf_gametype"])
		{
			NSString *name;
			int gm = [value intValue] - 1;
			if ((gm >= 0) && (gm < MAX_GAMENAME)) 
			{
				name = gameName[gm];
			}
			else
			{
				name = @"unknown";
			}
			
			[self.attributes setObject:name forKey:@"com_breedingpinetrees_sgf_gametype"];
		}
    }
	
    [self.data setLength:0];
}

- (void)doData:(const char *)data length:(size_t)length;
{
    [self.data appendBytes:data length:length];
}

@end
