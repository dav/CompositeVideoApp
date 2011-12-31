//
//  CVAMainViewController.m
//  CompositeVideoApp
//
//  Created by dav on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CVAMainViewController.h"
#import "AVManager.h"

@implementation CVAMainViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 380)];
  _mainImageView.backgroundColor = [UIColor redColor];
  [self.view addSubview:_mainImageView];

  _avManager = [[AVManager alloc] initWithViewForPreview:_mainImageView];

  _button = [[UIButton alloc] initWithFrame:CGRectMake(60, 400, 200, 44)];
  [_button setTitle:@"Toggle" forState:UIControlStateNormal];
  [_button addTarget:_avManager action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_button];
  
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [_mainImageView release];
  _mainImageView = nil;
  [_avManager release];
  _avManager = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(CVAFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    CVAFlipsideViewController *controller = [[[CVAFlipsideViewController alloc] initWithNibName:@"CVAFlipsideViewController" bundle:nil] autorelease];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

@end
