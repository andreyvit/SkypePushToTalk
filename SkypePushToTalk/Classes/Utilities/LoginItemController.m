// -------------------------------------------------------
// LoginItemController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
//
// Thx to Justin Williams
// http://carpeaqua.com/2008/03/01/adding-an-application-to-login-items-in-mac-os-x-leopard/
// -------------------------------------------------------

#import "LoginItemController.h"


static LoginItemController *sharedController;


@interface LoginItemController ()

- (NSURL *) applicationPath;
- (LSSharedFileListRef) getLoginItemList;
- (void) addApplicationToLoginList: (LSSharedFileListRef) list;
- (BOOL) findApplicationInLoginList: (LSSharedFileListRef) list andRemove: (BOOL) remove;

@end


@implementation LoginItemController

+ (LoginItemController *)sharedController {
	if (sharedController == nil) {
		sharedController = [[LoginItemController alloc] init];
	}
	return sharedController;
}

- (BOOL) loginItemEnabled {
	LSSharedFileListRef list = [self getLoginItemList];
	BOOL found = [self findApplicationInLoginList: list andRemove: NO];
	CFRelease(list);
	return found;
}

- (void) setLoginItemEnabled: (BOOL) enabled {
	LSSharedFileListRef list = [self getLoginItemList];
	if (enabled) {
		[self addApplicationToLoginList: list];
	} else {
		[self findApplicationInLoginList: list andRemove: YES];
	}
	CFRelease(list);
}

- (void) addApplicationToLoginList: (LSSharedFileListRef) list {
	CFURLRef url = (CFURLRef) [self applicationPath];
	LSSharedFileListItemRef item =
    LSSharedFileListInsertItemURL(list, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item) {
		CFRelease(item);
	} else {
		NSLog(@"Error: Gitifier could not be added to login items.");
	}
}

- (BOOL) findApplicationInLoginList: (LSSharedFileListRef) list andRemove: (BOOL) remove {
	NSURL *applicationUrl = [self applicationPath];
	CFURLRef url;
	NSURL *nsurl;
	CFArrayRef array = LSSharedFileListCopySnapshot(list, NULL);
	NSInteger itemCount = CFArrayGetCount(array);
	BOOL found = NO;
	
	for (NSInteger i = 0; i < itemCount; i++) {
		LSSharedFileListItemRef item = (LSSharedFileListItemRef) CFArrayGetValueAtIndex(array, i);
		if (LSSharedFileListItemResolve(item, 0, &url, NULL) == noErr) {
			nsurl = (NSURL *) url;
			if ([nsurl isEqual: applicationUrl]) {
				found = YES;
				if (remove) {
					LSSharedFileListItemRemove(list, item);
				} else {
					CFRelease(url);
					break;
				}
			}
			CFRelease(url);
		}
	}
	
	CFRelease(array);
	return found;
}

- (LSSharedFileListRef) getLoginItemList {
	return LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
}

- (NSURL *) applicationPath {
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	return [NSURL fileURLWithPath: bundlePath];
}

@end
