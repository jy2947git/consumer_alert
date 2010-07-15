//
//  FocaploAdView.m
//  USRecall
//
//  Created by Junqiang You on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FocaploAdView.h"


@implementation FocaploAdView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0,30, 220, 48)];
		message.text=@"test";
		message.textColor=[UIColor blackColor];
		//message.backgroundColor=[UIColor blackColor];
		[self addSubview:message];
		[message release];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	[(UIView*)[[self subviews] objectAtIndex:0] setNeedsDisplay];
}


- (void)dealloc {
    [super dealloc];
}


@end
