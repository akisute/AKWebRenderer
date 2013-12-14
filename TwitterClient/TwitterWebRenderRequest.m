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

- (NSUInteger)hash
{
    return [self.url hash] + self.mode;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TwitterWebRenderRequest class]]) {
        TwitterWebRenderRequest *request = object;
        return [self.url isEqual:request.url] && self.mode == request.mode;
    }
    return NO;
}

@end
