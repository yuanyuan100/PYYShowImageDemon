//
//  NSString+PY_LinkSort.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "NSString+PY_LinkSort.h"

@implementation NSString (PY_LinkSort)
- (BOOL)isUrl {
    
    if(self == nil) return NO;
    
    
    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    
//    return [urlTest evaluateWithObject:self];
    return YES;
    
}

- (BOOL)isLocalFile {
    BOOL ret_D;
    BOOL ret_F = [[NSFileManager defaultManager] fileExistsAtPath:self isDirectory:&ret_D];
    if (ret_D) {
        return NO;
    }
    return ret_F;
}
@end
