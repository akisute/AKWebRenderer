//
//  MTweetMediaObject.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/14.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MTweetMediaType_ {
    MTweetMediaTypeUnknown = 0,
    MTweetMediaTypePhoto,
} MTweetMediaType;

/*
 * Refer followin API docs for more info:
 * https://dev.twitter.com/docs/platform-objects/entities
 */
@interface MTweetMediaObject : NSObject

- (id)initWithJSONObject:(NSDictionary *)jsonObject;

@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSURL *expandedURL;
@property (nonatomic, copy) NSURL *mediaURL;
@property (nonatomic, copy) NSString *displayURLString;

@property (nonatomic) CGSize thumbnailSize; // always resize=crop
@property (nonatomic) CGSize smallSize;     // always resize=fit
@property (nonatomic) CGSize mediumSize;    // always resize=fit
@property (nonatomic) CGSize largeSize;     // always resize=fit

@property (nonatomic) MTweetMediaType mediaType; // Only supports "photo" for now

@end
