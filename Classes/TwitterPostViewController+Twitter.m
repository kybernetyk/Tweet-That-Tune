//
//  MainViewController+Twitter.m
//  DeineMudda
//
//  Created by jrk on 17/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "TwitterPostViewController+Twitter.h"
#import "NSString+Search.h"

@implementation TwitterPostViewController (Twitter)

- (void) startTwitterShare
{
	if (twitterEngine)
	{	
		[self sendTwitterUpdate];
		return;
	}
	
	twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	[twitterEngine setConsumerKey: @"jO7XQ99WL4GjulUusJ0UUA"];
	[twitterEngine setConsumerSecret: @"eAaFAyfVpMGM8X6db83rOE508RY8Ego4vMi5fiEOxbc"];
	
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: twitterEngine delegate: self];
	if (controller) 
	{
		[self presentModalViewController: controller animated: YES];
	}
	else 
	{
		[self sendTwitterUpdate];
	}
}

- (void) sendTwitterUpdate
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	
	NSLog(@"sending twitter update!");
	[twitterEngine sendUpdate: nowPlayingString];
	//[twitterEngine sendUpdate: @"Deine Mutter zieht LKW auf DSF."];
}

- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username 
{
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"twitterAuthData"];
	[defaults synchronize];
}

- (void) removeSavedTwitterAuthData
{
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey: @"twitterAuthData"];
	[defaults synchronize];
	[twitterEngine release];
	twitterEngine = nil;
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username 
{
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"twitterAuthData"];
}


#pragma mark SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username 
{
	NSLog(@"Authenicated for %@", username);
	
	[self sendTwitterUpdate];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller 
{
	NSLog(@"Authentication Failed!");
	[twitterEngine release], twitterEngine = nil;
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller 
{
	NSLog(@"Authentication Canceled.");
	[twitterEngine release], twitterEngine = nil;
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate

#pragma mark twitter sending stuff
- (void) requestSucceeded: (NSString *) requestIdentifier 
{
	[self setResultText:@"Tweet successfully posted."];
	[activityIndicator stopAnimating];
	[self setResultImagetoSuccess: YES];
	
	NSLog(@"Request %@ succeeded", requestIdentifier);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];

	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Twitter",nil) 
													message:NSLocalizedString(@"Update erfolgreich gesendet!",nil)
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release]; */
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error 
{
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	if ([[error localizedDescription] containsString: @"401" ignoringCase: YES])
	{
		[self removeSavedTwitterAuthData];
		[self startTwitterShare];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Twitter",nil) 
														message:[NSString stringWithFormat: NSLocalizedString(@"Update failed: %@",nil), [error localizedDescription]]
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release]; 
		
		[self setResultText: @"Twitter update failed :-("];
		[activityIndicator stopAnimating];
		[self setResultImagetoSuccess: NO];
		
	}
}


@end
