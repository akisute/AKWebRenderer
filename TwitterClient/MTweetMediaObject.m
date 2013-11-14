//
//  MTweetMediaObject.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/14.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "MTweetMediaObject.h"

@implementation MTweetMediaObject

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        if ([jsonObject[@"type"] isEqualToString:@"photo"]) {
            self.mediaType = MTweetMediaTypePhoto;
            self.mediaID            = jsonObject[@"id_str"];
            self.url                = [NSURL URLWithString:jsonObject[@"url"]];
            self.expandedURL        = [NSURL URLWithString:jsonObject[@"expanded_url"]];
            self.mediaURL           = [NSURL URLWithString:jsonObject[@"media_url"]];
            self.displayURLString   = jsonObject[@"display_url"];
            
            self.thumbnailSize      = CGSizeMake([jsonObject[@"sizes"][@"thumb"][@"w"] floatValue], [jsonObject[@"sizes"][@"thumb"][@"h"] floatValue]);
            self.smallSize          = CGSizeMake([jsonObject[@"sizes"][@"small"][@"w"] floatValue], [jsonObject[@"sizes"][@"small"][@"h"] floatValue]);
            self.mediumSize         = CGSizeMake([jsonObject[@"sizes"][@"medium"][@"w"] floatValue], [jsonObject[@"sizes"][@"medium"][@"h"] floatValue]);
            self.largeSize          = CGSizeMake([jsonObject[@"sizes"][@"large"][@"w"] floatValue], [jsonObject[@"sizes"][@"large"][@"h"] floatValue]);
        } else {
            // Unsupported media type
            return nil;
        }
    }
    return self;
}

@end
