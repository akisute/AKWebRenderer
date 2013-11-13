//
//  MTweetURLObject.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/13.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTweetURLObject : NSObject

- (id)initWithJSONObject:(NSDictionary *)jsonObject;

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSURL *expandedURL;
@property (nonatomic, copy) NSString *displayURLString;

@end
