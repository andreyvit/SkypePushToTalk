
#import "SkypePushToTalkAppDelegate.h"
#import "DDHotKeyCenter.h"
#import "LoginItemController.h"
#import "SkypeController.h"


// copied from Carbon to avoid inclusion
enum {
	kVK_F1                        = 0x7A,
};


@interface SkypePushToTalkAppDelegate ()

- (void)hotKeyDown;
- (void)hotKeyUp;

- (void)updateOpenAtLoginMenuItem;
- (void)updateMenuToSkypeState;

@end


@implementation SkypePushToTalkAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[_statusItem setTitle:@"PTT"];
	[_statusItem setHighlightMode:YES];
	[_statusItem setMenu:_statusItemMenu];
	
	_hotKeyCenter = [[DDHotKeyCenter alloc] init];
//	BOOL hotKeyOK = [_hotKeyCenter registerHotKeyWithKeyCode:kVK_F1 modifierFlags:0 target:self action:@selector(pushToTalkPressed:) object:nil];
//	NSAssert(hotKeyOK, @"Cannot register hotkey");

	[self updateOpenAtLoginMenuItem];
	[self updateMenuToSkypeState];

	NSLog(@"AXAPIEnabled() == %d", AXAPIEnabled());
	NSLog(@"AXIsProcessTrusted() == %d", AXIsProcessTrusted());
	//AXMakeProcessTrusted([[NSBundle mainBundle] executablePath]);

	[NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask|NSKeyUpMask handler:^(NSEvent *incomingEvent) {
		NSLog(@"Global event monitor called for event %d", [incomingEvent type]);
		if ([incomingEvent type] == NSKeyDown) {
			if ([incomingEvent keyCode] == kVK_F1) {
				[self hotKeyDown];
			}
		} else if ([incomingEvent type] == NSKeyUp) {
			if ([incomingEvent keyCode] == kVK_F1) {
				[self hotKeyUp];
			}
		}
	}];

	[[SkypeController sharedSkypeController] addObserver:self forKeyPath:@"muted" options:0 context:nil];
	[[SkypeController sharedSkypeController] connectToSkype];
}

- (IBAction)quitApplication:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)pushToTalkPressed:(NSEvent *)event {
	[self hotKeyUp];
}


#pragma mark Hot Key Handling

- (void)hotKeyDown {
	if (!_hotKeyDownReceived) {
		_hotKeyDownReceived = YES;
		_hotKeyDownAt = [[NSDate date] timeIntervalSinceReferenceDate];
		_wasMutedAtKeyDown = [[SkypeController sharedSkypeController] isMuted];

		NSLog(@"Hot Key Pressed, muted=%d, setting muted to OFF", _wasMutedAtKeyDown);
		[[SkypeController sharedSkypeController] setMuted:NO];
	}
}

- (void)hotKeyUp {
	BOOL avail = [SkypeController sharedSkypeController].connected;
	if (avail) {
		BOOL newMuted;
		if (_hotKeyDownReceived) {
			NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceReferenceDate] - _hotKeyDownAt;
			if (elapsed >= 0.2) {
				newMuted = YES;
			} else {
				newMuted = !_wasMutedAtKeyDown;
			}
		} else {
			newMuted = ![[SkypeController sharedSkypeController] isMuted];
		}

		NSLog(@"Hot Key Released, setting muted to %d", newMuted);
		[[SkypeController sharedSkypeController] setMuted:newMuted];
	}

	_hotKeyDownReceived = NO;
}


#pragma mark -
#pragma mark Open at Login

- (IBAction)toggleOpenAtLogin:(id)sender {
	[LoginItemController sharedController].loginItemEnabled = ![LoginItemController sharedController].loginItemEnabled;
	[self updateOpenAtLoginMenuItem];
}

- (void)updateOpenAtLoginMenuItem {
	[_openAtLoginMenuItem setState:([LoginItemController sharedController].loginItemEnabled ? NSOnState : NSOffState)];
}


#pragma mark -
#pragma mark Muting Skype

- (IBAction)muteSkype:(id)sender {
	[[SkypeController sharedSkypeController] setMuted:YES];
}

- (IBAction)unmuteSkype:(id)sender {
	[[SkypeController sharedSkypeController] setMuted:NO];
}


#pragma mark -
#pragma mark KVO notifications

- (void)updateMenuToSkypeState {
	BOOL muted = [[SkypeController sharedSkypeController] isMuted];
	BOOL avail = [SkypeController sharedSkypeController].connected;
	[_connectionErrorMenuItem setHidden:avail];
	[_muteMenuItem setHidden:!avail || muted];
	[_unmuteMenuItem setHidden:!avail || !muted];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"muted"]) {
		[self updateMenuToSkypeState];
	}
}


@end
