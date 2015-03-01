//
//  bridging-header.h
//  Story1
//
//  Created by James Nocentini on 03/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NMRangeSlider.h"
#import "LLACircularProgressView.h"
#import <CommonCrypto/CommonCrypto.h>
#import "JSONModelLib.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface CBLModel()
- (instancetype) initWithDocument: (nullable CBLDocument*)document
                       orDatabase: (nullable CBLDatabase*)database NS_DESIGNATED_INITIALIZER;
@end