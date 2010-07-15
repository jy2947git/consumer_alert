//
//  USRecallAppDelegate.m
//  USRecall
//
//  Created by Junqiang You on 6/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "USRecallAppDelegate.h"
#import "GlobalConfiguration.h"
#import "ConsumerInformationViewController.h"
#import "RecallListViewController.h"
#import "MoneyInformationViewController.h"
#import "FocaploAdViewController.h"

@implementation USRecallAppDelegate

@synthesize window;
@synthesize navController;
@synthesize controllerTabBar;
@synthesize viewControllers;
@synthesize configuration;
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//create configuration first always
	GlobalConfiguration *conf = [[GlobalConfiguration alloc] init];
	self.configuration = conf;
	[conf release];
	
	
    RecallListViewController *r = [[RecallListViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *nr = [[UINavigationController alloc] initWithRootViewController:r];
	UITabBarItem *tr=[[UITabBarItem alloc] initWithTitle:@"recall" image:[UIImage imageNamed:@"recall-tab.png"] tag:1];
	r.title=NSLocalizedString(@"Recalls",@"Recalls");
	nr.tabBarItem=tr;
	
	ConsumerInformationViewController *c = [[ConsumerInformationViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
	UITabBarItem *tc=[[UITabBarItem alloc] initWithTitle:@"consumer" image:[UIImage imageNamed:@"consumer-tab.png"] tag:2];
	c.title=NSLocalizedString(@"Consumer Info",@"Consumer Info");
	nc.tabBarItem=tc;
	
	MoneyInformationViewController *m = [[MoneyInformationViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *nm = [[UINavigationController alloc] initWithRootViewController:m];
	UITabBarItem *tm=[[UITabBarItem alloc] initWithTitle:@"money" image:[UIImage imageNamed:@"finance-tab.png"] tag:3];
	m.title=NSLocalizedString(@"Money",@"Money");
	nm.tabBarItem=tm;
	
	NSArray *vs = [[NSArray alloc] initWithObjects:nr,nc,nm,nil];
	self.viewControllers = vs;

	
	UITabBarController *t = [[UITabBarController alloc] init];
	self.controllerTabBar=t;
	[t release];
	
	self.controllerTabBar.viewControllers=self.viewControllers;
	self.controllerTabBar.selectedIndex=0;
	[window addSubview:self.controllerTabBar.view];
	//instantiate the singleton and pre-fetch ads
	FocaploAdViewController *myAdController = [FocaploAdViewController instance:@"focaplo-consumer-alert"];
	
    [window makeKeyAndVisible];
	[r release];
	[c release];
	[m release];
	[nr release];
	[nc release];
	[nm release];
	[vs release];
	[tr release];
	[tc release];
	[tm release];
}


- (void)dealloc {
	[self.configuration release];
	[self.viewControllers release];
	[self.controllerTabBar release];
	[self.controllerTabBar release];
    [window release];
    [super dealloc];
}


@end
