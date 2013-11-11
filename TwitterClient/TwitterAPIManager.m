//
//  TwitterAPIManager.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterAPIManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterAPIManager ()
@property (nonatomic) ACAccount *account;
@end

@implementation TwitterAPIManager

+ (id)sharedManager
{
    static TwitterAPIManager* sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TwitterAPIManager alloc] init];
    });
    return sharedManager;
}

- (void)requestAccessTokenWithCompletionHandler:(void (^)(BOOL granted, NSError *error))completionHandler
{
    void (^callback)(BOOL granted, NSError *error) = [completionHandler copy]; //void (^callback)(BOOL, NSError *) = [completionHandler copy]; でも問題ない。blocksの引数名はあってもなくても同じ型みたいだ
    __weak TwitterAPIManager *__self = self;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error) {
                                           if (granted){
                                               NSArray *availableAccounts = [accountStore accountsWithAccountType:accountType];
                                               if (availableAccounts.count) {
                                                   // Access Granted, accounts available
                                                   __self.account = [availableAccounts firstObject];
                                                   callback(granted, error);
                                               } else {
                                                   // Access Granted, but no accounts available
                                                   // Callback with an error object to indicate no accounts are available
                                                   NSError *e = [NSError errorWithDomain:ACErrorDomain code:ACErrorFetchCredentialFailed userInfo:nil];
                                                   callback(granted, e);
                                               }
                                           } else {
                                               // Access Denied
                                               // Callback
                                               callback(granted, error);
                                           }
                                       }];
}

- (BOOL)GET:(NSString *)path params:(NSDictionary *)params completionHandler:(TwitterAPICompletionHandler)completionHandler
{
    if (self.account) {
        return [self __GET:path params:params completionHandler:completionHandler];
    } else {
        TwitterAPICompletionHandler callback = [completionHandler copy];
        [self requestAccessTokenWithCompletionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                if (error) {
                    // Access Granted, but something is wrong
                    // callback with error
                    callback(nil, nil, error);
                } else {
                    // Access Granted, API call is ready
                    [self __GET:path params:params completionHandler:callback];
                }
            } else {
                // Access Denied
                // callback with error
                callback(nil, nil, error);
            }
        }];
        return YES;
    }
}

- (BOOL)__GET:(NSString *)path params:(NSDictionary *)params completionHandler:(TwitterAPICompletionHandler)completionHandler
{
    // TODO: do not fix urlstring here. instead, append path to the API base url.
    // TODO: setup nsurlsessio before here
    NSString *urlString = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:urlString]
                                               parameters:params];
    request.account = self.account;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    TwitterAPICompletionHandler callback = [completionHandler copy];
    
    [[session dataTaskWithRequest:[request preparedURLRequest]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    if (callback) {
                        callback(jsonObject, response, error);
                    }
                }] resume];
    
    return YES;
}

@end
