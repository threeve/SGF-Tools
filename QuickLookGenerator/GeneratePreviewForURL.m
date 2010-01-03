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

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
//    #warning To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    MDItemRef metadata = MDItemCreateWithURL(NULL, url);
    if (!metadata)
        return noErr;
    
    NSArray *attributeNames = (NSArray*)MDItemCopyAttributeNames(metadata);

    NSLog(@"Got attrib names: %@", attributeNames);
    
    [attributeNames release];
    CFRelease(metadata);
    
    CGSize size = CGSizeMake(400, 400);
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, size, false, NULL);
    
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void*)cgContext flipped:YES];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];

    // TODO draw properties here.

    [NSGraphicsContext restoreGraphicsState];

    QLPreviewRequestFlushContext(preview, cgContext);
    
    CFRelease(cgContext);
    [pool drain];
    
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
