
#import <Cocoa/Cocoa.h>

@class DDHotKeyCenter;

@interface SkypePushToTalkAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSStatusItem *_statusItem;
	DDHotKeyCenter *_hotKeyCenter;
}

@property (assign) IBOutlet NSWindow *window;

@end
