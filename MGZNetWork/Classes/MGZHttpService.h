//
//  MGZHttpService.h
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "MGZHttpRequest.h"
#import "MGZHTTPConfig.h"


NS_ASSUME_NONNULL_BEGIN


@interface MGZHttpService : NSObject

+(instancetype)sharedInstance;


@property (nonatomic,strong)MGZHTTPConfig *config;

@property (nonatomic,strong) NSString *baseUrl;


- (RACSignal *)postRequestWithPath:(NSString *)path params:(NSDictionary *)dict convertResultClass:(nullable Class)resultClass;


/**
 GET普通请求

 @param request request
 @return 信号量
 */
-(RACSignal *)getRequestNetWorkData:(MGZHttpRequest *)request;

/**
 POST普通请求

 @param request request
 @return 信号量
 */
-(RACSignal *)postRequestNetWorkData:(MGZHttpRequest *)request;

/**
 POST加密请求

 @param request request
 @return 信号量
 */
-(RACSignal *)postRequestEncryptionNetWorkData:(MGZHttpRequest *)request;


/**
 POST加密请求

 @param request request
 @param isCache 是否缓存数据
 @return 信号量
 */
- (RACSignal *)postRequestEncryptionNetWorkData:(MGZHttpRequest *)request isCache:(BOOL)isCache;


- (RACSignal *)downloadFileWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
