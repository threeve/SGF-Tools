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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SGFGoban.h"


@interface SGFGoban () 
+ (unsigned) charToVal:(unichar)c;
+ (unichar) valToChar:(unsigned)v;
@end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@implementation SGFGoban


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
        [self resetBoard];
        size = newSize;
    }
}

+ (unsigned) charToVal:(unichar)c {
    if (('a' <= c) && (c <= 'z')) {
        return c - 'a';
    } else if (('A' <= c) && (c <= 'Z')) {
        return c - 'A' + 26;
    }
    
    return MAX_BOARD_SIZE;
}

+ (unichar) valToChar:(unsigned)v {
    if (v < (MAX_BOARD_SIZE/2)) {
        return 'a'+v;
    } else if (v < MAX_BOARD_SIZE) {
        return 'A'+v;
    }

    return '!'; // return bogus char for illegal v
}

+ (unsigned) getRowOf:(NSString*)location {    
    if ([location length] < 2) {
        return 0;
    }
    
    return [self charToVal:[location characterAtIndex:0]];
}

+ (unsigned) getColOf:(NSString*)location {
    if ([location length] < 2) {
        return 0;
    }
    
    return [self charToVal:[location characterAtIndex:1]];
}


+ (NSString*) getLocationForRow:(unsigned)row Col:(unsigned)col {
    if ((row >= MAX_BOARD_SIZE) || (col >= MAX_BOARD_SIZE)) {
        return [NSString string];
    }
    
    unichar loc[2];
    loc[0] = [SGFGoban valToChar:row];
    loc[1] = [SGFGoban valToChar:col];
    
    return [[NSString alloc] initWithCharacters:loc length:2];
}


- (stoneColor) getStoneAt:(NSString*)location {
    unsigned row = [SGFGoban getRowOf:location];
    unsigned col = [SGFGoban getColOf:location];
    
    if ((row >= size) || (col >= size)) {
        return empty;
    }
    
    return board[row][col];
}



- (void) setStone:(stoneColor)stone at:(NSString*)location {
    board[[SGFGoban getRowOf:location]][[SGFGoban getColOf:location]] = stone;
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
    
    board[row][col] = stone;
    
    // if any adjacent enemy groups have no liberties,
    //   then remove them and add to prisoners
    
    // if the group at location has no liberties (suicide),
    //   then remove it and add to prisoners
    
}



@end
