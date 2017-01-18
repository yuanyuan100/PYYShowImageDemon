//
//  PYYShowImage.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYYShowImage : UIView

/** 小图的Size */
@property (nonatomic, readonly, assign) CGSize size;
@property (nonatomic, readonly, assign) CGFloat height;

/** 一行展示个数 */
@property (nonatomic, assign) NSInteger count; // default 5
/** 每个item直接的spacing */
@property (nonatomic, assign) CGFloat spacing; // default 12.0f;
/** 距离屏幕左右的距离 */
@property (nonatomic, assign) CGFloat spacingLF; // default 11.0f;
/** 距离屏幕上下的距离 */
@property (nonatomic, assign) CGFloat spacingTB; // default 15.0f;
/**
 如果需要修改默认属性，则在调用该方法前修改
 */
- (void)startInitUI;

@property (nonatomic, strong) UIImage *image;
/** 网络地址 或者 本地地址 */
@property (nonatomic, copy) NSString *URL;


@end
