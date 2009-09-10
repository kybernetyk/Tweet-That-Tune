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
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UISwitch *postOnSongChangeSwitch;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UISwitch *postOnSongChangeSwitch;

- (IBAction) usernameFieldChanged: (id) sender;
- (IBAction) passwordFieldChanged: (id) sender;
- (IBAction) postOnSongChangeSwitchChanged: (id) sender;

@end
