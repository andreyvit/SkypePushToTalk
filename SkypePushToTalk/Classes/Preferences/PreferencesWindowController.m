
#import "Global.h"
#import "PreferencesWindowController.h"
#import "Preferences.h"


@interface PreferencesWindowController ()

- (void)linkifyButton:(NSButton *)label;

@end



@implementation PreferencesWindowController


- (NSString *)versionString {
	return [NSString stringWithFormat:@"Push-To-Talk %@", [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]];
}

- (id)init {
	if (self = [super initWithWindowNibName: @"Preferences"]) {
	}
	return self;
}

- (void)awakeFromNib {
	[self linkifyButton:websiteLabel];
}

- (void)linkifyButton:(NSButton *)label {
	NSString *url = label.title;
	NSDictionary *linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSColor blueColor], NSForegroundColorAttributeName,
									[NSCursor pointingHandCursor], NSCursorAttributeName,
									nil];
	
	NSAttributedString *link = [[NSAttributedString alloc] initWithString: url attributes: linkAttributes];
	label.attributedTitle = link;
}

- (IBAction)openProjectWebsite:(id) sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: [sender title]]];
}

- (void)setupToolbar {
	[self addView: generalPreferencesView
			label: @"General"
			image: [NSImage imageNamed:@"NSPreferencesGeneral"]];
	[self addView: aboutPreferencesView
			label: @"About"
			image: [NSImage imageNamed:@"NSApplicationIcon"]];
	[self setCrossFade:YES];
}

- (void)showWindow: (id) sender {
	if (!self.window || !self.window.isVisible) {
		[super showWindow:sender];
	}
}

@end
