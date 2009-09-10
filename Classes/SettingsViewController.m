//
//  SettingsViewController.m
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "SettingsViewController.h"
#import "Twitter_TuneAppDelegate.h"

@implementation SettingsViewController
@synthesize usernameField;
@synthesize passwordField;
@synthesize postOnSongChangeSwitch;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//	NSLog(@"return?");
	
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) usernameFieldChanged: (id) sender
{
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	[ad setTwitterUsername: [usernameField text]];
}

- (IBAction) passwordFieldChanged: (id) sender
{
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	[ad setTwitterPassword: [passwordField text]];
}

- (IBAction) postOnSongChangeSwitchChanged: (id) sender
{
	//NSLog(@"sender %@",sender);
	//NSLog(@"post %@",postOnSongChangeSwitch);
	
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	[ad setShouldPostOnSongChange: [postOnSongChangeSwitch isOn]];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSDictionary *creds = [ad twitterCredentials];
	//NSLog(@"%@",creds);
	
	[usernameField setText: [creds objectForKey:@"username"]];
	[passwordField setText: [creds objectForKey:@"password"]];
	
	[postOnSongChangeSwitch setOn: [ad shouldPostOnSongChange] animated: NO];
	
//	[usernameLabel setText:@"fettemama"];
//	[passwordLabel setText:@"warbird"];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
