//
//  USRecallAppDelegate.h
//  USRecall
//
//  Created by Junqiang You on 6/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GlobalConfiguration;

@interface USRecallAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *controllerTabBar;
	UINavigationController *navController;
	NSArray *viewControllers;
	GlobalConfiguration *configuration;
}
@property (nonatomic, retain) GlobalConfiguration *configuration;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *controllerTabBar;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) NSArray *viewControllers;
@end

