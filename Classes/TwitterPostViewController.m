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
	
	shouldExit = NO;
	
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
	
	
	//[self postSongToTwitter];
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
	//shouldExit = NO;	
	[self postSongToTwitter];
}

- (IBAction) postToTwitterAndExit: (id) sender
{
	shouldExit = YES;
	[self postToTwitter: sender];
}

#pragma mark music player stuff
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
	
	
	
	
	[player beginGeneratingPlaybackNotifications];
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
	MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
	[player endGeneratingPlaybackNotifications];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
}


#pragma mark twitter sending stuff
- (void)requestSucceeded:(NSString *)requestIdentifier
{
//	NSLog(@"post succeeded! %@",requestIdentifier);
	[self setResultText:@"Tweet successfully posted."];
	[activityIndicator stopAnimating];
	[self setResultImagetoSuccess: YES];
	
//	NSLog(@"%i",shouldExit);
	if (shouldExit)
	{
		exit(0);
	}
	shouldExit = NO;
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
	NSLog(@"could not post to twitter! %@ %@",requestIdentifier,error);
	if ([error code] == 401)
		[self setResultText:@"Post Request failed!\r\nYour password/username\r\nseems to be incorrect."];
	else if ([error code] == 1200)
		[self setResultText:@"Post Request failed!\r\nThis is a temporary error.\r\nPlease try again."];
	else
		[self setResultText:[NSString stringWithFormat: @"Post Request failed with code %i.",[error code]]];
	shouldExit = NO;
	[activityIndicator stopAnimating];
	[self setResultImagetoSuccess: NO];
}


- (void) postSongToTwitter
{
	Twitter_TuneAppDelegate *ad = (Twitter_TuneAppDelegate *)[[UIApplication sharedApplication] delegate];

	
	[resultImage setHidden: YES];
	[activityIndicator startAnimating];
	[self setResultText:@"Posting to twitter ..."];

	if (![ad isOnline])
	{
		[activityIndicator stopAnimating];
		[self setResultImagetoSuccess: NO];
		[self setResultText:@"You are offline.\r\nPlease connect to the internet."];
		return;
	}
	
	NSDictionary *creds = [ad twitterCredentials];
	//	NSLog(@"%@",creds);
	
	
	
	NSString *user = [creds objectForKey:@"username"];
	NSString *pass = [creds objectForKey:@"password"];
	
	if (!twitterEngine)
		twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	
	if (!twitterEngine)
	{	
		NSLog(@"could not create twitterEngine!");
	}
	[twitterEngine setUsesSecureConnection: NO];
	[twitterEngine setUsername: user password: pass];
	[twitterEngine setClientName:@"TTune" version:@"0.1" URL:@"http://www.fluxforge.com" token:@"mutweet"];
	
	NSString *ret = [twitterEngine sendUpdate: nowPlayingString];
	NSLog(@"sending update: %@",ret);
	//- (NSString *)sendUpdate:(NSString *)status;
}


@end
