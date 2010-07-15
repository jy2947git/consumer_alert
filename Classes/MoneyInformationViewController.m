//
//  MoneyInformationViewController.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MoneyInformationViewController.h"


@implementation MoneyInformationViewController
- (void)viewDidLoad {
	//National Highway Traffic Safety Administration
	[self.urls addObject:@"http://www.pueblo.gsa.gov/rss/money.xml?WT.rss_f=Money+News+From+Pueblo&WT.rss_ev=s"];[self.tags addObject:@"PUEBLO-Money"];

	
	[super viewDidLoad];
}


-(NSString*)getRssSourceDateFormat{
	//22 Jul 2009 20:17:55 GMT
	return @"dd MMM yyyy HH:mm:ss z";
}
@end

