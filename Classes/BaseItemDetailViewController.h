//
//  BaseItemDetailViewController.h
//  USRecall
//
//  Created by Junqiang You on 7/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgrammaticAdViewController.h"

@interface BaseItemDetailViewController : ProgrammaticAdViewController <UIScrollViewDelegate, UIWebViewDelegate> {

	NSDictionary *element;


	IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
   
	NSMutableArray *views;
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
	UIActivityIndicatorView *spin;
}
@property(nonatomic,copy) NSDictionary *element;
@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, retain) UIActivityIndicatorView *spin;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
-(void)email:(id)sender;
- (void)changePage:(int)page;
- (id)initWithElement:(NSDictionary*)e;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void)segmentAction:(id)sender;
-(void)loadUrl:(NSString*)urlString toWebView:(UIWebView*)uv;
@end
