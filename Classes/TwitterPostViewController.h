//
//  TwitterPostViewController.h
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"
#import <iAd/iAd.h>
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"

@interface TwitterPostViewController : UIViewController 
{
	IBOutlet UIImageView *coverArtView;
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *resultLabel;
	IBOutlet UIImageView *resultImage;
	IBOutlet ADBannerView *bannerView;
	
	NSString *currentTitle;
	NSString *currentArtist;
	UIImage *currentCover;
	NSString *nowPlayingString;
	
	SA_OAuthTwitterEngine *twitterEngine;
	
	NSTimer *scrobbleTimer;
	
	CGRect bannerVisibleFrame;
	CGRect bannerHiddenFrame;
	BOOL isBannerLoaded;
	BOOL isBannerVisible;
}

@property (nonatomic, retain) IBOutlet UIImageView *coverArtView;
@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *resultLabel;
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;

- (IBAction) postToTwitterAndExit: (id) sender;
- (IBAction) postToTwitter: (id) sender;

- (void) registerForMusicPlayerNotifications;
- (void) updateMediaPlayerState;
- (void) handlePlayerStateChanged: (id) notification;
- (void) handleNowPlayingItemChanged: (id)notification;

- (void) requestSucceeded: (NSString *)requestIdentifier;
- (void) requestFailed: (NSString *)requestIdentifier withError: (NSError *) error;

- (void) postSongToTwitter;

@end
