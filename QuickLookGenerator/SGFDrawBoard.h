//
//  SGFDrawBoard.h
//  SGFTools
//
//  Created by John Mifsud on 1/15/10.
//  This class implements a class that draws a go board.
//
// The MIT License
//
// Copyright (c) 2010 SGF Tools Developers
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
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>

#import "SGFGoban.h"


#define DEFAULT_BOARD_NSCOLOR [NSColor colorWithDeviceRed:0.968 green:0.704 blue:0.382 alpha:1.000]
#define DEFAULT_WHITE_NON_FLAT_STONE_NSCOLOR [NSColor colorWithDeviceRed:0.78 green:0.78 blue:0.78 alpha:1.000]


@interface SGFDrawBoard : NSObject {
    // number of intersections on board in each dimention
    unsigned size;
    
    // bounds within which board will be drawn
    NSRect bounds;
    
    // size of each intersection/location in graphic coords
    CGFloat locationWidth;
    
    BOOL flatStyle;
    CFBundleRef cfBundle;
}

@property (assign, nonatomic) unsigned size;
@property (assign, nonatomic) BOOL flatStyle;
@property (assign, nonatomic) CFBundleRef cfBundle;

- (id) initWithBoardSize:(unsigned)newSize;

- (void) setBounds:(NSRect)newBounds;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// The following drawXxxx functions expect the current graphics context to be a 
// flipped coordinate space!

// draw a complete game position (board, grid, stones)
// position string must be in the format produced by [SGFGoban getPositionString]
- (void) drawPosition:(NSString*)position;

- (void) drawBoardColor:(NSColor*)color;
- (void) drawGrid;

// location is a 2 letter string that describes an intersection on the board in sgf style
- (void) drawStoneAtLocation:(NSString*)location color:(NSColor*)color;
- (void) drawStoneAtPoint:(NSPoint)point color:(NSColor*)color;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// location is a 2 letter string that describes an intersection on the board in sgf style
// returns graphics coords for upper-left point of board location
- (NSPoint) getPointForLocation:(NSString*)location;

// here x & y are board intersection coords, not graphics coords
// returns graphics coords for upper-left point of board intersection x,y
- (NSPoint) getPointForX:(unsigned)x Y:(unsigned)y;

// returns graphics coords for center point of board intersection x,y
- (NSPoint) getCenterPointForX:(unsigned)x Y:(unsigned)y;
    
@end
