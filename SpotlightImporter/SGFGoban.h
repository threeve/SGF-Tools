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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>

#define MAX_BOARD_SIZE 52


enum bpointTag {
    empty=0, white, black
};
typedef enum bpointTag bpoint;


@interface SGFGoban : NSObject {
    unsigned size;
    bpoint board[MAX_BOARD_SIZE][MAX_BOARD_SIZE];
}

@property (assign, nonatomic) unsigned size;

- (void) resetBoard;

@end
