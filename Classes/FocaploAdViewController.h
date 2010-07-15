//
//  FocaploAdViewController.h
//  USRecall
//
//  Created by Junqiang You on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPMoviePlayerController;
@interface FocaploAdViewController : UIViewController {
	UIImageView *adImg;
	NSMutableArray *adData;
	CGRect frame;
	NSString *appId;
	NSTimer *displayAdTimer;
	int currentAd;
	BOOL viewLoaded;
	MPMoviePlayerController *videoPlayer;
}
@property(nonatomic,retain)	MPMoviePlayerController *videoPlayer;
@property(nonatomic) BOOL viewLoaded;
@property(nonatomic,retain)	NSString *appId;
@property(nonatomic,retain)	UIImageView *adImg;
@property(nonatomic,retain)	NSMutableArray *adData;
@property(nonatomic) CGRect frame;
@property(nonatomic) int currentAd;
@property(nonatomic,retain)	NSTimer *displayAdTimer;
+(id)instance:(NSString*)aid;
-(void)startToDisplayAds:(id)obj;

//private
-(void)backgroundLoadAd:(NSString*)appId;
-(void)displayAdDetail:(id)sender;
-(void)fetchAds:(NSString*)aid;
-(void)displayAds:(id)obj;
-(void)appearAdView;
-(void)downloadVideo:(NSDictionary*)dic;
@end
