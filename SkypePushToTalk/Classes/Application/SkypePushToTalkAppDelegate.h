
#import <Cocoa/Cocoa.h>

@class DDHotKeyCenter;

@interface SkypePushToTalkAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet NSMenu *_statusItemMenu;
	IBOutlet NSMenuItem *_openAtLoginMenuItem;

    NSWindow *window;
	NSStatusItem *_statusItem;
	DDHotKeyCenter *_hotKeyCenter;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)quitApplication:(id)sender;
- (IBAction)toggleOpenAtLogin:(id)sender;

@end
