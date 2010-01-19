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
#import <Quartz/Quartz.h>

#import "SGFDrawBoard.h"
#import "SGFPreviewViewController.h"


OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, 
                               CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    MDItemRef metadata = MDItemCreateWithURL(NULL, url);
    if (!metadata) {
        [pool drain];
        return noErr;
    }
    
    CFArrayRef attributeNames = MDItemCopyAttributeNames(metadata);
    NSDictionary *attributes = (NSDictionary*)MDItemCopyAttributes(metadata, attributeNames);
    [attributes autorelease];
    CFRelease(attributeNames);
    CFRelease(metadata);
    
    NSString *boardPosition = (NSString *) [attributes objectForKey:@"com_breedingpinetrees_sgf_boardposition"];
	BOOL isCollection = [[attributes objectForKey:@"com_breedingpinetrees_sgf_iscollection"] boolValue];
    
	NSString *qlnib;
	if (isCollection) {
		qlnib = @"SGFCollectionPreview";
	}
	else {
		qlnib = @"SGFPreview";
	}
    
    SGFPreviewViewController *sgfPreview = [[SGFPreviewViewController alloc] initWithNibName:qlnib bundle:[NSBundle bundleForClass:[SGFPreviewViewController class]]];
    [sgfPreview autorelease];
    [sgfPreview setRepresentedObject:attributes];

    NSRect viewBounds = [[sgfPreview view] bounds];
    NSSize bigger = viewBounds.size;
    bigger.width += viewBounds.size.height;
    
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, NSSizeToCGSize(bigger), false, NULL);
    if (cgContext) {
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void*)cgContext flipped:YES];
        if (context) {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:context];
            
            NSAffineTransform* xform = [NSAffineTransform transform];
            [xform translateXBy:viewBounds.size.height yBy:0.0];
            [xform scaleXBy:1.0 yBy:1.0];
            [xform concat];
            
            [[[NSColor blackColor] colorWithAlphaComponent:0.25] setFill];
            [NSBezierPath fillRect:viewBounds];
            [[sgfPreview view] displayRectIgnoringOpacity:viewBounds inContext:context];
            
            NSRect bounds = NSMakeRect(0.0, 0.0, viewBounds.size.height-2.0, viewBounds.size.height-2.0);
            
            // force flipped y coords by applying a transform
            [xform translateXBy:(-2.0*viewBounds.size.height)+2.0 yBy:bounds.size.height];
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
            board.cfBundle = QLPreviewRequestGetGeneratorBundle(preview);
            board.flatStyle = [(NSNumber*) CFBundleGetValueForInfoDictionaryKey(QLPreviewRequestGetGeneratorBundle(preview), 
                                                                                CFSTR("Board Style Flat")) boolValue];
            [board drawPosition:boardPosition];

            [NSGraphicsContext restoreGraphicsState];
        }
    
        QLPreviewRequestFlushContext(preview, cgContext);
        CFRelease(cgContext);
    }
    
    [pool drain];
    return noErr;
}



void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
