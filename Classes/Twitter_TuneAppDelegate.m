//
//  Twitter_TuneAppDelegate.m
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright flux forge 2009. All rights reserved.
//

#import "Twitter_TuneAppDelegate.h"
#import "Reachability.h"

@implementation Twitter_TuneAppDelegate

@synthesize window;
@synthesize tabBarController;


+ (void) initialize
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"", @"username",
								 @"", @"password",
								 [NSNumber numberWithBool: NO],@"postOnSongChange",
								 
								 nil]; 
	[userDefaults registerDefaults:appDefaults];
}

- (NSDictionary *) twitterCredentials
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *username = [userDefaults stringForKey:@"username"];
	NSString *password = [userDefaults stringForKey:@"password"];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password",nil];
	
	//NSMutableArray *profiles = [[NSUserDefaults standardUserDefaults] objectForKey:@"profiles"];
}

//saves the twitter credentials to user defaults
- (void) setTwitterUsername: (NSString *) username andPassword: (NSString *) password
{
	//NSLog(@"saving %@ %@",username, password);
	[self setTwitterUsername: username];
	[self setTwitterPassword: password];
}

- (void) setTwitterUsername: (NSString *) username
{
//	NSLog(@"newUser: %@",username);
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:username forKey:@"username"];
}

- (void) setTwitterPassword: (NSString *) password
{
//	NSLog(@"newPass: %@",password);
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:password forKey:@"password"];
}


- (BOOL) shouldPostOnSongChange
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:@"postOnSongChange"];
}

- (void) setShouldPostOnSongChange: (BOOL) shouldPost
{
	NSLog(@"shouldPost: %i",shouldPost);
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:shouldPost forKey:@"postOnSongChange"];
}

- (BOOL) isOnline
{
	[[Reachability sharedReachability] setHostName:@"twitter.com"];
	NetworkStatus internetConnectionStatus = [[Reachability sharedReachability] remoteHostStatus];
	
	if (internetConnectionStatus == NotReachable)
	{	
		return NO;
	}
	
	return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{

	// Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];  
	
	// Make this interesting.  
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];  
	splashView.image = [UIImage imageNamed:@"Default.png"];  
	[window addSubview:splashView];  
	[window bringSubviewToFront:splashView];  
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:0.5];  
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];  
	[UIView setAnimationDelegate:self];   
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];  
	splashView.alpha = 0.0;  
	splashView.frame = CGRectMake(-60, -85, 440, 635);  
	[UIView commitAnimations]; 
	
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {  
	[splashView removeFromSuperview];  
	[splashView release];  
}  

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

