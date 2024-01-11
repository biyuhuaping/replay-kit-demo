//
//  ZYCameraWiFIManager.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NSString * const CameraWIFIEnable = @"CameraWIFIEnable";
NSString * const ZYWifiStatusNoti = @"ZYWifiStatusNoti";
// 访问相册状态回调
NSString * const ZYCamera_AlbumVisit_Notifi = @"ZYCamera_AlbumVisit_Notifi";
NSString * const ZYCamera_DoRetryDataSuccess = @"ZYCamera_DoRetryDataSuccess";// 重新获取数据

#import "ZYCameraWiFIManager.h"
#import "ZYBleDeviceClient.h"
#import "ZYDeviceStabilizer.h"
#import "ZYDeviceManager.h"
#import "UIDevice+WifiOpened.h"
#import "ZYBlWiFiHotspotPSWData.h"
#import "ZYBlWiFiHotspotSetPSWData.h"
#import "ZYBlWiFiHotspotGetSSIDData.h"
#import "ZYBlWiFiHotspotStatusData.h"
#import "ZYBlWiFiHotspotEnableData.h"
#import "ZYBlWiFiHotspotDisableData.h"
#import "ZYBlWiFiHotspotResetData.h"
#import "ZYBlWiFiHotspotDHCPCleanData.h"
//#import "ZYNetwrokManager.h"
#import "ZYDeviceStablizerTestTool.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
//#import "UIDevice+BatteryString.h"

#define kMinConnectCount   1
#define kHeartCheckTimerDistance 3

@interface ZYCameraWiFIManager ()

/*!
 云鹤系列相机设备的数据模型
 */
@property (nonatomic, readwrite) ZYCameraWifiData  *cameraData;

@property (nonatomic)            NSUInteger          connectCount;//连接和断开连接的次数的次数记录

@property (nonatomic)         BOOL                  ZYCameraWifiParaCodeAlling;//正在获取所有的数据

@property (nonatomic)         BOOL                  isConnectWifiAndRDISRecive;//RDIS通过Wi-Fi已经收到

@property (nonatomic)         NSDate                 *wifiReadyCheckDate;//校验Wi-Fi是否可以使用，用指令去匹配
@property (nonatomic)         NSDate                 *wifiReadyCheckDateBegain;//校验Wi-Fi是否可以使用，用指令去匹配

@property (nonatomic)         NSDate                 *wifiHeartBeatRecive;//心跳的指令

@property (nonatomic, readwrite) NSTimer             *heartCheckTimer;//心跳检测的定时器



@end
@implementation ZYCameraWiFIManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        _cameraData = [[ZYCameraWifiData alloc] init];
        _connectCount = 0;
        _wifiEnable = NO;
        _isConnectWifiAndRDISRecive = NO;
        [self addCheckWifiConnectNoti];
       
    }
    return self;
}

-(void)setSendDelegate:(id<ZYSendRequest>)sendDelegate{
    _cameraData.sendDelegate = sendDelegate;
    _sendDelegate = sendDelegate;
}

-(BOOL)appFunctionWithType:(ZYCameraFunctonType)type status:(ZYCameraFunctonTypeStatus)status handler:(void (^)(BOOL))handler{
    
    ZYCameraWifiParaCode code = ZYCameraWifiParaNormalRecord;
    if ([self supportCameraSettingHandler:handler]) {
        
        
        switch (type) {
            case ZYCameraFunctonTypeMoveDelayRecord:
            {
                code = ZYCameraWifiParaMoveDelayRecord;
                break;
            }
            case ZYCameraFunctonTypeFullView:
            {
                code = ZYCameraWifiParaFullView;
                break;
            }
            case ZYCameraFunctonTypeNormalRecord:
            {
                code = ZYCameraWifiParaNormalRecord;
                break;
            }
            default:
            {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
                return NO;
                break;
            }
        }
        NSString *value = nil;
        switch (status) {
            case ZYCameraFunctonTypeStatusBegain:
            {
                value = @"1";
                break;
            }
            case ZYCameraFunctonTypeStatusEnd:
            {
                value = @"0";
                break;
            }
            case ZYCameraFunctonTypeStatusCancel:
            {
                value = @"2";
                break;
            }
            default:
            {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
                return NO;
                break;
            }
        }
        
        [self.cameraData setCameraWithCode:code value:value handler:handler];
        return YES;
    }
    else{
        return NO;
    }
    
}
#pragma -mark zoom
/**
 相机添加变焦，按键组3键值及对应功能
 
 @param isWOrT 只有WT
 @param level level  0~7等级
 @param handler 设置成功的回掉
 @return 是否成功设置的回掉
 */
-(BOOL)zoomCameraWithIsW:(BOOL)isWOrT level:(NSInteger)level handler:(void (^)(BOOL success))handler{
    
    if ([self supportCameraSettingHandler:handler]) {
        if (level < 0) {
            level = 0;
        }
        else if (level > 7){
            level = 7;
        }
        
        int event_button = isWOrT ? kCLICK_EVENT_BUTTON3_ZOOM_W_KEY: kCLICK_EVENT_BUTTON3_ZOOM_T_KEY;
        
        NSNumber *data = @(makeKeyTypeGroupParam(KCLICK_KEY_TYPE_PRESSURE,kCLICK_GROUP_3,level, event_button));
        
        [self sendRequest:ZYBleInteractButtonEvent data:data completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
            } else {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
            }
        }];
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)focusWithClockwise:(BOOL)isClockwise handler:(void (^)(BOOL))handler{
    NSNumber *data = @(makeGroupParam(kCLICK_GROUP_1, kCLICK_EVENT_BUTTON1_ENC_CW_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
    if (isClockwise) {
        data = @(makeGroupParam(kCLICK_GROUP_1, kCLICK_EVENT_BUTTON1_ENC_CCW_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
    }
    [self sendRequest:ZYBleInteractButtonEvent data:data completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
        } else {
            BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        }
    }];
    return YES;
}

-(BOOL)zoomWithValue:(NSUInteger)value handler:(void (^)(BOOL success))handler{
    if ([self supportCameraSettingHandler:handler]) {
        
        if (value >= 65536) {
            value = value % 65535;
        }
        [self sendRequest:ZYBleInteractZoomControl data:@(value) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
            } else {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
            }
        }];
        return YES;
    }
    else{
        return NO;
    }
}

-(void)zoomValueHandler:(void (^)(NSUInteger))handler{
    if ([self supportCameraSettingHandler:nil]) {
        [self sendRequest:ZYBleInteractZoomVirtualPos data:@(0) withCount:3 completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, param)
            } else {
                
                BLOCK_EXEC_ON_MAINQUEUE(handler, 0);
            }
        }];
    }
    else{
        handler(0);
    }
}

-(BOOL)focusWithValue:(NSUInteger)value handler:(void (^)(BOOL success))handler{
    if ([self supportCameraSettingHandler:handler]) {
        
        if (value >= 65536) {
            value = value % 65535;
        }
        [self sendRequest:ZYBleInteractFFControl data:@(value) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
            } else {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
            }
        }];
        return YES;
    }
    else{
        return NO;
    }
    
}

-(void)focusValueHandler:(void (^)(NSUInteger))handler{
    if ([self supportCameraSettingHandler:nil]) {
        [self sendRequest:ZYBleInteractFFVirtualPos data:@(0) withCount:3 completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, param)
            } else {
                
                BLOCK_EXEC_ON_MAINQUEUE(handler, 0);
            }
        }];
    }
    else{
        handler(0);
    }
}


#pragma -mark camera
-(BOOL)supportCameraSettingHandler:(void (^)(BOOL success))handler{
    
    BOOL support = [[self class] supportCameraSetting];
    if (support == NO) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
    }
    return support;
}

+(BOOL)supportCameraSetting{
    ZYDeviceSeries deviceSeries = [ZYDeviceManager defaultManager].stablizerDevice.deviceSeries;
    BOOL deviceSupport = (deviceSeries == ZYDeviceSeriesCrane || deviceSeries == ZYDeviceSeriesWeebill || deviceSeries == ZYDeviceSeriesImageBox);
    
    if (ZYDeviceSeriesUnknow == deviceSeries || deviceSupport) {
        NSString *modelNumberString = [ZYDeviceManager defaultManager].stablizerDevice.modelNumberString;
        if (modelNumberString == nil) {
            modelNumberString = [ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString;
        }
        if ([ZYBleDeviceDataModel isModelSupportWIFI:modelNumberString]) {
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}
/**
 相机iso调节
 
 @param isoValue ISO的值
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithISO:(NSString *)isoValue handler:(void (^)(BOOL success))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (isoValue.length > 0) {
#ifdef DEBUG
            NSLog(@"-------ZYDeviceStablizerTestTool");
#endif
            
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeISO value:isoValue handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"iso = %@ not support",isoValue);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraWithAperture:(NSString *)aperture handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (aperture.length > 0) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeF_Number value:aperture handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"aperture = %@ not support",aperture);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configVisitCameraSource:(BOOL)enableVisitCamera handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (![self.cameraData.supportVisitCameraSource isEqualToString:@"1"]) {
            NSLog(@"不能访问相册 supportVisitCameraSource 130 不为 1");
            return NO;
        }
        
        if (enableVisitCamera) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeConfigVisitCamera value:@"1" handler:handler];
            return YES;
        }
        else{
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeConfigVisitCamera value:@"0" handler:handler];
            return YES;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)supplyLineCameraControlPower:(NSString *)controlPower handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (controlPower.length > 0) {
            NSString *name = [[UIDevice currentDevice] name];
            
            if (![controlPower isEqualToString:@"0"]) {
                if (self.cameraData.suppplyControlPower.length >2) {
                    name = [self.cameraData.suppplyControlPower substringWithRange: NSMakeRange(2, self.cameraData.suppplyControlPower.length - 2)];
                    
                }
                controlPower = [NSString stringWithFormat:@"%@,%@",controlPower,name];
                
            }
            else{
                controlPower = [NSString stringWithFormat:@"%@,%@,%@",controlPower,[self p_deviceIdentifierForVendor],name];
            }
            NSLog(@"controlPower====%@",controlPower);
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeSupplyControlPower value:controlPower handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"controlPower = %@ not support",shutterTime);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraWithShutterTime:(NSString *)shutterTime handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (shutterTime.length > 0) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeShutterSpeed value:shutterTime handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"shutterTime = %@ not support",shutterTime);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraWithEV:(NSString *)evValue handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (evValue.length > 0) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeEV value:evValue handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"ev = %@ not support",evValue);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraWithWB:(NSString *)wbValue handler:(void (^)(BOOL success))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (wbValue.length > 0) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeWB value:wbValue handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"wb = %@ not support",wbValue);
            return NO;
        }
    }
    else{
        return NO;
    }
    
}

-(BOOL)configCameraWithAFareaWithXloction:(int)x yLocation:(int)y handler:(void (^)(BOOL))handler{
    if (x < 0) {
        x = 0;
    }
    else if (x > 65535){
        x = 65535;
    }
    
    if (y < 0) {
        y = 0;
    }
    else if (y > 65535){
        y = 65535;
    }
    
    NSString *str = [NSString stringWithFormat:@"%dx%d",x,y];
    return [self configCameraWithAFarea:str handler:handler];
}

-(BOOL)configCameraWithAFarea:(NSString *)afarea handler:(void (^)(BOOL))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (afarea.length > 0) {
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeAfarea value:afarea handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"wb = %@ not support",wbValue);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraWithimageTransferQualityControl:(NSString *)qualityValue handler:(void (^)(BOOL success))handler{
    if ([self supportCameraSettingHandler:handler]) {
        if (qualityValue.length > 0) {
            //            @weakify(self);
#ifdef DEBUG
            
            NSLog(@"首先b关闭图传");
#endif
            //            [self enableImageTransport:NO noti:NO handler:^(BOOL success) {
            //                @strongify(self);
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeImageTransferQualityControl value:qualityValue handler:handler];
            //            }];
            
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            //            NSLog(@"wb = %@ not support",wbValue);
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)configCameraTransitionDecodeType:(NSString *)decodeType handler:(void (^)(BOOL))handler{
    
    if ([self supportCameraSettingHandler:handler]) {
        if (decodeType.length > 0) {
            
            [self.cameraData setCameraWithCode:ZYCameraWifiParaCodeImageTransferAddressAndPara value:decodeType handler:handler];
            return YES;
        }
        else{
            BLOCK_EXEC_ON_MAINQUEUE(handler,NO);
            return NO;
        }
    }
    else{
        return NO;
    }
    
}


-(void)supportArgument:(NSString *)argument handler:(void (^)(NSArray *))handler{
    
    NSString *cameraMode = self.cameraData.cameraMode;
#pragma -mark 测试,正式版本去掉
    if (cameraMode == nil) {
        //        NSLog(@"cameraMode nil");
        cameraMode = @"M";
    }
    [self.cameraData getAllCameraDic:^(NSDictionary *dic) {
        if (dic) {
            NSDictionary *argumentDic = [dic objectForKey:argument];
            if (argumentDic) {
                NSArray *array = [argumentDic objectForKey:cameraMode];
                if (array) {
                    handler(array);
                }
                else{
                    //                    NSLog(@"参数%@在模式%@不支持", argument, cameraMode);
                    handler(@[]);
                }
            }
            else{
                //                NSLog(@"参数%@不支持",argument);
                handler(@[]);
            }
            
        }else{
            //            NSLog(@"参数列表没获取到");
            handler(@[]);
        }
    }];
}

-(void)allSupportArgumentHandler:(void (^)(NSArray *))handler{
    
    [self.cameraData getAllCameraDic:^(NSDictionary *dic) {
        if (dic) {
            NSMutableArray *returnArr = [[NSMutableArray alloc] init];
            for (NSString *str  in dic.allKeys) {
                [self supportArgument:str handler:^(NSArray *inner) {
                    if (inner.count) {
                        [returnArr addObject:str];
                    }
                }];
            }
            handler(returnArr);
        }else{
            //            NSLog(@"参数列表没获取到");
            handler(@[]);
        }
    }];
}

-(void)allSupportImageTransQualityHandler:(void (^)(NSArray *))handler{
    
    [self.cameraData getAllCameraDic:^(NSDictionary *dic) {
        if (dic) {
            NSMutableArray *returnArr = [[NSMutableArray alloc] init];
            for (NSString *str  in dic.allKeys) {
                [self supportImageTransQualityArgumentHandler:^(NSArray *inner) {
                    if (inner.count) {
                        [returnArr addObject:str];
                    }
                }];
            }
            handler(returnArr);
        }else{
            //            NSLog(@"参数列表没获取到");
            handler(@[]);
        }
    }];
}

-(void)supportImageTransQualityArgumentHandler:(void (^)(NSArray *))handler{
    
    [self.cameraData getImageTransferQualityControlhandler:handler];
}

-(void)enableImageTransport:(BOOL)enable noti:(BOOL)noti sendCode:(BOOL)sendCode handler:(void (^)(BOOL))handler{
    //    NSLog(@"%d 图传",enable);
    
    if (sendCode == NO) {
        if (noti) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraLiveSteamEnable object:nil];
            
        }
        if (handler) {
            handler(YES);
        }
        return;
    }
    
    ZYUsbInstructionMediaStreamData* usbInstructionMediaStreamData = [[ZYUsbInstructionMediaStreamData alloc] init];
    usbInstructionMediaStreamData.flag = enable?1:0; //UMCMediaStreamStatusOpen;
    [usbInstructionMediaStreamData createRawData];
    ZYBleMutableRequest* usbInstructionMediaStreamRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:usbInstructionMediaStreamData];
    [self sendMutableRequest:usbInstructionMediaStreamRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYUsbInstructionMediaStreamData* usbInstructionMediaStreamDataRespond = (ZYUsbInstructionMediaStreamData*)param;
            //            NSLog(@"打开视频流:%lu:%lu", (unsigned long)usbInstructionMediaStreamDataRespond.cmdStatus, (unsigned long)usbInstructionMediaStreamDataRespond.flag);
            if (handler) {
                handler(YES);
            }
        } else {
            //            NSLog(@"打开视频流超时");
            if (handler) {
                handler(NO);
            }
            
        }
        if (noti) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraLiveSteamEnable object:nil];
            
        }
    }];
}
-(void)enableImageTransport:(BOOL)enable noti:(BOOL)noti handler:(void (^)(BOOL success))handler{
    [self enableImageTransport:enable noti:noti sendCode:YES handler:handler];
}

-(void)enableImageTransport:(BOOL)enable handler:(void (^)(BOOL success))handler{
    [self enableImageTransport:enable noti:YES handler:handler];
}
-(void)p_doBegainBaseQueryData:(void (^)(void))completed withSSID:(NSString *)ssid changeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection{
    #pragma -mark 提交图传盒子
    BOOL imageBox = [self isImageTransBox];
    
    NSString *strWifi = ssid;
    if (imageBox || ([strWifi isEqualToString:self.cameraData.ssid] && strWifi.length > 0 && self.cameraData.ssid.length > 0)) {
        if (self.wifiReadyCheckDate == nil || [[NSDate date] timeIntervalSinceDate:self.wifiReadyCheckDate] > 1) {
            if (self.wifiReadyCheckDate == nil) {
                self.wifiReadyCheckDateBegain = [NSDate date];
                self.wifiReadyCheckDate = self.wifiReadyCheckDateBegain;
            }
            else{
                self.wifiReadyCheckDate = [NSDate date];
            }
            [self checkConnect];
        }
        
    }
    else{
        [self clearCheckConnect];
    }
    if (wifiConnection)
    {
        wifiConnection(self.wifiEnable);
    }
    if (completed) {
        completed();
    }
}
-(void)p_doBaseQueryData:(void (^)(void))completed changeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection{
    
    [self p_doBegainBaseQueryData:completed withSSID:self.cameraData.ssid changeToWifiConnection:wifiConnection];
}

-(void)checkConnect{
    self.cameraData.getAllParaState = ZYCameraWifiGetParaState_begain;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"begain"}];
    
    if ([self.modelNameString isEqualToString:modelNumberImageTransBox]) {
        ZYBlCCSGetConfigData* blData = [[ZYBlCCSGetConfigData alloc] init];
        blData.idx = ZYCameraWifiCodeSystemStatus_R;
        [blData createRawData];
        ZYBleMutableRequest* requestDevice = [[ZYBleMutableRequest alloc] initWithZYControlData:blData];
        [self configReq:requestDevice];
        
        requestDevice.trasmissionType = ZYTrasmissionTypeWIFI;
        @weakify(self);
        [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestDevice completionHandler:^(ZYBleDeviceRequestState state, id param) {
            @strongify(self);
            if (state == ZYBleDeviceRequestStateResponse) {
                if ([param isKindOfClass:[ZYBlCCSGetConfigData class]]) {
                    ZYBlCCSGetConfigData* blCCSGetConfigDataRespond = (ZYBlCCSGetConfigData*)param;
                    //                    NSLog(@"------查询设备状态%lu成功%@", blCCSGetConfigDataRespond.idx ,blCCSGetConfigDataRespond.value);
                    if (blCCSGetConfigDataRespond.idx == ZYCameraWifiCodeSystemStatus_R && blCCSGetConfigDataRespond.value.length > 0) {
                        
                        [self querySSIDWithCount:3 customTrsmisionn:ZYTrasmissionTypeWIFI completionHandler:^(NSString *ssid) {
                            @strongify(self);
                            self.isWifiReady = ZYWifiStatusIsReady;
                            [self p_wifiDoBaseQueryData:nil withSSid:ssid changeToWifiConnection:nil];
                            self.wifiReadyCheckDate = nil;
                        }];

                        
                    }
                    else{
                        [[ZYBleDeviceClient defaultClient] pauseReceiving];
                    }
                }
                
            }
            else{
                if (self.wifiReadyCheckDate) {
                    [self performSelector:@selector(doAgainWifiReadyCheck) withObject:nil afterDelay:1];
                }
            }
        }];
    }
    else{
        ZYBleDeviceRequest* requestDevice = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeSystemStatus_R param:@(0)];
        [self configReq:requestDevice];
        
        requestDevice.trasmissionType = ZYTrasmissionTypeWIFI;
        @weakify(self);
        [[ZYBleDeviceClient defaultClient] sendBLERequest:requestDevice completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            @strongify(self);
            if (state == ZYBleDeviceRequestStateResponse) {
                self.isWifiReady = ZYWifiStatusIsReady;
                [self p_wifiDoBaseQueryData:nil withSSid:self.cameraData.ssid changeToWifiConnection:nil];
                self.wifiReadyCheckDate = nil;
            }
            else{
                if (self.wifiReadyCheckDate) {
                    [self performSelector:@selector(doAgainWifiReadyCheck) withObject:nil afterDelay:1];
                }
            }
        }];
    }
    
}

-(void)clearCheckConnect{
    self.wifiReadyCheckDateBegain = nil;
    self.wifiReadyCheckDate = nil;
    self.wifiEnable = NO;
}

-(void)doAgainWifiReadyCheck{
    if ([[NSDate date] timeIntervalSinceDate:self.wifiReadyCheckDateBegain] > 15) {
        self.cameraData.getAllParaState = ZYCameraWifiGetParaState_error;
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"error"}];
        self.isWifiReady = ZYWifiStatusCantSendData;
        [self clearCheckConnect];
    }
    else{
        [self p_doBaseQueryData:nil changeToWifiConnection:nil];
    }
}


-(void)p_wifiDoBaseQueryData:(void (^)(void))completed withSSid:(NSString *)strWifi changeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection{
    
#pragma -mark 图传盒子
    BOOL isImageBox = [self isImageTransBox];
    BOOL needCloseImageTransport = NO;
    if (isImageBox || ([strWifi isEqualToString:self.cameraData.ssid] && strWifi.length > 0 && self.cameraData.ssid.length > 0)) {
        BOOL before = self.wifiEnable;
        if (isImageBox) {
            //如果是图传盒子，直接把ssid复制过去
            if (strWifi.length > 0) {
                if (![self.cameraData.ssid isEqualToString:strWifi]) {
                     self.cameraData.ssid = strWifi;
                }
            }
        }
        self.wifiEnable = YES;
        if (before == NO) {
#pragma mark 连接上设备之后关闭图传
            needCloseImageTransport = YES;
            
        }
        
        
    }
    else{
#pragma -mark wifienable = NO
        self.wifiEnable = NO;
        [self.cameraData cleanData];
        [self autoConnectWifi];
    }
    //    NSLog(@"当前wifi%@", self.wifiEnable ? @"可用" : @"不可用");
#pragma -mark 前面是蓝牙模块
    //切换到Wi-Fi
    if (wifiConnection)
    {
        wifiConnection(self.wifiEnable);
    }
#pragma -mark 后面是Wi-Fi模块
    if (self.wifiEnable && self.cameraData.cameraMode == nil) {
        if (needCloseImageTransport) {
            [self enableImageTransport:NO
                                  noti:NO handler:^(BOOL success) {
                
            }];
        }
        [self getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:1];
    }
    
    if (completed) {
        completed();
    }
}

-(NSString *)p_deviceIdentifierForVendor{
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    deviceUUID = [deviceUUID stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return deviceUUID;
}
-(BOOL)supportHevc {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0)
        return NO;
    
    if (@available(iOS 11.0, *))
        return VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC);
    
    return NO;
}

-(void)sendMessage{
    NSString *deviceUUID =[self p_deviceIdentifierForVendor];
    NSString *name = [[UIDevice currentDevice] name];
    NSString *supportDecodeType = @"h265";
    NSString *supportDecodeTypeH264 = @"h264";
    NSString *supportDecode = supportDecodeTypeH264;
    if ([self supportHevc]) {
        supportDecode = [NSString stringWithFormat:@"%@+%@",supportDecodeType,supportDecodeTypeH264];
    }
    NSString *localIphone = [NSString stringWithFormat:@"%@+%@+%@",deviceUUID,name,supportDecode];
    //    NSLog(@"localIphone====%@",localIphone);
    
    [self sendMessageWithCount:3 withMessage:localIphone];
}

-(void)sendMessageWithCount:(int)count withMessage:(NSString *)localIphone{
    __block int innerCount = count - 1;
    __block NSString *inner = localIphone;
    ZYBlOtherDeviceInfoData *data = [[ZYBlOtherDeviceInfoData alloc] init];
    NSLog(@"localIphone=%@",localIphone);
    data.localInfo = localIphone;
    [self sendRequest:data completionHandler:^(ZYBleDeviceRequestState state, id param) {
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlOtherDeviceInfoData class]]) {
                //                ZYBlOtherDeviceInfoData *innerData = param;
                //                NSLog(@"%@ %lu %@",innerData.localInfo,(unsigned long)innerData.flag,innerData.remoteInfo);
            }
        }
        else{
            if (count >= 0) {
                [self sendMessageWithCount:innerCount withMessage:inner];
            }
        }
        
    }];
}

-(void)doBaseQueryData:(void (^)(void))completed changeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection{
    
    
    if ([self isImageTransBox]) {
        [self p_doBegainBaseQueryData:completed withSSID:nil changeToWifiConnection:wifiConnection];
        return;
    }
    
    //Todo
    @weakify(self)
    [self getSSIDcompletionHandler:^(NSString *ssid) {
        @strongify(self);
        [self getPwdCompletionHandler:^(NSString *pwd) {
            @strongify(self);
            [self p_doBegainBaseQueryData:completed withSSID:ssid changeToWifiConnection:wifiConnection];
        }];
    }];
}

-(void)clearDHCPCompletionHandler:(void(^)(BOOL success))handler{
    ZYBlWiFiHotspotDHCPCleanData *reset = [[ZYBlWiFiHotspotDHCPCleanData alloc] init];
    @weakify(self)
    [self sendRequest:reset completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotDHCPCleanData class]]) {
                ZYBlWiFiHotspotDHCPCleanData* respond = (ZYBlWiFiHotspotDHCPCleanData*)param;
#ifdef DEBUG
                NSLog(@"reset 成功");
#endif
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(YES);
                }
                return ;
            }
            
        } else {
            //            NSLog(@"ZYBlWiFiHotspotDHCPCleanData查询设备状态失败");
        }
        if (handler) {
            handler(NO);
        }
    }];
}

-(void)resetWifiCompletionHandler:(void(^)(BOOL success))handler{
    ZYBlWiFiHotspotResetData *reset = [[ZYBlWiFiHotspotResetData alloc] init];
    @weakify(self)
    [self sendRequest:reset completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotResetData class]]) {
                ZYBlWiFiHotspotResetData* respond = (ZYBlWiFiHotspotResetData*)param;
#ifdef DEBUG
                NSLog(@"reset 成功");
#endif
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(YES);
                }
                return ;
            }
            
        } else {
            //            NSLog(@"ZYBlWiFiHotspotResetData查询设备状态失败");
        }
        if (handler) {
            handler(NO);
        }
    }];
}

-(void)enableWifi:(BOOL)enable completionHandler:(void(^)(BOOL success))handler{
    ZYBlData *ble = nil;
    if (enable) {
        ble = [[ZYBlWiFiHotspotEnableData alloc] init];
    }
    else{
        ble = [[ZYBlWiFiHotspotDisableData alloc] init];
    }
    @weakify(self)
    
    [self sendRequest:ble completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotEnableData class]]) {
                ZYBlWiFiHotspotEnableData* respond = (ZYBlWiFiHotspotEnableData*)param;
#ifdef DEBUG
                NSLog(@"Enable wifi成功");
#endif
                [self changeWifiStatus:respond.wifiStatus];
                if (handler) {
                    handler(YES);
                }
                return ;
            }
            else  if ([param isKindOfClass:[ZYBlWiFiHotspotDisableData class]]) {
                ZYBlWiFiHotspotDisableData* respond = (ZYBlWiFiHotspotDisableData*)param;
#ifdef DEBUG
                NSLog(@"disable wifi成功");
#endif
                [self changeWifiStatus:respond.wifiStatus];
                if (handler) {
                    handler(YES);
                }
                return ;
            }
            
        } else {
            //            NSLog(@"ZYBlWiFiHotspotEnableData Or Disable查询设备状态失败");
        }
        if (handler) {
            handler(NO);
        }
    }];
}

-(void)changeWifiStatus:(STSTUS_WIFI_STATUS)status{
    self.cameraData.wifiStatus = status;
}

-(void)getWifiStatusCompletionHandler:(void(^)(STSTUS_WIFI_STATUS statue))handler{
    ZYBlWiFiHotspotStatusData *sendData = [[ZYBlWiFiHotspotStatusData alloc] init];
    @weakify(self)
    [self sendRequest:sendData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotStatusData class]]) {
                ZYBlWiFiHotspotStatusData* respond = (ZYBlWiFiHotspotStatusData*)param;
#ifdef DEBUG
                
                NSLog(@"查询设备status =%lu成功", (unsigned long)respond.wifiStatus);
#endif
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(respond.wifiStatus);
                }
                return ;
            }
            
        } else {
            //            NSLog(@"ZYBlWiFiHotspotStatusData查询设备状态失败");
        }
        if (handler) {
            handler(STSTUS_WIFI_STATUS_NONE);
        }
    }];
}

-(void)queryPwdWithCount:(int)count  completionHandler:(void(^)(NSString *pwd))handler{
    __block int totalCount = count - 1 ;
    
    ZYBlWiFiHotspotPSWData *pwdCMD = [[ZYBlWiFiHotspotPSWData alloc] init];
    @weakify(self)
    
    [self sendRequest:pwdCMD  completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotPSWData class]]) {
                ZYBlWiFiHotspotPSWData* respond = (ZYBlWiFiHotspotPSWData*)param;
#ifdef DEBUG
                NSLog(@"查询设备pwd =%@成功", respond.PSW);
#endif
                self.cameraData.password = respond.PSW;
                
                [self autoConnectWifi];
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(respond.PSW);
                }
                return ;
            }
            
        } else {
            if (totalCount <= 0) {
                if (handler) {
                    handler(nil);
                }
            }
            else{
                [self queryPwdWithCount:totalCount completionHandler:handler];
            }
        }
    }];
}


-(void)queryPwdWithCount:(int)count customTrsmisionn:(ZYTrasmissionType)customTrsmisionn   completionHandler:(void(^)(NSString *pwd))handler{
    __block int totalCount = count - 1 ;
    
    ZYBlWiFiHotspotPSWData *pwdCMD = [[ZYBlWiFiHotspotPSWData alloc] init];
    @weakify(self)
    
    [self sendRequest:pwdCMD customTrsmisionn:customTrsmisionn  completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotPSWData class]]) {
                ZYBlWiFiHotspotPSWData* respond = (ZYBlWiFiHotspotPSWData*)param;
#ifdef DEBUG
                NSLog(@"查询设备pwd =%@成功", respond.PSW);
#endif
                self.cameraData.password = respond.PSW;
                
                [self autoConnectWifi];
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(respond.PSW);
                }
                return ;
            }
            
        } else {
            if (totalCount <= 0) {
                if (handler) {
                    handler(nil);
                }
            }
            else{
                [self queryPwdWithCount:totalCount customTrsmisionn:customTrsmisionn completionHandler:handler];
            }
        }
    }];
}

-(void)getPwdCompletionHandler:(void(^)(NSString *pwd))handler{
    if (self.cameraData.password.length > 0) {
        handler(self.cameraData.password);
    }
    else{
        if ([self p_is3LabAndWeebillLab]) {
            [self queryPwdWithCount:3 customTrsmisionn:ZYTrasmissionTypeBLE completionHandler:handler];
        }
        else{
            [self queryPwdWithCount:3 completionHandler:handler];
        }
    }
}

-(void)setPassword:(NSString *)password completionHandler:(void (^)(BOOL success))handler{
    NSString * regex = @"^[A-Za-z0-9]{8,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:password];
    if (isMatch) {
        ZYBlWiFiHotspotSetPSWData *passwordData = [[ZYBlWiFiHotspotSetPSWData alloc] init];
        passwordData.password = password;
        [self sendRequest:passwordData completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                if ([param isKindOfClass:[ZYBlWiFiHotspotSetPSWData class]]) {
                    ZYBlWiFiHotspotSetPSWData* respond = (ZYBlWiFiHotspotSetPSWData*)param;
#ifdef DEBUG
                    NSLog(@"设置设备password =%@成功", password);
#endif
                    NSLog(@"设置 =%lu成功", (unsigned long)respond.wifiStatus);
                    if (handler) {
                        handler(YES);
                    }
                }
                else{
                    if (handler) {
                        handler(NO);
                    }
                }
            }
            else{
                if (handler) {
                    handler(NO);
                }
            }
        }];
    }
    else{
        NSLog(@"字母匹配不合理，只能是A-Za-z0-9");
        if (handler) {
            handler(NO);
        }
    }
}

- (void)scanWiFiInfosWithType:(uint8_t)type :(void(^)(BOOL scanSuccess, NSArray *results))handler {
    ZYBlWiFiHotspotScan *scan = [[ZYBlWiFiHotspotScan alloc] init];
    scan.opt = type;
    [self sendRequest:scan completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotScan class]]) {
                ZYBlWiFiHotspotScan *tmp = (ZYBlWiFiHotspotScan *)param;
                if (type == 0)
                    handler(YES, nil);
                else if (type == 1)
                    handler(YES, tmp.array);
            }else {
                handler(NO, nil);
            }
        }else {
            handler(NO, nil);
        }
    }];
}

- (void)getWiFiList:(void(^)(NSArray<NSString *> *results))handler {
    ZYBlWiFiHotspotGetCHNList *getChnList = [[ZYBlWiFiHotspotGetCHNList alloc] init];
    [self sendRequest:getChnList completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotGetCHNList class]]) {
                ZYBlWiFiHotspotGetCHNList *tmp = (ZYBlWiFiHotspotGetCHNList *)param;
                handler(tmp.array);
            }else {
                handler(nil);
            }
        }else {
            handler(nil);
        }
    }];
}

- (void)getWiFiChannel:(void(^)(NSString *channelStr, uint8_t status))handler {
    ZYBlWiFiHotspotSetGetChannel *channel = [[ZYBlWiFiHotspotSetGetChannel alloc] init];
    channel.opt = 0;
    channel.channel_status = 0;
    channel.channel = @"";
    [self sendRequest:channel completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotSetGetChannel class]]) {
                ZYBlWiFiHotspotSetGetChannel *tmp = (ZYBlWiFiHotspotSetGetChannel *)param;
                handler(tmp.channel, tmp.channel_status);
            }else {
                handler(nil, 0);
            }
        }else {
            handler(nil, 0);
        }
    }];
}

- (void)setWiFiChannelWithStatus:(uint8_t)status channel:(NSString *)channel handler:(void(^)(bool isSuccess))handler {
    ZYBlWiFiHotspotSetGetChannel *obj = [[ZYBlWiFiHotspotSetGetChannel alloc] init];
    obj.opt = 1;
    obj.channel_status = status;
    if (obj.status == 2)
        channel = @"";
    
    obj.channel = channel;
    [self sendRequest:obj completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotSetGetChannel class]]) {
                ZYBlWiFiHotspotSetGetChannel *tmp = (ZYBlWiFiHotspotSetGetChannel *)param;
                if ([tmp.channel isEqualToString:channel] && tmp.channel_status == status && tmp.opt == 1)
                    handler(YES);
                else
                    handler(NO);
            }else {
                handler(NO);
            }
        }else {
            handler(NO);
        }
    }];
}

// 信道的流程图组合函数 暂时没用到
//- (void)testWiFiChannel:(void(^)(NSArray *array))handler {
//    [self getWiFiList:^(NSArray *results) {
//        if (!results || results.count < 1)
//            return;
//
//        [self scanWiFiInfosWithType:0 :^(BOOL scanSuccess, NSArray *results) {
//            if (!scanSuccess)
//                return;
//
//            sleep(6);
//            [self scanWiFiInfosWithType:1 :^(BOOL scanSuccess, NSArray *results) {
//                if (results.count > 0)
//                    handler(results);
//            }];
//        }];
//    }];
//}

-(void)p_querySSIDWithCount:(int)count customTrsmisionn:(ZYTrasmissionType)tranmisstion completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    __block int totalCount = count - 1 ;
    ZYBlWiFiHotspotGetSSIDData *ssidCMD = [[ZYBlWiFiHotspotGetSSIDData alloc] init];
    @weakify(self)
    [self sendRequest:ssidCMD customTrsmisionn:tranmisstion completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (handler) {
                handler(state,param);
            }
        } else {
            if (totalCount <= 0) {
                if (handler) {
                    handler(state,param);
                }
            }
            else{
                [self p_querySSIDWithCount:totalCount customTrsmisionn:tranmisstion completionHandler:handler];
            }
            
            //            NSLog(@"第%d次 ZYBlWiFiHotspotGetSSIDData查询设备状态失败",totalCount+1);
        }
        
    }];
}

-(void)p_querySSIDWithCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    __block int totalCount = count - 1 ;
    ZYBlWiFiHotspotGetSSIDData *ssidCMD = [[ZYBlWiFiHotspotGetSSIDData alloc] init];
    @weakify(self)
    [self sendRequest:ssidCMD completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (handler) {
                handler(state,param);
            }
        } else {
            if (totalCount <= 0) {
                if (handler) {
                    handler(state,param);
                }
            }
            else{
                [self p_querySSIDWithCount:totalCount completionHandler:handler];
            }
            
            //            NSLog(@"第%d次 ZYBlWiFiHotspotGetSSIDData查询设备状态失败",totalCount+1);
        }
        
    }];
}

-(void)querySSIDWithCount:(int)count completionHandler:(void(^)(NSString *ssid))handler{
    @weakify(self)
    [self p_querySSIDWithCount:count completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotGetSSIDData class]]) {
                ZYBlWiFiHotspotGetSSIDData* respond = (ZYBlWiFiHotspotGetSSIDData*)param;
#ifdef DEBUG
                //                NSLog(@"查询设备ssid =%@成功", respond.SSID);
#endif
                NSLog(@"查询设备ssid =%@成功", respond.SSID);
                self.cameraData.ssid = respond.SSID;
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(respond.SSID);
                }
                return ;
            }
        }
        else {
            if (handler) {
                handler(nil);
            }
        }
    }];
    
}

-(void)querySSIDWithCount:(int)count customTrsmisionn:(ZYTrasmissionType)tranmisstion completionHandler:(void(^)(NSString *ssid))handler{
    @weakify(self)
    [self p_querySSIDWithCount:count customTrsmisionn:tranmisstion completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiHotspotGetSSIDData class]]) {
                ZYBlWiFiHotspotGetSSIDData* respond = (ZYBlWiFiHotspotGetSSIDData*)param;
#ifdef DEBUG
                //                NSLog(@"查询设备ssid =%@成功", respond.SSID);
#endif
                NSLog(@"查询设备ssid =%@成功", respond.SSID);
                self.cameraData.ssid = respond.SSID;
                [self changeWifiStatus:(STSTUS_WIFI_STATUS)respond.wifiStatus];
                if (handler) {
                    handler(respond.SSID);
                }
                return ;
            }
        }
        else {
            if (handler) {
                handler(nil);
            }
        }
    }];
    
}

-(void)getSSIDcompletionHandler:(void(^)(NSString *ssid))handler{
    
    //    if ([self isImageTransBox]) {
    //        handler(@"");
    //        return;
    //    }
    if (self.cameraData.ssid.length > 0) {
        handler(self.cameraData.ssid);
    }
    else{
        if ([self p_is3LabAndWeebillLab]) {
            [self querySSIDWithCount:3 customTrsmisionn:ZYTrasmissionTypeBLE completionHandler:handler];
        }
        else{
            [self querySSIDWithCount:3 completionHandler:handler];
        }
    }
}
-(void)sendRequest:(ZYBlData *)blData customTrsmisionn:(ZYTrasmissionType)tranmisstion completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    [blData createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:blData];
    [self sendMutableRequest:request customTrsmisionn:tranmisstion completionHandler:handler];
}

-(void)sendRequest:(ZYBlData *)blData completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    
    [blData createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:blData];
    [self sendMutableRequest:request completionHandler:handler];
}

-(void)sendMutableRequest:(ZYBleMutableRequest *)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    [self configReq:request];
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:request completionHandler:handler];
}

-(void)sendMutableRequest:(ZYBleMutableRequest *)request customTrsmisionn:(ZYTrasmissionType)tranmisstion completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    [self configReq:request];
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    request.trasmissionType = tranmisstion;
    [client sendMutableRequest:request completionHandler:handler];
}

-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count{
    [self.cameraData getCameraDataWithNum:num withCount:count];
}

-(void)setWifiEnable:(BOOL)wifiEnable{
    _wifiEnable = wifiEnable;
    
    if (_wifiEnable == NO) {
        self.cameraData.imageTransferEnable = NO;
        self.isWifiReady = ZYWifiStatusCantSendData;
        [self configIsCameraConnecting:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraWIFIEnable object:nil userInfo:@{CameraWIFIEnable:@(wifiEnable)}];
    
}

-(void)removeCheckWifiConnectNoti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZYDeviceRDISReciveNoti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZYDC_CameraArgumentCallback object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"udpsocketClose" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWifiReciveHearBeat object:nil];
    
}

/**
 检查WIFI是否连接上的通知
 */
-(void)addCheckWifiConnectNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiCheckNoti:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiCheckNoti:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rdisChange:) name:ZYDeviceRDISReciveNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udpsocketClose:) name:@"udpsocketClose" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerVisitAlbumAction_Notifi:) name:ZYDC_CameraArgumentCallback object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiReciveHearBeat:) name:kWifiReciveHearBeat object:nil];
    
}

-(NSTimer *)heartCheckTimer{
    if (_heartCheckTimer == nil) {
        _heartCheckTimer = [NSTimer timerWithTimeInterval:kHeartCheckTimerDistance target:self selector:@selector(timerUp) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_heartCheckTimer forMode:NSDefaultRunLoopMode];
    }
    return _heartCheckTimer;
}

-(void)begainTime{
    if (![_heartCheckTimer isValid]) {
        [self.heartCheckTimer fire];
    }
    
}

-(void)endTime{
    [_heartCheckTimer invalidate];
    _heartCheckTimer = nil;
}

-(void)timerUp{
    if ([[NSDate date] timeIntervalSinceDate:self.wifiHeartBeatRecive] > 15 && self.wifiHeartBeatRecive) {
        NSLog(@"==========================-----wifi心跳丢失---------");
        if ([self isImageTransBox]) {
            [self p_doWifiCheck];
        }
    }
    else{
        
    }
}

-(void)wifiReciveHearBeat:(NSNotification *)noti{
    NSLog(@"==========================-----wifi心跳收到---------");
    self.wifiHeartBeatRecive = [NSDate date];
    if ([self isImageTransBox]) {
        [self begainTime];
    }
}

-(void)udpsocketClose:(NSNotification *)noti{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_doBaseQueryData:^{
            
        } changeToWifiConnection:^(BOOL wifiEnable) {
            
        }];
    });
}

-(void)setIsConnectWifiAndRDISRecive:(BOOL)isConnectWifiAndRDISRecive{
    _isConnectWifiAndRDISRecive = isConnectWifiAndRDISRecive;
    if (isConnectWifiAndRDISRecive) {
        //        NSLog(@"----------------获取RDIS之后再次获取-------------%@",self.modelNameString);
        if ([self p_is3LabAndWeebillLab]) {
            [self doBaseQueryData:^{
                
            } changeToWifiConnection:^(BOOL wifiEnable) {
                
            }];
        }
        
    }
}

-(BOOL)p_is3LabAndWeebillLab{
    if ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberCrane3Lab] || [[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberWeebillLab]) {
        return YES;
    }
    return NO;
    
}

-(void)rdisChange:(NSNotification *)noti{
    
    BOOL beforeValue = _isConnectWifiAndRDISRecive;
    if (beforeValue != self.wifiEnable) {
        self.isConnectWifiAndRDISRecive = self.wifiEnable;
    }
    
    if (self.cameraData.RDISVersion == NO || ([[ZYDeviceManager defaultManager].stablizerDevice.softwareVersion intValue] > 181 && ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberWeebillLab]))) {
        return;
    }
    
    if ([self p_is3LabAndWeebillLab]) {
        BOOL support = self.wifiEnable;
        if (support) {
            ZYBlRdisData* data = (ZYBlRdisData*)[noti object];
            
            self.cameraData.RDISRecording = data.rdisData.isRecording;
#pragma -mark 反正错误断开的问题
            if (self.connectCount >= kMinConnectCount) {
                self.connectCount = 0;
                [self configIsCameraConnecting:data.rdisData.isConnectiong];
            }
            else{
                if (self.cameraData.isCameraConnecting == data.rdisData.isConnectiong) {
                    self.connectCount = 0;
                }
                else{
                    self.connectCount ++;
                }
            }
        }
        else{
            self.connectCount = 0;
            [self configIsCameraConnecting:NO];
        }
    }
    
}

-(void)configIsCameraConnecting:(BOOL)isConnectiong{
    
    BOOL before = self.cameraData.isCameraConnecting;
    self.cameraData.isCameraConnecting = isConnectiong;
    if (before != isConnectiong) {
        if (isConnectiong) {
            if (_wifiEnable) {
                [self getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:1];
            }
        }
        else{
            [self.cameraData cleanData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_SupportArgumentCallback object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraArgumentCallback object:nil userInfo:@{@"type":@(ZYCameraWifiParaCodeCameraMode)}];
            });
        }
    }
    
}

-(void)p_doWifiCheck{
     if (self.wifiEnable) {
                    @weakify(self)
                    [self p_querySSIDWithCount:3 completionHandler:^(ZYBleDeviceRequestState state, id param) {
                        @strongify(self)
                        if (state == ZYBleDeviceRequestStateResponse) {
                            if ([param isKindOfClass:[ZYBlWiFiHotspotGetSSIDData class]]) {
                                ZYBlWiFiHotspotGetSSIDData* respond = (ZYBlWiFiHotspotGetSSIDData*)param;
    #ifdef DEBUG
                                //                NSLog(@"查询设备ssid =%@成功", respond.SSID);
    #endif
                                NSLog(@"查询设备ssid =%@成功", respond.SSID);
                                if ([self.cameraData.ssid isEqualToString:respond.SSID]) {
                                    [self p_doRetryData];
                                    return;
                                }
                                else{
                                    self.wifiEnable = NO;
                                    [self doBaseQueryData:^{
                                        
                                    } changeToWifiConnection:^(BOOL wifiEnable) {
                                        
                                    }];
                                }
                            }
                        }
                        else {
                            NSLog(@"查询设备ssid 失败");
                            self.wifiEnable = NO;
                            [self doBaseQueryData:^{
                                
                            } changeToWifiConnection:^(BOOL wifiEnable) {
                                
                            }];
                        }
                    }];
                    return;
                }
}

/**
 wifi检查是否连接的wifi稳定器
 
 @param noti 通知名
 */
-(void)wifiCheckNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        
        if ([self isImageTransBox]) {
            if (self.wifiEnable) {
                [self p_doWifiCheck];
                return;
            }
        }
        [self doBaseQueryData:^{
            
        } changeToWifiConnection:^(BOOL wifiEnable) {
            
        }];
        
    }
    
}

-(void)p_doRetryData{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeSystemStatus_R param:@(0)];
    [self configReq:request];
    [client sendBLERequest:request completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            [self sendMessage];
            [self.cameraData getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:1];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYCamera_DoRetryDataSuccess object:nil];
        }
    }];
   
                  
    
}

-(void)dealloc{
    [self endTime];
    [self removeCheckWifiConnectNoti];
    
    NSLog(@"%@",[self class]);
}

-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data withCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    __block int totalCount = count - 1;
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configReq:request];
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            handler(state,param);
        }
        else{
            if (totalCount <= 0) {
                handler(state,param);
            }
            else{
                [self sendRequest:code data:data withCount:totalCount completionHandler:handler];
            }
        }
    }];
}


-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    [self sendRequest:code data:data withCount:1 completionHandler:handler];
}

-(void)configReq:(ZYBleDeviceRequest *)request{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
}

-(void)autoConnectWifi{
    if (![ZYDeviceManager defaultManager].enableOnlyWifi) {
        return;
    }
    [self needShowAutoConnectWifi];
}

-(BOOL)needShowAutoConnectWifi{
    if (self.cameraData.ssid.length > 0 && self.cameraData.password.length > 0 && self.wifiEnable == NO ) {
        return [self autoNetworkConnectWith:self.cameraData.ssid pwd:self.cameraData.password];
    }
    else{
        return NO;
    }
}

-(BOOL)checkWifiSustain{
    
    BOOL isImageBox = [self isImageTransBox];
    
    NSString *strWifi = [UIDevice getWifiName];
    BOOL wifiConnect = NO;
    if (strWifi.length == 0) {
        return YES;
    }
    if ((isImageBox || ([strWifi isEqualToString:self.cameraData.ssid] && self.cameraData.ssid.length > 0) ) && self.wifiEnable) {
        wifiConnect = YES;
    }
    return wifiConnect;
}

-(BOOL)autoNetworkConnectWith:(NSString *)ssid pwd:(NSString *)pwd{
    if (@available(iOS 11.0, *)) {
        NEHotspotConfiguration *configuration=[[NEHotspotConfiguration alloc]initWithSSID:ssid passphrase:pwd isWEP:NO];
        NEHotspotConfigurationManager *manager=[NEHotspotConfigurationManager sharedManager];
        @weakify(self)
        [manager applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            @strongify(self)
            if (error) {
                
            }
            else{
                [self doBaseQuery];
            }
        }];
        return YES;
    } else {
        // Fallback on earlier versions
        return NO;
    }
}

-(void)doBaseQuery{
    [self p_doBaseQueryData:^{
        
    } changeToWifiConnection:^(BOOL wifiEnable) {
        
    }];
}

-(void)setIsWifiReady:(ZYWifiStatus)isWifiReady{
    _isWifiReady = isWifiReady;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYWifiStatusNoti object:nil];
    });
}

/**
 是否是图传盒子
 
 @return 是否是图传盒子
 */
-(BOOL)isImageTransBox{
    return [[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox];
}

/**
 尝试访问相册，可能失败
 
 @param actionType 事件类型
 */
- (void)tryToVisitAlbum:(ZYCameraAlbumActionType)actionType{
    if (actionType == ZYCameraAlbumActionType_None) {
        return;
    }
    
    self.albumActionActive = YES;
    self.albumActionType = actionType;
    self.albumActionState = ZYCameraAlbumActionState_Waiting;
    
    BOOL isEnter = NO;
    if ((actionType == ZYCameraAlbumActionType_PicVideo_Enter) ||
        (actionType == ZYCameraAlbumActionType_SDCardLut_Enter)) {
        isEnter = YES;
    }
    if (isEnter && [self.cameraData canEnterCameraSource]) {
        NSMutableDictionary *retUserInfo = @{}.mutableCopy;
        retUserInfo[@"state"] = @(ZYCameraAlbumActionState_Success);
        retUserInfo[@"actionType"] = @(actionType);
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYCamera_AlbumVisit_Notifi object:nil userInfo:retUserInfo];
        return;
    }
    if (!isEnter && ![self.cameraData canEnterCameraSource]) {
        NSMutableDictionary *retUserInfo = @{}.mutableCopy;
        retUserInfo[@"state"] = @(ZYCameraAlbumActionState_Success);
        retUserInfo[@"actionType"] = @(actionType);
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYCamera_AlbumVisit_Notifi object:nil userInfo:retUserInfo];
        return;
    }
    
    [self configVisitCameraSource:isEnter handler:^(BOOL success) {}];
    [self performSelector:@selector(dealWithTimeOut) withObject:nil afterDelay:8.0f];
}

- (void)dealWithTimeOut{
    if (self.albumActionActive) {
        self.albumActionActive = NO;
        NSMutableDictionary *retUserInfo = @{}.mutableCopy;
        retUserInfo[@"state"] = @(ZYCameraAlbumActionState_Timeout);
        retUserInfo[@"actionType"] = @(self.albumActionType);
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYCamera_AlbumVisit_Notifi object:nil userInfo:retUserInfo];
        self.albumActionState = ZYCameraAlbumActionState_Idle;
    }
}

- (void)handlerVisitAlbumAction_Notifi:(NSNotification *)notifi{
    NSDictionary *userInfo = notifi.userInfo;
    if (!userInfo || ![userInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (![userInfo.allKeys containsObject:@"type"] ||
        ![userInfo.allKeys containsObject:@"status"]) {
        return;
    }
    NSInteger actionType = [[userInfo objectForKey:@"type"] intValue];
    if (actionType != ZYCameraWifiParaCodeConfigVisitCamera) {
        return;
    }
    if (!self.albumActionActive) {
        return;
    }
    if (self.albumActionType == ZYCameraAlbumActionType_None) {
        return;
    }
    self.albumActionActive = NO;
    // 是否是进入操作（进入相册，或者）
    BOOL isEnterAction = ((self.albumActionType == ZYCameraAlbumActionType_PicVideo_Enter) ||
                          (self.albumActionType == ZYCameraAlbumActionType_SDCardLut_Enter));
    
    NSInteger enterStatus = [[userInfo objectForKey:@"status"] intValue];
    // 收到的是0
    BOOL albumStatusIsOut = (enterStatus == 0);
    // 操作是否成功
    BOOL isActionSuccess = isEnterAction;
    if (albumStatusIsOut) {
        isActionSuccess = !isEnterAction;
    }
    self.albumActionState = isActionSuccess?ZYCameraAlbumActionState_Success:ZYCameraAlbumActionState_Fail;
    NSMutableDictionary *retUserInfo = @{}.mutableCopy;
    retUserInfo[@"state"] = @(self.albumActionState);
    retUserInfo[@"actionType"] = @(self.albumActionType);
    [[NSNotificationCenter defaultCenter] postNotificationName:ZYCamera_AlbumVisit_Notifi object:nil userInfo:retUserInfo];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dealWithTimeOut) object:nil];
}


-(void)clearData{
    [self endTime];
}
@end
