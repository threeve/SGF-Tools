//
//  SGFGoban.h
//  SGF-Tools
//
//  Created by John Mifsud on 1/12/10.
//  This class implements a data model of a go board.
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

#define MAX_BOARD_SIZE 52
#define DEFAULT_BOARD_SIZE 19


enum stoneColorTag {
    empty=0, white, black
};
typedef enum stoneColorTag stoneColor;
typedef stoneColor boardAry[MAX_BOARD_SIZE][MAX_BOARD_SIZE];

#define ENEMY(stone) ((white == stone) ? black : white)

@interface SGFGoban : NSObject {
    unsigned size;
    boardAry board;
    
    unsigned whitePrisoners, blackPrisoners;
}

@property (assign, nonatomic) unsigned size;
@property (readonly) unsigned whitePrisoners, blackPrisoners;

- (void) resetBoard;

+ (unsigned) getRowOf:(NSString*)location;
+ (unsigned) getColOf:(NSString*)location;
+ (NSString*) getLocationForRow:(unsigned)row Col:(unsigned)col;

- (stoneColor) getStoneAt:(NSString*)location;

// set stone at location without checking for captures, etc.
// use for handicap stones, setup, etc.
- (void) setStone:(stoneColor)stone at:(NSString*)location;

// play stone at location, then check for captures & suicide
// use for normal moves
- (void) playStone:(stoneColor)stone at:(NSString*)location;

// returns special string used for encoding current board position
- (NSString*) getPositionString;

// splits a position string into its component parts
// returns TRUE if successful
+ (BOOL) getSize:(unsigned*)pboardSize blackStones:(NSString**)pblackStones whiteStones:(NSString**)pwhiteStones 
      ofPosition:(NSString*)position;

@end
