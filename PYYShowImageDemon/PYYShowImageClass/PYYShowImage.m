//
//  PYYShowImage.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "PYYShowImage.h"
#import "PYYShowImageCell.h"

#ifndef UI_SCREEN_WIDTH
#define UI_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif

#ifndef UI_SCREEN_HEIGHT
#define UI_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

UIKIT_STATIC_INLINE CGSize PYGetSize(NSInteger count, CGFloat spacingLR, CGFloat spacingM) {
    CGFloat width = (UI_SCREEN_WIDTH - spacingLR * 2 - spacingM * (count - 1)) / count;
    return CGSizeMake(width, width);
}

@interface PYYShowImage () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;



/** 小图的Size */
@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CGFloat height;
@end

@implementation PYYShowImage
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initProperty];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
    }
    return self;
}

- (void)startInitUI {
    self.size = PYGetSize(_count, _spacingLF, _spacing);
    [self addSubview:self.collectionView];
    self.height = _size.height + _spacingTB * 2;
}

#pragma mark ---------- 初始化默认属性
- (void)initProperty {
    self.count = 5;
    self.spacing = 12.0f;
    self.spacingLF = 11.0f;
    self.spacingTB = 15.0f;
}


#pragma mark ---------- getter
- (UICollectionView *)collectionView {
    if (_collectionView) {
        return _collectionView;
    }
    return _collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = _size;
        flowLayout.minimumLineSpacing =  _spacing;
        flowLayout.minimumInteritemSpacing = _spacing;
        
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(_spacingLF, _spacingTB, UI_SCREEN_WIDTH - 2 * _spacingLF, _size.height) collectionViewLayout:flowLayout];
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = [UIColor clearColor];
        
        [view registerNib:[UINib nibWithNibName:NSStringFromClass([PYYShowImageCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
        
        view;
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PYYShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString *str = @"http://www.people.com.cn/mediafile/pic/20140611/53/2881261099810828949.jpg";
    [cell refreshImage:str callBack:^(NSString * _Nonnull path) {
        NSLog(@"path is %@", path);
    }];
    return cell;
}
@end













