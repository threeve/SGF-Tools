#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#include <Cocoa/Cocoa.h>

#include "SGFImporter.h"


/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SGFImporter *imp = [[SGFImporter alloc] initWithAttributeDictionary:(NSMutableDictionary*)attributes];
    BOOL res = [imp importFileAtPath:(NSString*)pathToFile];
    [imp release];
    
    [pool release];
    
    return res;
}
