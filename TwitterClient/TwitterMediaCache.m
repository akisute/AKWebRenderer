//
//  TwitterMediaCache.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterMediaCache.h"

@implementation TwitterMediaCache

+ (id)sharedCache
{
    static TwitterMediaCache* sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[TwitterMediaCache alloc] init];
    });
    return sharedCache;
}

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(id)completionHandler
{
    return NO;
}

@end
