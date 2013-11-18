//
//  TwitterMediaCache.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterMediaCache : NSObject

+ (id)sharedCache;

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(id)completionHandler;

@end
