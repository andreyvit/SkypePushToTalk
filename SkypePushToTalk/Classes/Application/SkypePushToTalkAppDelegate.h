
#import <Cocoa/Cocoa.h>

@class DDHotKeyCenter;

@interface SkypePushToTalkAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet NSMenu *_statusItemMenu;
	IBOutlet NSMenuItem *_openAtLoginMenuItem;
	IBOutlet NSMenuItem *_connectionErrorMenuItem;
	IBOutlet NSMenuItem *_muteMenuItem;
	IBOutlet NSMenuItem *_unmuteMenuItem;

    NSWindow *window;
	NSStatusItem *_statusItem;
	DDHotKeyCenter *_hotKeyCenter;

	NSImage *_iconNormal, *_iconActive, *_iconMuted;

	BOOL _hotKeyDownReceived;
	BOOL _wasMutedAtKeyDown;
	BOOL _showPushToTalkActive;
	NSTimeInterval _hotKeyDownAt;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)quitApplication:(id)sender;
- (IBAction)toggleOpenAtLogin:(id)sender;
- (IBAction)muteSkype:(id)sender;
- (IBAction)unmuteSkype:(id)sender;

@end
