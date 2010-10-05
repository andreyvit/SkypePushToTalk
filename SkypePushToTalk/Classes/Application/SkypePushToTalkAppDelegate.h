
#import <Cocoa/Cocoa.h>

@interface SkypePushToTalkAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSStatusItem *_statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@end
