//
//  FocaploAdViewController.m
//  USRecall
//
//  Created by Junqiang You on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FocaploAdViewController.h"
#import "GlobalHeader.h"
#import "MediaPlayer/MPMoviePlayerController.h"

@implementation FocaploAdViewController
@synthesize viewLoaded,currentAd,appId,frame,adImg,adData,displayAdTimer,videoPlayer;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

static FocaploAdViewController *instance;
+(id)instance:(NSString*)aid{
	
	
	@synchronized(self) {
		if(!instance) {
			DebugLog(@"creating the focaplo-view-controller instance");
			instance = [[FocaploAdViewController alloc] init];
			instance.viewLoaded=NO;
			//
			NSMutableArray *d = [[NSMutableArray alloc] init];
			instance.adData=d;
			[d release];
			[instance fetchAds:aid];
			
			// Register to receive a notification that the movie is now in memory and ready to play
			[[NSNotificationCenter defaultCenter] addObserver:instance 
													 selector:@selector(moviePreloadDidFinish:) 
														 name:MPMoviePlayerContentPreloadDidFinishNotification 
													   object:nil];
			
			// Register to receive a notification when the movie has finished playing. 
			[[NSNotificationCenter defaultCenter] addObserver:instance 
													 selector:@selector(moviePlayBackDidFinish:) 
														 name:MPMoviePlayerPlaybackDidFinishNotification 
													   object:nil];
			
			// Register to receive a notification when the movie scaling mode has changed. 
			[[NSNotificationCenter defaultCenter] addObserver:instance 
													 selector:@selector(movieScalingModeDidChange:) 
														 name:MPMoviePlayerScalingModeDidChangeNotification 
													   object:nil];
		}
	}
	
	return instance;
	
}

-(void)fetchAds:(NSString*)aid{
	instance.appId=aid;
	//start a background thread to download ad data
	[NSThread detachNewThreadSelector:@selector(backgroundLoadAd:) toTarget:instance withObject:instance.appId];

}


-(void)backgroundLoadAd:(NSString*)appId{
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	//
	NSURL *url = [[NSURL alloc] initWithString:@"http://locallerads.appspot.com/serve?token=939237200300-1=39012&command=browseXml&start=1&end=100"];
	NSError *error=nil;
	NSData *plistXML = [NSData dataWithContentsOfURL:url options:NSUncachedRead error:&error];
	
	if(error){
		//something wong, tell parent view not to display ad
		DebugLog(@"Failed to download ad data:%@ %@",[error localizedFailureReason],[error localizedDescription]);
		
	}else{
		NSString *errorDesc = nil;
		NSPropertyListFormat format;
		NSArray *temp = (NSArray *)[NSPropertyListSerialization
										  
										  propertyListFromData:plistXML
										  
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  
										  format:&format errorDescription:&errorDesc];
	
		if (!temp) {
			DebugLog(@"Failed to parse xml data:%@",errorDesc);
			[errorDesc release];
			//tell parent not to display ad
		}else{
			[instance.adData removeAllObjects];
			for (id dic in temp) {
				[instance.adData addObject:dic];
			}
			DebugLog(@"find %i ads",[instance.adData count]);
			NSDictionary *dic;
			for(dic in instance.adData){
				DebugLog(@"name:%@ image:%@",[dic objectForKey:@"name"],[dic objectForKey:@"image-link"]);
				[instance downloadVideo:dic];
			}


		}
	}
	[p release];
}

-(void)downloadVideo:(NSDictionary*)dic{
	if([dic objectForKey:@"video-name"]!=nil){
		//check whether local has it
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *localPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[dic objectForKey:@"video-name"]];
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL localExist=NO;
		if([fm fileExistsAtPath:localPath]){
			DebugLog(@"find local video at %@",localPath);
			localExist=YES;
		}else{
			//check remote host
			DebugLog(@"no local file, check remote");
			if([dic objectForKey:@"video-link"]!=nil){
				DebugLog(@"exist link, try to download and save to local");
				NSURL *movieURL = [NSURL URLWithString:[dic objectForKey:@"video-link"]];
				//download to local
				NSError *error=nil;
				NSData *movie = [NSData dataWithContentsOfURL:movieURL options:NSUncachedRead error:&error];
				if(error){
					DebugLog(@"failed to download video %@",[error localizedDescription]);
				}else{
					//save to local
					DebugLog(@"saving to local %@", localPath);
					[movie writeToFile:localPath options:NSUncachedRead error:&error];
					if(error){
						DebugLog(@"failed to save movie to local %@",[error localizedDescription]);
					}else{
						localExist=YES;
					}
				}
			}else{
				//no hope
				DebugLog(@"not local, not remote");
			}
		}
	}
}
-(void)startToDisplayAds:(id)obj{
	//tell parent to display ad by reloading the view
	if(instance.displayAdTimer!=nil && [instance.displayAdTimer isValid]){
		//already started
		DebugLog(@"already started");
		return;
	}
	if([instance.adData count]>0){
		instance.currentAd=-1;
		[instance displayAds:nil];
		instance.displayAdTimer=[NSTimer scheduledTimerWithTimeInterval:3 target:instance selector:@selector(displayAds:) userInfo:nil repeats:YES];
	}
}

-(void)appearAdView{
	//animate up
	[instance.adImg setNeedsDisplay];
	instance.adImg.frame=CGRectMake(0, 50, self.view.frame.size.width, 48);
	[ UIView beginAnimations: nil context: nil ]; // Tell UIView we're ready to start animations.
	[ UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
	[ UIView setAnimationDuration: 1.0f ]; // Set the duration to 1 second.
	instance.adImg.frame=CGRectMake(0, 0, self.view.frame.size.width, 48);
	[UIView commitAnimations];
}

-(void)displayAds:(id)obj{
	
	if([instance.adData count]<=0){
		return;
	}

	instance.currentAd++;
	if(instance.currentAd>=[instance.adData count]){
		instance.currentAd=0;
	}
	NSDictionary *dic = (NSDictionary*)[instance.adData objectAtIndex:instance.currentAd];
	if([dic objectForKey:@"image-link"]!=nil){
		DebugLog(@"reload image");
		instance.adImg.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"image-link"]]]];
		[instance.adImg setNeedsDisplay];

	}
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if(instance.viewLoaded){
		DebugLog(@"view already loaded");
		return;
	}else{
		DebugLog(@"start to load view");
	}
	[super loadView];
	DebugLog(@"creating root view");
	// this frame doesn't matter, the caller will change frame later
	CGRect appFrame =CGRectMake(0, 500, 320, 48);
	NSLog(@"appframe %f %f %f %f",appFrame.origin.x, appFrame.origin.y, appFrame.size.width, appFrame.size.height);
	UIView *v = [[UIView alloc] initWithFrame:appFrame];
	// making flexible because this will end up in a navigation controller.
	v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view = v;
	
	[v release];
	NSLog(@"root view frame %f %f %f %f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	

	
	UIImageView *i = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
	self.adImg=i;
	[i release];
	if([self.adData count]>0){
		NSDictionary *dic = (NSDictionary*)[self.adData objectAtIndex:0];
		if([dic objectForKey:@"image-link"]!=nil){
			self.adImg.image=[UIImage imageWithContentsOfFile:[dic objectForKey:@"image-link"]];
		}
	}
	[self.view addSubview:self.adImg];
	//add the transparent button
	UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
	b.backgroundColor=[UIColor clearColor];
	[b addTarget:self action:@selector(displayAdDetail:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:b];
	[b release];
	DebugLog(@"view loaded");
	instance.viewLoaded=YES;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
	//[self appearAdView];
}

-(void)displayAdDetail:(id)sender{
	DebugLog(@"clicked ad bar");
	NSDictionary *dic = (NSDictionary*)[instance.adData objectAtIndex:instance.currentAd];
	if([dic objectForKey:@"video-name"]!=nil){
		//check whether local has it
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *localPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[dic objectForKey:@"video-name"]];
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL localExist=NO;
		if([fm fileExistsAtPath:localPath]){
			DebugLog(@"find local video at %@",localPath);
			localExist=YES;
		}
		if(localExist){
			DebugLog(@"try to play from local file");
			//play movie from local
			NSURL *localMovie = [NSURL fileURLWithPath:localPath];
			MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:localMovie];
			self.videoPlayer=mp;
			self.videoPlayer.scalingMode=MPMovieScalingModeNone;
			[self.videoPlayer play];
			[mp release];
		}
	}
	
}


//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	/* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    /*     
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
    /* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
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
	[videoPlayer release];
	[displayAdTimer invalidate];
	[appId release];
	[adImg release];
	[adData release];
    [super dealloc];
}


@end
