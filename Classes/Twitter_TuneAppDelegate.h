//
//  Twitter_TuneAppDelegate.h
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright flux forge 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Twitter_TuneAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
{
    UIWindow *window;
    UITabBarController *tabBarController;
	
	UIImageView *splashView; 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


//returns the twitter login credentials from user defaults
//username: the username
//password: the password
- (NSDictionary *) twitterCredentials;
- (void) setTwitterUsername: (NSString *) username andPassword: (NSString *) password;
- (void) setTwitterUsername: (NSString *) username;
- (void) setTwitterPassword: (NSString *) password;

//connected to net?
- (BOOL) isOnline;

//should be every songchange twittered?
- (BOOL) shouldPostOnSongChange;
- (void) setShouldPostOnSongChange: (BOOL) shouldPost;


@end
