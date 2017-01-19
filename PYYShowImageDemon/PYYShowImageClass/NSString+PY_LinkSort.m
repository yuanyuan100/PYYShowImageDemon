//
//  NSString+PY_LinkSort.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "NSString+PY_LinkSort.h"

@implementation NSString (PY_LinkSort)
- (BOOL)isLocalFile {
    BOOL ret_D;
    BOOL ret_F = [[NSFileManager defaultManager] fileExistsAtPath:self isDirectory:&ret_D];
    if (ret_D) {
        return NO;
    }
    return ret_F;
}
@end
