//
//  TwitterPostViewController.m
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "Twitter_TuneAppDelegate.h"
#import "TwitterPostViewController.h"
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MGTwitterEngine.h"

#import "TwitterPostViewController+Twitter.h"
#import "TwitterPostViewController+iAd.h"

@implementation TwitterPostViewController
@synthesize coverArtView;
@synthesize artistLabel;
@synthesize titleLabel;
@synthesize activityIndicator;
@synthesize resultLabel;
@synthesize resultImage;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//[activityIndicator startAnimating];
	[self registerForMusicPlayerNotifications];
	[self updateMediaPlayerState];
	
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (![ad isOnline])
	{
		[self setResultImagetoSuccess: NO];
		[self setResultText:@"You are offline.\r\nPlease connect to the internet."];
		return;
	}
	
	bannerVisibleFrame = [bannerView frame];
	bannerHiddenFrame = bannerVisibleFrame;
	bannerHiddenFrame.origin.x -= 330;
	
	[bannerView setFrame: bannerHiddenFrame];
	
	isBannerLoaded = NO;
	isBannerVisible = NO;
}

- (void) updateUI
{
	[artistLabel setText: currentArtist];
	[titleLabel setText: currentTitle];
//	NSLog(@"%@",currentCover);
	[coverArtView setImage: currentCover];
}

- (void) setResultText: (NSString *) text
{
	[resultLabel setHidden: NO];
	[resultLabel setText: text];
}

- (void) setResultImagetoSuccess: (BOOL) success
{
	if (success)
		[resultImage setImage: [UIImage imageNamed:@"ok.png"]];
	else
		[resultImage setImage: [UIImage imageNamed:@"error.png"]];
	
	[resultImage setHidden: NO];
}
#pragma mark Button actions

- (IBAction) postToTwitter: (id) sender
{
	[self startTwitterShare];
}

- (IBAction) postToTwitterAndExit: (id) sender
{
	[self postToTwitter: sender];
}

#pragma mark music player stuff

- (void) unregisterFromMusicPlayerNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}
- (void) registerForMusicPlayerNotifications
{
	MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
	
    // Register for music player notifications  
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];  
    [notificationCenter addObserver:self   
                           selector:@selector(handleNowPlayingItemChanged:)  
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification   
                             object:player];  

    [notificationCenter addObserver:self   
                           selector:@selector(handlePlayerStateChanged:)  
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification   
                             object:player];  
	
	[notificationCenter addObserver: self
						   selector: @selector(handleTwitterLogout:)
							   name: @"logoutTwitterNow"
							 object: nil];
	
	
	
	[player beginGeneratingPlaybackNotifications];
}

- (void) handleTwitterLogout: (id) notification
{
	[self removeSavedTwitterAuthData];
}

- (void) handlePostTimer: (NSTimer *) theTimer
{
	NSLog(@"timer fired %i",[theTimer retainCount]);
	[self postSongToTwitter];
	
	scrobbleTimer = nil;
}


- (void)handleNowPlayingItemChanged:(id)notification 
{  
	[self updateMediaPlayerState];
	
	if (scrobbleTimer)
	{
		[scrobbleTimer invalidate];
		scrobbleTimer = nil;
	}
	
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([ad shouldPostOnSongChange])
	{	
		//create timer to avaoid posting tracks the user has skipped
		scrobbleTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target: self selector:@selector(handlePostTimer:) userInfo:nil repeats:NO];
	}
} 

- (void) handlePlayerStateChanged: (id) notification
{
	[self updateMediaPlayerState];
}

- (void) updateMediaPlayerState
{
	[currentTitle autorelease];
	[currentArtist autorelease];
	[currentCover autorelease];
	[nowPlayingString autorelease];
	currentTitle = nil;
	currentArtist = nil;
	currentCover = nil;
	nowPlayingString = nil;
	
	MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
	
//	[player setQueueWithItemCollection: playbackQueue];
//	[player play];
	
	MPMediaItem *currentSong = [player nowPlayingItem];
	NSString *songTitle = [currentSong valueForProperty: MPMediaItemPropertyTitle];
	NSString *songArtist = [currentSong valueForProperty: MPMediaItemPropertyArtist];
	MPMediaItemArtwork *coverArt = [currentSong valueForProperty: MPMediaItemPropertyArtwork];
	
	if ([player playbackState] != MPMusicPlaybackStatePlaying)
	{	
		songTitle = nil;
		songArtist = nil;
		coverArt = nil;
	}
	
	//NSString *persID = [currentSong valueForProperty: MPMediaItemPropertyPersistentID];
	
	if (songTitle)
	{	
		currentTitle = [[NSString alloc] initWithString: songTitle];
	}
	else
	{
		currentTitle = [[NSString alloc] initWithString: @"No Title"];
	}

	if (songArtist)
	{	
		currentArtist = [[NSString alloc] initWithString: songArtist];
	}
	else
	{
		currentArtist = [[NSString alloc] initWithString: @"No Artist"];
	}

	if (coverArt)
	{	
		currentCover = [coverArt imageWithSize:	CGSizeMake(128.0,128.0)];
		[currentCover retain];
		
		//NSLog(@"%i",[currentCover retainCount]);
	}
	else
	{
		currentCover = [UIImage imageNamed:@"noart.png"];
		[currentCover retain];
	}
	
	NSString *strTemp;
	
	if (songTitle && songArtist)
		strTemp = [NSString stringWithFormat: @"♫ %@ - %@",songArtist,songTitle];
	else
	{	
		strTemp = @"♫ Silence";
		
	}
	
	nowPlayingString = [[NSString alloc] initWithString: strTemp];
	
	//NSLog(@"%@",nowPlayingString);
	
	[self updateUI];	
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

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[coverArtView release], coverArtView = nil;
	[artistLabel release], artistLabel = nil;
	[titleLabel release], titleLabel = nil;
	[activityIndicator release], activityIndicator = nil;
	[resultLabel release], resultLabel = nil;
	[resultImage release], resultImage = nil;

	
	
	[self unregisterFromMusicPlayerNotifications];
	
	MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
	[player endGeneratingPlaybackNotifications];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[coverArtView release], coverArtView = nil;
	[artistLabel release], artistLabel = nil;
	[titleLabel release], titleLabel = nil;
	[activityIndicator release], activityIndicator = nil;
	[resultLabel release], resultLabel = nil;
	[resultImage release], resultImage = nil;
	
	[twitterEngine release], twitterEngine = nil;
    [super dealloc];
}



@end
