/*
 *  GlobalHeader.h
 *  mylocal
 *
 *  Created by Junqiang You on 5/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#import"DebugLog.h"

#ifdef DEBUG

#define DebugLog(args...) _DebugLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);

#else

#define DebugLog(x...)

#endif

#ifndef serverHost
#ifdef DEBUG
#define serverHost @"localhost:8082" /**/
#else
#define serverHost @"senselocal.appspot.com"
#endif
#endif

#ifndef requestToken
#define requestToken @"29073429202020128953"
#endif

#ifndef FREE_APP
#define FREE_APP 0
#endif

#ifndef STANDARD_APP
#define STANDARD_APP 5
#endif

#ifndef appRelease
#define appRelease STANDARD_APP
#endif
