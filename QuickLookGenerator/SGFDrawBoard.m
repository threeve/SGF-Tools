//
//  SGFDrawBoard.m
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

#import "SGFDrawBoard.h"

#define DEFAULT_BOUNDS NSMakeRect(0.0, 0.0, 128.0, 128.0)
#define BOARD_WIDTH (locationWidth*size)

@interface SGFDrawBoard ()  // for private funcs
@end


@implementation SGFDrawBoard


- (unsigned) size {
    return size;
}

- (void) setSize:(unsigned)newSize {
    if ((newSize > 0) && (newSize <= MAX_BOARD_SIZE)) {
        size = newSize;
        locationWidth = bounds.size.height / (CGFloat)size;
    }
}


- (id)initWithBoardSize:(unsigned)newSize {
    if ((self = [super init]))
    {
        self.size = newSize;
        [self setBounds:DEFAULT_BOUNDS];
    }
    return self;
}


- (void) setBounds:(NSRect)newBounds {
    bounds = newBounds;
    locationWidth = bounds.size.height / (CGFloat)size;
}



- (void) drawPosition:(NSString*)position {
    unsigned boardSize;
    NSString *blackStones, *whiteStones;
    if (![SGFGoban getSize:&boardSize blackStones:&blackStones whiteStones:&whiteStones ofPosition:position]) {
        return;
    }
    self.size = boardSize;
    
    [self drawBoardColor:DEFAULT_BOARD_NSCOLOR];
    [self drawGrid];
        
    for (unsigned loc=0; loc < [blackStones length]; loc += 2) {
        [self drawStoneAtLocation:[blackStones substringWithRange:NSMakeRange(loc,2)] color:[NSColor blackColor]];
    }
     
    for (unsigned loc=0; loc < [whiteStones length]; loc += 2) {
        [self drawStoneAtLocation:[whiteStones substringWithRange:NSMakeRange(loc,2)] color:[NSColor whiteColor]];
    }
}


- (void) drawStoneAtLocation:(NSString*)location color:(NSColor*)color {
    [self drawStoneAtPoint:[self getPointForLocation:location] color:color];
}

- (void) drawStoneAtPoint:(NSPoint)point color:(NSColor*)color {
    NSRect srect;
    srect.origin = point;
    srect.size.width = locationWidth;
    srect.size.height = srect.size.width;
    
    [color setFill];
    [[NSBezierPath bezierPathWithOvalInRect:srect] fill];
}


- (void) drawBoardColor:(NSColor*)color {
    [color setFill];
    [NSBezierPath fillRect:NSMakeRect(0.0, 0.0, BOARD_WIDTH, BOARD_WIDTH)];
}


- (void) drawGrid {
    if (size < 2) {
        return;
    }
    
    CGFloat locCenter = locationWidth / 2.0;
    CGFloat gridSize = locationWidth * (size - 1);
    
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect:NSMakeRect(locCenter, locCenter, gridSize, gridSize)];
    
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    
    
    for (CGFloat x=locCenter+locationWidth; x < gridSize; x += locationWidth) {
        [gridPath moveToPoint:NSMakePoint(x, locCenter)];
        [gridPath lineToPoint:NSMakePoint(x, locCenter+gridSize)];
        
        [gridPath moveToPoint:NSMakePoint(locCenter, x)];
        [gridPath lineToPoint:NSMakePoint(locCenter+gridSize, x)];
    }
    [gridPath stroke];
}


- (NSPoint) getPointForX:(unsigned)x Y:(unsigned)y {
    CGFloat fx, fy;
    // FIX: need to properly scale & offset these!!!
    fx = (CGFloat)x*locationWidth;
    fy = (CGFloat)y*locationWidth;
    
    return NSMakePoint(fx, fy);
}

- (NSPoint) getPointForLocation:(NSString*)location {
    return [self getPointForX:[SGFGoban getColOf:location] Y:[SGFGoban getRowOf:location]];
}


@end
