//
//  ZYProductConfigTools.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/8/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 产品的系列号

 - ZYDeviceSeriesUnknow: 不知道的设备
 - ZYDeviceSeriesSmooth: smooth
 - ZYDeviceSeriesCrane: crane
 - ZYDeviceSeriesRider: Rider
 - ZYDeviceSeriesEvolution: EVO
 - ZYDeviceSeriesPround: pround
 - ZYDeviceSeriesShining: Shining
 - ZYDeviceSeriesWeebill: Weebill
 */
typedef NS_ENUM(NSInteger,ZYDeviceSeries) {
    ZYDeviceSeriesUnknow = 0,
    ZYDeviceSeriesSmooth,
    ZYDeviceSeriesCrane,
    ZYDeviceSeriesRider,
    ZYDeviceSeriesEvolution,
    ZYDeviceSeriesPround,
    ZYDeviceSeriesShining,
    ZYDeviceSeriesWeebill,
    ZYDeviceSeriesImageBox,
};

@interface ZYProductConfigTools : NSObject


/**
 获取每种产品的电池总电量

 @param modelNumberString 产品类型
 @return 电量的总数值
 */
+(float)batteryValueWithModelNumber:(NSString *)modelNumberString;

/**
 获取每种产品的可接受数据最大长度
 
 @param modelNumberString 产品类型
 @return 最大长度
 */
+(float)maximumWriteValueWithModelNumber:(NSString *)modelNumberString;

/**
 
云鹤，webblize设备的功能
 @param deviceSeries 系列号
 @return 是否是对应的设备
 */
+(BOOL)canSetStablizerWithDeviceSeries:(ZYDeviceSeries)deviceSeries;


/**
 获取设备的系列号

 @param name 设备的名字
 @return 设备的系列号
 */
+(ZYDeviceSeries)deviceSeriesWithDiviceName:(NSString *)name;
@end
