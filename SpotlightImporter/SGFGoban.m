//
//  SGFGoban.m
//  SGFTools
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

#import "SGFGoban.h"

#define LOC_RANGE_SPLIT (MAX_BOARD_SIZE/2)


@interface SGFGoban () 
+ (unsigned) charToVal:(unichar)c;
+ (unichar) valToChar:(unsigned)v;

- (void) removeIfDeadGroup:(stoneColor)stone Row:(unsigned)row Col:(unsigned)col;
- (BOOL) isDead:(stoneColor)stone X:(unsigned)x Y:(unsigned)y group:(boardAry)map;
- (void) captureGroup:(boardAry)map;
@end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@implementation SGFGoban

@synthesize whitePrisoners, blackPrisoners;


- (void) resetBoard 
{
    blackPrisoners = 0;
    whitePrisoners = 0;
    size = DEFAULT_BOARD_SIZE;
    memset(board, empty, sizeof(board));
}


- (unsigned) size {
    return size;
}

- (void) setSize:(unsigned)newSize {
    if ((newSize > 0) && (newSize <= MAX_BOARD_SIZE)) {
        size = newSize;
    }
}

+ (unsigned) charToVal:(unichar)c {
    if (('a' <= c) && (c <= 'z')) {
        return c - 'a';
    } else if (('A' <= c) && (c <= 'Z')) {
        return c - 'A' + LOC_RANGE_SPLIT;
    }
    
    return MAX_BOARD_SIZE;
}

+ (unichar) valToChar:(unsigned)v {
    if (v < LOC_RANGE_SPLIT) {
        return 'a' + v;
    } else if (v < MAX_BOARD_SIZE) {
        return 'A' + (v - LOC_RANGE_SPLIT);
    }

    return '!'; // return bogus char for illegal v
}

+ (unsigned) getRowOf:(NSString*)location {    
    if ([location length] < 2) {
        return MAX_BOARD_SIZE;
    }
    
    return [self charToVal:[location characterAtIndex:1]];
}

+ (unsigned) getColOf:(NSString*)location {
    if ([location length] < 2) {
        return MAX_BOARD_SIZE;
    }
    
    return [self charToVal:[location characterAtIndex:0]];
}


+ (NSString*) getLocationForRow:(unsigned)row Col:(unsigned)col {
    unichar loc[2];
    loc[0] = [SGFGoban valToChar:col];
    loc[1] = [SGFGoban valToChar:row];
    
    return [[[NSString alloc] initWithCharacters:loc length:2] autorelease];
}


- (stoneColor) getStoneAt:(NSString*)location {
    unsigned row = [SGFGoban getRowOf:location];
    unsigned col = [SGFGoban getColOf:location];
    
    if ((row >= size) || (col >= size)) {
        return empty;
    }
    
    return board[col][row];
}



// create string that describes the current board position:
// "[board size],[black stone locations],[white stone locations]"
- (NSString*) getPositionString {
    NSMutableString *blackstr = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *whitestr = [[[NSMutableString alloc] init] autorelease];
    
    for (unsigned col=0; col < size; col++)
        for (unsigned row=0; row < size; row++) {
            if (black == board[col][row]) {
                [blackstr appendString:[SGFGoban getLocationForRow:row Col:col]];
            } else if (white == board[col][row]) {
                [whitestr appendString:[SGFGoban getLocationForRow:row Col:col]];
            }
        }
    
    NSMutableString *postr = [[[NSMutableString alloc] initWithFormat:@"%u,%@,%@", size, blackstr, whitestr] autorelease];
    return postr;
}



+ (BOOL) getSize:(unsigned*)pboardSize blackStones:(NSString**)pblackStones whiteStones:(NSString**)pwhiteStones 
      ofPosition:(NSString*)position {
    if (!pboardSize || !pblackStones || !pwhiteStones) {
        return FALSE;
    }
    
    NSArray *parts = [position componentsSeparatedByString:@","];
    if (3 != [parts count]) {
        return FALSE;
    }
    
    *pboardSize = [[parts objectAtIndex:0] intValue];
    if ((*pboardSize < 1) || (*pboardSize > MAX_BOARD_SIZE)) {
        return FALSE;
    }
    
    *pblackStones = [[[NSString alloc] initWithString:[parts objectAtIndex:1]] autorelease];
    *pwhiteStones = [[[NSString alloc] initWithString:[parts objectAtIndex:2]] autorelease];
    if (!(*pblackStones) || !(*pwhiteStones)) {
        return FALSE;
    }
    
    return TRUE;
}



- (void) setStone:(stoneColor)stone at:(NSString*)location {
    unsigned row = [SGFGoban getRowOf:location];
    unsigned col = [SGFGoban getColOf:location];
    
    if ((row >= size) || (col >= size)) {
        return;
    }
    
    board[col][row] = stone;
}


- (void) playStone:(stoneColor)stone at:(NSString*)location {
    if ((white != stone) && (black != stone)) {
        return;
    }
    
    unsigned row = [SGFGoban getRowOf:location];
    unsigned col = [SGFGoban getColOf:location];
    
    if ((row >= size) || (col >= size)) {
        return;
    }
    
    board[col][row] = stone;
    
    // if any adjacent enemy groups have no liberties,
    //   then remove them and add to prisoners
    [self removeIfDeadGroup:ENEMY(stone) Row:row Col:col-1];
    [self removeIfDeadGroup:ENEMY(stone) Row:row Col:col+1];
    [self removeIfDeadGroup:ENEMY(stone) Row:row-1 Col:col];
    [self removeIfDeadGroup:ENEMY(stone) Row:row+1 Col:col];
    
    // if the group at location has no liberties (suicide),
    //   then remove it and add to prisoners
    [self removeIfDeadGroup:stone Row:row Col:col];
}
 

- (void) removeIfDeadGroup:(stoneColor)stone Row:(unsigned)row Col:(unsigned)col {
    if ((row >= size) || (col >= size)) {
        return; // beyond the fringe
    }

    if (board[col][row] != stone) {
        return; // these are not the stones you're looking for ;-)
    }
    
    // keep a map of group members for use during removal/capture
    // if group is dead
    boardAry map;
    memset(map, empty, sizeof(map));
    
    if ([self isDead:stone X:col Y:row group:map]) {
        [self captureGroup:map];
    }
}


// recursively determine whether the stone group including location(x,y) is dead.
// members of the group are marked in the corresponding location in map.
- (BOOL) isDead:(stoneColor)stone X:(unsigned)x Y:(unsigned)y group:(boardAry)map {
    if (empty == board[x][y]) {
        return FALSE;   // found liberty
    }
    
    if ((board[x][y] == ENEMY(stone)) || (map[x][y] == stone)) {
        return TRUE;    // keep looking for liberty
    }
    
    map[x][y] = stone;  // add group member
    
    // recursively check surrounding points...
    if (x > 0) {
        if (![self isDead:stone X:x-1 Y:y group:map]) {
            return FALSE;   // he's not quite dead
        }
    }

    if (x < (size-1)) {
        if (![self isDead:stone X:x+1 Y:y group:map]) {
            return FALSE;
        }
    }
    
    if (y > 0) {
        if (![self isDead:stone X:x Y:y-1 group:map]) {
            return FALSE;
        }
    }
    
    if (y < (size-1)) {
        if (![self isDead:stone X:x Y:y+1 group:map]) {
            return FALSE;
        }
    }
    
    return TRUE;    // he's dead Jim
}


- (void) captureGroup:(boardAry)map {    
    for (unsigned x=0; x < size; x++)
        for (unsigned y=0; y < size; y++) {
            if (white == map[x][y]) {
                board[x][y] = empty;
                whitePrisoners++;
            } else if (black == map[x][y]) {
                board[x][y] = empty;
                blackPrisoners++;
            }
        }
}


@end
