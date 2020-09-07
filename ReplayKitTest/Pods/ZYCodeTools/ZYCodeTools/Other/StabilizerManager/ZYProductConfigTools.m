//
//  ZYProductConfigTools.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/8/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYProductConfigTools.h"
#import "ZYBleDeviceDataModel.h"

@implementation ZYProductConfigTools
+(NSDictionary *)deviceInfos{
    return @{
             modelNumberPround       :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberEvolution    :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberEvolution2   :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberEvolution3   :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             modelNumberSmooth       :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberSmooth2      :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             modelNumberSmoothQ      :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberSmoothC11    :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberSmoothQ2     :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(70)},
             modelNumberSmoothX      :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(70)},
             modelNumberSmoothXS   :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(70)},
             modelNumberLiveStabilizer:    @{@"BatteryCount":@(2),@"maximumWriteValue":@(70)},
             modelNumberSmoothP1     :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(160)},
             modelNumberSmooth3      :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             modelNumberSmooth4      :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberRiderM       :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberCrane        :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberCraneM       :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberCraneS       :    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             modelNumberCraneL       :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(20)},
             modelNumberCraneTwo     :    @{@"BatteryCount":@(3),@"maximumWriteValue":@(20)},
             modelNumberCraneTwoS     :    @{@"BatteryCount":@(3),@"maximumWriteValue":@(180)},
             modelNumberCrane3S      :    @{@"BatteryCount":@(3),@"maximumWriteValue":@(180)},
             modelNumberCrane3Lab    :    @{@"BatteryCount":@(3),@"maximumWriteValue":@(180)},
             modelNumberWeebill      :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(180)},
             modelNumberWeebillLab   :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(180)},
             modelNumberWeebillS     :    @{@"BatteryCount":@(2),@"maximumWriteValue":@(180)},
             modelNumberShining      :    @{@"BatteryCount":@(4),@"maximumWriteValue":@(20)},
             modelNumberCraneM2      :    @{@"BatteryCount":@(3),@"maximumWriteValue":@(160)},
             modelNumberImageTransBox:    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             modelNumberImageTransBoxTwo:    @{@"BatteryCount":@(1),@"maximumWriteValue":@(20)},
             };
}

+(float)batteryValueWithModelNumber:(NSString *)modelNumberString{
    NSNumber *batterys = [[self.deviceInfos objectForKey:modelNumberString] objectForKey:@"BatteryCount"];
    if (batterys) {
        return [batterys floatValue];
    }
    else{
        return 1;
    }
}

+(float)maximumWriteValueWithModelNumber:(NSString *)modelNumberString
{
    NSNumber *batterys = [[self.deviceInfos objectForKey:modelNumberString] objectForKey:@"maximumWriteValue"];
    if (batterys) {
        return [batterys floatValue];
    }
    else{
        return 1;
    }
}

+(BOOL)canSetStablizerWithDeviceSeries:(ZYDeviceSeries)deviceSeries{
    switch (deviceSeries) {
        case ZYDeviceSeriesCrane:
        case ZYDeviceSeriesWeebill:
        case ZYDeviceSeriesImageBox:
        {
            return YES;
            break;
        }
        default:
            break;
    }
    return NO;
    
}

+(ZYDeviceSeries)deviceSeriesWithDiviceName:(NSString *)name{
    if (!name.length) {
        return ZYDeviceSeriesUnknow;
    }
    if ([name localizedCaseInsensitiveContainsString:@"crane"]) {
        return ZYDeviceSeriesCrane;
    }else if ([name localizedCaseInsensitiveContainsString:@"smooth"]){
        return ZYDeviceSeriesSmooth;
    }else if ([name localizedCaseInsensitiveContainsString:@"Rider"]){
        return ZYDeviceSeriesRider;
    }else if ([name localizedCaseInsensitiveContainsString:@"Evolution"]){
        return ZYDeviceSeriesEvolution;
    }else if ([name localizedCaseInsensitiveContainsString:@"Pround"]){
        return ZYDeviceSeriesPround;
    }else if ([name localizedCaseInsensitiveContainsString:@"Shining"]){
        return ZYDeviceSeriesShining;
    }else if ([name localizedCaseInsensitiveContainsString:@"Weebill"]){
        return ZYDeviceSeriesWeebill;
    }else if ([name localizedCaseInsensitiveContainsString:@"TransMount Image Transmission Transmitter"]){
        return ZYDeviceSeriesImageBox;
    }
    return ZYDeviceSeriesUnknow;

}

@end
