//
//  ProgrammaticAdViewController.h
//  AdMobSampleAds
//
//  Created by Michael Ying on 6/3/09.
//  Copyright 2009 AdMob, Inc.. All rights reserved.
//

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#import <UIKit/UIKit.h>



@interface ProgrammaticAdViewController : UIViewController {

  NSTimer *refreshTimer;
}

@end
