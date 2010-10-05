
#import "SkypeController.h"
#import <Skype/Skype.h>


static SkypeController *sharedSkypeController;


@interface SkypeController () <SkypeAPIDelegate>

@property(nonatomic) BOOL connected;

- (void)sendCommand:(NSString *)command;
- (void)processNotification:(NSString *)notification;

@end


@implementation SkypeController

@synthesize connected=_connected;


#pragma mark -
#pragma mark Lifecycle

+ (SkypeController *)sharedSkypeController {
	if (sharedSkypeController == nil) {
		sharedSkypeController = [[SkypeController alloc] init];
	}
	return sharedSkypeController;
}

- (id)init {
	if (self = [super init]) {
		[SkypeAPI setSkypeDelegate:self];
	}
	return self;
}


#pragma mark -
#pragma mark Basics

- (void)connectToSkype {
	[SkypeAPI connect];
}

- (void)sendCommand:(NSString *)command {
	NSLog(@"-> %@", command);
	NSString *response = [SkypeAPI sendSkypeCommand:command];
	NSLog(@"<- %@", response);
	[self processNotification:response];
}


#pragma mark -
#pragma mark Muting

- (BOOL)isMuted {
	return _muted;
}

- (void)setMuted:(BOOL)muted {
	[self sendCommand:(muted ? @"MUTE ON" : @"MUTE OFF")];
}

- (void)setKnownMuted:(BOOL)muted {
	NSLog(@"Muted is now known to be %@", muted ? @"ON" : @"OFF");
	[self willChangeValueForKey:@"muted"];
	_muted = muted;
	[self didChangeValueForKey:@"muted"];
}

- (void)updateMuted {
	[self sendCommand:@"GET MUTE"];
}


#pragma mark -
#pragma mark Notifications

- (void)processNotification:(NSString *)notification {
	NSArray *words = [notification componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *command = [words objectAtIndex:0];
	NSString *word2 = ([words count] < 2 ? nil : [words objectAtIndex:1]);
	if ([command isEqualToString:@"MUTE"]) {
		if ([word2 isEqualToString:@"ON"]) {
			[self setKnownMuted:YES];
		} else if ([word2 isEqualToString:@"OFF"]) {
			[self setKnownMuted:NO];
		}
	}
}


#pragma mark -
#pragma mark Startup

- (void)connectionEstablished {
	self.connected = YES;
	[self updateMuted];
}


#pragma mark -
#pragma mark SkypeAPIDelegate methods

- (NSString*)clientApplicationName {
	return @"Push-To-Talk";
}

- (void)skypeNotificationReceived:(NSString*)aNotificationString {
	NSLog(@"<= %@", aNotificationString);
	[self processNotification:aNotificationString];
}

// 0 - failed, 1 - success
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode {
	NSLog(@"skypeAttachResponse:%d", aAttachResponseCode);
	if (aAttachResponseCode == 1) {
		[self connectionEstablished];
	}
}

- (void)skypeBecameAvailable:(NSNotification*)aNotification {	
	NSLog(@"skypeBecameAvailable");
}

- (void)skypeBecameUnavailable:(NSNotification*)aNotification {
	NSLog(@"skypeBecameUnavailable");
}


@end
