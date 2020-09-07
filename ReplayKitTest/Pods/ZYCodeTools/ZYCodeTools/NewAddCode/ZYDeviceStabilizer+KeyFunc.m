//
//  ZYDeviceStabilizer+KeyFunc.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/24.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer+KeyFunc.h"

#import "ZYKeyFuncReadData.h"
#import "ZYBlKeyFuncSetData.h"
@implementation ZYDeviceStabilizer (KeyFunc)

/// 读取设备的按键信息
/// @param funcModel 按键的模型
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)readKeyFunWithKeyKeyFuncModel:(ZYKeyFuncModel *)funcModel  completionHandler:(void(^)(BOOL success,ZYkeyFunc curruntkeyFun,NSArray *keyFuns))completionHandler{
    ZYKeyFuncReadData *keyReadData =[[ZYKeyFuncReadData alloc] init];
    keyReadData.keyInfo = funcModel.keyInfo;
    
    [keyReadData createRawData];
    ZYBleMutableRequest* sendData = [[ZYBleMutableRequest alloc] initWithZYControlData:keyReadData];
    [self configRequest:sendData];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    [client sendMutableRequest:sendData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYKeyFuncReadData *data = param;
            if (completionHandler) {
                if (data.keyFun.count > 0) {
                    NSMutableArray *arrayR = [data.keyFun mutableCopy];
                    [arrayR removeObjectAtIndex:0];
                    completionHandler(YES,(ZYkeyFunc)[data.keyFun.firstObject intValue],arrayR);
                }
                else{
                    completionHandler(NO,ZYkeyFunc_NONE,nil);
                }
            }
        } else {
            if (completionHandler) {
                completionHandler(NO,ZYkeyFunc_NONE,nil);
            }
        }
    }];
}

-(void)readKeyFunWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8_t)keyValue completionHandler:(void(^)(BOOL success,ZYkeyFunc curruntkeyFun,NSArray *keyFuns))completionHandler{
    ZYKeyFuncModel *data = [[ZYKeyFuncModel alloc] initWithKeyType:keyType keyGroup:keyGroup keyEvent:keyEvent keyValue:keyValue];
    [self readKeyFunWithKeyKeyFuncModel:data completionHandler:completionHandler];
}

/// 设置自定义设备的按键信息
/// @param funcModel 按键的模型
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)setKeyFunWithKeyKeyFuncModel:(ZYKeyFuncModel *)funcModel keyFunc:(ZYkeyFunc)keyFun completionHandler:(void(^)(BOOL success))completionHandler{
    ZYBlKeyFuncSetData *keySetData =[[ZYBlKeyFuncSetData alloc] init];
    keySetData.keyInfo = funcModel.keyInfo;
    keySetData.keyFunc = keyFun;
    [keySetData createRawData];
    ZYBleMutableRequest* sendData = [[ZYBleMutableRequest alloc] initWithZYControlData:keySetData];
    [self configRequest:sendData];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    [client sendMutableRequest:sendData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"seatDataSuccess = %@",param);
            if (completionHandler) {
                completionHandler(YES);
            }
        } else {
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    }];
}
-(void)setKeyFunWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8_t)keyValue keyFunc:(ZYkeyFunc)keyFun completionHandler:(void(^)(BOOL success))completionHandler{
    ZYKeyFuncModel *data = [[ZYKeyFuncModel alloc] initWithKeyType:keyType keyGroup:keyGroup keyEvent:keyEvent keyValue:keyValue];
    [self setKeyFunWithKeyKeyFuncModel:data keyFunc:keyFun completionHandler:completionHandler];
}

@end
