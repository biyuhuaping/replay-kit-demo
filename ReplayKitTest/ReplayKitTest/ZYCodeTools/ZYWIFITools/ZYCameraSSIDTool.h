//
//  ZYCameraSSIDTool.h
//  ZYCamera
//
//  Created by ZY27 on 2019/7/11.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYCameraSSIDTool : NSObject

/**
 *  传入扫码获得的字符串 返回含有ssid key:SSID和密码 key:PW 的字典
 */
+(NSDictionary *)getSSIDAndPasswordWithStr:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
