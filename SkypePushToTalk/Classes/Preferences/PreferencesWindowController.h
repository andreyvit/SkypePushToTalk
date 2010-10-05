
#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "DBPrefsWindowController.h"

@class RepositoryListController;
@class SRRecorderControl;

@interface PreferencesWindowController : DBPrefsWindowController {
	IBOutlet NSView *generalPreferencesView;
	IBOutlet NSView *aboutPreferencesView;
	IBOutlet NSButton *websiteLabel;
	IBOutlet SRRecorderControl *shortcutControl;
}

- (IBAction)openProjectWebsite:(id)sender;

@property(nonatomic, retain) NSDictionary *keyCombo;

@end
