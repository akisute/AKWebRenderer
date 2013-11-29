//
//  TwitterWebRenderRequest.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TwitterWebRenderRequestMode_ {
    TwitterWebRenderRequestModeFullscreen = 0,
    TwitterWebRenderRequestModeSquareTopLeft,
    TwitterWebRenderRequestModeSquareCenter,
} TwitterWebRenderRequestMode;

@interface TwitterWebRenderRequest : NSObject
@property (nonatomic, copy) NSURL *url;
@property (nonatomic) TwitterWebRenderRequestMode mode;
+ (TwitterWebRenderRequest *)renderRequestWithURL:(NSURL *)url mode:(TwitterWebRenderRequestMode)mode;
@end
