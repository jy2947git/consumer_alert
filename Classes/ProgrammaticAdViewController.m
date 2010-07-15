//
//  ProgrammaticAdViewController.m
//  AdMobSampleAds
//
//  Created by Michael Ying on 6/3/09.
//  Copyright 2009 AdMob, Inc.. All rights reserved.
//

#import "ProgrammaticAdViewController.h"
#import "AdMobView.h"

@implementation ProgrammaticAdViewController

// The designated initializer.  Override if you create the controller programmatically 
// and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
    self.title = @"Programmatic Ad";
  }
  return self;
}
*/
// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView {
  // get the window frame here.
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  
  UIView *view = [[UIView alloc] initWithFrame:appFrame];
  // making flexible because this will end up in a navigation controller.
  view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.view = view;
  
  [view release];
  
  // Request an ad
  adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
  [adMobAd retain]; // this will be released when it loads (or fails to load)
  
}
*/
/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [adMobAd release];
  [refreshTimer invalidate];
  
  [super dealloc];
}

// Request a new ad. If a new ad is successfully loaded, it will be animated into location.
- (void)refreshAd:(NSTimer *)timer {
  [adMobAd requestFreshAd];
}

#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherId {
  return @"a14a7302f2c5698"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
  return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColor {
  return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColor {
  return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (BOOL)mayAskForLocation {
  return YES; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// To receive test ads rather than real ads...
/*
- (BOOL)useTestAd {
  return YES;
}
 
- (NSString *)testAdAction {
  return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
*/

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did receive ad");
  // get the view frame
  CGRect frame = self.view.frame;
	NSLog(@"%f %f %f %f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
  // put the ad at the bottom of the screen
  adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);
  
  [self.view addSubview:adMobAd];
  [refreshTimer invalidate];
  refreshTimer = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self selector:@selector(refreshAd:) userInfo:nil repeats:YES];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did fail to receive ad");
  [adMobAd release];
  adMobAd = nil;
  // we could start a new ad request here, but in the interests of the user's battery life, let's not
}



@end