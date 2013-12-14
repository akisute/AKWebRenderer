//
//  AKWebRenderRequest.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum AKWebRenderRequestMode_ {
    AKWebRenderRequestModeFullscreen = 0,
    AKWebRenderRequestModeSquareTopLeft,
    AKWebRenderRequestModeSquareCenter,
} AKWebRenderRequestMode;

@interface AKWebRenderRequest : NSObject
@property (nonatomic, copy) NSURL *url;
@property (nonatomic) AKWebRenderRequestMode mode;
+ (AKWebRenderRequest *)renderRequestWithURL:(NSURL *)url mode:(AKWebRenderRequestMode)mode;
@end
