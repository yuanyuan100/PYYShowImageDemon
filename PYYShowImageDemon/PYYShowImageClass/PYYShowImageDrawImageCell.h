//
//  PYYShowImageDrawImageCell.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYYShowImageDrawImageCell : UICollectionViewCell
/**
 更新
 
 @param obj 图片来源 UIIimage NSString(URL or localPath)
 @param callBack 将原图存储在沙盒的地址返回，若加载原图失败，则返回一个默认图片的名字
 */
- (void)refreshImage:(nonnull id)obj callBack:(void( ^ _Nonnull )( NSString * _Nonnull path))callBack;
@end
