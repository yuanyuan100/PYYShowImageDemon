//
//  PYYShowImageScrollVIewVCViewController.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/19.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PYPhoto;

@interface PYYShowImageScrollVIewVCViewController : UIViewController
- (instancetype)initWithImageArray:(NSArray<PYPhoto *> *)array index:(NSUInteger)index;
@property (nonatomic, strong) void(^DeleIndexBlock)(PYPhoto *);
@end
