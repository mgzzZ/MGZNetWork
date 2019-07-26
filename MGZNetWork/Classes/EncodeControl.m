//
//  Encode.m
//  Base64+rc4
//
//  Created by han on 2017/8/24.
//  Copyright © 2017年 han. All rights reserved.
//

#import "EncodeControl.h"
#include "rc4Encode.h"
#include "base64.h"


@implementation EncodeControl

+ (NSString *)encode:(NSString *)data key:(NSString *)key {
    
    unsigned long rc4_data_len = 0;
    int base64_data_len = 0;
    
    const char *pwd = [key UTF8String];
    
    const char * cData = [data UTF8String];
    rc4_data_len = (int)strlen(cData);
    char *outdata = (char*)calloc(rc4_data_len, 1);
    Transform(pwd, (int)key.length, outdata, cData, (int)rc4_data_len);
    
    base64_data_len = Base64encode_len((int)rc4_data_len);
    char *base64_data = (char*)malloc(base64_data_len);
    memset(base64_data, 0, base64_data_len);
    Base64encode(base64_data, outdata, (int)rc4_data_len);
    base64_data_len = (int)strlen(base64_data);
    
    NSString *str = [NSString stringWithCString:base64_data encoding:NSUTF8StringEncoding];
    
    return str;
}

+ (NSString *)decode:(NSString *)data key:(NSString *)key {
    char *rc4_data = NULL;
    int rc4_data_len = 0;
    const char * base64_data = [data UTF8String];
    const char *pwd = [key UTF8String];
    
    rc4_data_len = Base64decode_len(base64_data);
    rc4_data = (char*)malloc(rc4_data_len);
    memset(rc4_data, 0, rc4_data_len);
    // base64 decode
    rc4_data_len = Base64decode(rc4_data, base64_data);
    char *outdata = (char*)calloc(rc4_data_len + 1, 1);
    
    Transform(pwd, (int)key.length, outdata, rc4_data, rc4_data_len);
    outdata[rc4_data_len] = 0;
    NSString *str = [NSString stringWithCString:outdata encoding:NSUTF8StringEncoding];
    
    return str;
}

//解密数据
+(NSDictionary *)convertDataToDic:(NSString *)data
{
    NSString *str = [EncodeControl decode:data key:[MGZHttpService sharedInstance].config.encryptionKey];
    NSData *mdata = [[NSMutableData alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:mdata options:0 error:nil];
    NSMutableDictionary *mjson = [NSMutableDictionary dictionary];
    for (NSString *keyStr in dic.allKeys) {
        [mjson setObject:[dic objectForKey:keyStr] forKey:keyStr];
    }
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:mjson];
    return json;
}
//加密数据
+(NSString *)encodeData:(NSDictionary *)data
{
    if (!data) {
        return @"";
    }
    
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonstr = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    jsonstr = [EncodeControl encode:jsonstr key:[MGZHttpService sharedInstance].config.encryptionKey];
    return jsonstr;
}

@end

