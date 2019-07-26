//
//  MGZHttpResponse.m
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import "MGZHttpResponse.h"
#import "EncodeControl.h"
#import <MJExtension/MJExtension.h>
@interface MGZHttpResponse ()

@property(nonatomic,assign,readwrite) BOOL isSuccess;  //请求成功的判断
@property (nonatomic,assign,readwrite) NSInteger code; //返回成功或失败的code
@property (nonatomic,copy,readwrite) NSString * message; //返回的信息

@property (nonatomic,strong,readwrite) id  responseObject; //原装的返回
@property (nonatomic,strong,readwrite) id  jsonClassObject; //解析成指定class的返回
@property (nonatomic,strong,readwrite) NSError *  resError; //可能服务器返回的错误信息

@end

@implementation MGZHttpResponse

-(instancetype)initWithResponseSuccess:(id) result code:(NSInteger )code resultClass:(nullable Class)resultClass
{
    if (self = [super init]) {
        self.isSuccess = YES; //这里看自己工程，有些要code == 0才算成功
        self.responseObject = result;
        self.code = code;
        
        if (resultClass) {  //如果要 解析成指定的类型
            
            //用MJExtension来解析
            id convertClass = nil;
            if ([result isKindOfClass:[NSArray class]]) {
                NSMutableArray *resultList = [NSMutableArray array];
                
                for (id dataItem in result) {
                    [resultList addObject:[resultClass mj_objectWithKeyValues:dataItem]];
                }
                
                convertClass = resultList;
            } else if ([result isKindOfClass:[NSNumber class]] || [result isKindOfClass:[NSString class]]) {
                convertClass = result;
            } else {
                
                convertClass = [resultClass mj_objectWithKeyValues:result];
            }
            self.jsonClassObject = convertClass;
            
        }
    }
    return self;
}


-(instancetype)initWithResponseError:(NSError *) err code:(NSInteger )code
{
    if (self = [super init]) {
        self.isSuccess = NO;
        if(err.code == NSURLErrorTimedOut || err.code == NSURLErrorNotConnectedToInternet){
            NSError *error = [NSError errorWithDomain:@"网络异常" code:MGZHttpResponseCodeNotNet userInfo:nil];
            self.resError = error;
            self.code = MGZHttpResponseCodeNotNet;
            self.message = err.domain;
           // [WMTools showToastTips:@"网络异常"];
        }else{
            NSError *error = [NSError errorWithDomain:err.domain code:MGZHttpResponseCodeOther userInfo:nil];
            self.resError = error;
            self.code = MGZHttpResponseCodeOther;
            self.message = err.domain;
        }
        
    }
    return self;
}


-(instancetype)initWithResponseEncryption:(id) result code:(NSInteger )code resultClass:(nullable Class)resultClass{
    if (self = [super init]) {
        //这里看自己工程，有些要code == 0才算成功
        
        NSData *data = result;
        NSString *str = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [EncodeControl convertDataToDic:str];
        NSNumber *code = dic[@"code"];
        self.responseObject = dic;
        if ([str hasPrefix:@"<br />"]) {
            self.isSuccess = NO;
        }
        if ([dic[@"code"] isKindOfClass:[NSNull class]] ) {
            self.isSuccess = NO;
        }
        if(![dic[@"code"] isKindOfClass:[NSNull class]] && code.intValue == MGZHttpResponseCodeSuccess && ![str hasPrefix:@"<br />"]){
            self.isSuccess = YES;
            self.code = MGZHttpResponseCodeSuccess;
            if (resultClass) {  //如果要 解析成指定的类型
                
                //用MJExtension来解析
                id convertClass = nil;
                //字典数组
                if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *resultList = [NSMutableArray array];
                    for (id dataItem in dic[@"data"]) {
                        [resultList addObject:[resultClass mj_objectWithKeyValues:dataItem]];
                    }
                    convertClass = resultList;
                } else if ([dic[@"data"] isKindOfClass:[NSNumber class]] || [data isKindOfClass:[NSString class]] ||[dic[@"code"] isKindOfClass:[NSNull class]]) {
                    //非正常类型  这里看需求 也可以转换成error出去
                    convertClass = dic[@"data"];
                    NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"接口返回json错误\n%@",str] code:code.integerValue userInfo:nil];
                    //[WMTools showToastTips:error.domain];
                    self.resError = error;
                    self.code = MGZHttpResponseCodeOther;
                    self.message = @"接口返回json错误";
                    self.isSuccess = NO;
                } else {
                    //正常字典
                    convertClass = [resultClass mj_objectWithKeyValues:dic[@"data"]];
                }
                self.jsonClassObject = convertClass;
                
            }
        }else if([str hasPrefix:@"<br />"]){
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"接口返回json错误\n%@",str] code:code.integerValue userInfo:nil];
            //[WMTools showToastTips:error.domain];
            self.resError = error;
            self.code = MGZHttpResponseCodeOther;
            self.message = @"接口返回json错误";
            self.isSuccess = NO;
        }else if([dic[@"code"] isKindOfClass:[NSNull class]]){
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"接口返回json错误\n%@",str] code:MGZHttpResponseCodeNoPhone userInfo:nil];
            //[WMTools showToastTips:error.domain];
            self.resError = error;
            self.code = MGZHttpResponseCodeOther;
            self.message = @"接口返回json错误";
            self.isSuccess = NO;
        }else{
            //token失效
            if ([dic[@"msg"] isEqualToString:@"Token失效"] || [dic[@"msg"] isEqualToString:@"Token失效"] || [dic[@"msg"] containsString:@"oken失效"]) {
               
                
                NSError *error = [NSError errorWithDomain:dic[@"msg"] code:MGZHttpResponseCodeMissToken userInfo:nil];
                self.resError = error;
                self.code = MGZHttpResponseCodeMissToken;
                self.message = dic[@"msg"];
                self.isSuccess = NO;
            }else{
                NSError *error = [NSError errorWithDomain:dic[@"msg"] code:code.integerValue userInfo:nil];
                //[WMTools showToastTips:error.domain];
                self.resError = error;
                self.code = MGZHttpResponseCodeOther;
                self.message = dic[@"msg"];
                self.isSuccess = NO;
            }
            
        }
        
    }
    return self;
}


@end
