#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "base64.h"
#import "EncodeControl.h"
#import "MGZHTTPConfig.h"
#import "MGZHttpRequest.h"
#import "MGZHttpResponse.h"
#import "MGZHttpService.h"
#import "rc4Encode.h"

FOUNDATION_EXPORT double MGZNetWorkVersionNumber;
FOUNDATION_EXPORT const unsigned char MGZNetWorkVersionString[];

