//
//  NSString+PY_LinkSort.h
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PY_LinkSort)
- (BOOL)isUrl;

/**
 如果是本地沙盒文件(不包含路径)，且存在返回YES。反之,NO;
 */
- (BOOL)isLocalFile;
@end
