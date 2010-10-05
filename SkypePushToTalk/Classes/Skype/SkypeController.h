
#import <Cocoa/Cocoa.h>


@interface SkypeController : NSObject {
	BOOL _muted;
	BOOL _connected;
}

+ (SkypeController *)sharedSkypeController;

@property(nonatomic, readonly) BOOL connected;

- (void)connectToSkype;

- (BOOL)isMuted;
- (void)setMuted:(BOOL)muted;

@end
