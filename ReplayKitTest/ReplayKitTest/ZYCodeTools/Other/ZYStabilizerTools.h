//
//  ZYStabilizerTools.h
//  ZYCamera
//
//  Created by lgj on 2017/6/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYStabilizerTools : NSObject

/**
 用于显示固件的软件版本

 @param softwareVersion 软件版本,目前为字符串，
 @return 用于显示固件的软件版本
 */
+(NSString *)softwareVersionForDisplay:(id)softwareVersion;

/**
 是否需要升级

 @param softwareVersion 软件版本,目前为字符串，
 @return 是否需要升级
 */
+(BOOL)needToUpdateSoftwareVersionForMoveDelayRecord:(id)softwareVersion;
@end
