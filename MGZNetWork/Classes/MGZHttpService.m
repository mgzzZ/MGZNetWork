//
//  MGZHttpService.m
//  LittleBee
//
//  Created by 超盟 on 2019/6/4.
//  Copyright © 2019年 mgz. All rights reserved.
//

#import "MGZHttpService.h"
#import <AFNetworking/AFNetworking.h>
#import "MGZHttpResponse.h"
#import "EncodeControl.h"
NSString * const MGZHttpErrorDomain = @"请检查参数";
NSString * const MGZHttpErrorMessage = @"MGZHTTPErroMassage";

@interface MGZHttpService ()

@property (nonatomic,strong) AFHTTPSessionManager * netManager;



@end

@implementation MGZHttpService

+ (instancetype)sharedInstance {
    static MGZHttpService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MGZHttpService alloc]init];
    });
    
    return _sharedInstance;
}




-(void)configHttpService
{
    self.netManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];//不设置会报-1016或者会有编码问题
    self.netManager.requestSerializer = [AFHTTPRequestSerializer serializer]; //不设置会报-1016或者会有编码问题
    self.netManager.responseSerializer = [AFHTTPResponseSerializer serializer];    
    [self.netManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    
    self.netManager.requestSerializer.timeoutInterval = 15.0f;
    
    [self.netManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    
    self.netManager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json",
                                                                  @"text/json",
                                                                  @"text/javascript",
                                                                  @"text/html",
                                                                  @"text/plain",
                                                                  @"text/html",
                                                                  nil];
    self.netManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    /*
     设置请求头的设置
     //
     [self.netManager.requestSerializer setValue:TOKEN forHTTPHeaderField:@"token-id"];
     
     */
    
    //// 安全策略
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO
    //主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    securityPolicy.validatesDomainName = NO;
    
    self.netManager.securityPolicy = securityPolicy;
    
    /*
     添加网络监测等
     //
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
     [self.netManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
     if (status == AFNetworkReachabilityStatusUnknown) {
     //未知网络
     
     }else if(status == AFNetworkReachabilityStatusNotReachable){
     //未连接
     }else{
     //有网络
     }
     }];
     
     */
    
}



- (RACSignal *)postRequestWithPath:(NSString *)path params:(NSDictionary *)dict convertResultClass:(Class)resultClass{
    MGZHttpRequest *request = [MGZHttpRequest requestWithPath:path params:dict convertResultClass:resultClass];
    if (self.config.isEncryption) {
        return [[MGZHttpService sharedInstance] postRequestEncryptionNetWorkData:request];
    }else{
        return [[MGZHttpService sharedInstance] postRequestNetWorkData:request];
    }
}


-(RACSignal *)postRequestNetWorkData:(MGZHttpRequest *)request
{
    if (!request) {
        return  [RACSignal  error:[NSError errorWithDomain:MGZHttpErrorDomain code:-1 userInfo:nil]];
    }
    
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
        __block  NSURLSessionDataTask * task = nil;
        task = [self.netManager POST:request.path parameters:request.paramstr progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSData *data = responseObject;
            NSString *str = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
            NSDictionary *dic = [EncodeControl convertDataToDic:str];
            NSNumber *code = dic[@"code"];
            if (code.integerValue == MGZHttpResponseCodeSuccess) {
                MGZHttpResponse * response = [[MGZHttpResponse alloc] initWithResponseSuccess:responseObject code:MGZHttpResponseCodeSuccess resultClass:nil];
                NSLog(@"*******data : %@",response.responseObject);
                [subscriber sendNext:response.responseObject];
                [subscriber sendCompleted];
            }else if([dic[@"msg"] isEqualToString:@"Token失效"] || [dic[@"msg"] isEqualToString:@"Token失效"] || [dic[@"msg"] containsString:@"oken失效"]) {
              
                NSError *error = [NSError errorWithDomain:dic[@"msg"] code:MGZHttpResponseCodeMissToken userInfo:nil];
                [subscriber sendError:error];
                
            }else{
                NSError *error = [NSError errorWithDomain:dic[@"msg"] code:MGZHttpResponseCodeOther userInfo:nil];
                [subscriber sendError:error];
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"报错了%@",error);
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];  //取消
        }];
    }];
    
    return [signal replayLazily];  //多次订阅同样的信号，执行一次。
}

- (RACSignal *)getRequestNetWorkData:(MGZHttpRequest *)request{
    if (!request) {
        return  [RACSignal  error:[NSError errorWithDomain:MGZHttpErrorDomain code:-1 userInfo:nil]];
    }
    
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        //创建网络请求
        //        NSLog(@"======== %@ %@",request.path,request.params);
        __block  NSURLSessionDataTask * task = nil;
        task = [self.netManager GET:request.path parameters:request.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            MGZHttpResponse * response = [[MGZHttpResponse alloc] initWithResponseSuccess:responseObject code:0 resultClass:nil];
            //            NSLog(@"*******data : %@",response.responseObject);
            [subscriber sendNext:response.responseObject];
            [subscriber sendCompleted];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            NSLog(@"报错了%@",error);
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];  //取消
            
        }];
    }];
    
    return [signal replayLazily];  //多次订阅同样的信号，执行一次。
}


- (RACSignal *)postRequestEncryptionNetWorkData:(MGZHttpRequest *)request{
    if (!request) {
        return  [RACSignal  error:[NSError errorWithDomain:MGZHttpErrorDomain code:-1 userInfo:nil]];
    }
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        
        NSMutableURLRequest *netrequest = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:request.path parameters:nil error:nil];
        
        [netrequest addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
        
        NSData *bodyData = (NSData *)[request.paramstr dataUsingEncoding:NSUTF8StringEncoding];
        [netrequest setHTTPBody:bodyData];
        
        //发起请求
        __block  NSURLSessionDataTask * task = nil;
        task = [self.netManager dataTaskWithRequest:netrequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if(error){
                MGZHttpResponse *response = [[MGZHttpResponse alloc]initWithResponseError:error code:MGZHttpResponseCodeOther];
                
                [subscriber sendError:response.resError];
                
            } else {
                MGZHttpResponse *response = [[MGZHttpResponse alloc]initWithResponseEncryption:responseObject code:MGZHttpResponseCodeSuccess resultClass:request.resultClass];
                if (response.isSuccess) {
                    if (request.resultClass) {
                        [subscriber sendNext:response.jsonClassObject];
                        [subscriber sendCompleted];
                    }else{
                        [subscriber sendNext:response.responseObject];
                        [subscriber sendCompleted];
                    }
                }else{
                    [subscriber sendError:response.resError];
                }
            }
        }];
        [task resume];
        
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    
    return [signal replayLazily];
}


#pragma mark - Lazily

-(AFHTTPSessionManager *)netManager
{
    if (_netManager == nil) {
        _netManager = [AFHTTPSessionManager manager];
        [self configHttpService];
    }
    return _netManager;
}



- (NSString *)baseUrl{
    switch (self.config.devEnvironment) {
        case MGZHTTPdevEnvironmentOfDebug:
            return self.config.debugUrl;
            break;
            
        case MGZHTTPdevEnvironmentOfAlpha:
            return self.config.alphaUrl.length > 0 ? self.config.alphaUrl : self.config.debugUrl;
            break;
            
        case MGZHTTPdevEnvironmentOfRelease:
            return self.config.releaseUrl;
            break;
            
        default:
            break;
    }
}


- (void)setConfig:(MGZHTTPConfig *)config{
    _config = config;
}

@end
