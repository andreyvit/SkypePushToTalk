
#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/SRCommon.h>

@class DDHotKeyCenter;
@class PreferencesWindowController;

@interface SkypePushToTalkAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet NSMenu *_statusItemMenu;
	IBOutlet NSMenuItem *_openAtLoginMenuItem;
	IBOutlet NSMenuItem *_connectionErrorMenuItem;
	IBOutlet NSMenuItem *_muteMenuItem;
	IBOutlet NSMenuItem *_unmuteMenuItem;

    NSWindow *window;
	NSStatusItem *_statusItem;
	DDHotKeyCenter *_hotKeyCenter;
	PreferencesWindowController *preferencesWindowController;

	NSImage *_iconNormal, *_iconActive, *_iconMuted;

	BOOL _hotKeyDownReceived;
	BOOL _wasMutedAtKeyDown;
	BOOL _showPushToTalkActive;
	NSTimeInterval _hotKeyDownAt;
	
	KeyCombo _cachedKeyCombo;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)quitApplication:(id)sender;
- (IBAction)toggleOpenAtLogin:(id)sender;
- (IBAction)muteSkype:(id)sender;
- (IBAction)unmuteSkype:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
