//
//  SettingsViewController.h
//  Twitter Tune
//
//  Created by jrk on 14.08.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController 
{
	IBOutlet UISwitch *postOnSongChangeSwitch;
}

@property (nonatomic, retain) IBOutlet UISwitch *postOnSongChangeSwitch;

- (IBAction) postOnSongChangeSwitchChanged: (id) sender;
- (IBAction) logoutTwitter: (id) sender;
@end
