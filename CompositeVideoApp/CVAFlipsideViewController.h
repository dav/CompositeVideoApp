//
//  CVAFlipsideViewController.h
//  CompositeVideoApp
//
//  Created by dav on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVAFlipsideViewController;

@protocol CVAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(CVAFlipsideViewController *)controller;
@end

@interface CVAFlipsideViewController : UIViewController

@property (assign, nonatomic) IBOutlet id <CVAFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
