//
//  PYPhoto.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/19.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "PYPhoto.h"
#import "NSString+PY_LinkSort.h"
#import <CommonCrypto/CommonDigest.h>

#ifndef DefaultIMG_STR
#define DefaultIMG_STR @"default_Log_01"
#endif

NSString * const PYPhotoImageChangeToLocalNotification = @"PYPhotoImageChangeToLocalNotification";

@implementation PYPhoto
- (void)addImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = UIImagePNGRepresentation(image);
        NSString *path = [PYPhoto py_writeWithUrl:[PYPhoto getMD5WithData:data] data:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bigUniquePaht = path;
            [[NSNotificationCenter defaultCenter] postNotificationName:PYPhotoImageChangeToLocalNotification object:self];
        });
    });
}

- (void)setURL:(NSString *)URL {
    _URL = URL;
    if ([URL isLocalFile]) {
     // 本地存在的文件路径
        self.bigUniquePaht = URL;
    } else {
        // 将网络图片与本地图片做映射，以免同一地址的图片多少次加载
        NSString *localPath = [PYPhoto py_findWithUrl:URL];
        if (localPath) {
            self.bigUniquePaht = localPath;
        }
    }
}

///========================以下工具方法

+ (NSString*)md5:(NSString*)str
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

+ (NSString*)getMD5WithData:(NSData *)data{
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
//
+ (NSString *)py_findWithUrl:(NSString *)url {
    NSString *cache_Path = [PYGetPath() stringByAppendingPathComponent:[self md5:url]];
    // !< 查看文件是否存在
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:cache_Path];
    if (isExist ) {
        NSLog(@"文件已经存在");
        return cache_Path;
    } else {
        return nil;
    }
}
//创建文件
+ (NSString *)py_writeWithUrl:(NSString *)url data:(NSData *)data {
    NSString *cache_Path = nil;
    if (!url) {
        cache_Path = [self getMD5WithData:data];
        cache_Path = [PYGetPath() stringByAppendingPathComponent:cache_Path];
    } else {
        cache_Path = [PYGetPath() stringByAppendingPathComponent:[self md5:url]];
        NSLog(@"------------%@", cache_Path);
    }
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
@end
