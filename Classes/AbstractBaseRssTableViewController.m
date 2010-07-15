//
//  RecallListViewController.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AbstractBaseRssTableViewController.h"
#import "MyRssReader.h"
#import "USRecallAppDelegate.h"
#import "GlobalConfiguration.h"
#import "GlobalHeader.h"
#import "BaseItemDetailViewController.h"

@implementation AbstractBaseRssTableViewController
@synthesize items;
@synthesize spinner;
@synthesize urls;
@synthesize tags;
@synthesize imagePool;
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		NSMutableArray *m = [[NSMutableArray alloc] init];
		self.items=m;
		[m release];
		NSMutableArray *u = [[NSMutableArray alloc] init];
		self.urls=u;
		[u release];
		NSMutableArray *t = [[NSMutableArray alloc] init];
		self.tags=t;
		[t release];
		NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
		self.imagePool=d;
		[d release];
    }
    return self;
}



- (void)viewDidLoad {
	self.tableView.rowHeight=80;
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//first load content from local cache
	[self loadLatestFromLocalCache];
	//then start a new thread to check whether remote server has update
	[NSThread detachNewThreadSelector:@selector(backgroundLoadLatestCustomAlerts) toTarget:self withObject:nil];
	//[self backgroundLoadLatestCustomAlerts];
}

-(void)startSpinner{
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	if(self.spinner==nil){
		DebugLog(@"creagting spinner...");
		UIActivityIndicatorView *c = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		c.frame=CGRectMake(150, 200, 30, 30);
		c.backgroundColor=[UIColor darkGrayColor];
		self.spinner =c;
		[c release];
		[self.tableView addSubview:self.spinner];
		[self.tableView bringSubviewToFront:self.spinner];
	}
	if(![self.spinner isAnimating]){
		DebugLog(@"spinning...");
		[self.spinner startAnimating];
	}
}

-(void)stopSpinner{
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	if(self.spinner!=nil && [self.spinner isAnimating]){
		DebugLog(@"stoping spinning...");
		[self.spinner stopAnimating];
	}
}

-(void)loadLatestFromLocalCacheWithTag:(NSString*)tag{
	//get the local file
	USRecallAppDelegate *delegate = (USRecallAppDelegate*)[UIApplication sharedApplication].delegate;
	NSString *localFileName = [[NSString alloc] initWithFormat:@"%@.xml",tag];
	NSString *filePath = [delegate.configuration.docPath stringByAppendingPathComponent:localFileName];
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
		//load from file
		NSArray *existingData = [[NSArray alloc] initWithContentsOfFile:filePath];
		[self.items addObjectsFromArray:existingData];
		[existingData release];
	}
	[localFileName release];
}
-(void)loadLatestFromHost:(NSString*)host WithTag:(NSString*)tag{
	[self startSpinner];
	MyRssReader *reader = [[MyRssReader alloc] init];
	@try{
		BOOL success = [reader downloadRssEntriesFromAddress:host withTag:tag];
		if(!success){
			DebugLog(@"Failed to load from remote host");
		}else{
			//save the entries to local
			USRecallAppDelegate *delegate = (USRecallAppDelegate*)[UIApplication sharedApplication].delegate;
			NSString *localFileName = [[NSString alloc] initWithFormat:@"%@.xml",tag];
			[reader.entries writeToFile:[delegate.configuration.docPath stringByAppendingPathComponent:localFileName] atomically:YES];
			[localFileName release];
			
		}
	}@catch (NSException *exception) {
		NSLog(@"error when reading RSS feeds at %@ reason %@", host, [exception reason]);
	}@finally {
		[reader release];
		[self stopSpinner];
	}
	
}

-(void)backgroundLoadLatestCustomAlerts{
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	for(int i=0;i<[self.tags count];i++){
		[self performSelector:@selector(loadLatestFromHost:WithTag:) withObject:[self.urls objectAtIndex:i] withObject:[self.tags objectAtIndex:i]];
	}
	//reload from cache
	[self.items removeAllObjects];
	for(int i=0;i<[self.tags count];i++){
		[self loadLatestFromLocalCacheWithTag:[self.tags objectAtIndex:i]];
	}

	//
	//parse date
	//Mon, 20 Jul 2009 21:55:00 UTC
	//Tue, 21 Jul 2009 20:00:00 GMT
	NSArray *dateFormt = [[NSArray alloc] initWithObjects:@"EEE, dd MMM yyyy HH:mm:ss z",@"dd, MMM yyyy HH:mm:ss z",@"EEE, dd MMM yyyy HH:mm:ss zzz",@"EEE, dd MMM yyyy HH:mm:ss",nil];
	for(int i=0;i<[self.items count];i++){
		NSString *pubDate = [((NSDictionary*)[self.items objectAtIndex:i]) objectForKey:@"pubDate"];
		if(pubDate!=nil){
			if([pubDate hasSuffix:@"UTC"]){
				//don't know how to parse the string ending with UTC
				pubDate=[pubDate substringToIndex:[pubDate length]-4];
			}
			NSDate *parsedPubDate = [self parsedString:pubDate toDateWithFormatList:dateFormt];
			if(parsedPubDate!=nil){
				//DebugLog(@"parsed %@ of tag %@", pubDate,[((NSDictionary*)[self.items objectAtIndex:i]) objectForKey:@"app-tag"]);
				[((NSDictionary*)[self.items objectAtIndex:i]) setValue:parsedPubDate forKey:@"parsedPubDate"];
			}else{
				DebugLog(@"Failed to parse date %@ of tag %@", pubDate,[((NSDictionary*)[self.items objectAtIndex:i]) objectForKey:@"app-tag"]);
			}
		}
	}
	[dateFormt release];
	//sort array
	[self.items sortUsingFunction:sortItemsByPubDate context:nil];
	[self.tableView reloadData];
	NSString *currentTitle = [[NSString alloc] initWithFormat:@"%@ (%i)",self.title,[self.items count]];
	self.title=currentTitle;
	[currentTitle release];
	[p release];
}

-(NSString*)getRssSourceDateFormatOfTag:(NSString*)tag{
	return @"EEE, dd MMM yyyy HH:mm:ss z";
}

-(NSDate*)parsedString:(NSString*)dateString toDateWithFormatList:(NSArray*)formatArr{
	//
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSDate *parsedDate1 = nil;
	for(int i=0;i<[formatArr count];i++){
		if(parsedDate1!=nil){
			break;
		}
		[dateFormatter setDateFormat:[formatArr objectAtIndex:i]];
		parsedDate1 = [dateFormatter dateFromString:dateString];
	}
	[dateFormatter release];
	return parsedDate1;
}


	NSInteger sortItemsByPubDate(id data1, id data2, void *context)
	{
		NSDictionary *d1 = (NSDictionary*)data1;
		NSDictionary *d2 = (NSDictionary*)data2;
		NSDate *date1 = [d1 objectForKey:@"parsedPubDate"];
		NSDate *date2 = [d2 objectForKey:@"parsedPubDate"];
		if(date1==nil || date2==nil){
			return NSOrderedAscending;
		}else{
			NSComparisonResult res =  [date2 compare:date1];
			return res;
		}
		
	}
	
-(void)loadLatestFromLocalCache{
	for(int i=0;i<[self.tags count];i++){
		[self performSelector:@selector(loadLatestFromLocalCacheWithTag:) withObject:[self.tags objectAtIndex:i]];
	}
}

-(UIImage*)getImageOfTag:(NSString*)tag{
	//first check pool
	UIImage *img = [self.imagePool objectForKey:tag];
	if(img==nil){
		NSArray *imgTypes = [NSArray arrayWithObjects:@"png",@"jpg",@"jpeg",@"gif",nil];
		NSString *appPath = [[NSBundle mainBundle] resourcePath];
		NSString *imgType;
		NSFileManager *fm = [NSFileManager defaultManager];
		for(imgType in imgTypes){
			NSString *filePath = [appPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",tag,imgType]];
			if([fm fileExistsAtPath:filePath]){
				img = [UIImage imageWithContentsOfFile:filePath];
				if(img!=nil){
					[self.imagePool setObject:img forKey:tag];
					break;
				}
			}
		}

	}
	return img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *element = [self.items objectAtIndex:indexPath.row];
	//DebugLog(@"%i-%@",indexPath.row,[element objectForKey:@"title"]);
	NSString *tag = [element objectForKey:@"app-tag"];
	NSString *CellIdentifier = [NSString stringWithFormat:@"cell-%@",tag];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		//check the type of the element - child, tire, etc
		UIImage *img = [self getImageOfTag:tag];
		if(img!=nil){
			UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5,15,55,55)];
			imgView.image = img;
			[cell.contentView addSubview:[imgView autorelease]];
		}
		
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(65, 3, 200, 15)];
		line1.font=[UIFont systemFontOfSize:12];
		line1.textColor=[UIColor darkTextColor];
		line1.tag=1;
		UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(65, 19, 200, 40)];
		line2.font=[UIFont systemFontOfSize:10];
		line2.numberOfLines=3;
		line2.lineBreakMode=UILineBreakModeWordWrap;
		line2.textColor=[UIColor darkGrayColor];
		line2.tag=2;
		UILabel *line3 = [[UILabel alloc] initWithFrame:CGRectMake(65, 60, 200, 15)];
		line3.font=[UIFont systemFontOfSize:10];
		line3.textColor=[UIColor darkTextColor];
		line3.tag=3;
		UILabel *line3B = [[UILabel alloc] initWithFrame:CGRectMake(220, 60, 100, 15)];
		line3B.font=[UIFont systemFontOfSize:10];
		line3B.textColor=[UIColor darkTextColor];
		line3B.tag=4;
		[cell.contentView addSubview:line1];
		[cell.contentView addSubview:line2];
		[cell.contentView addSubview:line3];
		[cell.contentView addSubview:line3B];
		
	}
	
	// Set up the cell...
	NSString *instr = [element objectForKey:@"pubDate"];
	NSDate *parsedDate = [element objectForKey:@"parsedPubDate"];
	NSString *dateStr = nil;
//	if(parsedDate!=nil){
//		NSDateFormatter *outDateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
//		[outDateFormatter setDateFormat:@"MM/dd/yyyy"];
//		NSString *dateStr = [outDateFormatter stringFromDate:parsedDate];
//	}else{
		dateStr = instr;
//	}

	((UILabel*)[cell.contentView viewWithTag:3]).text=dateStr;
	((UILabel*)[cell.contentView viewWithTag:1]).text=[element objectForKey:@"title"];
	((UILabel*)[cell.contentView viewWithTag:2]).text=[element objectForKey:@"description"];
	((UILabel*)[cell.contentView viewWithTag:4]).text=[[((NSString*)[element objectForKey:@"app-tag"]) componentsSeparatedByString:@"-"] objectAtIndex:0];
	return cell;
}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}


// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//		
//		static NSString *CellIdentifier = @"Cell";
//		
//		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//		if (cell == nil) {
//			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//		}
//		
//		// Set up the cell...
//		
//		return cell;
//	}
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	BaseItemDetailViewController *anotherViewController = [[BaseItemDetailViewController alloc] initWithElement:[self.items objectAtIndex:indexPath.row]];
	
	[self.navigationController pushViewController:anotherViewController animated:YES];
	[anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[self.imagePool release];
	[self.urls release];
	[self.tags release];
	[self.spinner release];
	[self.items release];
    [super dealloc];
}


@end

