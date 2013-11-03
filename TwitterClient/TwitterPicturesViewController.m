//
//  TwitterPicturesViewController.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/02.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewController.h"
#import "PictureDetailViewController.h"

@interface TwitterPicturesViewController ()

@end

@implementation TwitterPicturesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
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
    if ([segue.identifier isEqualToString:@""]) {
        PictureDetailViewController *pictureDetailViewController = (PictureDetailViewController *)segue.destinationViewController;
        pictureDetailViewController.pictureImageView.image = nil;
    }
}

- (IBAction)dismissPictureDetailViewController:(UIStoryboardSegue *)segue
{
}


@end
