//
//  ZYAES128.h
//  ZYFilmic
//
//  Created by Liao GJ on 2020/3/15.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYAES128 : NSObject
+(NSData *)encryptDataWithData:(NSData *)data Key:(NSString *)key;
+(NSData *)decryptDataWithData:(NSData *)data andKey:(NSString *)key;

+(NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key;
+(NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
