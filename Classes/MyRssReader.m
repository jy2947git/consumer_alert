//
//  MyRssReader.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyRssReader.h"
#import "CXMLDocument.h"
#import "GlobalHeader.h"

@implementation MyRssReader
@synthesize entries;
@synthesize xmlString;
-(id)init{
	if((self=[super init])!=NULL){
		NSMutableArray *m = [[NSMutableArray alloc] init];
		self.entries=m;
		[m release];
	}
	return self;
}

- (void)dealloc {
	[self.xmlString release];
	[self.entries release];
    [super dealloc];
}


-(BOOL)downloadRssEntriesFromAddress:(NSString*)rssAddress withTag:(NSString*)tag{
	DebugLog(@"checking %@ with tag %@...", rssAddress,tag);
	BOOL result=YES;
	NSURL *url = [[NSURL alloc] initWithString:rssAddress];
	NSError *error;
	CXMLDocument *rssParser = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
	if(error){
		//wrong
		DebugLog(@"error:%@", [error localizedDescription]);
		result=NO;
	}else{
		//save the string of xml
		NSString *s = [[NSString alloc] initWithString:[rssParser XMLStringWithOptions:0]];
		self.xmlString = s;
		[s release];
		//parse the file
		NSArray *resultNotes = [rssParser nodesForXPath:@"//item" error:&error];
		if(error){
			//wrong
			DebugLog(@"error:%@ %@", [error localizedDescription], [error localizedFailureReason]);
			result=NO;
		}else{
			//iterate every item
			DebugLog(@"find %i", [resultNotes count]);
			for(CXMLElement *element in resultNotes){
				NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
				[item setObject:tag	forKey:@"app-tag"];
				for(int i=0;i<[element childCount];i++){
					[item setObject:[[element childAtIndex:i] stringValue] forKey:[[element childAtIndex:i] name]];
					//DebugLog(@"adding %@=%@",[[element childAtIndex:i] name],[[element childAtIndex:i] stringValue]);
				}
				[self.entries addObject:[item copy]];
				[item release];
			}
			
		}
	}
	[rssParser release];
	[url release];
	return result;
}
@end
