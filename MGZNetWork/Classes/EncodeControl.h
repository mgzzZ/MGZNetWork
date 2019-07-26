//
//  Encode.h
//  Base64+rc4
//
//  Created by han on 2017/8/24.
//  Copyright © 2017年 han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGZHttpService.h"
@interface EncodeControl : NSObject
+ (NSString *)encode:(NSString *)data key:(NSString *)key;
+ (NSString *)decode:(NSString *)data key:(NSString *)key;
/** 解密数据 */
+(NSDictionary *)convertDataToDic:(NSString *)data;
/** 加密数据 */
+(NSString *)encodeData:(NSDictionary *)data;

@end

