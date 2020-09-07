//
//  ZYProductNoModel.mm
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUpgradableInfoModel.h"
#define CheckBit(val, pos) ((val&(0x0001<<pos))==(0x0001<<pos))

@interface ZYUpgradableInfoModel()
//升级的时候安装包的数据信息
//@property(nonatomic, strong,readwrite)NSData *data;
@end

@implementation ZYUpgradableInfoModel

-(void) updateDeviceIdAndChannel:(NSUInteger)value
{
    _channel = [ZYUpgradableInfoModel updateChannel:value];
    _deviceId = [ZYUpgradableInfoModel deviceIDWithValue:value];
}

+(NSUInteger)deviceIDWithValue:(NSUInteger)value{
    return (0xFF00 & value) >> 8;
}

+(ZYUpgradableChannel)updateChannel:(NSUInteger)value{
    if (CheckBit(value, 0)) {
        return ZYUpgradableChannelBle;
    }
    if (CheckBit(value, 1)) {
        return ZYUpgradableChannelWiFi;
    }
    return ZYUpgradableChannelBle;
}

-(NSString*) description
{    
    return [NSString stringWithFormat:@" modelNumber:%lu deviceId:%lu version:%lu channel:%@ upgrateExtention:%@", _modelNumber,_deviceId, _version, _channel == ZYUpgradableChannelWiFi?@"WIFI":@"BLE",[self upgrateExtention]];
}

- (NSString *)upgrateExtention{

    if (_upgrateExtention) {//外部已经赋值的话，就用外部的值
        return _upgrateExtention;
    }
    else{
        
        switch (_deviceId) {
            case 0:
                return @".ptz";
            case 1:
                return @".ccs";
            case 2:
                return @".update";
            case 3:
                return @".cov";
            default:
                return @".ptz";
        }
    }
}

/// 通过refIDs初始化
/// @param modelNumber 设备ID比如0x0600图传盒子
-(instancetype)initWithModelNumber:(NSUInteger)modelNumber{
    self = [super init];
    if (self) {
        _modelNumber = modelNumber;
        if (modelNumber == 0x0531) {//weebillLab需要依赖
             _dependency = YES;
         }
    }
    return self;
}

-(NSData *)data{
    if (_data == nil) {
        if (_upgratedataURL) {
            _data = [NSData dataWithContentsOfFile:_upgratedataURL];
        }
    }
    return _data;
}

@end
