//
//  BaseItemDetailViewController.m
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseItemDetailViewController.h"

#import "GlobalHeader.h"
#import "FocaploAdView.h"
#import "AdMobView.h"
#import "FocaploAdViewController.h"

@implementation BaseItemDetailViewController

@synthesize element,spin;

@synthesize scrollView, pageControl,views;
const CGFloat kScrollObjHeight	= 199.0;
const CGFloat kScrollObjWidth	= 280.0;
const CGFloat pageHeight = 325.0;
const CGFloat pageWidth=320.0;
const CGFloat pageStartY=1.0;

- (id)initWithElement:(NSDictionary*)e{
	if(self=[super init]){
		self.element=[e copy];
		NSMutableArray *arr = [[NSMutableArray alloc] init];
		self.views=arr;
		[arr release];
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"email.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(email:)];
		self.navigationItem.rightBarButtonItem=rightButton;
		[rightButton release];
	}
	return self;
}


-(void)email:(id)sender{
	NSString *subString = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"Consumer Alert:",@"Consumer Alert:"),(NSString*)[element objectForKey:@"title"]];

	NSString *desc = [self.element valueForKey:@"description"];
	NSString *link = [self.element valueForKey:@"link"];
	NSString *s = [desc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	NSString *messageString = [[NSString alloc] initWithFormat:@"%@\n\n<a href='%@'>%@</a>\n\n",s,link,NSLocalizedString(@"link",@"link")];
	DebugLog(@"messageString[%@]",messageString);
    NSString *encodedMessageString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)messageString, CFSTR(""), CFSTR(" %\"?=&+<>;:-"), kCFStringEncodingUTF8);
	
	NSString *urlString = [[NSString alloc] initWithFormat: @"mailto:?subject=%@&body=%@" , 
						   [subString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						   encodedMessageString];
	DebugLog(@"urlString[%@]",urlString);
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[[UIApplication sharedApplication] openURL:url];
	[url release];

	[messageString release];
	[urlString release];
	[subString release];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
	- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSArray *segmentTextContent = [NSArray arrayWithObjects:
								   NSLocalizedString(@"Text", @"Text"),
								   NSLocalizedString(@"Web", @"Web"),
								   nil];
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 400, 30);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	//defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
	
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	//
	DebugLog(@"adding subviews");
	UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(0, pageStartY, pageWidth, pageHeight)];
	self.scrollView=s;
	[scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setCanCancelContentTouches:NO];
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	self.scrollView.scrollEnabled=NO;
	self.scrollView.pagingEnabled = YES;
	
	self.scrollView.showsHorizontalScrollIndicator = YES;
	self.scrollView.showsVerticalScrollIndicator = YES;
	self.scrollView.scrollsToTop = YES;
	self.scrollView.delegate = self;
	[s release];
	
	//	DebugLog(@"there are %i sub views",[[self.scrollView subviews] count]);
	//	UIPageControl *p = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 0, 58, 40)];
	//	p.backgroundColor=[UIColor blackColor];
	//	self.pageControl=p;
	//	pageControl.currentPage = 0;
	//	[pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:self.scrollView];
	//	[self.view addSubview:self.pageControl];
	
	//add the text view and N web views
	int page=0;
	UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width*page,0,scrollView.frame.size.width, pageHeight-0)];
	tv.text=[self.element valueForKey:@"description"];
	tv.editable=NO;
	tv.scrollEnabled=YES;
	
	[self.views addObject:tv];
	[self.scrollView addSubview:tv];
	[tv release];
	
	page++;
	UIWebView *uv = [[UIWebView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width*page, 0, scrollView.frame.size.width,  pageHeight-0)];
	uv.delegate=self;
	uv.tag=200+page;
	[self.views addObject:uv];
	[self.scrollView addSubview:uv];
	[uv release];
	
	self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (page+1), scrollView.frame.size.height);
	pageControl.numberOfPages = (page+1);

//	 CGRect frame = self.view.frame;
//	 NSLog(@"root view relative to window frame: %f %f %f %f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//	 
//	 UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-49-48, frame.size.width, 48)];
//	 message.text=@"test";
//	 message.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//	 message.textColor=[UIColor whiteColor];
//	 message.backgroundColor=[UIColor blackColor];
//	 [self.view addSubview:message];
	 
	 
//	 FocaploAdView *myAd = [[FocaploAdView alloc] initWithFrame:CGRectMake(0, frame.size.height-49-48, frame.size.width, 48)];
//	 [self.view addSubview:myAd];
//	 [myAd release];
	
	//below code can be used to switch between the AdMob and the local-ad
	FocaploAdViewController *myAdController = [FocaploAdViewController instance:@"focaplo-consumer-alert"];
	myAdController.view.frame=CGRectMake(0, self.view.frame.size.height-49-48, self.view.frame.size.width, 48);
	[self.view addSubview:myAdController.view];
	[myAdController startToDisplayAds:nil];
	//admob
	// Request an ad
	
	//adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
//	[adMobAd retain]; // this will be released when it loads (or fails to load)
	
	//NSLog(@"finally %f %f %f %f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

	
}

-(void)loadView{
	[super loadView];
	DebugLog(@"creating root view");
	// get the window frame here.
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	NSLog(@"appframe %f %f %f %f",appFrame.origin.x, appFrame.origin.y, appFrame.size.width, appFrame.size.height);
	UIView *v = [[UIView alloc] initWithFrame:appFrame];
	// making flexible because this will end up in a navigation controller.
	v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view = v;
	
	[v release];
	NSLog(@"root view frame %f %f %f %f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
}

- (void)segmentAction:(id)sender{
	UISegmentedControl* segCtl = sender;
	// the segmented control was clicked, handle it here 
	int page = [segCtl selectedSegmentIndex];
	//scroll
	[self changePage:page];
}
-(void)loadUrl:(NSString*)urlString toWebView:(UIWebView*)uv{
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
	[uv loadRequest:urlRequest];
	[urlRequest release];
	[url release];
	uv.scalesPageToFit=YES;
}

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


- (void)dealloc {
	if(self.spin!=nil){
		[spin release];
	}
    [scrollView release];
    [pageControl release];
	
	[views release];
	[element release];

    [super dealloc];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
	DebugLog(@"scrolling");
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
		 pageControlUsed = NO;
        return;
    }
	 pageControlUsed = NO;
    int page = floor((scrollView.contentOffset.x - 320 / 2) / 320) + 1;
    pageControl.currentPage = page;

}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (void)changePage:(int)page {
	DebugLog(@"page changed");
	UIView *v = [[self.scrollView subviews] objectAtIndex:page];
	if ([v isKindOfClass:[UIWebView class]]){
		if(v.tag < 300){
		//web view not loaded yet
			[self loadUrl:[self.element valueForKey:@"link"] toWebView:v];
			v.tag=300+page;
		}
	}
//    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
//    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	DebugLog(@"start loading web page...");
	if(self.spin==nil){
		DebugLog(@"creating spin");
		UIActivityIndicatorView *s = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 160, 30, 30)];
		s.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
		s.hidesWhenStopped=YES;
		self.spin=s;
		[self.view addSubview:self.spin];
		[s release];
	}
	[self.spin startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	DebugLog(@"successfully downloaded page");
	[self.spin stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	DebugLog(@"failed to download page");
	[self.spin stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	//put message up
	UILabel *err = [[UILabel alloc] initWithFrame:CGRectMake(webView.frame.size.width/3, webView.frame.size.height/3, 300, 40)];
	
	err.font=[UIFont systemFontOfSize:14];
	err.backgroundColor=[UIColor clearColor];
	err.textColor=[UIColor whiteColor];
	err.text=NSLocalizedString(@"web view is unavailable",@"web view is unavailable");
	[webView addSubview:err];
	[err release];
}

@end
