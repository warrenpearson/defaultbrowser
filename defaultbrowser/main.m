//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        NSString *newb; // requested browser
        NSString *browser;
        
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        
        if ( [args count] > 1 ) {
            newb = [args objectAtIndex:1];        }
        else {
            printf("Please specify a browser\n");
            return -1;
        }
        
        NSDictionary *browsers = @{ @"f" : @"firefox",
                                    @"s" : @"safari",
                                    @"c" : @"chrome",
                                    @"v" : @"vivaldi",
                                    @"o" : @"opera"
                                    };
        
        if ( [browsers objectForKey:newb] == nil) {
            printf("Please specify a valid brower\n");
            return -1;
        }
        
        browser = [browsers objectForKey:newb];
        
        
        // we're interested in things which can handle http/https
        NSArray *urlschemerefs = [[NSArray alloc] initWithObjects:@"http", @"https", nil];
        
        // what is our current handler?
        NSString *currentHandler = (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
                                                                                          (__bridge CFStringRef)([urlschemerefs objectAtIndex:0]));
        
        currentHandler = [[currentHandler componentsSeparatedByString:@"."] lastObject];
        
        if ( [currentHandler isEqualToString:browser]) {
            printf("Current browser is %s, no action required\n", [browser UTF8String]);
            return 0;
        }
        
        printf("Previous:  %s\n", [currentHandler UTF8String]);
        printf("Requested: %s\n", [browser UTF8String]);
        
        // lets figure out which handlers are available
        NSArray *HTTPHandlers = (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
                                                                                   (__bridge CFStringRef)([urlschemerefs objectAtIndex:0]));
        NSMutableDictionary *handlers = [NSMutableDictionary dictionary];
        for (int i = 0; i < [HTTPHandlers count]; i++) {
            NSString *split = [HTTPHandlers objectAtIndex:i];
            //            NSLog(@"%@", split);
            NSArray *parts = [split componentsSeparatedByString:@"."];
            [handlers setObject:split  forKey:[[parts lastObject] lowercaseString]];
        }
        
        // set a new default
        if ([handlers valueForKey:[browser lowercaseString]] != nil) {
            CFStringRef newHandler = (__bridge CFStringRef)([handlers valueForKey:[browser lowercaseString]]);
            for (NSString *urlschemeref in urlschemerefs) {
                LSSetDefaultHandlerForURLScheme((__bridge CFStringRef)(urlschemeref), newHandler);
            }
        } else {
            printf("%s is not available as a HTTP browser\n", [browser cStringUsingEncoding:NSUTF8StringEncoding]);
            printf("Available browsers:\n");
            for (NSString *key in handlers) {
                printf("- %s\n", [key cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            return 1;
        }
        
    }
    return 0;
}
