//
//  PYYShowImageDrawImageCell.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "PYYShowImageDrawImageCell.h"
#import "NSString+PY_LinkSort.h"
#import <CommonCrypto/CommonDigest.h>

#ifndef DefaultIMG_STR
#define DefaultIMG_STR @"default_Log_01"
#endif
//获取Cache目录
UIKIT_STATIC_INLINE NSString* PYGetPath() {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    return cachePath;
}

@implementation PYYShowImageDrawImageCell
- (void)refreshImage:(id)obj callBack:(void (^ _Nonnull)(NSString * _Nonnull))callBack {
    if (obj == nil) {
        return;
    } else if ([obj isKindOfClass:[UIImage class]]) {
        [self drawImage:obj];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *data = UIImagePNGRepresentation(obj);
            NSString *path = [self py_writeWithUrl:[self getMD5WithData:data] data:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack) {
                    callBack(path);
                }
            });
        });
        
    } else if (![obj isKindOfClass:[NSString class]]) {
        return;
    } else {
        NSString *path = obj;
        if ([path isLocalFile]) {
            // !< 加载本地图片
            NSData *data = [NSData dataWithContentsOfFile:path];
            if (data.length > 0) {
                [self drawImage:[UIImage imageWithData:data]];
                if (callBack) {
                    callBack(path);
                }
            } else {
                if (callBack) {
                    callBack(DefaultIMG_STR);
                }
            }
        } else if ([path isUrl]) {
            // !< 加载网络图片
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
                if (data.length > 0) {
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self drawImage:image];
                    });
                    
                    
                    NSString *savePath = [self py_writeWithUrl:path data:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callBack) {
                            callBack(savePath);
                        }
                    });
                } else {
                    if (callBack) {
                        callBack(DefaultIMG_STR);
                    }
                }
            
            });
        } else {
            UIImage *image = [UIImage imageNamed:path];
            if (image) {
                [self drawImage:image];
            }
        }
    }
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
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.contentView.layer.contentsScale);
    [image drawInRect:CGRectMake(0, 0, self.contentView.frame.size.width * self.contentView.layer.contentsScale, self.contentView.frame.size.height * self.contentView.layer.contentsScale)];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return currentImage;
}

//创建文件
- (NSString *)py_writeWithUrl:(NSString *)url data:(NSData *)data {
    NSString *cache_Path = [PYGetPath() stringByAppendingPathComponent:[self md5:url]];
    // !< 查看文件是否存在
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:cache_Path];
    if (isExist ) {
        NSLog(@"文件已经存在");
        return cache_Path;
    }
    
    
    BOOL res=[[NSFileManager defaultManager] createFileAtPath:cache_Path contents:data attributes:nil];
    if (res) {
        NSLog(@"文件创建成功: %@" ,cache_Path);
        return cache_Path;
    }else {
        NSLog(@"文件创建失败");
        return DefaultIMG_STR;
    }
}

- (NSString*)md5:(NSString*)str
{
    if(!str||[str length]==0) return nil;
    const char*cStr =[str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
    return nil;
}

- (NSString*)getMD5WithData:(NSData *)data{
    const char* original_str = (const char *)[data bytes];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    
    //也可以定义一个字节数组来接收计算得到的MD5值
    //    Byte byte[16];
    //    CC_MD5(original_str, strlen(original_str), byte);
    //    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    //    for(int  i = 0; i<CC_MD5_DIGEST_LENGTH;i++){
    //        [outPutStr appendFormat:@"%02x",byte[i]];
    //    }
    //    [temp release];
    
    return [outPutStr lowercaseString];
    
}
@end
