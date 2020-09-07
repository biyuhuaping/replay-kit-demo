//
//  ZYStabilizerConnectManager.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/14.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

/*
 1.通过原名称返回是否需要自动连接
 2.通过原名称返回需要显示的名称
 3.通过设备的原本名称，和修改了的名称，  ->进行修改需要显示的名称
 4.通过设备的原本名称，和是否需要自动连接->进行修改是否需要自动连接
 5.获取保存了的设备个数
 */
#import <Foundation/Foundation.h>
#import "ZYConectModel.h"

@interface ZYStabilizerConnectManager : NSObject

+(BOOL)getIsNeedAutoConnectFromOrignalName:(NSString *)orignalName;

+(NSString *)getDisplayNameFromOrignalName:(NSString *)orignalName;

+(void)resetDisplayNameFromOrignalName:(NSString *)orignalName  changeName:(NSString*)changeName;

+(void)resetIsNeedAutoConnectFromOrignalName:(NSString *)orignalName  isNeedAutoConnect:(BOOL)isNeedAutoConnect;

+(NSInteger)getSaveBlueToothCount;
@end
