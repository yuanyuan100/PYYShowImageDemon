//
//  PYYShowImage.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "PYYShowImage.h"
#import "PYYShowImageCell.h"
#import "PYPhoto.h"

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
@property (nonatomic, strong) NSMutableArray<PYPhoto *> *dataSource;

/** 小图的Size */
@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CGFloat height;
@end

@implementation PYYShowImage
-(instancetype)initWithImageArray:(NSArray<PYPhoto *> *)array {
    self = [self init];
    [self.dataSource addObjectsFromArray:array];
    return self;
}
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
    [self setupViewFrame];
}

- (void)setupViewFrame {
    self.height = _size.height + _size.height * self.dataSource.count / _count + _spacingTB * 2 + _spacing * self.dataSource.count / _count;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.height);
    _collectionView.frame = CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, self.height -  _spacingTB * 2);
}

- (void)addImageArray:(NSArray<PYPhoto *> *)array {
    [self.dataSource addObjectsFromArray:array];
    [self setupViewFrame];
    [_collectionView reloadData];
}

- (NSArray<PYPhoto *> *)getImageArray {
    return _dataSource;
}

#pragma mark ---------- 初始化默认属性
- (void)initProperty {
    self.count = 5;
    self.spacing = 12.0f;
    self.spacingLF = 11.0f;
    self.spacingTB = 15.0f;
    self.number = 5;
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
        view.bounces = NO;
        
        [view registerNib:[UINib nibWithNibName:NSStringFromClass([PYYShowImageCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
        
        view;
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_number <= self.dataSource.count) {
        return _number;
    }
    return self.dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PYYShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.item == self.dataSource.count && _number != self.dataSource.count) {
        // 最后一个为增加item
        [cell refreshDefaultImage:[UIImage imageNamed:@"PYYShow_AddImage@2x"]];
    } else {
        [cell refreshModel:self.dataSource[indexPath.item]];
    }
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.dataSource.count && _number != self.dataSource.count) {
        // 最后一个为增加item
        if (self.AddImageBlock) {
            NSArray<PYPhoto*> *dataSource = self.AddImageBlock(_number - indexPath.item - 1);
            if (dataSource.count > 0) {
                [self.dataSource addObjectsFromArray:dataSource];
                [self setupViewFrame];
                [collectionView reloadData];
            }
        }
    } else {
        if (self.SeeBigImageBlock) {
            NSArray<PYPhoto *> *deleArr = self.SeeBigImageBlock(self.dataSource, indexPath.item);
            for (PYPhoto *deleModel in deleArr) {
                [self.dataSource removeObject:deleModel];
            }
            if (deleArr.count > 0) {
                [self setupViewFrame];
                [collectionView reloadData];
            }
        }
        
    }
}

- (NSMutableArray<PYPhoto *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}
@end













