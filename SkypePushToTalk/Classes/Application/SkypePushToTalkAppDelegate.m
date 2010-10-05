
#import "Global.h"
#import "SkypePushToTalkAppDelegate.h"
#import "DDHotKeyCenter.h"
#import "LoginItemController.h"
#import "SkypeController.h"
#import "PreferencesWindowController.h"
#import "Preferences.h"


#define kPushToTalkDelay 0.2
#define kPushToTalkShowActiveDelay 0.2


@interface SkypePushToTalkAppDelegate ()

- (void)hotKeyDown;
- (void)hotKeyUp;

- (void)showPushToTalkAsActive;

- (void)showPreferences;

- (void)updateOpenAtLoginMenuItem;
- (void)updateMenuToSkypeState;

- (void)updateShortcutMonitoring;

@end


@implementation SkypePushToTalkAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[_statusItem setHighlightMode:YES];
	[_statusItem setMenu:_statusItemMenu];
	[_statusItem setAlternateImage:[NSImage imageNamed:@"ptt-menubar-highlighted.png"]];

	_iconNormal = [NSImage imageNamed:@"ptt-menubar-normal.png"];
	_iconActive = [NSImage imageNamed:@"ptt-menubar-active.png"];
	_iconMuted  = [NSImage imageNamed:@"ptt-menubar-muted.png"];
	
	_hotKeyCenter = [[DDHotKeyCenter alloc] init];
//	BOOL hotKeyOK = [_hotKeyCenter registerHotKeyWithKeyCode:KeyF1 modifierFlags:0 target:self action:@selector(pushToTalkPressed:) object:nil];
//	NSAssert(hotKeyOK, @"Cannot register hotkey");

	[self updateOpenAtLoginMenuItem];
	[self updateMenuToSkypeState];

	NSLog(@"AXAPIEnabled() == %d", AXAPIEnabled());
	NSLog(@"AXIsProcessTrusted() == %d", AXIsProcessTrusted());
	//AXMakeProcessTrusted([[NSBundle mainBundle] executablePath]);

	[self updateShortcutMonitoring];
	[NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask|NSKeyUpMask handler:^(NSEvent *incomingEvent) {
		NSUInteger modifierFlags = [incomingEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;
		NSLog(@"Got %@ for key %d flags %X, looking for key %d flags %x",
			  ([incomingEvent type] == NSKeyDown ? @"KeyDown" : @"KeyUp"),
			  [incomingEvent keyCode], modifierFlags,
			  _cachedKeyCombo.code, _cachedKeyCombo.flags);
		if ([incomingEvent type] == NSKeyDown) {
			if ([incomingEvent keyCode] == _cachedKeyCombo.code && modifierFlags == _cachedKeyCombo.flags) {
				[self hotKeyDown];
			}
		} else if ([incomingEvent type] == NSKeyUp) {
			if ([incomingEvent keyCode] == _cachedKeyCombo.code && modifierFlags == _cachedKeyCombo.flags) {
				[self hotKeyUp];
			}
		}
	}];

	[[SkypeController sharedSkypeController] addObserver:self forKeyPath:@"muted" options:0 context:nil];
	[[SkypeController sharedSkypeController] addObserver:self forKeyPath:@"connected" options:0 context:nil];
	[[SkypeController sharedSkypeController] connectToSkype];
	
	[[Preferences sharedPreferences] addObserver:self forKeyPath:@"shortcut" options:0 context:nil];
	
	if ([Preferences sharedPreferences].isFirstRun)
		[self showPreferences];
}

- (IBAction)quitApplication:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)pushToTalkPressed:(NSEvent *)event {
	[self hotKeyUp];
}

- (IBAction)showPreferences:(id)sender {
	[self showPreferences];
}


#pragma mark -
#pragma mark Preferences

- (void)showPreferences {
	if (preferencesWindowController == nil) {
		preferencesWindowController = [[PreferencesWindowController alloc] init];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindowController showWindow:self];
}


#pragma mark Hot Key Handling

- (void)updateShortcutMonitoring {
	_cachedKeyCombo = [Preferences sharedPreferences].shortcutCombo;
	NSLog(@"Updated cached key combo");
}

- (void)hotKeyDown {
	if (!_hotKeyDownReceived) {
		_hotKeyDownReceived = YES;
		_hotKeyDownAt = [[NSDate date] timeIntervalSinceReferenceDate];
		_wasMutedAtKeyDown = [[SkypeController sharedSkypeController] isMuted];

		NSLog(@"Hot Key Pressed, muted=%d, setting muted to OFF", _wasMutedAtKeyDown);
		[[SkypeController sharedSkypeController] setMuted:NO];

		// avoid flashing "green" icon when pressing and releasing fast (i.e. when toggling unmuted -> muted)
		if (_wasMutedAtKeyDown) {
			[self showPushToTalkAsActive];
		} else {
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPushToTalkAsActive) object:nil];
			[self performSelector:@selector(showPushToTalkAsActive) withObject:nil afterDelay:kPushToTalkShowActiveDelay];
		}
	}
}

- (void)showPushToTalkAsActive {
	if (_hotKeyDownReceived) {
		_showPushToTalkActive = YES;
		[self updateMenuToSkypeState];
	}
}

- (void)hotKeyUp {
	BOOL avail = [SkypeController sharedSkypeController].connected;
	if (avail) {
		BOOL newMuted;
		if (_hotKeyDownReceived) {
			NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceReferenceDate] - _hotKeyDownAt;
			if (elapsed >= kPushToTalkDelay) {
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

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPushToTalkAsActive) object:nil];
	_hotKeyDownReceived = NO;
	_showPushToTalkActive = NO;
	[self updateMenuToSkypeState];
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

	NSImage *icon = _iconNormal;
	if (muted)
		icon = _iconMuted;
	else if (_showPushToTalkActive)
		icon = _iconActive;

	[_statusItem setImage:icon];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"muted"] || [keyPath isEqualToString:@"connected"]) {
		[self updateMenuToSkypeState];
	} else if ([keyPath isEqualToString:@"shortcut"]) {
		[self updateShortcutMonitoring];
	}
}


@end
