//
//  MGZHttpRequest.h
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , MGZRequestType)
{
    MGZRequestTypePost = 0, //Post请求
    MGZHttpRequestGet,
};


@interface MGZHttpRequest : NSObject

@property (nonatomic,copy) NSString * path; //就基于baseUrl的相对path
@property (nonatomic) MGZRequestType requestType;  //P（这里没用到了）
@property (nonatomic,strong) NSDictionary * params; //参数
@property (nonatomic,strong) NSString * paramstr; //参数  加密字符串
@property (nonatomic,strong) Class resultClass; //返回指定的类结构


/**
 请求类
 
 @param path 相对于basePath的path
 @param dict 参数字典集
 @param resultClass 返回指定的类型
 */
+ (instancetype)requestWithPath:(NSString *)path params:(NSDictionary *)dict convertResultClass:(nullable Class)resultClass;

@end

NS_ASSUME_NONNULL_END
