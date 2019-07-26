//
//  MGZHTTPConfig.h
//  NetWork
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 mgzzz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,MGZHttpResponseCode){
    MGZHttpResponseCodeSuccess = 0,
    MGZHttpResponseCodeMissToken = -1,
    MGZHttpResponseCodeNotNet = -1009,
    MGZHttpResponseCodeNoPhone = -1111,
    MGZHttpResponseCodeWithdraw = 5003,
    MGZHttpResponseCodeOther
    
};

typedef NS_ENUM(NSInteger,MGZHTTPdevEnvironmentType){
    MGZHTTPdevEnvironmentOfDebug = 0,//测试服务器
    MGZHTTPdevEnvironmentOfAlpha = 1,//备用服务器
    MGZHTTPdevEnvironmentOfRelease = 2//正式服务器
};

@interface MGZHTTPConfig : NSObject


/**
 测试环境地址
 */
@property (nonatomic,strong)NSString *debugUrl;


/**
 正式环境地址
 */
@property (nonatomic,strong)NSString *releaseUrl;


/**
 备用环境地址
 */
@property (nonatomic,strong)NSString *alphaUrl;



/**
 当前开发环境
 */
@property (nonatomic,assign)MGZHTTPdevEnvironmentType devEnvironment;


/**
 公共参数
 */
@property (nonatomic,strong)NSDictionary *commonParameters;


/**
 是否加密
 */
@property (nonatomic,assign)BOOL isEncryption;


/**
 加密Key
 */
@property (nonatomic,strong)NSString *encryptionKey;



@end

NS_ASSUME_NONNULL_END
