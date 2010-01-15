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

#import "SGFGoban.h"
#import "SGFDrawBoard.h"


@interface SGFDrawBoard ()
+ (NSPoint) getPointForLocation:(NSString*)location;
+ (NSPoint) getPointForX:(unsigned)x Y:(unsigned)y;
@end


@implementation SGFDrawBoard


+ (void) drawPosition:(NSString*)position inContext:(NSGraphicsContext*)context {
    if (!context) {
        return;
    }

    unsigned boardSize;
    NSString *blackStones, *whiteStones;
    if (![SGFGoban getSize:&boardSize blackStones:&blackStones whiteStones:&whiteStones ofPosition:position]) {
        return;
    }
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];

    // draw board
    
    // draw grid & hoshi
        
    // draw stones
    for (unsigned loc=0; loc < [blackStones length]; loc +=2) {
        [SGFDrawBoard drawStoneAtPoint:[SGFDrawBoard getPointForLocation:[blackStones substringWithRange:NSMakeRange(loc,2)]] 
                                 color:[NSColor blackColor]];
    }
    
    for (unsigned loc=0; loc < [whiteStones length]; loc +=2) {
        [SGFDrawBoard drawStoneAtPoint:[SGFDrawBoard getPointForLocation:[whiteStones substringWithRange:NSMakeRange(loc,2)]] 
                                 color:[NSColor whiteColor]];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}


+ (void) drawStoneAtPoint:(NSPoint)point color:(NSColor*)color {
    // FIX: draw
    
}


+ (NSPoint) getPointForX:(unsigned)x Y:(unsigned)y {
    CGFloat fx, fy;
    
    // FIX: need to properly scale & offset these!!!
    fx = x;
    fy = y;
    
    return NSMakePoint(fx, fy);
}

+ (NSPoint) getPointForLocation:(NSString*)location {
    return [SGFDrawBoard getPointForX:[SGFGoban getColOf:location] Y:[SGFGoban getRowOf:location]];
}


@end
