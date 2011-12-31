//
//  CVAMainViewController.h
//  CompositeVideoApp
//
//  Created by dav on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CVAFlipsideViewController.h"

@class AVManager;

@interface CVAMainViewController : UIViewController <CVAFlipsideViewControllerDelegate> {
  UIImageView* _mainImageView;
  UIButton* _button;
  AVManager* _avManager;
}

- (IBAction)showInfo:(id)sender;

@end
