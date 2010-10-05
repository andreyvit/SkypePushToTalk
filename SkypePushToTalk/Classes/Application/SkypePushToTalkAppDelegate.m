
#import "SkypePushToTalkAppDelegate.h"
#import "DDHotKeyCenter.h"

// copied from Carbon to avoid inclusion
enum {
	kVK_F1                        = 0x7A,
};

@implementation SkypePushToTalkAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[_statusItem setTitle:@"PTT"];
	[_statusItem setTarget:self];
	[_statusItem setHighlightMode:YES];
	[_statusItem setAction:@selector(quitApp)];
	
	_hotKeyCenter = [[DDHotKeyCenter alloc] init];
	BOOL hotKeyOK = [_hotKeyCenter registerHotKeyWithKeyCode:kVK_F1 modifierFlags:0 target:self action:@selector(pushToTalkPressed:) object:nil];
	NSAssert(hotKeyOK, @"Cannot register hotkey");
}

- (IBAction)quitApp {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)pushToTalkPressed:(NSEvent *)event {
	[[NSApplication sharedApplication] terminate:self];
}

@end
