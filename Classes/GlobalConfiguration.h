//
//  GlobalConfiguration.h
//  iSpeak
//
//  Created by Junqiang You on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GlobalConfiguration : NSObject {

	int appPrivilege;

	NSString *osVersion;
	NSString *deviceId;
	NSString *appPath;
	NSString *docPath;
}
@property(nonatomic, retain) NSString *osVersion;
@property(nonatomic, retain) NSString *deviceId;
@property int appPrivilege;
@property(nonatomic, retain) NSString *appPath;
@property(nonatomic, retain) NSString *docPath;
-(void)saveToFile;
-(BOOL)isOS3;
-(NSString*)decodeDeviceSpecificString:(NSString*)encodedString;
-(NSString*)encodeDeviceSpecificString:(NSString*)inputString;
@end
