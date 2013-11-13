//
//  MTweetURLObject.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/13.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "MTweetURLObject.h"

@implementation MTweetURLObject

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        self.url                = [NSURL URLWithString:jsonObject[@"url"]];
        self.expandedURL        = [NSURL URLWithString:jsonObject[@"expanded_url"]];
        self.displayURLString   = jsonObject[@"display_url"];
    }
    return self;
}

@end
