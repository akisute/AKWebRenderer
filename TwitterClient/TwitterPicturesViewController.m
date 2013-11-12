//
//  TwitterPicturesViewController.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/02.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewController.h"

#import "TwitterPicturesViewTextCell.h"
#import "TwitterPicturesViewWebCell.h"
#import "TwitterPicturesViewImageCell.h"
#import "PictureDetailViewController.h"

#import "TwitterAPIManager.h"
#import "MTweets.h"

@interface TwitterPicturesViewController ()

@end

@implementation TwitterPicturesViewController


#pragma mark - UIViewController


- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[TwitterAPIManager sharedManager] GET:@"" params:nil completionHandler:^(id jsonObject, NSURLResponse *response, NSError *error) {
        NSArray *tweetObjects = jsonObject;
        for (NSDictionary *tweetObject in tweetObjects) {
            MTweets *tweet = [[MTweets alloc] initWithJSONObject:tweetObject];
            [MTweets insertNewObject:tweet];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [MTweets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *allTweets = [MTweets allObjects];
    MTweets *tweet = allTweets[indexPath.row];
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    switch (tweet.tweetType) {
        case MTWeetsTypeText:
        {
            TwitterPicturesViewTextCell *cell = (TwitterPicturesViewTextCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TwitterPicturesViewTextCell class]) forIndexPath:indexPath];
            cell.textView.text = tweet.text;
            return cell;
        }
        case MTWeetsTypeWeb:
        {
            TwitterPicturesViewWebCell *cell = (TwitterPicturesViewWebCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TwitterPicturesViewWebCell class]) forIndexPath:indexPath];
            cell.URLLabel.text = [tweet.urls.firstObject description];
            return cell;
        }
        case MTWeetsTypeImage:
        {
            TwitterPicturesViewImageCell *cell = (TwitterPicturesViewImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TwitterPicturesViewImageCell class]) forIndexPath:indexPath];
            // TODO: load image with URL
            return cell;
        }
        default:
            return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *viewIdentifier = @"View";
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:viewIdentifier forIndexPath:indexPath];
    
    return view;
}

#pragma mark - IBAction


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TwitterPicturesViewImageCell *cell = sender;
    if ([segue.identifier isEqualToString:@"PictureDetailViewController"]) {
        PictureDetailViewController *pictureDetailViewController = (PictureDetailViewController *)segue.destinationViewController;
        pictureDetailViewController.picture = cell.imageView.image;
    }
}

- (IBAction)dismissPictureDetailViewController:(UIStoryboardSegue *)segue
{
}


@end
