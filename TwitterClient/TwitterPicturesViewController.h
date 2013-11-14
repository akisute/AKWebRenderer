//
//  TwitterPicturesViewController.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/02.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterPicturesViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)refresh:(id)sender;
- (IBAction)dismissPictureDetailViewController:(UIStoryboardSegue *)segue;
- (IBAction)dismissWebViewController:(UIStoryboardSegue *)segue;

@end
