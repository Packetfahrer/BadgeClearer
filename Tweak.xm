//Hello World! (keeping traditions alive)
#define BLACKLIST @"/var/mobile/Library/Preferences/com.gnos.BadgeClearer.blacklist.plist"

@interface SBApplication 
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
- (id)displayName;
@end

static BOOL justLaunch = NO;

%hook SBApplicationIcon

- (void)launch {
	BOOL debug = NO;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
	//Is BLACKLIST an invalid plist?
	if (!prefs) {
		// then launch normally
		[[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"enabled", @"debug", nil]] writeToFile:BLACKLIST atomically:YES];
	prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist again
	}

	NSNumber *obj = (NSNumber *)[prefs objectForKey:@"enabled"];
	// does prefs contain a @"enabled" key? or is it true?
	if (!obj || ![obj boolValue]) {
		// then launch normally
		justLaunch = YES;
	}

	NSString *launchingBundleID = [self applicationBundleID];
	//if the list is valid and it contains the bundle ID for the launching app, it means that the application is present
	// in blacklist; therefore it should do the original implementation.
	if ([prefs objectForKey:launchingBundleID]) {
		// then launch normally
		justLaunch = YES;
	}

	// justLaunch will be YES when:
	// -the tweak is disabled
	// -the app is in the blacklist
	// -the user selects either option 2 or 3 in the UIAlertView that shows up
	// ![self badgeValue] will be true only when it is 0
	if (justLaunch || ![self badgeValue]) {
		//reset for next launch
		justLaunch = NO;
		%orig;
	}
	else {
		//main working of tweak
		NSString *displayName = [self displayName];

		obj = (NSNumber *)[prefs objectForKey:@"debug"];
		if (obj) {
			debug = [obj boolValue];
		}
		// Show the alert view	 
		UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:(debug?launchingBundleID:displayName) //ternary operator, switches between the string SpringBoard shows and the internal name for the app
			message:nil
			delegate:self
			cancelButtonTitle:@"Cancel"
			otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
		[launchView show];
		[launchView release];
	}
	[prefs release];
}

%new(v@:@@) - (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
	switch (button) {
	case 3: // "Both" pressed
		// Because there is no 'break;', code will continue onto case 2 and then break
		[self setBadge:nil];   
	case 2: // "Launch app" pressed
		// Launch the app, skip all the other checks
		justLaunch = YES;	
		[self launch];
		break;
	case 1: // "Clear Badges" pressed
		// Clear badge count
		[self setBadge:nil];
		break;
	}
}
%end
