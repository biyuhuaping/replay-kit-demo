//
//  ZYDeviceBase.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/21.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceBase.h"
#import "ZYDeviceManager.h"

/**
 云台断开连接
 */
NSString* const Deivce_Disconnected                         = @"Deivce_Disconnected";

NSString* const Device_PTZReadyToUse    = @"Device_PTZReadyToUse";

NSString* const Device_PTZOffLine       = @"Device_PTZOffLine";

NSString* const kWorkingStateChange     = @"kWorkingStateChange";



@implementation ZYDeviceBase
+(instancetype)deviceBaseWithdDeviceInfo:(ZYBleDeviceInfo *)info{
    if ([info isKindOfClass:[ZYBleDeviceInfo class]]) {
       ZYDeviceBase *base = [[self alloc] init];
        base.deviceInfo = info;
        return base;
    }
    return nil;
}

-(void)connectSetup{
    @throw [NSException exceptionWithName:@"Error" reason:@"请实现该方法，初始化连接属性" userInfo:nil];

}

-(void)clearDataSource{
    @throw [NSException exceptionWithName:@"Error" reason:@"请实现该方法，清除属性" userInfo:nil];

}

-(ZYBleDeviceInfo*)curDeviceInfo
{
    return [ZYDeviceManager defaultManager].curDeviceInfo;
}

-(NSString *)deviceName{
    return _deviceInfo.name;
}

-(void)configEncodeAndTransmissionForRequest:(ZYBleDeviceRequest *)request{
    request.parseFormat = ZYCodeParseStar;
    request.trasmissionType = ZYTrasmissionTypeBLE;
}

-(ZYProductSupportFunctionModel *)functionModel{
    return nil;
}
@end
