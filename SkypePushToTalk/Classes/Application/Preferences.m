
#import "Global.h"
#import "Preferences.h"


static Preferences *sharedPreferences;


@implementation Preferences

@synthesize isFirstRun=_isFirstRun;

+ (Preferences *)sharedPreferences {
	if (sharedPreferences == nil) {
		[[Preferences alloc] init];
	}
	return sharedPreferences;
}

- (id)init {
	if (sharedPreferences != nil) {
		[self release];
		return [sharedPreferences retain];
	}
	if (self = [super init]) {
		sharedPreferences = self;
		
		BOOL nonFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:kFirstRunHappenedPreferenceKey];
		_isFirstRun = !nonFirstRun;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRunHappenedPreferenceKey];
		
		if (_isFirstRun) {
			self.shortcut = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInteger:kSRKeysF1], @"keyCode",
							 [NSNumber numberWithUnsignedInteger:0], @"modifierFlags",
							 nil];
		}
	}
	return self;
}

- (NSDictionary *)shortcut {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyComboPreferenceKey];
}

- (void)setShortcut:(NSDictionary *)keyCombo {
	[self willChangeValueForKey:@"shortcut"];
	[[NSUserDefaults standardUserDefaults] setObject:keyCombo forKey:kKeyComboPreferenceKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self didChangeValueForKey:@"shortcut"];
}

- (KeyCombo)shortcutCombo {
	NSDictionary *shortcut = self.shortcut;
	NSInteger keyCode = [[shortcut objectForKey:@"keyCode"] integerValue];
	NSUInteger modifierFlags = [[shortcut objectForKey:@"modifierFlags"] unsignedIntegerValue];
	return SRMakeKeyCombo(keyCode, modifierFlags);
}

@end
