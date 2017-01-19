//
//  PYYShowImageCell.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "PYYShowImageCell.h"
#import "PYPhoto.h"

@implementation PYYShowImageCell
{
    __weak IBOutlet UIImageView *_showImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)refreshDefaultImage:(UIImage *)image {
    _showImage.image = image;
}

- (void)refreshModel:(PYPhoto *)model {
    if (model.smallUniquePath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // !< 加载本地图片
            NSData *data = [NSData dataWithContentsOfFile:model.smallUniquePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length > 0) {
                    _showImage.image = [UIImage imageWithData:data];
                } else {
                    model.smallUniquePath = nil;
                }
            });
        });
    } else if (model.bigUniquePaht) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfFile:model.bigUniquePaht];
    
                if (data.length > 0) {
                    UIImage *image = [self drawImage:[UIImage imageWithData:data]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _showImage.image = image;
                    });
                    
                    NSString *smallUniquePath = [self saveSmallIamge:image model:model];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.smallUniquePath = smallUniquePath;
                    });
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.bigUniquePaht = nil;
                    });
                }

        });

    } else if (model.URL && !model.isFailure) {
        //当做网络文件尝试访问
        // !< 加载网络图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.URL]];
            if (data.length > 0) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *smallImage = [self drawImage:image];
                    _showImage.image = smallImage;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSString *smallUniquePath = [self saveSmallIamge:smallImage model:model];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            model.smallUniquePath = smallUniquePath;
                        });
                    });
                });
                
                NSString *savePath = [PYPhoto py_writeWithUrl:model.URL data:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.bigUniquePaht = savePath;
                });
            } else {
                // 访问失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.failure = YES;
                });
            }
        });
    } else if (!model.isFailure && !model.URL) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:PYPhotoImageChangeToLocalNotification object:model];
    }
}

- (void)getNotification:(NSNotification *)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PYPhotoImageChangeToLocalNotification object:noti.object];
    [self refreshModel:(PYPhoto *)noti.object];
}

- (NSString *)saveSmallIamge:(UIImage *)image model:(PYPhoto *)model {
    NSString *smallStr = @"small";
    if (model.URL) {
        smallStr = [smallStr stringByAppendingString:model.URL];
    } else {
        NSTimeInterval time = [NSDate date].timeIntervalSince1970;
        NSString *timeStr = [NSString stringWithFormat:@"%f", time];
        smallStr = [smallStr stringByAppendingString:timeStr];;
    }
    return [PYPhoto py_writeWithUrl:smallStr data:UIImagePNGRepresentation(image)];
}

- (UIImage *)drawImage:(UIImage *)image {
    CGSize size = self.contentView.frame.size;
    CGSize imageSize = image.size;
    if (!(imageSize.height == imageSize.width)) {
        if (imageSize.height > imageSize.width) {
            size = CGSizeMake(size.width , size.width * imageSize.height/imageSize.width);
        } else {
            size = CGSizeMake(size.height * imageSize.width/imageSize.height, size.height);
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 2);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"length is %ld", [UIImagePNGRepresentation(currentImage) length]);
    return currentImage;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
