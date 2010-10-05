
#import <Foundation/Foundation.h>
#import <ShortcutRecorder/SRCommon.h>

@interface Preferences : NSObject {
	BOOL _isFirstRun;
}

+ (Preferences *)sharedPreferences;

@property(nonatomic, retain) NSDictionary *shortcut;

@property(nonatomic, readonly) KeyCombo shortcutCombo;

@property(nonatomic, readonly) BOOL isFirstRun;

@end
