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

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

#import "SGFDrawBoard.h"

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, 
                                 CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    MDItemRef metadata = MDItemCreateWithURL(NULL, url);
    if (!metadata) {
        [pool drain];
        return noErr;
    }
    
    NSNumber *sgf_iscollection = (NSNumber*) MDItemCopyAttribute(metadata, CFSTR("com_breedingpinetrees_sgf_iscollection"));
    BOOL isCollection = [sgf_iscollection boolValue];
    [sgf_iscollection release];
    
    NSString *boardPosition = (NSString *) MDItemCopyAttribute(metadata, CFSTR("com_breedingpinetrees_sgf_boardposition"));
    [boardPosition autorelease];
    CFRelease(metadata);
    
    CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, maxSize, false, NULL);
    if (cgContext) {
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void*)cgContext flipped:YES];

        if (context) {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:context];
            
            NSRect bounds;
            bounds.origin = NSMakePoint(0.0, 0.0);
            bounds.size = NSSizeFromCGSize(maxSize);
            
            // force flipped y coords by applying a transform
            NSAffineTransform* xform = [NSAffineTransform transform];
            [xform translateXBy:0.0 yBy:bounds.size.height];
            [xform scaleXBy:1.0 yBy:-1.0];
            [xform concat];
            
            if (isCollection) {
                CGFloat collectionOffset = 4.0f;
                unsigned numBoards = 3;
                bounds.origin.x = collectionOffset*numBoards;
                bounds.origin.y = collectionOffset*numBoards;
                bounds.size.width -= collectionOffset*numBoards;
                bounds.size.height -= collectionOffset*numBoards;
                
                // draw background that indicates file is a collection
                for (unsigned i=0; i < numBoards; i++) {
                    [[DEFAULT_BOARD_NSCOLOR colorWithAlphaComponent:0.25*i] setFill];
                    [NSBezierPath fillRect:bounds];
                    bounds = NSOffsetRect(bounds, -collectionOffset, -collectionOffset);
                }
            }
            
            SGFDrawBoard *board = [[SGFDrawBoard alloc] initWithBoardSize:DEFAULT_BOARD_SIZE];
            [board autorelease];
            [board setBounds:bounds];
            board.cfBundle = QLThumbnailRequestGetGeneratorBundle(thumbnail);
            board.flatStyle = [(NSNumber*) CFBundleGetValueForInfoDictionaryKey(QLThumbnailRequestGetGeneratorBundle(thumbnail), 
                                                                                CFSTR("Board Style Flat")) boolValue];
            [board drawPosition:boardPosition];
            
            [NSGraphicsContext restoreGraphicsState];
            QLThumbnailRequestFlushContext(thumbnail, cgContext);
        }
        CFRelease(cgContext);
    }
    
    [pool drain];
    return noErr;
}



void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
