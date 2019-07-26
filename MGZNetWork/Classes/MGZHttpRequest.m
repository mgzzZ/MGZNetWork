//
//  MGZHttpRequest.m
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import "MGZHttpRequest.h"
#import "EncodeControl.h"
#import "MGZHttpService.h"

@implementation MGZHttpRequest
/*功能
 1.这个类可以添加常用的默认请求参数：如token,app版本号等的处理
 2.处理请求数据的加密等
 */

/**
 请求类
 
 @param path 相对于basePath的path
 @param dict 参数字典集
 @param resultClass 返回指定的类型
 */
+(instancetype)requestWithPath:(NSString *)path params:(NSDictionary *)dict convertResultClass:(nullable Class)resultClass
{
    return  [[self alloc] initReqestParamsWithPath:path params:dict convertResultClass:resultClass];
}


-(instancetype)initReqestParamsWithPath:(NSString *)path params:(NSDictionary *)params convertResultClass:(Class)resultClass
{
    self = [super init];
    if (self) {
        
        self.path = [NSString stringWithFormat:@"%@%@",[MGZHttpService sharedInstance].baseUrl, path];  //拼接完整的url


        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:params];
        
        if ([MGZHttpService sharedInstance].config.commonParameters.count > 0) {
            [dic setValuesForKeysWithDictionary:[MGZHttpService sharedInstance].config.commonParameters];
        }
        
    
        if ([MGZHttpService sharedInstance].config.isEncryption) {
            self.paramstr = (NSString *)[EncodeControl encodeData:dic];;
        }else{
            self.params = dic;
        }
        
        self.resultClass = resultClass;
    }
    
    return self;
    
}

@end
