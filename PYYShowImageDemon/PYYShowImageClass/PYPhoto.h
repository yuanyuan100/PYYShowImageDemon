//
//  PYPhoto.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/19.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//获取Cache目录
UIKIT_STATIC_INLINE NSString* PYGetPath() {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    return cachePath;
}

@interface PYPhoto : NSObject

/** 网络地址 或者 本地地址 */
@property (nonatomic, copy) NSString *URL;
- (void)addImage:(UIImage *)image;

///======================================以下为程序自动调用方法
/** 小图的本地缓存地址 */
@property (nonatomic, copy) NSString *smallUniquePath;
/** 大图的本地缓存地址 */
@property (nonatomic, copy) NSString *bigUniquePaht;
/** 标记是否为有效访问路径 */
@property (nonatomic, getter=isFailure,assign) BOOL failure;
/** 是否允许网络图片映射到本地缓存 */
@property (nonatomic, getter = isMapping, assign) BOOL mapping; // developer可以设置

///=======================================工具方法
+ (NSString*)md5:(NSString*)str;
+ (NSString*)getMD5WithData:(NSData *)data;
+ (NSString *)py_writeWithUrl:(NSString *)url data:(NSData *)data;
@end

FOUNDATION_EXPORT NSString * const PYPhotoImageChangeToLocalNotification;
