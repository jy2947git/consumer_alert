//
//  MyRssReader.h
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyRssReader : NSObject {
	NSMutableArray *entries;
	NSString *xmlString;
}
@property(nonatomic, retain) NSMutableArray *entries;
@property(nonatomic, retain) NSString *xmlString;
-(BOOL)downloadRssEntriesFromAddress:(NSString*)rssAddress withTag:(NSString*)tag;
@end
