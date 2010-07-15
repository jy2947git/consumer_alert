//
//  BaseRssTableViewContrller.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RecallListViewController.h"
#import "GlobalHeader.h"

@implementation RecallListViewController
- (void)viewDidLoad {
	//National Highway Traffic Safety Administration
	[self.urls addObject:@"http://www-odi.nhtsa.dot.gov/rss/feeds/rss_recalls_C.xml"];[self.tags addObject:@"NHTSA-C"];
	[self.urls addObject:@"http://www-odi.nhtsa.dot.gov/rss/feeds/rss_recalls_T.xml"];[self.tags addObject:@"NHTSA-T"];
	[self.urls addObject:@"http://www-odi.nhtsa.dot.gov/rss/feeds/rss_recalls_V.xml"];[self.tags addObject:@"NHTSA-V"];
	//Food and Drug Administration
	[self.urls addObject:@"http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/Recalls/rss.xml"];[self.tags addObject:@"FDA"];
	//Consumer Product Safety Commission
	//	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerel.xml"];[self.tags addObject:@"cpsc-all"];
	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelchild.xml"];[self.tags addObject:@"CPSC-child"];
	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelhousehold.xml"];[self.tags addObject:@"CPSC-household"];
	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prereloutdoor.xml"];[self.tags addObject:@"CPSC-outdoor"];
	[self.urls addObject:@"http://www.cpsc.gov/cpscpub/prerel/prerelrecreation.xml"];[self.tags addObject:@"CPSC-recreation"];

	[super viewDidLoad];
}


@end

