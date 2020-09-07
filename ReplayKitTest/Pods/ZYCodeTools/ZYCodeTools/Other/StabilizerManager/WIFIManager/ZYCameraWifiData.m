//
//  ZYCameraWifiData.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import <Foundation/Foundation.h>

NSString * const CameraWIFISSIDChange = @"CameraWIFISSIDChange";
NSString * const ZYDC_SupportArgumentCallback=@"ZYDC_SupportArgumentCallback";//支持的所有模式
NSString * const ZYDC_CameraArgumentCallback=@"ZYDC_CameraArgumentCallback";//支持的模式对应的参数
NSString * const ZYDC_CameraControlRecordState=@"ZYDC_CameraControlRecordState";//拍摄和拍照状态
NSString * const ZYDC_CameraControlGetAllPara =@"ZYDC_CameraControlGetAllPara";//获取所有参数失败
NSString * const ZYDC_CameraLiveSteamEnable=@"ZYDC_CameraLiveSteamEnable";//开启图传的
NSString * const ZYDC_CameraModeChange = @"ZYDC_CameraModeChange"; //模式改变
NSString * const ZYDC_isCameraConnectingChange = @"ZYDC_isCameraConnectingChange"; //相机连接改变
NSString * const ZYDC_ReImageTransfer = @"ZYDC_ReImageTransfer"; //重新拉流
NSString * const ZYDC_ReImageTransferQualityControl = @"ZYDC_ReImageTransferQualityControl"; //图传质量的通知
NSString * const ZYDC_ImageTransferSupportWithLine = @"ZYDC_ImageTransferSupportWithLine"; //数据线是否支持图传
NSString * const ZYDC_CameraSupportFocus = @"ZYDC_CameraSupportFocus"; //是否支持对焦

#define kjsonUrl @"http://192.168.2.1/%@.json"

#import "ZYCameraWifiData.h"
#import "ZYBleMutableRequest.h"
#import "ZYBleDeviceClient.h"
//#import "OSSUtil.h"
//#import "NSString+Utils.h"
#include "blMsgdef.h"

@interface ZYCameraWifiData ()

/*!
 相机录像停留时间
 */
@property (nonatomic, strong) NSDate *timeData;

@property (nonatomic, strong) NSString *cameraControlTime;


/**
 收到了121的指令，用于兼容121没有添加的情况
 */
@property (nonatomic)         BOOL     isRecive121ImageTransfer;
@property (nonatomic)         BOOL     innerImageTransferEnable;//相机图传是否可以使用



@end

@implementation ZYCameraWifiData
- (instancetype)init
{
    self = [super init];
    if (self) {
        _RDISVersion = YES;
        _RDISRecording = NO;
        _isCameraConnecting = NO;
        _controlRecord = ZYCameraControlRecordDefault;
        _getAllParaState = ZYCameraWifiGetParaState_unknow;
        _isRecive121ImageTransfer = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraParaChange:) name:Device_State_Event_Notification_ResourceData object:nil];
        _videotapeEnable = YES;
        _photograpEnable = YES;
        _imageTransferSupportWithLine = YES;
        _cameraControlPower = @"1";
    }
    return self;
}

-(void)setCameraMode:(NSString *)cameraMode {
    _cameraMode = cameraMode;
    //    if (_cameraMode != cameraMode) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraModeChange object:nil];
    //
    //        });
    //    }
}

-(void)setSsid:(NSString *)ssid{
    _ssid = [ssid copy];
    //    NSLog(@"wifi ssid = %@",ssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CameraWIFISSIDChange object:ssid];
        
    });
}



-(void)setLineControlDic:(NSDictionary *)lineControlDic{
    _lineControlDic = lineControlDic;
    if (_lineControlDic.allKeys.count) {
        [self getImageTransferQualityControlWithLineDic:_lineControlDic handler:^(NSArray *arr) {
            if (arr.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_ReImageTransferQualityControl object:nil];
                });
                
            }
        }];
        @weakify(self)
        [self getLineControlImageTransferSupportWith:_lineControlDic Handler:^(BOOL transfer) {
            @strongify(self)
            self.imageTransferSupportWithLine = transfer;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_ImageTransferSupportWithLine object:nil];
            });
            
            
        }];
    }
}

-(void)setCameraDic:(NSDictionary *)cameraDic {
    _cameraDic = cameraDic;
    [self configTimeLapse];
    if (cameraDic.allKeys.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_SupportArgumentCallback object:nil];
        });
    }
}

-(void)configTimeLapse{
    if (_cameraDic.allKeys.count > 0) {
        NSDictionary *dic = [_cameraDic objectForKey:@"timelapse"];
        if (dic) {
            NSArray *array = [dic objectForKey:@"ALL"];
            if (array.count > 0) {
                _containTimelapse = YES;
                return;
            }
        }
    }
    _containTimelapse = NO;
    
}

-(BOOL)needGetJson:(CCSConfigItem *)data{
    switch ((ZYCameraWifiParaCode)data.idx) {
        case ZYCameraWifiParaCodeCameraName:
        case ZYCameraWifiParaCodeJsonUrl:
        {
            return YES;
        }
        default:{
            return NO;
        }
    }
}

-(BOOL)p_needGetLineJson:(CCSConfigItem *)data{
    switch ((ZYCameraWifiParaCode)data.idx) {
        case ZYCameraWifiParaCodeLineControlJsonURL:
        {
            return YES;
        }
        default:{
            return NO;
        }
    }
}

-(void)updateValueWith:(CCSConfigItem *)data{
    if (!data) {
        //        NSLog(@"no wifi data");
        return;
    }
    else{
        
        NSLog(@"wifi-------data = %@",data);
    }
    NSString* modleValue = data.itemLists[0];
    BOOL needNoti = NO;
    switch ((ZYCameraWifiParaCode)data.idx) {
        case ZYCameraWifiParaCodeF_Number:{
            if (![self.fNumber isEqualToString:modleValue]) {
                self.fNumber = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeShutterSpeed:{
            if (![self.shutterSpeed isEqualToString:modleValue]) {
                self.shutterSpeed = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeISO:{
            if (![self.iso isEqualToString:modleValue]) {
                self.iso = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeEV:{
            if (![self.ev isEqualToString:modleValue]) {
                self.ev = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeWB:{
            if (![self.wb isEqualToString:modleValue]) {
                self.wb = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeFocusmode:{
            if (![self.focusmode isEqualToString:modleValue]) {
                self.focusmode = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeManualfocus:{///暂时拿不到
            if (![self.manualfocus isEqualToString:modleValue]) {
                self.manualfocus = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeFlashmode:{
            if (![self.flashmode isEqualToString:modleValue]) {
                self.flashmode = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeImagequality:{
            if (![self.imagequality isEqualToString:modleValue]) {
                self.imagequality = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeCapturemode:{
            if (![self.capturemode isEqualToString:modleValue]) {
                self.capturemode = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeZoom:{///暂时拿不到
            if (![self.zoom isEqualToString:modleValue]) {
                self.zoom = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeBatterylevel:{
            if (![self.batterylevel isEqualToString:modleValue]) {
                self.batterylevel = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeAspectratio:{
            if (![self.aspectratio isEqualToString:modleValue]) {
                self.aspectratio = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeImagesize:{
            if (![self.imagesize isEqualToString:modleValue]) {
                self.imagesize = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeAfarea:{
            if (![self.afarea isEqualToString:modleValue]) {
                self.afarea = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeCameraName:{
            if (![self.cameraName isEqualToString:modleValue]) {
                if (![modleValue isEqualToString:@""]) {
                    self.cameraName = modleValue;
                    //                    NSLog(@"当前的相机名是%@", self.cameraName);
                    //                [self getAllCameraDic:nil];
                } else {
                    //                    NSLog(@"无效的相机名");
                }
                needNoti = YES;
            }
            
            break;
        }
        case ZYCameraWifiParaCodeCameraMode:{
            if (![self.cameraMode isEqualToString:modleValue]) {
                self.cameraMode = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeJsonUrl:{
            if (![self.jsonUrl isEqualToString:modleValue]) {
                self.cameraDic = nil;
                self.jsonUrl = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeRecordTime:{
            if (![self.recordTotalTime isEqualToString:modleValue]) {
                self.recordTotalTime = modleValue;
                [self judgeCameraControlRcorde:self.recordTotalTime];
                
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeCameraConnected:{
            self.RDISVersion = NO;
            [self configIsCameraConnecting:[modleValue boolValue]];
            break;
        }
            
        case ZYCameraWifiParaCodeUSB_VID:{
            break;
        }
        case ZYCameraWifiParaCodeImageTransferEnable:{
            needNoti = !self.isRecive121ImageTransfer;
            self.isRecive121ImageTransfer = YES;
            BOOL imageTransfer = [modleValue boolValue];
            if (imageTransfer != self.innerImageTransferEnable) {
                self.innerImageTransferEnable = imageTransfer;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeImageTransferQualityControl:{
            if (![self.imageTransferQualityControl isEqualToString:modleValue]) {
                self.imageTransferQualityControl = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodePhotograp:{
            BOOL photograp = [modleValue boolValue];
            if (photograp != self.photograpEnable) {
                self.photograpEnable = photograp;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeVideotape:{
            BOOL videotape = [modleValue boolValue];
            if (videotape != self.videotapeEnable) {
                self.videotapeEnable = videotape;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeLineControlType:{
            
            if (![self.lineControlType isEqualToString:modleValue]) {
                self.lineControlType = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeLineControlJsonURL:{
            if (![self.lineControlJsonURL isEqualToString:modleValue]) {
                self.lineControlDic = nil;
                self.lineControlJsonURL = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeImageTransferAddressAndPara:{
            if (![self.imageTransferAddressAndPara isEqualToString:modleValue]) {
                self.imageTransferAddressAndPara = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeCameraControlPower:{
            if (![self.cameraControlPower isEqualToString:modleValue]) {
                if (self.cameraControlPower.length > 0) {
                    [self getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:3];
                }
               
                self.cameraControlPower = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeSupplyControlPower:{
//            if (![self.suppplyControlPower isEqualToString:modleValue]) {
                self.suppplyControlPower = modleValue;
                NSLog(@"收到----%@",self.suppplyControlPower);
                needNoti = YES;
//            }
            break;
        }
        case ZYCameraWifiParaCodeSupportVisitCameraSource:{
            if (![self.supportVisitCameraSource isEqualToString:modleValue]) {
                self.supportVisitCameraSource = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYCameraWifiParaCodeConfigVisitCamera:{
            if (![self.configVisitCameraSource isEqualToString:modleValue] ||
                self.needNotifiVisitCameraSource) {
                self.configVisitCameraSource = modleValue;
                needNoti = YES;
                self.needNotifiVisitCameraSource = NO;
            }
            break;
        }
        case ZYCameraWifiParaCodeAll:{
            //            if ([modleValue isEqualToString:@"1"]
            //                ) {
            //                [self cleanData];
            //            }
            //            NSLog(@"ZYCameraWifiParaCodeAll = %@",modleValue);
            break;
        }
        default:{
#ifdef DEBUG
            NSLog(@"%lu不支持的idx",(unsigned long)data.idx);
#endif
            break;
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //参数改变
        if (needNoti) {
            NSMutableDictionary *infoDict = @{@"type":@(data.idx)}.mutableCopy;
            if ((data.idx == 129) && modleValue && [modleValue isKindOfClass:[NSString class]]) {
                infoDict[@"status"] = modleValue;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraArgumentCallback object:nil userInfo:infoDict];
        }
        
    });
    
    
}

-(NSString *)suppplyControlPowerName{
    NSArray *array = [self.suppplyControlPower componentsSeparatedByString:@","];
    if (array.count > 0) {
        return [array lastObject];
    }
    else{
        return [self.suppplyControlPower copy];
    }
}

-(NSString *)imageTransferAddress{
     return [self p_imageTransferAddressAndParaSubStringWithIndex:0];
}

-(NSString *)decodeType{
    return [self p_imageTransferAddressAndParaSubStringWithIndex:1];
}

-(BOOL)isPrivateTranProtocol{
    NSString *str = [self decodeType];
    return [[str lowercaseString] containsString:@"pri"];
}

-(NSString *)ThrowPacket{
    return [self p_imageTransferAddressAndParaSubStringWithIndex:2];
}
-(NSString *)p_imageTransferAddressAndParaSubStringWithIndex:(NSUInteger)index{
    if (self.imageTransferAddressAndPara.length > 0) {
        NSArray *arrTemp = [self.imageTransferAddressAndPara componentsSeparatedByString:@","];
        if (arrTemp.count > index) {
            return arrTemp[index];
        }
    }
    return nil;
}
/**
 用于兼容121没加入之前
 
 @return 121的兼容问题
 */
-(BOOL)imageTransferEnable{
    if (_isRecive121ImageTransfer) {
        return (_innerImageTransferEnable&&_imageTransferSupportWithLine);
    }
    else{
        return (_isCameraConnecting&&_imageTransferSupportWithLine);
    }
}

-(void)configIsCameraConnecting:(BOOL)isConnectiong{
    
    BOOL before = self.isCameraConnecting;
    self.isCameraConnecting = isConnectiong;
   
   
    if (before != isConnectiong) {
        if (isConnectiong) {
            [self getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:1];
        }
        else{
            [self cleanDataWith121:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_SupportArgumentCallback object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraArgumentCallback object:nil userInfo:@{@"type":@(ZYCameraWifiParaCodeCameraMode)}];
                self.getAllParaState = ZYCameraWifiGetParaState_error;
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"error"}];

            });
        }
    }
    else{
//#pragma -mark 怕影响之前的逻辑
//        if (isConnectiong == YES && ![_cameraControlPower isEqualToString:@"1"]) {
//            //设备是连接上的，但是没有控制权，清理所有的数据
//            _cameraMode = nil;
//            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_SupportArgumentCallback object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraArgumentCallback object:nil userInfo:@{@"type":@(ZYCameraWifiParaCodeCameraMode)}];
//        }
        if (isConnectiong == NO) {
            self.getAllParaState = ZYCameraWifiGetParaState_error;
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"error"}];
        }
    }
  
    
}

-(void)postNotiWithState:(ZYCameraControlRecord)state{
    self.controlRecord = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlRecordState object:nil userInfo:@{@"state":@(state)}];
}

- (void)judgeCameraControlRcorde:(NSString *)str {
    NSString *timeStr;
    if ([self.recordTotalTime containsString:@"RPN"] ) {
        [self postNotiWithState:ZYCameraControlTakePhotoStop];
        
    }
    else if ([self.recordTotalTime containsString:@"RY"]) {
        timeStr = [str stringByReplacingOccurrencesOfString:@"RY" withString:@""];
        self.cameraControlTime = timeStr;
        self.timeData = [NSDate date];
        [self postNotiWithState:ZYCameraControlRecordVideoStart];
        
    } else if ([self.recordTotalTime containsString:@"RN"] ) {
        [self postNotiWithState:ZYCameraControlRecordVideoStop];
        
    } else if ([self.recordTotalTime containsString:@"PY"] ) {
        [self postNotiWithState:ZYCameraControlTakePhotoStart];
        
    } else if ([self.recordTotalTime containsString:@"PN"] ) {
        [self postNotiWithState:ZYCameraControlTakePhotoStop];
    }
    else{
#pragma mark RDIS版本
        self.timeData = [NSDate date];
        self.cameraControlTime = str;
        
    }
}

- (void)setIsCameraConnecting:(BOOL)isCameraConnecting {
    if (_isCameraConnecting !=isCameraConnecting) {
        _isCameraConnecting = isCameraConnecting;
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_isCameraConnectingChange object:nil];
    }
}

-(void)setRDISRecording:(BOOL)RDISRecording{
    if (_RDISRecording != RDISRecording && _RDISVersion) {
        if (RDISRecording) {
            //发送开始录像
            [self postNotiWithState:ZYCameraControlRecordVideoStart];
        }
        else{
            [self postNotiWithState:ZYCameraControlRecordVideoStop];
        }
    }
    _RDISRecording = RDISRecording;
    
}

- (NSTimeInterval)getcurrentCameraTime {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.timeData];
    return [self.cameraControlTime floatValue] + interval;
}

-(void)cleanDataWith121:(BOOL)recive121 {
    if (recive121) {
        self.isRecive121ImageTransfer = NO;
    }
    self.cameraDic = nil;
    self.cameraMode = nil;
    self.jsonUrl = nil;
    self.cameraName = nil;
    _controlRecord = ZYCameraControlRecordDefault;
    self.cameraControlTime = nil;
    self.timeData = nil;
    self.isCameraConnecting = NO;
    _containTimelapse = NO;
    _videotapeEnable = YES;
    _photograpEnable = YES;
    _imageTransferSupportWithLine = YES;
//    _cameraControlPower = @"1";//清除控制器不需要清除
    self.lineControlDic = nil;
}

-(void)cleanData{
    [self cleanDataWith121:YES];
}

-(void)cameraParaChange:(NSNotification *)noti{
    NSDictionary* userInfo = [noti userInfo];
    if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlCCSGetConfigData class]) ]) {
        ZYBlCCSGetConfigData* data = (ZYBlCCSGetConfigData*)[noti object];
//                        NSLog(@"查询设备通知%lu:%@%@ %d", data.idx, data.configs, data.value,data.cmdStatus);
        if (data.cmdStatus == ZYBICCSCmdStatusNoErr) {
            BOOL needGetJson = NO;
            BOOL needGetLineJson = NO;
            for (CCSConfigItem* item in data.configs) {
                [self updateValueWith:item];
                needGetJson = needGetJson | [self needGetJson:item];
                needGetLineJson = needGetLineJson | [self p_needGetLineJson:item];
                
            }
            if (needGetJson) {
                [self getAllCameraDic:nil];
            }
            if (needGetLineJson) {
                @weakify(self)
                [self getLineControlDic:^(NSDictionary *dicT) {
                    @strongify(self)
                    if (needGetJson == NO) {
                        self.getAllParaState = ZYCameraWifiGetParaState_finish;
                        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"finished"}];
                    }
                }];
            }
        }
        else if (data.cmdStatus == ZYBICCSCmdStatusGenErr){
            for (CCSConfigItem* item in data.configs) {
                NSInteger index = (ZYCameraWifiParaCode)item.idx;
                if (index == ZYCameraWifiParaCodeAll) {
                    //                    NSLog(@"相机接触有问题，获取不到数据");
                    self.getAllParaState = ZYCameraWifiGetParaState_error;
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"error"}];
                    
                }
            }
        }
        else if (data.cmdStatus == ZYBICCSCmdStatusWait){
                        NSLog(@"正在等待通知");
        }
        
    } else if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlCCSSetConfigData class]) ]) {
        //        ZYBlCCSSetConfigData* data = (ZYBlCCSSetConfigData*)[noti object];
        //        NSLog(@"设置设备通知%lu:%@", data.idx, data.value);
    }else if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYUsbInstructionMediaStreamData class]) ]) {
#pragma -mark 通知重新拉流下一个版本使用
        //        return;
        ZYUsbInstructionMediaStreamData* data = (ZYUsbInstructionMediaStreamData*)[noti object];
        
        if (data.flag == 4) {
#ifdef DEBUG
            
            //            NSLog(@"通知重新拉流");
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_ReImageTransfer object:nil];
        }
    }
}

-(void)setCameraWithCode:(ZYCameraWifiParaCode)code value:(NSString *)value handler:(void (^)(BOOL success))handler{
    // 如果是129的状态设置为YES
    if (code == ZYCameraWifiParaCodeConfigVisitCamera) {
        self.needNotifiVisitCameraSource = YES;
    }
    //    NSLog(@"------%d-%@",code,value);
    ZYBlCCSSetConfigData* blCCSSetConfigData = [[ZYBlCCSSetConfigData alloc] init];
    blCCSSetConfigData.idx = code;
    blCCSSetConfigData.value = value;
    [blCCSSetConfigData createRawData];
    ZYBleMutableRequest* blCCSSetConfigRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blCCSSetConfigData];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:blCCSSetConfigRequest];
    }
    //    NSLog(@"---------------%@",blCCSSetConfigRequest);
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:blCCSSetConfigRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            handler(YES);
            ZYBlCCSSetConfigData* blCCSSetConfigDataRespond = (ZYBlCCSSetConfigData*)param;
            //            NSLog(@"设置设备状态%lu成功", blCCSSetConfigDataRespond.idx);
        } else {
            handler(NO);
            //            NSLog(@"设置设备状态失败");
        }
    }];
    
}

-(void)p_urlRequest:(NSString *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

-(void)getLineControlDic:(void (^)(NSDictionary *))handler{
    if (self.lineControlDic) {
        if (handler) {
            handler(self.lineControlDic);
        }
    }
    else{
        if (self.lineControlJsonURL.length > 0) {
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @strongify(self);
                NSString *url = [self urlStringWithString:self.lineControlJsonURL];
                
                [self p_urlRequest:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    @strongify(self);
                    if (data && !error) {
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        self.lineControlDic = jsonDic;
                                                NSLog(@"%@",jsonDic);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @strongify(self);
                            if (handler) {
                                handler(self.lineControlDic);
                            }
                        });
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (handler) {
                                handler(nil);
                            }
                        });
                        
                    }
                }];
            });
        }
        else{
            if (handler) {
                handler(nil);
            }
        }
    }
}

-(NSString *)urlStringWithString:(NSString *)urlString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)urlString,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
    return encodedString;
}

-(void)getLineControlImageTransferSupportWith:(NSDictionary *)lineDic Handler:(void (^)(BOOL transfer))handler{
    if (self.lineControlType.length > 0) {
        NSArray *arrTem = lineDic.allKeys;
        NSString *keyValue = nil;
        for (int i = 0; i < arrTem.count; i ++) {
            NSRange range= [arrTem[i] rangeOfString:[self.lineControlType lowercaseString] options:NSCaseInsensitiveSearch];
            if (range.length) {
                keyValue = arrTem[i];
                break;
            }
        }
        if (keyValue) {
            NSArray *array = [lineDic objectForKey:keyValue];
            if (array.count > 0) {
                BOOL transferAvaliable = YES;
                for (NSString *str in array) {
                    NSRange range=[str rangeOfString:@"picturetrans," options:NSCaseInsensitiveSearch];
                    if (range.length) {
                        NSArray *innArr = [str componentsSeparatedByString:@","];
                        if ([[innArr.lastObject lowercaseString] isEqualToString:@"no"]) {
                            transferAvaliable = NO;
                        }
                        else{
                            transferAvaliable = YES;
                        }
                        break;
                    }
                }
                if (handler) {
                    handler(transferAvaliable);
                }
                
            }
            else{
                if (handler) {
                    handler(YES);
                }
            }
        }
        else{
            if (handler) {
                handler(YES);
            }
        }
    }
    else{
        if (handler) {
            handler(YES);
        }
    }
}
-(void)getLineControlImageTransferSupportHandler:(void (^)(BOOL transfer))handler{
    if (self.lineControlType.length > 0) {
        [self getLineControlDic:^(NSDictionary *lineDic) {
            NSArray *arrTem = lineDic.allKeys;
            NSString *keyValue = nil;
            for (int i = 0; i < arrTem.count; i ++) {
                NSRange range= [arrTem[i] rangeOfString:[self.lineControlType lowercaseString] options:NSCaseInsensitiveSearch];
                if (range.length) {
                    keyValue = arrTem[i];
                    break;
                }
            }
            if (keyValue) {
                NSArray *array = [lineDic objectForKey:keyValue];
                if (array.count > 0) {
                    BOOL transferAvaliable = YES;
                    for (NSString *str in array) {
                        NSRange range=[str rangeOfString:@"picturetrans," options:NSCaseInsensitiveSearch];
                        if (range.length) {
                            NSArray *innArr = [str componentsSeparatedByString:@","];
                            if ([[innArr.lastObject lowercaseString] isEqualToString:@"no"]) {
                                transferAvaliable = NO;
                            }
                            else{
                                transferAvaliable = YES;
                            }
                            break;
                        }
                    }
                    if (handler) {
                        handler(transferAvaliable);
                    }
                    
                }
                else{
                    if (handler) {
                        handler(YES);
                    }
                }
            }
            else{
                if (handler) {
                    handler(YES);
                }
            }
            
        }];
    }
    else{
        if (handler) {
            handler(YES);
        }
    }
}
-(void)getImageTransferQualityControlWithLineDic:(NSDictionary *)lineDic handler:(void (^)(NSArray *))handler{
    if (self.imageTransferQualityControl.length > 0) {
        NSArray *arrTem = lineDic.allKeys;
        NSString *keyValue = nil;
        for (int i = 0; i < arrTem.count; i ++) {
            NSRange range= [arrTem[i] rangeOfString:@"PictureTrsCtrlQual" options:NSCaseInsensitiveSearch];
            if (range.length) {
                keyValue = arrTem[i];
                break;
            }
        }
        
        if (keyValue) {
            NSArray *array = [lineDic objectForKey:keyValue];
            if (array.count > 0) {
                if (handler) {
                    handler(array);
                }
            }
            else{
                if (handler) {
                    handler(@[]);
                }
            }
        }
        else{
            if (handler) {
                handler(@[]);
            }
        }
    }
    else{
        if (handler) {
            handler(@[]);
        }
    }
}

-(void)getImageTransferQualityControlhandler:(void (^)(NSArray *))handler{
    if (self.imageTransferQualityControl.length > 0) {
        [self getLineControlDic:^(NSDictionary *lineDic) {
            NSArray *arrTem = lineDic.allKeys;
            NSString *keyValue = nil;
            for (int i = 0; i < arrTem.count; i ++) {
                NSRange range= [arrTem[i] rangeOfString:@"PictureTrsCtrlQual" options:NSCaseInsensitiveSearch];
                if (range.length) {
                    keyValue = arrTem[i];
                    break;
                }
            }
            
            if (keyValue) {
                NSArray *array = [lineDic objectForKey:keyValue];
                if (array.count > 0) {
                    if (handler) {
                        handler(array);
                    }
                }
                else{
                    if (handler) {
                        handler(@[]);
                    }
                }
            }
            else{
                if (handler) {
                    handler(@[]);
                }
            }
        }];
    }
    else{
        if (handler) {
            handler(@[]);
        }
    }
}


-(void)getAllCameraDic:(void (^)(NSDictionary *))handler{
    
    if (self.cameraDic) {
        if (handler) {
            handler(self.cameraDic);
        }
    }else{
        if (self.cameraName.length > 0 || self.jsonUrl.length > 0) {
            
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @strongify(self);
                NSString *url = [NSString stringWithFormat:kjsonUrl, self.cameraName];
                url = [self urlStringWithString:url];
                //                NSLog(@"相机配置文件目录%@", url);
                if (self.jsonUrl.length > 0) {
                    url = [self urlStringWithString:self.jsonUrl];
                }
                [self p_urlRequest:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    @strongify(self);
                    self.getAllParaState = ZYCameraWifiGetParaState_finish;

                    [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"finished"}];
                    if (data && !error) {
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        self.cameraDic = jsonDic;
#ifdef DEBUG
                        NSLog(@"json=============%@",jsonDic);
                        NSLog(@"allkeys =============%@",self.cameraDic.allKeys);
#endif
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @strongify(self);
                            if (handler) {
                                handler(self.cameraDic);
                            }
                        });
                    }
                    else{
                        //                        NSLog(@"不支持的相机名%@", self.cameraName);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (handler) {
                                handler(nil);
                            }
                        });
                        
                    }
                }];
            });
        }
        else{
            //            NSLog(@"不支持的空相机名%@", self.cameraName);
            
            if (handler) {
                handler(nil);
            }
        }
    }
}
#pragma -mark getValue
-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    if (num == ZYCameraWifiParaCodeAll) {
        self.getAllParaState = ZYCameraWifiGetParaState_begain;

        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDC_CameraControlGetAllPara object:nil userInfo:@{@"getPara":@"begain"}];
        
    }
    __block int totalCount = count - 1;
    __block NSUInteger blockNum = num;
    ZYBlCCSGetConfigData* blCCSGetConfigData = [[ZYBlCCSGetConfigData alloc] init];
    blCCSGetConfigData.idx = num;
//    NSLog(@"------begin查询设备状态%lu", num );
    @weakify(self);
    [self sendRequest:blCCSGetConfigData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
//            NSLog(@"------查询设备状态%lu成功%@", blCCSGetConfigDataRespond.idx ,blCCSGetConfigDataRespond.value);
            if (handler) {
                handler(state,param);
            }
        } else {
            if (totalCount <= 0 ) {
                if (blockNum == ZYCameraWifiParaCodeAll) {
                    [self performSelector:@selector(do255Again) withObject:nil afterDelay:2];
                }
                else{
                    if (handler) {
                        handler(state,param);
                    }
                }
                
            }
            else{
                [self getCameraDataWithNum:blockNum withCount:totalCount];
            }
            //            NSLog(@"第%d次 ZYBlCCSGetConfigDatas查询设备状态失败",totalCount);
        }
    }];
}
#pragma -mark getValue
-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count{
    [self getCameraDataWithNum:num withCount:count completionHandler:nil];
   
}

-(void)do255Again{
    if (self.cameraMode == nil) {
        [self getCameraDataWithNum:ZYCameraWifiParaCodeAll withCount:1];
    }
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

-(void)configReq:(ZYBleDeviceRequest *)request{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
}

/**
 能够进入到相机资源界面
 
 @return 能够进入
 */
-(BOOL)canEnterCameraSource{
    if ([self.supportVisitCameraSource isEqualToString:@"1"] && [self.configVisitCameraSource isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

-(void)dealloc{
#ifdef DEBUG
    
    NSLog(@"%@",[self class]);
#endif
    
}
@end
