
#import "SkypePushToTalkAppDelegate.h"

@implementation SkypePushToTalkAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[_statusItem setTitle:@"PTT"];
	[_statusItem setTarget:self];
	[_statusItem setHighlightMode:YES];
	[_statusItem setAction:@selector(quitApp)];
}

- (IBAction)quitApp {
	[[NSApplication sharedApplication] terminate:self];
}

@end
