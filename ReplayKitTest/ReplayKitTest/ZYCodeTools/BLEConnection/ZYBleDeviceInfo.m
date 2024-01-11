//
//  ZYBleDeviceInfo.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/9.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceInfo_internal.h"
#import "ZYBleDeviceDataModel.h"
#import "ZYProductSupportFunctionManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSArray<NSString*>* validModelNumbers = nil;

@interface ZYBleDeviceInfo ()
@property (nonatomic, readonly, strong) NSNumber* RSSI;
@property (nonatomic, readwrite, strong) NSDate* lastUpdateDataTimeStamp;
@end

@implementation ZYBleDeviceInfo

-(instancetype) initWithNamePeripheralAndRSSI:(NSString*)name withPeripheral:(CBPeripheral*)peripheral withRSSI:(NSNumber*)RSSI;
{
    self = [self init];
    if (self) {
        _name = name;
        _peripheral = peripheral;
        _nameValid = [ZYBleDeviceInfo isKindOfZYDevice:name];
        _RSSI = RSSI;
        self.lastUpdateDataTimeStamp = [NSDate date];
        _manufacturerData = nil;
        _modelNumberString = modelNumberUnknown;
        _isAddress16 = NO;
        _isOEMDevice = NO;
    }
    return self;
}

-(void) updateManufacturerData:(NSData*)data
{
    BOOL valid = YES;
    _manufacturerData = data;
    if (data.length >= 2) {
        Byte* byteData = (Byte*)[data bytes];
        if (byteData[0] == 0x09
            && byteData[1] == 0x05) {
            valid = YES;
            if (valid && data.length >= 4) {
                union {
                    unsigned short val;
                    unsigned char byte[2];
                } serial;
                serial.byte[0] = byteData[2];
                serial.byte[1] = byteData[3];
                _modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:serial.val];
                ZYProductSupportFunctionModel *model = [[ZYProductSupportFunctionManager defaultManager] modelWithProductId:serial.val];
                if (model.oem) {
                    _isOEMDevice = YES;
                }
            }
        }
        if (data.length >= 5) {
            _isAddress16 = byteData[4]>0;
        }
        if (data.length >= 7 && valid) {
            union {
                unsigned short val;
                unsigned char byte[2];
            } serial;
            serial.byte[0] = byteData[5];
            serial.byte[1] = byteData[6];
            NSString *tempString = [ZYBleDeviceDataModel translateToModelNumber:serial.val];
            
            if ([tempString isEqualToString:_modelNumberString] && (tempString != modelNumberUnknown)) {
                _isOEMDevice = YES;
            }
           
        }
       
    } else {
        valid = NO;
    }
    _nameValid &= valid;
}

-(NSInteger) showSignal
{
    //信号小于-100 为0  大于-50为 100
    return (MIN(MAX(_RSSI.integerValue, -100), -50)+100)*2;
}

-(void) updateConnectedDeviceInfo
{
    //读取ota版本
    for (CBService *service in _peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:@"180A"]) {
            for (CBCharacteristic *cha in service.characteristics) {
                if ([cha.UUID.UUIDString isEqualToString:Device_FIRMWARE_UUID]) {
                    _otaVersion = [[NSString alloc]initWithData:cha.value encoding:NSUTF8StringEncoding];
                } else if ([cha.UUID.UUIDString isEqualToString:Device_MANUFACTURER_UUID]) {
                    NSString *value =[[NSString alloc]initWithData:cha.value encoding:NSUTF8StringEncoding];
                    _deviceValid = [value isEqualToString:@"Zhiyun"];
                } else if ([cha.UUID.UUIDString isEqualToString:Device_SYSTEM_ID_UUID]) {
                    //6位 mac 地址
                    if (cha.value.length > 6) {
                        Byte* bytes = (Byte*)cha.value.bytes;
                        _identifier = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", bytes[5], bytes[4], bytes[3], bytes[2], bytes[1], bytes[0]];
                    }
                }
            }
        }
    }
}

+(BOOL) isKindOfZYDevice:(NSString*)name
{
    if ([[name uppercaseString] containsString:@"ZHIYUN-BLE"]) {
        return YES;
    }
    
    if (validModelNumbers == nil) {
        validModelNumbers = [NSArray arrayWithObjects:
                             modelNumberPround,
                             modelNumberEvolution,
                             modelNumberEvolution2,
                             modelNumberEvolution3,
                             modelNumberSmooth,
                             modelNumberSmoothX,
                             modelNumberSmoothXS,
                             modelNumberLiveStabilizer,
                             modelNumberSmoothC11,
                             modelNumberSmoothP1,
                             modelNumberRider,
                             modelNumberCrane,
                             modelNumberWeebill,
                             modelNumberShining,
                             modelNumberCraneEngineering,
                             modelNumberCraneZWB,
                             modelNumberImageTransBox,
                             modelNumberCraneM2,nil];
    }
    for (NSString* modelNumber in validModelNumbers) {
        NSRange foundObj = [name rangeOfString:modelNumber options:NSCaseInsensitiveSearch];
        if(foundObj.length>0) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isDataNeedUpdate:(ZYBleDeviceInfo*)info;
{
    NSTimeInterval timeElapse = [[NSDate date] timeIntervalSinceDate:_lastUpdateDataTimeStamp];
    if (info.isRetriveDevice) {
       if (timeElapse > 1.5) {
           return YES;
       }
    }
    return timeElapse > 5 && info.RSSI != self.RSSI;
}

-(void)recordUpdateDataTime
{
    self.lastUpdateDataTimeStamp = [NSDate date];
}


-(void)configName:(NSString *)name{
    _name = name;
}

-(BOOL)isHIDSupportDevice{
    return [ZYBleDeviceDataModel isHIDSupportDeviceWithModelString:_modelNumberString];
}

@end
