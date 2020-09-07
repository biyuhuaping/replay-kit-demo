//
//  ZYDeviceRemoteControl.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceRemoteControl.h"
#import "ZYBleDeviceClient.h"
#import "ZYHardwareUpgradeSyncModel.h"
#import "ZYDeviceManager.h"
#import "ZYBleDeviceDataModel.h"

@implementation ZYDeviceRemoteControl
-(instancetype)init{
    if (self == [super init]) {

    }
    return self;
}

-(void)onDeviceBLEReadyToUse:(NSNotification *)noty{
    [self queryVersionCompleted:^(BOOL isSuccess, NSString *Version) {
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_PTZReadyToUse object:self];
#ifdef DEBUG
            
            NSLog(@"ZWB query Version :%@",Version);
#endif

            self.workingState = 1;
            [ZYDeviceManager defaultManager].modelNumberString = modelNumberCraneZWB;
            self.hardwareUpgradeManager = [ZYHardwareUpgradeManager hardwareUpgradeManagerWithSoftwareVersion:Version modelNumberString:@"ZW-B"];
            self.hardwareUpgradeManager.sendDelegate = self;
            
#pragma -mark 检查是否需要升级
                [[NSNotificationCenter defaultCenter] postNotificationName:HardwareUpgrade_IsNeedToUpgrade object:nil userInfo:@{@"isNeed":@(NO)}];

        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_PTZOffLine object:self];


            self.workingState = 0;
        }
    }];     
}


-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configRequest:request];
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}

-(void)configRequest:(ZYBleDeviceRequest *)request{
    //配置传输方式
    
    request.trasmissionType = ZYTrasmissionTypeBLE;
    
    //配置解码方式
    request.parseFormat = ZYCodeParseStar;
}

#pragma -mark zysendDelegate
-(void)configEncodeAndTransmissionForRequest:(ZYBleDeviceRequest *)request{
    [self configRequest:request];
}

-(void)queryVersionCompleted:(void(^)(BOOL isSuccess,NSString* Version))handler{
    if (self.deviceInfo) {
        @weakify(self)
        [self sendRequest:ZYBleInteractSysReset data:@(ZYBLE_DATA_RESET) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if ((state == ZYBleDeviceRequestStateResponse) || (state == ZYBleDeviceRequestStateTimeout)) {
                @strongify(self)
                ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:1 withCommand:ZYBleInteractSync];
                [self configRequest:request];
                [[ZYBleDeviceClient defaultClient] sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
                    @strongify(self)
                    if (state == ZYBleDeviceRequestStateResponse) {
                        //                BLOCK_EXEC(successed,param);
                        ZYHardwareUpgradeSyncModel *syncResult =  [ZYHardwareUpgradeSyncModel UpgradeSyncModelWithDictionary:param];
#ifdef DEBUG
                        
                        NSLog(@"Sync ZWB success！：%@",param);
#endif


                        BLOCK_EXEC(handler,YES,[NSString stringWithFormat:@"%ld",syncResult.hwVersion]);
                    } else {
#ifdef DEBUG
                        
                        NSLog(@"query ZWB Version error state:%ld param:%@",state,param);
#endif

                        BLOCK_EXEC(handler,NO,nil);
                    }
                }];

            } else {
//                NSError *error = [NSError errorWithDomain:@"System reset farilure" code:0 userInfo:nil];
#ifdef DEBUG
                
                NSLog(@"System reset farilure");
#endif

                BLOCK_EXEC(handler,NO,Nil);
            }
        }];

    }
}



-(void)connectSetup{
#ifdef DEBUG
  NSLog(@" %@ connectSetup SSSSSSSSS!",[self deviceName]);
#endif

  

//    self.hardwareUpgradeManager = [[ZYHardwareUpgradeManager alloc] init];//初始化下载管理.


    self.workingState = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceBLEReadyToUse:) name:Device_BLEReadyToUse object:nil];
}

-(void)clearDataSource{
    self.workingState = -1;
#ifdef DEBUG
    
    NSLog(@" %@ clearDataSource CCCCCCCCC!",[self deviceName]);
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
