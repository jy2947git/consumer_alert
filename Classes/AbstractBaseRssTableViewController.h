//
//  RecallListViewController.h
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AbstractBaseRssTableViewController : UITableViewController {
	NSMutableArray *items;
	UIActivityIndicatorView *spinner;
	NSMutableArray *urls;
	NSMutableArray *tags;
	NSMutableDictionary *imagePool;
}
@property(nonatomic, retain) NSMutableDictionary *imagePool;
@property(nonatomic, retain) NSMutableArray *items;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) NSMutableArray *urls;
@property(nonatomic, retain) NSMutableArray *tags;
-(void)loadLatestFromLocalCacheWithTag:(NSString*)tag;
-(void)loadLatestFromHost:(NSString*)host WithTag:(NSString*)tag;
-(void)backgroundLoadLatestCustomAlerts;
-(void)loadLatestFromLocalCache;
-(NSDate*)parsedString:(NSString*)dateString toDateWithFormatList:(NSArray*)formatArr;
NSInteger sortItemsByPubDate(id data1, id data2, void *context);
-(UIImage*)getImageOfTag:(NSString*)tag;
-(NSString*)getRssSourceDateFormatOfTag:(NSString*)tag;
@end
