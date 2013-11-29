//
//  TwitterMediaCache.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h> // Requires UIKit and views, might not work in XCTest environment

typedef void (^TwitterMediaCacheImageCompletionHandler)(UIImage *image);
typedef void (^TwitterMediaCacheSnapshotViewCompletionHandler)(UIView *view);

@interface TwitterMediaCache : NSObject

+ (id)sharedCache;

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(TwitterMediaCacheImageCompletionHandler)completionHandler;
- (BOOL)snapshotViewWithURL:(NSURL *)url completionHandler:(TwitterMediaCacheSnapshotViewCompletionHandler)completionHandler;

@end
