//
//  PYYShowImageCell.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PYPhoto;

@interface PYYShowImageCell : UICollectionViewCell
- (void)refreshModel:(PYPhoto *)model;
- (void)refreshDefaultImage:(UIImage *)image;
@end
