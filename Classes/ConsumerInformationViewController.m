//
//  ConsumerInformationViewController.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConsumerInformationViewController.h"


@implementation ConsumerInformationViewController
- (void)viewDidLoad {
	//National Highway Traffic Safety Administration
	[self.urls addObject:@"http://www.pueblo.gsa.gov/rss/consumer.xml?WT.rss_f=Consumer+News+From+Pueblo&WT.rss_ev=s"];[self.tags addObject:@"PUEBLO-Consumer"];
//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelchild.xml"];[self.tags addObject:@"CPSC-child"];
//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelhousehold.xml"];[self.tags addObject:@"CPSC-household"];
//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prereloutdoor.xml"];[self.tags addObject:@"CPSC-outdoor"];
//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelrecreation.xml"];[self.tags addObject:@"CPSC-recreation"];
//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelcpsia.xml"];[self.tags addObject:@"CPSC-sia"];
	[super viewDidLoad];
}


-(NSString*)getRssSourceDateFormat{
	//22 Jul 2009 20:17:55 GMT
	return @"dd MMM yyyy HH:mm:ss z";
}
@end

