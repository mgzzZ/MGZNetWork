//
//  MGZHttpResponse.h
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGZHttpService.h"

NS_ASSUME_NONNULL_BEGIN

@interface MGZHttpResponse : NSObject

@property(nonatomic,assign,readonly) BOOL isSuccess;  //请求成功的判断

@property (nonatomic,assign,readonly) NSInteger code; //返回成功或失败的code

@property (nonatomic,copy,readonly) NSString * message; //返回的信息

@property (nonatomic,strong,readonly) id  responseObject; //原装的返回

@property (nonatomic,strong,readonly) id  jsonClassObject; //解析成指定class的返回

@property (nonatomic,strong,readonly) NSError *  resError; //可能服务器返回的错误信息


-(instancetype)initWithResponseSuccess:(id) result code:(NSInteger )code resultClass:(nullable Class)resultClass;

-(instancetype)initWithResponseError:(NSError *) err code:(NSInteger )code;


-(instancetype)initWithResponseEncryption:(id) result code:(NSInteger )code resultClass:(nullable Class)resultClass;

@end

NS_ASSUME_NONNULL_END
