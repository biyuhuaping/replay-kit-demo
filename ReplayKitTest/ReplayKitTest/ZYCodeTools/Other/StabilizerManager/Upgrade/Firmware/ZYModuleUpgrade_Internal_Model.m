//
//  ZYModuleUpgrade_Internal_Model.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYModuleUpgrade_Internal_Model.h"
#define CheckBit(val, pos) ((val&(0x0001<<pos))==(0x0001<<pos))

@implementation ZYModuleUpgrade_Internal_Model

-(void)setData:(NSString *)data{
    _data = data;
    [self updateDeviceIdAndChannel:[data integerValue]];
}
-(void) updateDeviceIdAndChannel:(NSUInteger)value
{
    if (CheckBit(value, 0)) {
        _channel = ZYUpgradableChannelBle;
    }
    if (CheckBit(value, 1)) {
        _channel = ZYUpgradableChannelWiFi;
    }
//#warning 测试代码，郑工发了错误的测试数据
//    _channel = ZYUpgradableChannelWiFi;
    _deviceId = (0xFF00 & value) >> 8;
}

//- (NSString *)upgrateExtention{
//    if (_upgrateExtention) {
//        return _upgrateExtention;
//    }
//    else{
//
//        switch (_deviceId) {
//            case 0:
//                return @".ptz";
//            case 1:
//                return @".ccs";
//            case 2:
//                return @".update";
//            case 3:
//                return @".cov";
//            default:
//                return @".ptz";
//        }
//    }
//}
@end
