//
//  ;
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/19.
//  Copyright © 2017年 IAsk. All rights reserved.
//

//** 放大的话则只放大imageview 仅移动imageview，当imageview到达边界时再移动scrollview *//

#import "PYYShowImageScrollVIewVCViewController.h"
#import "PYPhoto.h"
#import "NSString+PY_LinkSort.h"


#ifndef UI_SCREEN_WIDTH
#define UI_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif

#ifndef UI_SCREEN_HEIGHT
#define UI_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

typedef NS_ENUM(NSUInteger, PYYShowImageScrollViewPosition) {
    PYYShowImageScrollViewPositionMiddle,
    PYYShowImageScrollViewPositionLeft,
    PYYShowImageScrollViewPositionRight,
};

@interface PYYShowImageScrollVIewVCViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageL;
@property (nonatomic, strong) UIImageView *imageM;
@property (nonatomic, strong) UIImageView *imageR;
//@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *textNumber;
@property (nonatomic, strong) UIView *realTopView;

@property (nonatomic, strong) NSMutableArray<PYPhoto*> *dataSource;
@property (nonatomic, assign) NSInteger imageCount;
/** 当前展示的位置 */
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) PYYShowImageScrollViewPosition position;

@property (nonatomic, strong) void(^LoadSmallBlock)();
@end

@implementation PYYShowImageScrollVIewVCViewController
{
    CGPoint _tempContentOffset;
}

- (instancetype)initWithImageArray:(NSArray<PYPhoto *> *)array index:(NSUInteger)index{
    if (self = [self init]) {
        self.imageCount = array.count;
        self.index = index;
        [self.dataSource addObjectsFromArray:array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollView];
//    [self.view addSubview:self.activityView];
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"PYYTopView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 64);
    self.textNumber.text = [NSString stringWithFormat:@"%ld/%ld", _index+1, self.dataSource.count];
    [self.view addSubview:view];
    self.realTopView = view;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCurrent)];
    [self.scrollView addGestureRecognizer:tap];
    
    [self showImage];
}

- (void)clickCurrent {
    if (self.realTopView.frame.origin.y == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.realTopView.frame = CGRectMake(0, -64, UI_SCREEN_WIDTH, 64);
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.realTopView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 64);
        }];
    }
}

#pragma mark --------- showImage
- (void)showImage {
    switch (self.dataSource.count) {
        case 1:
            [self asyncCurrentImage:self.imageL model:self.dataSource[_index]];
            self.position = PYYShowImageScrollViewPositionLeft;
            break;
        case 2:
            if (_index == 0) {
                [self asyncCurrentImage:self.imageL model:self.dataSource[_index]];
                [self asyncLoadImage:self.imageM model:self.dataSource[1]];
                self.position = PYYShowImageScrollViewPositionLeft;
                _tempContentOffset = CGPointMake(0, 0);
                self.scrollView.contentOffset = _tempContentOffset;
            } else {
                [self asyncCurrentImage:self.imageM model:self.dataSource[_index]];
                [self asyncLoadImage:self.imageL model:self.dataSource[0]];
                self.position = PYYShowImageScrollViewPositionMiddle;
                _tempContentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
                self.scrollView.contentOffset = _tempContentOffset;
            }
            break;
        default:
            [self asyncCurrentImage:self.imageM model:self.dataSource[_index]];
            [self asyncLoadImage:self.imageL model:self.dataSource[[self dealCurrentIndex:-1 realIndex:_index]]];
            [self asyncLoadImage:self.imageR model:self.dataSource[[self dealCurrentIndex:1 realIndex:_index]]];
            self.position = PYYShowImageScrollViewPositionMiddle;
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (CGPointEqualToPoint(_tempContentOffset, scrollView.contentOffset)) {
        return;
    }
    if (_tempContentOffset.x > scrollView.contentOffset.x) {
        self.position = PYYShowImageScrollViewPositionLeft;
        if (self.dataSource.count >= 3) {
            // 需要归位到中间
            self.position = PYYShowImageScrollViewPositionMiddle;
            _tempContentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
            [self asyncCurrentImage:self.imageM model:self.dataSource[[self dealCurrentIndex: -1 realIndex:_index]]];
            NSUInteger recoderIndex = _index;
            self.index = [self dealCurrentIndex:-1 realIndex:_index];
            __weak typeof(self) weakSelf = self;
            self.LoadSmallBlock = ^void() {
                [weakSelf asyncLoadImage:weakSelf.imageL model:weakSelf.dataSource[[weakSelf dealCurrentIndex: -2 realIndex:[weakSelf checkRealIndex:recoderIndex]]]];
                [weakSelf asyncLoadImage:weakSelf.imageR model:weakSelf.dataSource[[weakSelf checkRealIndex:recoderIndex]]];
                
            };

            
        } else if (self.dataSource.count == 2) {
            self.index = 0;
            [self asyncCurrentImage:self.imageL model:self.dataSource[0]];
            [self asyncLoadImage:self.imageM model:self.dataSource[1]];
            _tempContentOffset = scrollView.contentOffset;
        } else if (self.dataSource.count == 1) {
            self.index = 0;
            [self asyncCurrentImage:self.imageL model:self.dataSource[0]];
            
        }
    } else {
        self.position = PYYShowImageScrollViewPositionRight;
        if (self.dataSource.count >= 3) {
            // 需要归位到中间
            self.position = PYYShowImageScrollViewPositionMiddle;
            _tempContentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
            [self asyncCurrentImage:self.imageM model:self.dataSource[[self dealCurrentIndex:1 realIndex:_index]]];
            NSUInteger recoderIndex = _index;
            self.index = [self dealCurrentIndex:1 realIndex:_index];
            __weak typeof(self) weakSelf = self;
            self.LoadSmallBlock = ^void() {
                [weakSelf asyncLoadImage:weakSelf.imageL model:weakSelf.dataSource[[weakSelf checkRealIndex:recoderIndex]]];
                [weakSelf asyncLoadImage:weakSelf.imageR model:weakSelf.dataSource[[weakSelf dealCurrentIndex:2 realIndex:[weakSelf checkRealIndex:recoderIndex]]]];
                
            };
            
            
        } else if (self.dataSource.count == 2) {
            self.index = 1;
            [self asyncCurrentImage:self.imageM model:self.dataSource[1]];
            [self asyncLoadImage:self.imageL model:self.dataSource[0]];
            self.position = PYYShowImageScrollViewPositionMiddle;
            
            _tempContentOffset = scrollView.contentOffset;
        } else if (self.dataSource.count == 1) {
            self.index = 0;
            [self asyncCurrentImage:self.imageL model:self.dataSource[0]];
        }
    }
}

- (NSInteger)dealCurrentIndex:(NSInteger)i realIndex:(NSUInteger)index{
    NSInteger temp = index + i;
    if (temp < 0) {
        temp = self.dataSource.count + temp;
    } else if (temp > self.dataSource.count - 1) {
        temp = temp - self.dataSource.count;
    }
    return temp;
}

- (NSInteger)checkRealIndex:(NSUInteger)index {
    NSInteger temp = index;
    if (temp < 0) {
        temp = self.dataSource.count + temp;
    } else if (temp > self.dataSource.count - 1) {
        temp = temp - self.dataSource.count;
    }
    return temp;
}

// 展示时加载的图片
- (void)asyncCurrentImage:(UIImageView *)imageView model:(PYPhoto *)model {
//    if (!self.activityView.isAnimating) {
//        [self.activityView startAnimating];
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([model.bigUniquePaht isLocalFile]) {
            NSData *data = [NSData dataWithContentsOfFile:model.bigUniquePaht];
            if (data.length > 0) {
                [self asyncNotiMain:imageView image:[UIImage imageWithData:data] stop:YES];
            }
        }
    });
}

// 隐藏时加载的图片
- (void)asyncLoadImage:(UIImageView *)imageView model:(PYPhoto *)model {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([model.smallUniquePath isLocalFile]) {
            NSData *data = [NSData dataWithContentsOfFile:model.smallUniquePath];
            [self asyncNotiMain:imageView image:[UIImage imageWithData:data] stop:NO];
        } else if (model.bigUniquePaht && ![model.bigUniquePaht isLocalFile]) {
            // 存的默认图片
            [self asyncNotiMain:imageView image:[UIImage imageNamed:model.bigUniquePaht] stop:NO];
        }
    });
}

- (void)asyncNotiMain:(UIImageView *)imageView image:(UIImage *)image stop:(BOOL)isStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isStop) {
            // 调整imageView frame
            [self changeFrame:imageView image:image];
            if (_position == PYYShowImageScrollViewPositionMiddle) {
                [_scrollView setContentOffset:_tempContentOffset animated:NO];
                if (self.LoadSmallBlock) {
                    self.LoadSmallBlock();
                }
            }
        }
        imageView.image = image;
//        if (self.activityView.isAnimating && isStop) {
//            [self.activityView stopAnimating];
//        }
    });
}

- (void)changeFrame:(UIImageView *)imageView image:(UIImage *)image {
    CGSize imageSize = image.size;
    CGPoint center = imageView.center;
    CGRect frame = imageView.frame;
    
    if (imageSize.width >= imageSize.height) {
        CGFloat height = UI_SCREEN_WIDTH * imageSize.height / imageSize.width;
        imageView.frame = CGRectMake(frame.origin.x,\
                                     center.y - height/2,\
                                     UI_SCREEN_WIDTH,\
                                     height);
    } else {
        CGFloat width = UI_SCREEN_HEIGHT * imageSize.width / imageSize.height;
        imageView.frame = CGRectMake(center.x - width / 2,\
                                     frame.origin.y,\
                                     width,\
                                     UI_SCREEN_HEIGHT);
    }
}

#pragma mark -------- event response
- (IBAction)cancelBack:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBar.hidden = NO;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)deleImage:(id)sender {
    if (self.DeleIndexBlock) {
        self.DeleIndexBlock(self.dataSource[_index]);
    }
    [self.dataSource removeObjectAtIndex:_index];
    
    if (self.dataSource.count == 0) {
        [self cancelBack:nil];
    } else if (self.dataSource.count == 1) {
        self.index = 0;
    }
    
    if (self.position == PYYShowImageScrollViewPositionMiddle) {
        if (self.dataSource.count == 2) {
            self.position = PYYShowImageScrollViewPositionRight;
            [_scrollView setContentOffset:CGPointMake(UI_SCREEN_WIDTH * 2, 0)];
        } else {
            self.position = PYYShowImageScrollViewPositionLeft;
            [_scrollView setContentOffset:CGPointMake(0, 0)];
        }
        
        [self scrollViewDidEndDecelerating:_scrollView];
    } else if (self.position == PYYShowImageScrollViewPositionLeft) {
        [_scrollView setContentOffset:CGPointMake(UI_SCREEN_WIDTH, 0)];
        [self scrollViewDidEndDecelerating:_scrollView];
        
    }
    
    self.imageCount = self.dataSource.count;
}

#pragma mark --------- setter
- (void)setImageCount:(NSInteger)imageCount {
    _imageCount = imageCount;
    
    if (imageCount == 1){
        self.scrollView.contentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        self.scrollView.contentOffset = CGPointMake(0, 0);
    } else if (imageCount == 2) {
        self.scrollView.contentSize = CGSizeMake(UI_SCREEN_WIDTH * 2, UI_SCREEN_HEIGHT);
        self.imageR.hidden = YES;
        switch (_position) {
            case PYYShowImageScrollViewPositionMiddle:
                self.scrollView.contentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
                break;
            case PYYShowImageScrollViewPositionLeft:
                self.scrollView.contentOffset = CGPointMake(0, 0);
                break;
            case PYYShowImageScrollViewPositionRight:
                self.scrollView.contentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
                break;
        }
        self.scrollView.contentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
    } else {
        self.scrollView.contentSize = CGSizeMake(UI_SCREEN_WIDTH * 3, UI_SCREEN_HEIGHT);
        self.scrollView.contentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
    }
    
    
    
    
    _tempContentOffset = self.scrollView.contentOffset;
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    
    self.textNumber.text = [NSString stringWithFormat:@"%ld/%ld", index+1, self.dataSource.count];
}

#pragma mark --------- getter
- (UIScrollView *)scrollView {
    if (_scrollView) {
        return _scrollView;
    }
    return _scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.bounces = YES;
        scrollView.contentSize = CGSizeMake(UI_SCREEN_WIDTH * 3, UI_SCREEN_HEIGHT);
        scrollView.contentOffset = CGPointMake(UI_SCREEN_WIDTH, 0);
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        
        [scrollView addSubview:self.imageL];
        [scrollView addSubview:self.imageM];
        [scrollView addSubview:self.imageR];
        
        
        scrollView;
    });
}

- (NSMutableArray<PYPhoto *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UIImageView *)imageL {
    if (_imageL) {
        return _imageL;
    }
    return _imageL = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        imageView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
}
- (UIImageView *)imageM {
    if (_imageM) {
        return _imageM;
    }
    return _imageM = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(UI_SCREEN_WIDTH, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        imageView.center = CGPointMake(UI_SCREEN_WIDTH/2 + UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT/2);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
}
- (UIImageView *)imageR {
    if (_imageR) {
        return _imageR;
    }
    return _imageR = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(UI_SCREEN_WIDTH * 2, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        imageView.center = CGPointMake(UI_SCREEN_WIDTH/2 + UI_SCREEN_WIDTH * 2, UI_SCREEN_HEIGHT/2);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
}

//- (UIActivityIndicatorView *)activityView {
//    if (_activityView) {
//        return _activityView;
//    }
//    return _activityView = ({
//        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH / 2 - 25, UI_SCREEN_HEIGHT / 2 - 25, 50, 50)];
//        view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//        view.hidesWhenStopped = YES;
//        if (view.isAnimating) {
//            [view stopAnimating];
//        }
//        
//        view;
//    });
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
