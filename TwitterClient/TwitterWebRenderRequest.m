//
//  TwitterWebRenderRequest.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterWebRenderRequest.h"

@implementation TwitterWebRenderRequest

+ (TwitterWebRenderRequest *)renderRequestWithURL:(NSURL *)url mode:(TwitterWebRenderRequestMode)mode
{
    TwitterWebRenderRequest *renderRequest = [[TwitterWebRenderRequest alloc] init];
    renderRequest.url = url;
    renderRequest.mode = mode;
    return renderRequest;
}

@end
