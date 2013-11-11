//
//  TwitterAPIManager.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TwitterAPICompletionHandler)(id jsonObject, NSURLResponse *response, NSError *error);

@interface TwitterAPIManager : NSObject

+ (id)sharedManager;

- (BOOL)GET:(NSString *)path params:(NSDictionary *)params completionHandler:(TwitterAPICompletionHandler)completionHandler;

@end
