
//
//  ZYDeviceStabilizer.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//


#define kMaxBatteryVoltage 4.0
#define kMinBatteryVoltage 3.25
#define kRisingProportion  (100.0 * 1 / (kMaxBatteryVoltage - kMinBatteryVoltage))

#define kMinMiddleAndBackInterval 1

#import "ZYBleDeviceClient.h"
#import "ZYDeviceStabilizer.h"
#import "ZYBleDeviceDataModel.h"
#import "ZYBleProtocol.h"
#import "ZYDeviceManager.h"
#import "ZYBleMutableRequest.h"

#import "ZYDeviceStablizerTestTool.h"
#import "ZYProductConfigTools.h"

#import "ZYDeviceManager.h"
#import "ZYBlOtherDeviceTypeData.h"
#import "ZYBlOtherSyncData.h"
#import "ZYBlOtherHeart.h"
#import "ZYStabilizerTools.h"
#import "UIDevice+WifiOpened.h"
#import "ZYUpgradeServerTool.h"
#import "SpaceBlocksHandle.h"
#import "ZYAES128.h"
#import "NSData+AES256.h"
#include "active.h"
@interface ZYDeviceStabilizer ()

@property (nonatomic, copy) SpaceDelayedBlockHandle delayedBlockHandle;
@property (nonatomic, copy) SpaceDelayedBlockHandle batteryDelayedBlockHandle;

@property(nonatomic, strong)NSDate* lastMiddleAndBack;

@property(atomic) NSInteger powerOnTestMissCount;
@property(nonatomic, strong)NSDate* powerOnTestTimeStamp;
@property(nonatomic)BOOL powerOnFirstTest;


@property (nonatomic, readwrite) ZYBleInteractMotorPower motorState;

@property (nonatomic, readwrite) ZYBleInteractDeviceDebugMode deviceDebugOriginalMode;

@property (nonatomic, strong)   ZYProductKeyNoti   *keyNoti;//按钮的处理类

@end


@implementation ZYDeviceStabilizer

-(void)connectSetup{
#ifdef DEBUG
    
    NSLog(@"%@ connectSetup SSSSSSSSSSS!",[self deviceName]);
#endif
    _supportOffLineMoveDelay = NO;
    _dataCache = [[ZYBleDeviceDataModel alloc] init];
    _otherSynData = [[ZYOtheSynData alloc] init];
    _offLineMoveDelay = [[ZYOffLineMoveDelay alloc] initWith:self];
    [[ZYBleDeviceClient defaultClient] setDataCache:_dataCache];
    _wifiManager = [[ZYBleWiFiManager alloc] init];//Wi-Fi初始化
    [_wifiManager setSendDelegate:self];
    _hardwareUpgradeManager = [[ZYHardwareUpgradeManager alloc] init];//初始化下载管理.
    [_hardwareUpgradeManager setSendDelegate:self];
    _calibrationManager = [[ZYStabilizerCalibrationManager alloc] init];
    [_calibrationManager setSendDelegate:self];//一定要记得设置代理
    _upgradeCheckType = DeviceUpgradeCheckTypeNoCheck;//是否检查过升级
    _motionManager = [[ZYStabilizerMotionManager alloc] init];
    [_motionManager setSendDelegate:self];//一定要记得设置代理
    
    _keyNoti = [[ZYProductKeyNoti alloc] init];
    _batteryValue = -1;
    
    self.workingState = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceBLEReadyToUse:) name:Device_BLEReadyToUse object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RDISRecive:) name:ZYDeviceRDISReciveNoti object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceBLEOffLine:) name:Device_BLEOffLine object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synData:) name:ZYOtherSynDataRecived object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blOtherHeartRecive:) name:ZYBlOtherHeartReciveNoti object:nil];
    
    _rollSharpTurning = 0.0;
    _pitchSharpTurning = 0.0;
    _lastMiddleAndBack = [NSDate date];
    
    self.handlerFocusMode = ZYBleInteractHDLFocusModeUnknown;
    
    self.moduleUpgradeInfos = nil;
    
#pragma -mark wifiNoti
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiTransConnect:) name:ZYWifiStatusNoti object:nil];
    
    if ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox]) {
        
        self.modelNumberString = modelNumberImageTransBox;
        [self checkSeriesByDeviceName:modelNumberImageTransBox];
        [self queryOtherBaseDataFinishChangeToWifiConnection:^(BOOL wifiEnable) {
            if (wifiEnable) {
                [ZYDeviceManager defaultManager].connectType = ZYConnectTypeOnlyWifi;
                
            }
            
        }];
    }
}

-(void)synData:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYOtherSynDataRecived]) {
        id type = noti.userInfo[ZYOtherSynDataRecivedTpyeKey];
        if ([type isKindOfClass:[NSNumber class]]) {
            if ([type integerValue] == ZYOtherSynDataCodeImageBoxWorkMode) {
                [self p_doSubaccessoriesQuery];
            }
        }
    }
}

-(void)blOtherHeartRecive:(NSNotification *)noti{
    if ([noti.object isKindOfClass:[ZYBlOtherHeart class]]) {
        if ([self supportBle_Hid] >= Ble_hidTypeNoSupport) {
            ZYBlOtherHeart *heart = (ZYBlOtherHeart *)noti.object;
            if (heart.battery > 0) {
                [self endBatteryLoopQuery];
                
                int batteryHeart = heart.battery;
                if (batteryHeart == 0xff) {
                    self.valueType = BatteryValueTypeUnsupport;
                    return;
                }
                
                if ((batteryHeart&0x80) == 0x80) {
                    self.valueType = BatteryValueTypeCharging;
                    batteryHeart = batteryHeart & 0x7f;
                }
                else{
                    self.valueType = BatteryValueTypeAvailable;
                }
                
                if (heart.battery != fabs(self.batteryValue)) {
                    self.batteryValue = heart.battery;
                }
                
            }
            self.errorType = heart.errorType;
        }
    }
}

-(void)setErrorType:(int)errorType{
    if (_errorType == errorType) {
        return;
    }
    _errorType = errorType;
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Device_ErrorTypeDidChange_Notification object:nil userInfo:@{@"errorType":@(errorType)}];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_ErrorTypeDidChange_Notification object:nil userInfo:@{@"errorType":@(errorType)}];
            
        });
    }
}


-(void)RDISRecive:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYDeviceRDISReciveNoti]) {
        
        if ([noti.object isKindOfClass:[ZYBlRdisData class]]) {
            ZYBlRdisData *rdis = noti.object;
            if (rdis) {
                BOOL connectingStatue = rdis.rdisData.imageBoxConnecting;
                if (self.RDISImageBoxConnecting != connectingStatue) {
                    self.RDISImageBoxConnecting = connectingStatue;
                    [[NSNotificationCenter defaultCenter] postNotificationName:RDISImageBoxConnectingNoti object:nil];
                }
            }
        }
        
    }
}

-(void)wifiTransConnect:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYWifiStatusNoti]) {
        
        if (self.cameraWifiManager.isWifiReady == ZYWifiStatusCantSendData) {
            if ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox] ) {
                self.workingState = 0;
            };
        }
        
        if (self.cameraWifiManager.isWifiReady != ZYWifiStatusIsReady) {
            return;
        }
        
        if ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox] ) {
            [self.deviceInfo configName:self.cameraWifiManager.cameraData.ssid];
#pragma -mark 图传盒子需要设置连接
            [ZYDeviceManager defaultManager].connectType = ZYConnectTypeOnlyWifi;
            [self onDeviceBLEReadyToUse:nil];
        }
        
        if ([self p_needQuerySubMessageWithString:[ZYDeviceManager defaultManager].modelNumberString]) {
            //请求是否是子设备
            @weakify(self);
            [self querySubTypeConnectionComplete:^(BOOL success, ZYBlOtherSyncData *info) {
                @strongify(self);
                
            }];
            //请求moveline
            [self querySupportFile];
            //发送本设备的信息和支持h264还是h265的解码给稳定器
            [self.cameraWifiManager sendMessage];
        }
    }
}

-(BOOL)p_needQuerySubMessageWithString:(NSString *)modelString{
    if ([ZYBleDeviceDataModel likeWeebillsWithString:[ZYDeviceManager defaultManager].modelNumberString] || [[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox]) {
        return YES;
    }
    else{
        return NO;
    }
}

-(void)querySupportFile{
    if ([self p_needQuerySubMessageWithString:[ZYDeviceManager defaultManager].modelNumberString]) {
        [self querySupportWithCount:3];
    }
}

-(void)querySupportWithCount:(int)count{
    
    MovelineType moveLineType = self.functionModel.moveline;
    if ([self.accessory.modelNumberString isEqualToString:modelNumberImageTransBox]) {
        moveLineType = self.accessory.functionModel.moveline;
    }
    
    if (moveLineType != MovelineTypeNoSupport) {
        self.supportOffLineMoveDelay = YES;
        return;
    }
    if (!self.functionModel.jsonData){
        return ;
    }
    __block int innerCount = count - 1;
    @weakify(self)
    [self queryJsonFileIfFormatAvalueble:ZYBlOtherCustomFileDataFormatSupport complete:^(BOOL success, id info) {
        @strongify(self)
        if (!success) {
            if (innerCount > 0) {
                [self querySupportWithCount:innerCount];
            }
            return ;
        }
        NSString *str = [info objectForKey:@"moveline"];
        NSInteger support = [str integerValue];
        [self p_supportOffLineMoveDelayWithValue:support];
    }];
}

-(void)p_supportOffLineMoveDelayWithValue:(NSInteger)support{
    if (support & 0x01) {
        NSLog(@"支持离线");
        if (support & 0x0100) {
            NSLog(@"支持Wi-Fi");
            self.supportOffLineMoveDelay = YES;
        }
        if (support & 0x10) {
            NSLog(@"支持蓝牙");
        }
    }
}

-(void)queryModulesWithCount:(int)count handler:(void(^)(BOOL success,ZYModuleUpgrade_New_Model *result))handler{
    
    __block int innerCount = count - 1;
    @weakify(self);
    [self queryJsonFileIfFormatAvalueble:ZYBlOtherCustomFileDataFormatModules complete:^(BOOL success, NSDictionary * info) {
        @strongify(self);
        NSLog(@"infosuccess:%d -----:%@",success,info);
        if (!success) {
            if (innerCount > 0) {
                [self queryModulesWithCount:innerCount handler:handler];
                return ;
                
            }else{
                BLOCK_EXEC(handler,NO,nil);
                return ;
            }
        }
        if ( [info isKindOfClass:[NSDictionary class]] ) {
            if (![info objectForKey:@"version"]) {
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ZYModuleUpgrade_New_Model *mod = [ZYModuleUpgrade_New_Model initWithDic:info andCurrentModelNumber:self.modelNumber];
                if (mod) {
                    BLOCK_EXEC(handler,(mod != nil),mod);
                }
            });
            
        }
    }];
}

-(void)clearDataSource{
#ifdef DEBUG
    
    NSLog(@"%@=%@ clearDataSource CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC!",self,[self deviceName]);
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)queryBaseDataCompleted:(void(^)(void))completed{
    
    [self queryBaseDataCompleted:completed showNoti:NO];
}

-(void)p_begainQueryMustData{
    [self queryBaseDataCompleted:nil showNoti:YES];
}

#pragma mark - queryBaseData
-(void)queryBaseDataCompleted:(void(^)(void))completed showNoti:(BOOL)noti{
    [self closeAllLoop];
    
    @weakify(self)
    [self p_queryDeviceCategoryCompleted:^(NSString *value, BOOL success) {
        @strongify(self)
        self.modelNumberString = value;
        self.keyNoti.modelNumberString = value;
        [self checkSeriesByDeviceName:value];
        if (self.functionModel.needAppForceUpgrade) {
            [self p_queryValueWithCodeVersionWithCount:3 Completed:^(NSString *invalue, BOOL success) {
                @strongify(self)
                if (invalue == nil) {
                    invalue = @"";
                }
                self.softwareVersion = invalue;
                self.needAppForceUpgrade = [self.functionModel forceUpgradeWith:invalue];
                if (self.needAppForceUpgrade) {
                    [self doUpgradeCheckForceUpgradeHandler:^(BOOL isNeedUpdate) {
                        @strongify(self)
                        [self p_doCheckActivateShowNoti:noti];
                    }];
                }
                else{
                    [self p_doCheckActivateShowNoti:noti];
                }

            }];
        }
        else{
            [self p_doCheckActivateShowNoti:noti];
        }
                
    }];
}

-(void)doUpgradeCheckForceUpgradeHandler:(void (^)(BOOL isNeedUpdate))handler{
    @weakify(self);
    [self queryUpgradableInfos:^(NSArray<ZYUpgradableInfoModel *> *infos) {
                   @strongify(self)
       if (infos.count > 0) {
           self.moduleUpgradeInfos = infos;
           self.hardwareUpgradeManager.moduleUpgradeInfos = infos;
           [self addConnectedDataWithrefID:self.modelNumber softVersion:self.softwareVersion deviceName:[self deviceName]   moduleMessage:nil];
           if ([self checkIsNeedToUpgradByModelNumberStr:self.modelNumberString]) {
               [self serverCheckNeedUpgradeWithrefID:self.modelNumber softVersion:self.softwareVersion moduleMessage:nil handler:handler];
           } else {
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


-(void)p_queryValueWithCodeVersionWithCount:(int)count Completed:(void(^)(NSString*value ,BOOL success))completed{
    __block int innerCount = count;
    @weakify(self);
    [self p_queryValueWithCodeVersion_RCompleted:^(NSString *value, BOOL success) {
        @strongify(self);
       if (success) {
           completed(value,success);
       }
       else{
           if (innerCount > 0) {
               [self p_queryValueWithCodeVersionWithCount:(innerCount - 1) Completed:completed];
           }
           else{
               completed(@"",NO);
           }
       }
   }];
}

-(void)p_doCheckActivateShowNoti:(BOOL)noti{
    //通知设备已经可以使用了
    @weakify(self)
    [self checkActivateCompletionHandler:^(BOOL needActivate, ZYBleDeviceRequestState state, ZYBlCheckActiveInfoData *checkActive) {
        @strongify(self)
        [self p_doReadyNotiWithShowNoti:noti];
    }];

}


-(void)p_doReadyNotiWithShowNoti:(BOOL)noti{
    [self p_postDevice_PTZReadyToUse];
    [self p_doUpGradeCheckWithShowNoti:noti];
}

-(void)doUpgradeCheckAfterActivate{
    [self p_doUpGradeCheckWithShowNoti:YES];
    
}

-(void)p_postDevice_PTZReadyToUse{
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Device_PTZReadyToUse object:self];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_PTZReadyToUse object:self];
        });
    }
}

-(void)p_doUpGradeCheckWithShowNoti:(BOOL)noti{
#pragma -mark 没激活的设备不能升级
    BOOL updateSupport = (self.functionModel.activate == ActivateTypeNoSupport);
    
    if (updateSupport == NO) {
        if (self.activeState == ActiveStatueActive) {
            updateSupport = YES;
        }
        else{
            updateSupport = NO;
        }
    }
    @weakify(self);
    if (self.functionModel.update != UpdateTypeNoSupport && updateSupport) {
        if (self.functionModel.jsonData && self.functionModel.update == UpdateTypeCombineModules) {
            //模块化升级的类型
            [self queryModulesWithCount:3 handler:^(BOOL success, ZYModuleUpgrade_New_Model *result) {
                @strongify(self)
                
                if (success && result) {
                    self.moduleNewModel = result;
                    self.hardwareUpgradeManager.jsonNewModel = result;
                    
                    self.moduleUpgradeInfos = result.modules;
                    self.hardwareUpgradeManager.moduleUpgradeInfos = result.modules;
                    [self p_beaginQueryValueWithCodeVersion_RCompletedAuto:^(NSString *value, BOOL success) {
                        @strongify(self);
                        [self addConnectedDataWithrefID:self.modelNumber softVersion:self.softwareVersion deviceName:[self deviceName]   moduleMessage:result.origionDic];
                        if ([self checkIsNeedToUpgradByModelNumberStr:self.modelNumberString]) {
                            [self serverCheckNeedUpgradeWithrefID:self.modelNumber softVersion:self.softwareVersion moduleMessage:result handler:^(BOOL isNeedUpdate) {
                                @strongify(self);
                                [self checkUpdateResult:isNeedUpdate showNoti:noti];
                                
                            }];
                        } else {
                            [self checkUpdateResult:NO showNoti:noti];
                        }
                        [self readNoMustData];
                        
                    }];
                }else{
                    //获取模块化信息失败
                    [self p_beaginQueryValueWithCodeVersion_RCompletedAuto:^(NSString *value, BOOL success) {
                        @strongify(self);
                        [self readNoMustData];
                    }];
                }
            }];
        }
        else{
            
            [self queryUpgradableInfos:^(NSArray<ZYUpgradableInfoModel *> *infos) {
                @strongify(self)
                //                NSLog(@"%@",infos);
                if (infos.count > 0) {
                    
                    self.moduleUpgradeInfos = infos;
                    self.hardwareUpgradeManager.moduleUpgradeInfos = infos;
                    [self p_beaginQueryValueWithCodeVersion_RCompletedAuto:^(NSString *value, BOOL success) {
                        @strongify(self);
                        [self addConnectedDataWithrefID:self.modelNumber softVersion:self.softwareVersion deviceName:[self deviceName]   moduleMessage:nil];
                        if ([self checkIsNeedToUpgradByModelNumberStr:self.modelNumberString]) {
                            [self serverCheckNeedUpgradeWithrefID:self.modelNumber softVersion:self.softwareVersion moduleMessage:nil handler:^(BOOL isNeedUpdate) {
                                @strongify(self);
                                [self checkUpdateResult:isNeedUpdate showNoti:noti];
                            }];
                        } else {
                            [self checkUpdateResult:NO showNoti:noti];
                        }
                        [self readNoMustData];
                        
                    }];
                }
                else{
                    [self p_beaginQueryValueWithCodeVersion_RCompletedAuto:^(NSString *value, BOOL success) {
                        @strongify(self);
                        [self checkUpdateResult:NO showNoti:noti];
                        [self readNoMustData];
                    }];
                    
                }
            }];
        }
    }
    else{
        [self p_beaginQueryValueWithCodeVersion_RCompletedAuto:^(NSString *value, BOOL success) {
            @strongify(self);
            [self checkUpdateResult:NO showNoti:noti];
            [self readNoMustData];
        }];
    }
}

- (BOOL)upgradeMessageReady{
    if (self.hardwareUpgradeManager.moduleUpgradeInfos.count > 0) {
        return YES;
    }
    else{
        return NO;
    }
}

-(void)addConnectedDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion deviceName:(NSString *)deviceName moduleMessage:(NSDictionary *)modulMessage {
    [[ZYConnectedDataBase sharedDataBase] addConnectedDataWithrefID:refID softVersion:softVersion deviceName:deviceName moduleMessage:modulMessage];
}

-(void)serverCheckNeedUpgradeWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion  moduleMessage:(ZYModuleUpgrade_New_Model *)modulMessage handler:(void (^)(BOOL isNeedUpdate))handler{
    [[ZYUpgradeServerTool shareInstant] serverCheckNeedUpgradeWithrefID:refID softVersion:softVersion moduleMessage:modulMessage handler:handler];
}

-(void)p_queryDeviceCategoryCompleted:(void(^)(NSString*value ,BOOL success))completed{
    if ([self p_isCCSQueryBaseMessage]) {
        [self p_imageBoxGetCameraDataWithNum:ZYCameraWifiDeviceCategory_R withCount:3 completionHandler:completed];
    }
    else{
        [self queryValueWithCode:ZYBleInteractCodeDeviceCategory_R completed:completed];
    }
}


-(void)p_imageBoxGetCameraDataWithNum:(NSUInteger)num withCount:(int)count completionHandler:(void(^)(id value ,BOOL success))handler{
    @weakify(self)
    [self.cameraWifiManager.cameraData getCameraDataWithNum:num withCount:count completionHandler:^(ZYBleDeviceRequestState state, id param) {
        ZYBlCCSGetConfigData* blCCSGetConfigDataRespond = (ZYBlCCSGetConfigData*)param;
        NSString *str = blCCSGetConfigDataRespond.value;
        @strongify(self)
        NSLog(@"===============%@",str);
        if (state == ZYBleDeviceRequestStateResponse) {
            BOOL suc = YES;
            id data = @"";
            switch (blCCSGetConfigDataRespond.idx) {
                case ZYCameraWifiDeviceCategory_R:
                {
                    [self.dataCache updateModel:ZYBleInteractCodeDeviceCategory_R param:[str integerValue]];
                    self.modelNumber = self.dataCache.modelNumber;
                    data = self.dataCache.modelNumberString;
                    break;
                }
                case ZYCameraWifiProductionNo:
                {
                    [self.dataCache.productionNo updateContent:str];
                    data = str;
                    break;
                }
                default:
                {
                    data = str;
                    break ;
                }
                    
            }
            BLOCK_EXEC(handler,data,suc);
        } else {
            if (self.workingState != 1) {
                NSLog(@"workingState != 1");
                return ;
            }
            BLOCK_EXEC(handler,@"",NO);
            
        }
    }];
    
}

-(BOOL)checkIsNeedToUpgradByModelNumberStr:(NSString *)modelNumberString{
    BOOL isNeedCheckUpgrade = NO; //是否需要检查升级
    isNeedCheckUpgrade = self.functionModel.update != UpdateTypeNoSupport;
#pragma -mark 当前是在wifionly的时候不检查升级,并且不是图传盒子
    if ([ZYDeviceManager defaultManager].enableOnlyWifi && ![modelNumberString localizedCaseInsensitiveContainsString:modelNumberImageTransBox]) {
        isNeedCheckUpgrade = NO;
    }
    return isNeedCheckUpgrade;
}

-(void)p_queryValueWithCodeVersion_RCompleted:(void(^)(NSString*value ,BOOL success))completed{
    if ([self p_isCCSQueryBaseMessage]) {
        if (self.moduleNewModel) {
            NSUInteger version = [self.moduleNewModel.version integerValue];
            NSString *data = [NSString stringWithFormat:@"%lu",(unsigned long)version];
            [self.dataCache updateModel:ZYBleInteractCodeVersion_R param:version];
            BLOCK_EXEC(completed,data,YES);
        }
        else{
            [self queryValueWithCode:ZYBleInteractCodeVersion_R completed:completed];
        }
    }
    else{
        [self queryValueWithCode:ZYBleInteractCodeVersion_R completed:completed];
    }
}
-(void)p_beaginQueryValueWithCodeVersion_RCompletedAuto:(void(^)(NSString*value ,BOOL success))completed{
    @weakify(self)
    [self p_queryValueWithCodeVersion_RCompleted:^(NSString *value, BOOL success) {
        @strongify(self)
        if (value == nil) {
            value = @"";
        }
        self.softwareVersion = value;
        [self.motionManager configMotionControlTypeWithSoftWithsoftwareVersion:value andModelNumberString:self.modelNumberString];
        BLOCK_EXEC(completed,value,success);
    }];
}
//读取非必须的数据
-(void)readNoMustData{
    @weakify(self)
    [self queryProductionSerialNo:^(NSString *serialNo) {
        @strongify(self)
        self.serialNo = serialNo;
        if (serialNo.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SerialNumberGetNoti object:nil];
        }
    }];
    [self readSharpTurningSettingsWithHandler:nil];//查询微调
    [self p_queryCraneDataBase];//查询云鹤的电机力度,和相机厂商
#pragma -mark sm4需要请求的数据
    if ([[ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString isEqualToString:modelNumberSmooth4]) {
        [self getFoucsMode:^(ZYBleInteractHDLFocusModeType mode) {
            @strongify(self)
            self.handlerFocusMode = mode;
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth_FocusMode_Notification object:self userInfo:@{@"mode":@(mode)}];
        }];
    }
    
}

-(void)checkUpdateResult:(BOOL)isNeed showNoti:(BOOL)noti
{
#pragma -mark 图传盒子不需要重新获取 其他信息
    @weakify(self)
    if ([ZYCameraWiFIManager supportCameraSetting] && ![self.modelNumberString isEqualToString:modelNumberImageTransBox]) {
        
        [self queryOtherBaseDataFinishChangeToWifiConnection:^(BOOL wifiEnable) {
            @strongify(self)
            [self p_postDevice_PTZReadyToUse];
            if (noti ) {
                [self postUpgradeNotiWithUpgrad:isNeed];
            }
        }];
    }else{
        if (noti) {
            [self postUpgradeNotiWithUpgrad:isNeed];
        }
    }
}


-(void)postUpgradeNotiWithUpgrad:(BOOL)isNeed {
    if (isNeed) {
        self.upgradeCheckType = DeviceUpgradeCheckTypeCheckedUpgrade;
    }
    else{
        self.upgradeCheckType = DeviceUpgradeCheckTypeCheckedNoUpgrade;
    }
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HardwareUpgrade_IsNeedToUpgrade object:nil userInfo:@{@"isNeed":@(isNeed)}];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:HardwareUpgrade_IsNeedToUpgrade object:nil userInfo:@{@"isNeed":@(isNeed)}];
        });
    }
    
}

-(void)checkSeriesByDeviceName:(NSString *)name{
    _deviceSeries = [ZYProductConfigTools deviceSeriesWithDiviceName:name];
}

-(void)queryValueNoLoopWithCode:(NSInteger)code completed:(void(^)(NSString*value ,BOOL success))completed{
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    if (![ZYDeviceManager defaultManager].curDeviceInfo) {
        NSLog(@"Device no ready!!!!!");
        
        BLOCK_EXEC(completed,nil,NO);
        return;
    }
    ZYBleDeviceDataModel* value = client.dataCache;
    @weakify(self)
    [self sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        NSLog(@"state = %d Device no ready!!!!!",state);
        
        if (state == ZYBleDeviceRequestStateResponse) {
            BOOL suc = YES;
            NSString *data = @"";
            switch (code) {
                case ZYBleInteractCodeDeviceCategory_R:
                    if (value.modelNumberString.length) {
                        data = value.modelNumberString;
                        self.modelNumber = value.modelNumber;
                    }
                    break;
                    
                case ZYBleInteractCodeVersion_R:
                    data = [NSString stringWithFormat:@"%lu",(unsigned long)value.softwareVersion];
                    break;
                case ZYBleInteractCodeBatteryVoltage_R:
                    data = [NSString stringWithFormat:@"%f",value.fBatteryVoltage];
                    break;
                default: ;
                    
            }
            BLOCK_EXEC(completed,data,suc);
        } else  if (state == ZYBleDeviceRequestStateTimeout) {
            NSLog(@"%@ 查询电池超时！！！！",self);
            BLOCK_EXEC(completed,nil,NO);
            
        } else {
            if (self.workingState != 1) {
                NSLog(@"workingState != 1");
                return ;
            }
            BLOCK_EXEC(completed,nil,NO);
            
        }
        
    }];
}

-(void)queryValueWithCode:(NSInteger)code completed:(void(^)(NSString*value ,BOOL success))completed{
    
#pragma -mark 图传盒子需要屏蔽
    
    if (![ZYDeviceManager defaultManager].curDeviceInfo) {
        NSLog(@"Device no ready!!!!!");
        
        BLOCK_EXEC(completed,nil,NO);
        return;
    }
    [self p_queryValueWithCode:code withCount:1 completed:completed];
}

-(void)p_queryValueWithCode:(NSInteger)code withCount:(int)count completed:(void(^)(NSString*value ,BOOL success))completed{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    @weakify(self)
    [self sendRequestCode:code withCount:count completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            BOOL suc = YES;
            NSString *data = @"";
            switch (code) {
                case ZYBleInteractCodeDeviceCategory_R:
                    if (value.modelNumberString.length) {
                        data = value.modelNumberString;
                        self.modelNumber = value.modelNumber;
                    }
                    break;
                    
                case ZYBleInteractCodeVersion_R:
                    data = [NSString stringWithFormat:@"%lu",(unsigned long)value.softwareVersion];
                    break;
                case ZYBleInteractCodeBatteryVoltage_R:
                    data = [NSString stringWithFormat:@"%f",value.fBatteryVoltage];
                    break;
                default:
                    
                    return ;
            }
            BLOCK_EXEC(completed,data,suc);
        } else {
            BLOCK_EXEC(completed,@"",NO);
        }
    }];
}

-(void)setModelNumberString:(NSString *)modelNumberString{
    _modelNumberString = modelNumberString;
    [ZYDeviceManager defaultManager].modelNumberString = modelNumberString;
}

-(void)p_queryCraneDataBase{
    if ([ZYProductConfigTools canSetStablizerWithDeviceSeries:_deviceSeries]) {
        @weakify(self)
        if (_deviceSeries == ZYDeviceSeriesImageBox) {
            return;
        }
        [self readCameraManufacturerHandler:^(BOOL success, ZYCameraManufacturerType type) {
            if (success) {
                @strongify(self)
                self.cameraManufacturer = type;
            }
        }];
        
        [self readCraneMotorForceModeHandler:^(BOOL success, ZYBleDeviceMotorForceMode motorForceMode) {
            if (success) {
                @strongify(self)
                self.craneMotorForce = motorForceMode;
            }
        }];
    }
}

#pragma mark - 稳定器电机模式相关

-(void) checkMotorMode:(void (^)(BOOL success, ZYBleInteractMotorPower originalMode))handler
{
    ZYBleDeviceDataModel* value = [ZYBleDeviceClient defaultClient].dataCache;
    @weakify(self)
    [self sendRequestCode:ZYBleInteractCodePower_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler, YES, value.powerStatus)
            self.motorState = value.powerStatus;
        } else {
            BLOCK_EXEC(handler, NO, ZYBleInteractMotorPowerUnkown);
        }
    }];
}

-(void) enableMotor:(ZYBleInteractMotorPower)mode compeletion:(void (^)(BOOL success, ZYBleInteractMotorPower originalMode))handler;
{
    [self checkMotorMode:^(BOOL success, ZYBleInteractMotorPower originalMode) {
        if (mode == ZYBleDeviceWorkModeUnkown) {
            //查询当前电机工作模式直接返回
            BLOCK_EXEC(handler, success, originalMode)
        } else {
            if (originalMode == mode) {
                //当前电机模式已经是设置值
                BLOCK_EXEC(handler, success, originalMode);
            } else {
                //设置期望的电机模式
                [self sendRequestCode:ZYBleInteractCodePower_W data:@(mode) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        self.motorState = mode;
                        BLOCK_EXEC(handler, YES, originalMode);
                    } else {
                        BLOCK_EXEC(handler, NO, originalMode);
                    }
                }];
            }
        }
    }];
}

#pragma mark - 稳定器内置功能

- (BOOL)motion_goToMiddle:(void (^)(ZYBleDeviceRequestState state))handler
{
    if ([[NSDate date] timeIntervalSinceDate:_lastMiddleAndBack]<kMinMiddleAndBackInterval) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, ZYBleDeviceRequestStateIgnore);
        return NO;
    }
    
    _lastMiddleAndBack = [NSDate date];
    [self sendRequestCode:ZYBleInteractFunctionEvent data:@(ZYBleInteractDeviceEventReturn) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, state);
    }];
    return YES;
}

-(BOOL) goToMiddle:(void (^)(BOOL success))handler
{
    if ([[NSDate date] timeIntervalSinceDate:_lastMiddleAndBack]<kMinMiddleAndBackInterval) {
        return NO;
    }
    
    _lastMiddleAndBack = [NSDate date];
    [self sendRequestCode:ZYBleInteractFunctionEvent data:@(ZYBleInteractDeviceEventReturn) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
        } else {
            BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        }
    }];
    return YES;
}

-(BOOL) goToBack:(void (^)(BOOL success))handler
{
    if ([[NSDate date] timeIntervalSinceDate:_lastMiddleAndBack]<kMinMiddleAndBackInterval) {
        return NO;
    }
    
    _lastMiddleAndBack = [NSDate date];
    [self sendRequestCode:ZYBleInteractFunctionEvent data:@(ZYBleInteractDeviceEventBackhead) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
        } else {
            BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        }
    }];
    
    return YES;
}

/**
 变焦事件
 
 @param isAddZoom 是否是变焦+
 @param isStart 是否是开始
 */
- (BOOL)zoomStatusChanged:(BOOL)isAddZoom isStart:(BOOL)isStart result:(void (^)(BOOL success))handler
{
    // 判断是否属于 云鹤，webblize系列设备
    //    BOOL deviceSupport = [ZYProductConfigTools canSetStablizerWithDeviceSeries:_deviceSeries];
    //    if (!deviceSupport) {
    //        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
    //        return NO;
    //    }
#pragma -mark 不需要判断是否是云鹤M2了，直接根据digitalZoom变量
    // 判断是否是云鹤 CraneM2
    //    NSString *curDeviceModelNumStr = [ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString;
    //    if (![curDeviceModelNumStr isEqualToString:modelNumberCraneM2]) {
    //
    //    }
    
    if (self.functionModel.digitalZoom == NO) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        return NO;
    }
    
    NSUInteger eventType = isStart?kCLICK_EVENT_PRESSED_NOTIFY_KEY:kCLICK_EVENT_RELEASE_NOTIFY_KEY;
    NSUInteger eventValue = isAddZoom?kCLICK_EVENT_BUTTON_T_KEY:kCLICK_EVENT_BUTTON_W_KEY;
    
    [self sendRequestCode:ZYBleInteractButtonEvent data:@(makeEventParam(eventValue, eventType)) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
        } else {
            BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        }
    }];
    return YES;
}

-(BOOL)isGroup0WithString:(NSString *)curDeviceModelNumStr{
    if ([ZYBleDeviceDataModel likeWeebillsWithString:curDeviceModelNumStr] || [curDeviceModelNumStr isEqualToString:modelNumberCraneM2]) {
        return YES;
    }
    return NO;
}

-(BOOL) notifyPhotoButtonClick:(void (^)(BOOL success))handler
{
    BOOL deviceSupport = [ZYProductConfigTools canSetStablizerWithDeviceSeries:_deviceSeries];
    if (!deviceSupport) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        return NO;
    } else {
        NSNumber *data = nil;
        NSString *curDeviceModelNumStr = [ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString;
        if ([self isGroup0WithString:curDeviceModelNumStr]) {
            data =@(makeEventParam(kCLICK_EVENT_BUTTON_CAPTURE_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
        } else {
            if ([ZYBleDeviceDataModel isModelSupportWIFI:self.modelNumberString]) {
                data =@(makeGroupParam(kCLICK_GROUP_1,kCLICK_EVENT_BUTTON1_CAPTURE_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
            }
            else{
                data =@(makeEventParam(kCLICK_EVENT_BUTTON_PHOTOS_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
            }
        }
        [self sendRequestCode:ZYBleInteractButtonEvent data:data completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
            } else {
                BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
            }
        }];
        return YES;
    }
}

-(BOOL) notifyPhotoButtonDoubleClick:(void (^)(BOOL success))handler
{
    BOOL deviceSupport = [ZYProductConfigTools canSetStablizerWithDeviceSeries:_deviceSeries];
    if (!deviceSupport) {
        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
        return NO;
    } else {
        NSNumber *data = nil;
        NSString *curDeviceModelNumStr = [ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString;
        if ([self isGroup0WithString:curDeviceModelNumStr]) {
            ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractButtonEvent param:@(makeEventParam(kCLICK_EVENT_BUTTON_RECORD_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY))];
            [self sendRequests:[NSArray arrayWithObjects:request1, nil] completionHandler:handler];
        }else{
            if ([ZYBleDeviceDataModel isModelSupportWIFI:self.modelNumberString]) {
                data =@(makeGroupParam(kCLICK_GROUP_1,kCLICK_EVENT_BUTTON1_RECORD_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY));
                
                [self sendRequestCode:ZYBleInteractButtonEvent data:data completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        BLOCK_EXEC_ON_MAINQUEUE(handler, YES)
                    } else {
                        BLOCK_EXEC_ON_MAINQUEUE(handler, NO);
                    }
                }];
                return YES;
            }
            else{
                if ([self.softwareVersion   compare: @"170"]  == NSOrderedAscending ){
#pragma -mark 老设备需要发两次，其他没有特殊要求的时候不需要发送两次
                    ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractButtonEvent param:@(makeEventParam(kCLICK_EVENT_BUTTON_PHOTOS_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY))];
                    request1.packedWithNext = YES;
                    ZYBleDeviceRequest* request2 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractButtonEvent param:@(makeEventParam(kCLICK_EVENT_BUTTON_PHOTOS_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY))];
                    
                    [self sendRequests:[NSArray arrayWithObjects:request1, request2, nil] completionHandler:handler];
                }
                else {
                    ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractButtonEvent param:@(makeEventParam(kCLICK_EVENT_BUTTON_RECORD_KEY, kCLICK_EVENT_CLICKED_NOTIFY_KEY))];
                    [self sendRequests:[NSArray arrayWithObjects:request1, nil] completionHandler:handler];
                }
                
            }
        }
        return YES;
    }
}

#pragma mark - 相机厂商
-(void)setCameraManufacturerWithType:(ZYCameraManufacturerType)manufacturerType Handler:(void(^)(BOOL success))handler{
    @weakify(self)
    [self sendRequestCode:ZYBleInteractCodeCameraManufacturer_W data:@(manufacturerType) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            @strongify(self);
            self.cameraManufacturer = manufacturerType;
            BLOCK_EXEC(handler,YES);
        }else{
            NSLog(@"setCameraManufacturerWithType error %s",__func__);
            
            BLOCK_EXEC(handler,NO);
        }
    }];
}

-(void)readCameraManufacturerHandler:(void(^)(BOOL success,ZYCameraManufacturerType type))handler{
    [self sendRequestCode:ZYBleInteractCodeCameraManufacturer_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler,YES,param);
        }else{
            BLOCK_EXEC(handler,NO,-1);
            NSLog(@"readCameraManufacturerHandler state:%ld error: %s",(long)state,__func__);
            
        }
    }];
}

#pragma mark - 云鹤力度
-(void)readCraneMotorForceModeHandler:(void(^)(BOOL success,ZYBleDeviceMotorForceMode motorForceMode))handler{
    [self sendRequestCode:ZYBleInteractCodeMotorForce_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler,YES,param);
        }else{
            NSLog(@"readCraneMotorForceModeHandler state:%ld ERROR: %s",(long)state,__func__);
            BLOCK_EXEC(handler,NO,param);
        }
    }];
}

-(void)setCraneMotorForceMode:(ZYBleDeviceMotorForceMode)model handler:(void(^)(BOOL success))handler{
    @weakify(self)
    [self sendRequestCode:ZYBleInteractCodeMotorForce_W data:@(model) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            @strongify(self)
            self.craneMotorForce = model;
            
            BLOCK_EXEC(handler,YES);
        }else{
            NSLog(@"setCraneMotorForceMode state:%ld ERROR %s",param,__func__);
            BLOCK_EXEC(handler,NO);
        }
    }];
}

#pragma mark - 微调
-(void)readSharpTurningSettingsWithHandler:(void(^)(BOOL success, float pitchSharpTurning, float rollSharpTurning))handler;
{
    if ([self.modelNumberString isEqualToString:modelNumberImageTransBox]) {
        NSLog(@"不支持微调节的赌气");
        BLOCK_EXEC(handler,NO,0,0);
        return;
    }
    
    ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodePitchSharpTurning_R param:@(0)];
    ZYBleDeviceRequest* request2 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeRollSharpTurning_R param:@(0)];
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    @weakify(self)
    
    [self sendRequests:[NSArray arrayWithObjects:request1, request2, nil] completionHandler:^(BOOL success){
        @strongify(self)
        self.pitchSharpTurning = client.dataCache.pitchSharpTurning;
        self.rollSharpTurning = client.dataCache.rollSharpTurning;
        BLOCK_EXEC(handler,success,client.dataCache.pitchSharpTurning,client.dataCache.rollSharpTurning);
        //        handler(success, client.dataCache.pitchSharpTurning, client.dataCache.rollSharpTurning);
    }];
}

-(void)writeSharpTurningSettingsWithHandler:(float)pitchSharpTurning roll:(float)rollSharpTurning handler:(void(^)(BOOL success))handler
{
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    @weakify(self)
    void (^writeSharpTurningValue)(void) = ^(void) {
        @strongify(self)
        ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodePitchSharpTurning_W param:@(pitchSharpTurning)];
        ZYBleDeviceRequest* request2 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeRollSharpTurning_W param:@(rollSharpTurning)];
        
        [self sendRequests:[NSArray arrayWithObjects:request1, request2, nil] completionHandler:^(BOOL success) {
            if (success) {
                @strongify(self)
                self.pitchSharpTurning = pitchSharpTurning;
                self.rollSharpTurning = rollSharpTurning;
            }
            BLOCK_EXEC(handler,success);
        }];
    };
    [self sendRequestCode:ZYBleInteractCodeDebug_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            @strongify(self)
            if (value.debugMode != ZYBleInteractDeviceDebugModeIMUAdjust) {
                ZYBleInteractDeviceDebugMode originalMode = value.debugMode;
                [self sendRequestCode:ZYBleInteractCodeDebug_W data:@(ZYBleInteractDeviceDebugModeIMUAdjust)completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    @strongify(self)
                    if (state == ZYBleDeviceRequestStateResponse) {
                        writeSharpTurningValue();
                        [self sendRequestCode:ZYBleInteractCodeDebug_W data:@(originalMode) completionHandler:nil];
                    } else {
                        handler(NO);
                    }
                }];
            } else {
                writeSharpTurningValue();
            }
        } else {
            handler(NO);
        }
    }];
}

-(void)beginIMUAdjust:(void(^)(BOOL success))handler
{
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    [self sendRequestCode:ZYBleInteractCodeDebug_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if (value.debugMode != ZYBleInteractDeviceDebugModeIMUAdjust) {
                self.deviceDebugOriginalMode = value.debugMode;
                [self sendRequestCode:ZYBleInteractCodeDebug_W data:@(ZYBleInteractDeviceDebugModeIMUAdjust)completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        handler(YES);
                    } else {
                        handler(NO);
                    }
                }];
            } else {
                handler(YES);
            }
        } else {
            handler(NO);
        }
    }];
}

-(void)setSharpTurningSetting:(float)pitchSharpTurning roll:(float)rollSharpTurning handler:(void(^)(BOOL success))handler
{
    ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodePitchSharpTurning_W param:@(pitchSharpTurning)];
    ZYBleDeviceRequest* request2 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeRollSharpTurning_W param:@(rollSharpTurning)];
    
    @weakify(self)
    
    [self sendRequests:[NSArray arrayWithObjects:request1, request2, nil] completionHandler:^(BOOL success) {
        if (success) {
            @strongify(self)
            self.pitchSharpTurning = pitchSharpTurning;
            self.rollSharpTurning = rollSharpTurning;
        }
        BLOCK_EXEC(handler,success);
    }];
}

-(void)endIMUAdjust:(void(^)(BOOL success))handler
{
    [self sendRequestCode:ZYBleInteractCodeDebug_W data:@(self.deviceDebugOriginalMode) completionHandler:nil];
}

#pragma mark - 保存设置
-(void)saveSettingsWithHandler:(void(^)(BOOL success))handler{
    //    NSLog(@"发送保存数据的指令-----");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendRequestCode:ZYBleInteractSave data:@(ZYBLE_SAVE_PARAM) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC(handler,YES);
            }else{
                NSLog(@"saveSettingsWithHandler state:%ld ERROR %s",param,__func__);
                BLOCK_EXEC(handler,NO);
            }
            
        }];
    });
    
}

-(void)queryProductionSerialNo:(void(^)(NSString* serialNo))handler
{
    @weakify(self)
    
    if ([self p_isCCSQueryBaseMessage]) {
        [self p_imageBoxGetCameraDataWithNum:ZYCameraWifiProductionNo withCount:3 completionHandler:^(NSString *value, BOOL success) {
            @strongify(self)
            if (success) {
                handler(self.dataCache.productionNo.content);
            } else {
                handler(@"");
            }
        }];
    }
    else{
        ZYBleDeviceRequest* request1 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractProductionNo1_R param:@(0)];
        request1.mask = ZYBleDeviceRequestMaskUpdate;
        ZYBleDeviceRequest* request2 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractProductionNo2_R param:@(0)];
        request2.mask = ZYBleDeviceRequestMaskUpdate;

        ZYBleDeviceRequest* request3 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractProductionNo3_R param:@(0)];
        request3.mask = ZYBleDeviceRequestMaskUpdate;

        ZYBleDeviceRequest* request4 = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractProductionNo4_R param:@(0)];
        request4.mask = ZYBleDeviceRequestMaskUpdate;

        [self sendRequests:[NSArray arrayWithObjects:request1, request2, request3, request4, nil] completionHandler:^(BOOL success){
            @strongify(self)
            if (success) {
                self.serialNo = self.dataCache.productionNo.content;
                handler(self.dataCache.productionNo.content);
            } else {
                handler(@"");
            }
        }];
    }
    
}

#pragma mark - 变焦对焦设置
-(void)setFoucsMode:(ZYBleInteractHDLFocusModeType)flag handler:(void(^)(BOOL success))handler {
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithHandlerCodeAndParam:flag param:flag];
    request.handler = ^(ZYBleDeviceRequestState state, NSUInteger param){
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler, YES);
        } else {
            BLOCK_EXEC(handler, NO);
        }
    };
    [self sendDeviceRequest:request];
}

-(void)getFoucsMode:(void(^)(ZYBleInteractHDLFocusModeType mode))handler
{
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithHandlerCodeAndParam:ZYBleInteractHDLFocusMode param:ZYBleInteractHDLFocusModeUnknown];
    request.handler = ^(ZYBleDeviceRequestState state, NSUInteger param){
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler, param);
        } else {
            BLOCK_EXEC(handler, ZYBleInteractHDLFocusModeUnknown);
        }
    };
    
    [self sendDeviceRequest:request];
}

-(void)queryUpgradableInfos:(void(^)(NSArray<ZYUpgradableInfoModel*>* infos))handler
{
    [self queryUpgradableModuleCount:^(NSUInteger num) {
        if (num > 0) {
            NSMutableArray<ZYUpgradableInfoModel*>* infos = [NSMutableArray array];
            for (int i = 0; i < num; i++) {
                [self queryUpgradableModuleInfo:i+1 completionHandler:^(ZYUpgradableInfoModel *model) {
                    [infos addObject:model];
                    if (infos.count == num) {
                        BLOCK_EXEC(handler, infos);
                    }
                }];
            }
        } else {
            BLOCK_EXEC(handler, nil);
        };
    }];
}

-(void)queryUpgradableModuleCount:(void(^)(NSUInteger num))handler
{
    [self sendRequestCode:ZYBleInteractUpgradableModuleCount completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler, param);
        } else {
            BLOCK_EXEC(handler, 0);
        }
    }];
}

-(void)queryUpgradableModuleInfo:(NSUInteger)idx completionHandler:(void(^)(ZYUpgradableInfoModel*))handler
{
    __block NSUInteger requestCount = 0;
    __block BOOL resultFlag = YES;
    ZYUpgradableInfoModel* model = [[ZYUpgradableInfoModel alloc] initWithModelNumber:self.modelNumber];
    void(^checkResult)(BOOL success, NSUInteger value) = ^(BOOL success, NSUInteger value) {
        resultFlag &= success;
        if (++requestCount>=2) {
            if (resultFlag) {
                BLOCK_EXEC(handler, model);
            } else {
                BLOCK_EXEC(handler, model);
            }
        }
    };
    
    NSUInteger code = ZYBleInteractInvalid;
    code = ZYBleInteractUpgradableDeviceId;
    [self sendRequestCode:code data:@(idx) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            [model updateDeviceIdAndChannel:param];
            BLOCK_EXEC(checkResult, YES, param);
        } else {
            BLOCK_EXEC(checkResult, NO, 0);
        }
    }];
    
    code = ZYBleInteractUpgradableVersion;
    [self sendRequestCode:code data:@(idx) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            model.version = param;
            BLOCK_EXEC(checkResult, YES, param);
        } else {
            BLOCK_EXEC(checkResult, NO, 0);
        }
    }];
}

#pragma mark - Battery Query

-(void)beginqueryBatteryValueLoop{
    [self queryBatteryWithLastValue:-1];
}

-(void)closeAllLoop{
    if (nil != _delayedBlockHandle) {
        _delayedBlockHandle(YES);
    }
    _delayedBlockHandle = nil;
    [self endBatteryLoopQuery];
}

-(void)endBatteryLoopQuery{
    //    NSLog(@"closeBatteryLoop!");
    if (nil != _batteryDelayedBlockHandle) {
        _batteryDelayedBlockHandle(YES);
    }
    _batteryDelayedBlockHandle = nil;
}

/* 查询电池电压，并换算出电量，每隔60秒循环查询一次.
 电量计算公式:
 最大电压是4.0伏i~最小电压是3.25伏j，根据设备型号获得电池数量x，获取当前电压总量y,
 当前电量 = (x / y - j) * (100 /(i - j))
 */
-(void)queryBatteryWithLastValue:(float)lastValue{
    
    @weakify(self)
    if (!self.modelNumberString.length) {
        [self queryBaseDataCompleted:^{
            @strongify(self)
            [self beginqueryBatteryValueLoop];
        }];
        return;
    }
    [self endBatteryLoopQuery];
    
    [self queryValueWithCode:ZYBleInteractCodeBatteryVoltage_R completed:^(NSString *value, BOOL success) {
        @strongify(self)
        float currentValue = [value floatValue];
        if (currentValue != lastValue) {
            float batteryScale = [self calculationBatteryWithValue:value];
            
            self.batteryValue = batteryScale;
            
        }
        self.batteryDelayedBlockHandle = perform_block_after_delay_seconds(60, ^{
            @strongify(self)
            [self queryBatteryWithLastValue:[value floatValue]];
            self.batteryDelayedBlockHandle = nil;
        });
    }];
}

-(void)queryBatteryWithRepeatCount:(int)repeatCount completed:(void(^)(void))completed{
    [self queryBatteryWithRepeatCount:repeatCount currentIndex:1 completed:completed];
    
}

-(void)queryBatteryWithRepeatCount:(int)repeatCount currentIndex:(int)currentIndex completed:(void(^)(void))completed{
    @weakify(self)
    
    [self queryValueNoLoopWithCode:ZYBleInteractCodeBatteryVoltage_R completed:^(NSString *value, BOOL success) {
        @strongify(self)
        NSLog(@"battorycoutnt = %d %d %@",currentIndex,success,value);
        if (success) {
            self.batteryValue = [self calculationBatteryWithValue:value];
            if ([NSThread currentThread ] == [NSThread mainThread]) {
                BLOCK_EXEC(completed);
            }
            else{
                BLOCK_EXEC_ON_MAINQUEUE(completed);
            }
            
            return ;
            
        }
        if (currentIndex == repeatCount) {
            if ([NSThread currentThread ] == [NSThread mainThread]) {
                BLOCK_EXEC(completed);
            }
            else{
                BLOCK_EXEC_ON_MAINQUEUE(completed);
            }
            return ;
        }
        [self queryBatteryWithRepeatCount:repeatCount currentIndex:currentIndex+1 completed:completed];
    }];
}

-(BOOL)supportKeyRedfineSetting{
    BOOL supportKeyRedfine = self.functionModel.supportKeyRedfineSetting;
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        supportKeyRedfine = self.accessory.functionModel.supportKeyRedfineSetting;
    }
    return supportKeyRedfine;
}

-(Ble_hidType)supportBle_Hid{
    Ble_hidType supportBle_Hidd = self.functionModel.ble_hid;
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        supportBle_Hidd = self.accessory.functionModel.ble_hid;
    }
    return supportBle_Hidd;
}

-(NSMutableArray *)keyredefine{
    NSMutableArray * keyredefine = [self.functionModel.keyredefine mutableCopy];
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        keyredefine = [self.accessory.functionModel.keyredefine mutableCopy];
    }
    return keyredefine;
}

-(NSMutableArray *)motorStrength{
    NSMutableArray * motorStrength = [self.functionModel.motorStrength mutableCopy];
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        motorStrength = [self.accessory.functionModel.motorStrength mutableCopy];
    }
    return motorStrength;
}

-(NSMutableArray *)motorStrengthCustom{
    NSMutableArray * motorStrengthCustom = [self.functionModel.motorStrengthCustom mutableCopy];
      if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
          motorStrengthCustom = [self.accessory.functionModel.motorStrengthCustom mutableCopy];
      }
      return motorStrengthCustom;
}

-(BOOL)motorStrengthAdjustNotify{
    BOOL motorStrengthAdjustNotify = self.functionModel.motorStrengthAdjustNotify;
       if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
           motorStrengthAdjustNotify = self.accessory.functionModel.motorStrengthAdjustNotify;
       }
    return motorStrengthAdjustNotify;
}

-(BOOL)newtrackingCodeSupport{
    BOOL tracking = self.functionModel.tracking;
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        tracking = self.accessory.functionModel.tracking;
    }
    return tracking;
}

-(BOOL)newWifiChannelCodeSupport{
    BOOL wifichannel = self.functionModel.wifichannel;
    if ([self.accessory.modelNumberString isEqualToString:modelNumberImageTransBox]) {
        wifichannel = self.accessory.functionModel.wifichannel;
    }
    return wifichannel;
}

-(float)calculationBatteryWithValue:(NSString *)value{
    if (!value ||(![value isKindOfClass:[NSString class]])) {
        return 0.0;
    }
    float currentValue = [value floatValue];
    float batteryScale = 0.00;
    float totalBattery = self.functionModel.battery;
    if ([ZYBleDeviceDataModel likeWeebillsWithString:self.accessory.modelNumberString]) {
        totalBattery = self.accessory.functionModel.battery;
    }
    
    float currentVoltage = currentValue / totalBattery;
    if (currentVoltage >= kMaxBatteryVoltage) {
        batteryScale = 100.000;
    }else if(currentVoltage < kMinBatteryVoltage){
        batteryScale = 0;
    }else{
        batteryScale = (currentVoltage - kMinBatteryVoltage)*kRisingProportion;
    }
    return batteryScale;
}

/**
 查询系统的状态
 */
-(void)queryStabilizerState
{
    if (![ZYDeviceManager defaultManager].deviceReady && !self.cameraWifiManager.wifiEnable) {
        return;
    }
    
    if (self.powerOnTestMissCount < 0) {
        return;
    }
    
    //NSLog(@"发送指令%@.....", self);
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    //第一次测试,当前测试结果未知,空闲时间超过2秒均开始检查
    if (self.powerOnFirstTest || self.workingState == -1 || client.idleTime > 2) {
        self.powerOnFirstTest = NO;
        @weakify(self)
        [self sendRequestCode:ZYBleInteractCodeSystemStatus_R withDelayMill:250 completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            @strongify(self)
            NSUInteger delayInSeconds = 0;
            if (self.powerOnTestMissCount < 0) {
                //已经停止连接检查
                return;
            }
            BOOL readyToUse = (state == ZYBleDeviceRequestStateResponse && param > 0);
            if (readyToUse) {
                delayInSeconds = 30;
                if (self.workingState != 1) {
                    self.workingState = 1;
                    [self p_begainQueryMustData];//开始同步必要的数据
                    //                    [ZYDeviceStablizerTestTool testStory];
#ifdef DEBUG
                    //                    [ZYDeviceStablizerTestTool testCraneM2Request];
                    NSLog(@"workingState %ld 检查成功....", (long)self.workingState);
#endif
                    
                }
                //NSLog(@"发送指令成功....");
            } else {
                self.powerOnTestMissCount++;
                if (self.powerOnTestMissCount!=0) {
                    NSTimeInterval timeElapse = [[NSDate date] timeIntervalSinceDate:self.powerOnTestTimeStamp];
                    float missRate = self.powerOnTestMissCount/timeElapse;
                    if ((missRate > 5 && timeElapse > 1)
                        || self.powerOnTestMissCount > 4) {
                        NSLog(@"丢包速度%.3f, 时长%.3f 次数%ld", missRate, timeElapse, self.powerOnTestMissCount);
                        [self notifyStabilizerOffLine:@(0)];
                    }
                }
                if (self.workingState != -1 ) {
                    delayInSeconds = 10;
                }
                //NSLog(@"发送指令失败....");
            }
            //NSLog(@"下次发送指令时间%ld....", delayInSeconds);
            //            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (self.powerOnTestMissCount < 0) {
                    //已经停止连接检查
                    return;
                }
                if (readyToUse) {
                    //上次测试通过,重新开始计算
                    self.powerOnTestMissCount = 0;
                    self.powerOnTestTimeStamp = [NSDate date];
                }
                [self queryStabilizerState];
            });
        }];
    } else {
        @weakify(self)
        NSUInteger delayInSeconds = 30;
        self.powerOnTestMissCount = 0;
        self.powerOnTestTimeStamp = [NSDate date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            if (self.powerOnTestMissCount < 0) {
                //已经停止连接检查
                return;
            }
            [self queryStabilizerState];
        });
    }
    
}


-(void)setBatteryValue:(float)batteryValue{
    _batteryValue = batteryValue;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Device_BatteryDidChange_Notification object:nil userInfo:@{@"KEY":@(batteryValue)}];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_BatteryDidChange_Notification object:nil userInfo:@{@"KEY":@(batteryValue)}];
            
        });
    }
}

-(void)setValueType:(BatteryValueType)valueType{
    if (valueType == _valueType) {
        return;
    }
    _valueType = valueType;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Device_BatteryTypeDidChange_Notification object:nil userInfo:@{@"valueType":@(valueType)}];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:Device_BatteryTypeDidChange_Notification object:nil userInfo:@{@"valueType":@(valueType)}];
            
        });
    }
}

#pragma mark - Working State check
-(void)onDeviceBLEReadyToUse:(NSNotification*)notification
{
    if (![[ZYDeviceManager defaultManager].curDeviceInfo.name isEqualToString:self.deviceInfo.name]) {
        return;
    }
#ifdef DEBUG
    //    NSLog(@"%@ xxx %s",self.deviceInfo.name,__func__);
#endif
    //初始化数据
    [self initStabilizerWorkingTest];
    [self queryStabilizerState];
}

-(void)onDeviceBLEOffLine:(NSNotification*)notification
{
    if (![[ZYDeviceManager defaultManager].curDeviceInfo.name isEqualToString:self.deviceInfo.name]) {
        return;
    }
#ifdef DEBUG
    
    NSLog(@"%@ xxx %s",self.deviceInfo.name,__func__);
#endif
    
    [self notifyStabilizerOffLine:@(0)];
    //NSLog(@"断开设备.....");
}

/**
 初始化设备的测试
 */
-(void)initStabilizerWorkingTest
{
    //丢失的数量大于等于0时 进行测试
    self.powerOnTestMissCount = 0;
    self.powerOnTestTimeStamp = [NSDate date];
    self.workingState = -1;
    self.powerOnFirstTest = YES;
}

-(void)notifyStabilizerOffLine:(NSNumber*)mode
{
    
    if ([ZYDeviceManager defaultManager].connectType >= ZYConnectTypeBleAndWifi) {
        return;
    }
    
    //已经是未连接 不必通知 但是需要清零统计
    if (self.workingState != 0) {
        
        self.workingState = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Device_PTZOffLine object:self userInfo:@{@"mode":mode}];
        
    }
    
    if (mode.unsignedIntegerValue == 0) {
        self.powerOnTestMissCount = 0;
        self.powerOnTestTimeStamp = [NSDate date];
    } else {
        //丢失的数量小于0时 不在进行测试
        self.powerOnTestMissCount = -1;
        self.powerOnTestTimeStamp = [NSDate date];
    }
}


#pragma mark - Dealloc
-(void)dealloc{
    
#ifdef DEBUG
    if (self.modelNumberString) {
        NSLog(@"(((((((((dealloc %@ = %@",[self class],self.modelNumberString);
    }
#endif
    [_wifiManager clearData];
    [_cameraWifiManager clearData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 查询其他的参数
-(void)queryOtherBaseDataFinishChangeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection{
    if ([ZYCameraWiFIManager supportCameraSetting]) {
        _cameraWifiManager = [[ZYCameraWiFIManager alloc] init];//云鹤系列的相机Wi-Fi管理类
        _cameraWifiManager.modelNameString = self.modelNumberString;
        [_cameraWifiManager setSendDelegate:self];
        if ([ZYBleDeviceDataModel likeWeebillsWithString:self.modelNumberString]) {
            if (self.RDISImageBoxConnecting ) {
                [self.cameraWifiManager doBaseQueryData:^{
                    
                } changeToWifiConnection:wifiConnection];
            }
            else{
                if (wifiConnection) {
                    wifiConnection(NO);
                }
            }
        }
        else{
            [self.cameraWifiManager doBaseQueryData:^{
                
            } changeToWifiConnection:wifiConnection];
        }
    }
}

-(void)configRequest:(ZYBleDeviceRequest *)request{
    //配置传输方式
    if (self.cameraWifiManager.wifiEnable) {
        request.trasmissionType = ZYTrasmissionTypeWIFI;
    }
    else{
        request.trasmissionType = ZYTrasmissionTypeBLE;
    }
    
    //配置解码方式
    NSString *modelNumberString = self.modelNumberString;
    if (modelNumberString == nil) {
        modelNumberString =[ZYDeviceManager defaultManager].curDeviceInfo.modelNumberString;
    }
    if ([self p_parseStarWithString:modelNumberString]) {
        request.parseFormat = ZYCodeParseStar;
    }
    else if ([[ZYBleDeviceDataModel supportWIFIModelList]
              containsObject:modelNumberString]) {
        if (request.trasmissionType == ZYTrasmissionTypeWIFI
            || request.trasmissionType == ZYTrasmissionTypeUSB) {
            request.parseFormat = ZYCodeParseUsb;
        } else {
            request.parseFormat = ZYCodeParseBl;
        }
    } else {
        request.parseFormat = ZYCodeParseBl;
    }
}
-(BOOL)p_parseStarWithString:(NSString *)modelString{
    
    if ([@[modelNumberPround,
           modelNumberEvolution,
           modelNumberSmooth,
           modelNumberSmooth2,
           modelNumberSmooth3,
           modelNumberSmoothQ,
           modelNumberSmoothC11,
           modelNumberRiderM,
           modelNumberCrane,
           modelNumberCraneM,
           modelNumberCraneS,
           modelNumberCraneL,
           modelNumberCraneH,
           modelNumberCranePlus,
           modelNumberCraneTwo,
           modelNumberShining]
         containsObject:modelString]) {
        return YES;
    }
    else{
        return NO;
    }
}

#pragma -mark ZYSendRequest协议
- (void)configEncodeAndTransmissionForRequest:(ZYBleDeviceRequest *)request{
    [self configRequest:request];
}

-(NSString *)modelStr{
    return _modelNumberString;
}
-(ZYProductSupportFunctionModel *)delegatefunctionModel{
    return _functionModel;
}
/**
 发送请求
 
 @param code 指令代号
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code withCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    __block int innerCount = count - 1;
    [self sendRequestCode:code data:@(0) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if (handler) {
                handler(state,param);
            }
        }
        else{
            if (innerCount <= 0) {
                if (handler) {
                    handler(state,param);
                }
            }
            else{
                [self sendRequestCode:code withCount:innerCount completionHandler:handler];
            }
        }
    }];
}

/**
 发送请求
 
 @param code 指令代号
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    [self sendRequestCode:code data:@(0) completionHandler:handler];
}

/**
 发送请求
 
 @param code 指令代号
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code withDelayMill:(NSInteger)delayMill completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    [self sendRequestCode:code data:@(0) withDelayMill:delayMill completionHandler:handler];
}

/**
 发送请求
 
 @param code 指令代号
 @param data 指令参数
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code data:(NSNumber*)data withDelayMill:(NSInteger)delayMill completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configRequest:request];
    request.delayMillisecond = delayMill;
    [client sendBLERequest:request completionHandler:handler];
    
}
/**
 发送请求
 
 @param code 指令代号
 @param data 指令参数
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configRequest:request];
    [client sendBLERequest:request completionHandler:handler];
    
}

-(void) sendRequestCode:(NSUInteger)code data:(NSNumber*)data noNeedToUpdateDataCache:(BOOL)noNeedToUpdateDataCache completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configRequest:request];
    request.noNeedToUpdateDataCache = noNeedToUpdateDataCache;
    [client sendBLERequest:request completionHandler:handler];
    
}

-(void) sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests completionHandler:(void(^)(BOOL success))completionHandler{
    
    for (ZYBleDeviceRequest *req in requests) {
        [self configRequest:req];
    }
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [client sendRequests:requests completionHandler:completionHandler];
}

-(void)sendDeviceRequest:(ZYBleDeviceRequest *)request{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [self configRequest:request];
    [client sendDeviceRequest:request];
}

// 设置稳定器搭载类型
- (void)setStabilizerCarryDeviceTypeIsMobile:(BOOL)isMobile complete:(void(^)(BOOL success, ZYBlOtherDeviceTypeData *info))complete{
    [self requestStabilizerCarryDeviceInfo:ZYBlOtherDeviceOperationSet type:isMobile?ZYBlOtherDeviceTypeMobile:ZYBlOtherDeviceTypeCamera complete:complete];
}

// 获取稳定器搭载类型
- (void)getStabilizerCarryDeviceType:(void(^)(BOOL success, ZYBlOtherDeviceTypeData *info))complete{
    [self requestStabilizerCarryDeviceInfo:ZYBlOtherDeviceOperationGet type:ZYBlOtherDeviceTypeCamera complete:complete];
}

- (void)requestStabilizerCarryDeviceInfo:(NSUInteger)direct type:(NSUInteger)type complete:(void(^)(BOOL success, ZYBlOtherDeviceTypeData *info))complete{
    ZYBlOtherDeviceTypeData *data = [[ZYBlOtherDeviceTypeData alloc] init];
    data.direct = direct;
    data.type = type;
    [data createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
    [self configRequest:request];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherDeviceTypeData *innaData = param;
            NSLog(@"设备类型type = %ld direct =%ld请求成功", innaData.type,innaData.direct);
            complete(YES, param);
        } else {
            NSLog(@"设备类型%@请求失败", param);
            complete(NO, nil);
        }
    }];
}

// 检验是否支持该格式
- (void)checkJsonFileFormatAvalueble:(ZYBlOtherCustomFileDataFormat)format direct:(int)direct complete:(ZYFileRequestResultBlock)complete{
    // 第一步：发送 page==0xffff，查询是否支持 support 格式
    
    
    ZYBlOtherCustomFileData *info = [ZYBlOtherCustomFileData dataWithPage:ZYBlOtherCustomFileData_CODE_AUTHCHECK direction:direct dataType:format];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        switch (state) {
            case ZYBleDeviceRequestStateResponse:
            {
                ZYBlOtherCustomFileData *innaData = param;
                NSLog(@"查询是否支持support =%d %d", innaData.isSupport,format);
                if (innaData.isSupport) {
                    BLOCK_EXEC(complete, YES, @"有权限");
                }else{
                    BLOCK_EXEC(complete, YES, @"无权限");
                }
            }
                break;
            case ZYBleDeviceRequestStateTimeout:{
                BLOCK_EXEC(complete, NO, @"超时");
            }
                break;
            case ZYBleDeviceRequestStateFail:{
                BLOCK_EXEC(complete, NO, @"校验失败");
            }
                break;
            default:{
                BLOCK_EXEC(complete, NO, @"未知错误");
            }
                break;
        }
    }];
}

// 检验是否支持该格式，若通过则获取json数据
- (void)queryJsonFileIfFormatAvalueble:(ZYBlOtherCustomFileDataFormat)format complete:(ZYFileRequestResultBlock)complete{
    // 第一步：发送 page==0xffff，查询是否支持 support 格式
    [self checkJsonFileFormatAvalueble:format direct:1 complete:^(BOOL success, id info) {
        if (success) {
            [self requestAvalueble:format jsonFilePageCount:complete];
        }else{
            BLOCK_EXEC(complete, NO, @"APP查询JSON文件失败");
        }
    }];
}

// 第二步：获取有多少页数据
- (void)requestAvalueble:(ZYBlOtherCustomFileDataFormat)format jsonFilePageCount:(ZYFileRequestResultBlock)complete{
    
    [self requestJsonFile:ZYBlOtherCustomFileData_CODE_PAGEINFO format:format complete:^(ZYBleDeviceRequestState state, id param) {
        NSLog(@"请求个数");
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCustomFileData *innaData = param;
            // 检测是否有数据（页数大于0）
            if (innaData.count > 0) {
                // 第三步：从第一页请求数据
                self.requestJsonFilePageBlock(1, innaData.count, [NSMutableData data], 3, complete);
            }else{
                BLOCK_EXEC(complete, NO, @"APP查询JSON文件：数据为空");
            }
        }else if (state == ZYBleDeviceRequestStateTimeout){
            BLOCK_EXEC(complete, NO, @"APP查询JSON文件超时");
        }else{
            BLOCK_EXEC(complete, NO, @"APP查询JSON文件失败");
        }
    }];
}


/**
 获取page数据
 step:当前请求页数
 pageCount：页码总数
 fileData：获取到的数据（每个step请求成功后会后面追加）
 reSendNum：允许重发次数，示例 3：表示允许重发3次，加上开始的1次最多会发4次
 */
- (void (^)(int step, NSInteger pageCount, NSMutableData *fileData, NSUInteger reSendNum, ZYFileRequestResultBlock completeBlock))requestJsonFilePageBlock{
    return ^(int step, NSInteger pageCount, NSMutableData *fileData, NSUInteger reSendNum, ZYFileRequestResultBlock completeBlock){
        if ((step < 1) || (step > pageCount) || (reSendNum < 0)) {
            BLOCK_EXEC(completeBlock, NO, @"APP查询JSON文件失败");
            return;
        }
        [self requestJsonFile:step complete:^(ZYBleDeviceRequestState state, id param1) {
            //            NSLog(@"获取json数据   \n页码：%d\n页码总数：%ld\n当前页码剩余重发次数：%ld\n请求状态:%ld\n请求结果：%@", step, pageCount, reSendNum, state, param1);
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlOtherCustomFileData *innaData = param1;
                [fileData appendData:innaData.data];
                if (step == pageCount) {
                    NSMutableData *data = [[NSMutableData alloc] initWithData:fileData];
                    BYTE byte[1];
                    byte[0] = 0x00;
                    [data appendData:[NSData dataWithBytes:byte length:1]];
                    //                    NSLog(@"收到 =%@",data);
                    NSString *jsonStr = [NSString stringWithFormat:@"%s",data.bytes];
                    //                    NSLog(@"jsonStr =%@",jsonStr);
                    
                    NSData *originData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                    //                    NSLog(@"originData =%@",originData);
                    
                    NSError *error;
                    NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:originData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&error];
                    if (!error && completeBlock) {
                        completeBlock(YES, retDict);
                    }else{
                        completeBlock(NO, @"解析失败");
                    }
                } else {
                    self.requestJsonFilePageBlock(step+1, pageCount, fileData, 3, completeBlock);
                }
            } else {
                // 这里处理重新获取逻辑
                if (reSendNum > 0) {
                    self.requestJsonFilePageBlock(step, pageCount, fileData, (reSendNum-1), completeBlock);
                }else{
                    if (state == ZYBleDeviceRequestStateTimeout){
                        BLOCK_EXEC(completeBlock, NO, @"APP查询JSON文件超时");
                    }else{
                        BLOCK_EXEC(completeBlock, NO, @"APP查询JSON文件失败");
                    }
                }
            }
        }];
    };
}

- (void)requestJsonFile:(int)page complete:(void(^)(ZYBleDeviceRequestState state, id param))complete{
    [self requestJsonFile:page format:ZYBlOtherCustomFileDataFormatSupport complete:complete];
}

- (void)requestJsonFile:(int)page format:(ZYBlOtherCustomFileDataFormat)format complete:(void(^)(ZYBleDeviceRequestState state, id param))complete{
    ZYBlOtherCustomFileData *info = [ZYBlOtherCustomFileData dataWithPage:page direction:1 dataType:format];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:complete];
}

- (void)sendJsonFileData:(id)fileInfo format:(ZYBlOtherCustomFileDataFormat)format complete:(ZYFileRequestResultBlock)complete{
    BOOL infoIsValuable = ([fileInfo isKindOfClass:[NSDictionary class]]
                           || [fileInfo isKindOfClass:[NSData class]]
                           || [fileInfo isKindOfClass:[NSArray class]]
                           || [fileInfo isKindOfClass:[NSString class]]);
    NSAssert(infoIsValuable, @"fileInfo 数据格式异常");
    
    // 第一步：发送 page==0xffff，查询是否支持 support 格式
    [self checkJsonFileFormatAvalueble:format direct:0 complete:^(BOOL success, id info) {
        if (success) {// 获取待发送的data
            NSData *fileData = [ZYDeviceStabilizer formatFileDataToBeSend:fileInfo];
            NSInteger lenth = [ZYDeviceStabilizer lenthWithFileInfo:fileInfo];
            NSLog(@"待发送的data数据:%@", fileData);
            
            // 数据不为空则开始发送
            if (fileData.length > 0) {
                // 第二步：发送页数
                ZYBlOtherCustomFileData *subDataInfo = [ZYBlOtherCustomFileData dataForSendLengthInfo:lenth];
                ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:subDataInfo];
                [self configRequest:requestInfo];
                [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param){
                    NSLog(@"设置页码: 请求状态:%ld   请求结果：%@", state, param);
                    if (state == ZYBleDeviceRequestStateResponse) {
                        // 第三步：发送数据
                        self.sendJsonFilePageBlock(0, fileData, 3, complete);
                    } else {
                        
                    }
                }];
            }
        }else{
            BLOCK_EXEC(complete, NO, @"APP查询JSON文件失败");
        }
    }];
}

- (void (^)(int step, NSData *fileData, NSUInteger reSendNum, ZYFileRequestResultBlock completeBlock))sendJsonFilePageBlock{
    return ^(int step, NSData *fileData, NSUInteger reSendNum, ZYFileRequestResultBlock completeBlock){
        // 处理异常、边界情况
        if (step >= fileData.length/10) {
            return;
        }
        NSUInteger subDataLength = 10;
        NSUInteger subDataLocation = (step)*subDataLength;
        NSData *subData = [fileData subdataWithRange:NSMakeRange(subDataLocation, subDataLength)];
        ZYBlOtherCustomFileData *subDataInfo = [ZYBlOtherCustomFileData dataForSendWithPage:(step+1) data:subData];
        ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:subDataInfo];
        [self configRequest:requestInfo];
        [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param){
            NSLog(@"发送json数据 页码：%d\n当前页码剩余重发次数：%ld\n请求状态:%ld\n请求结果：%@", step, reSendNum, state, param);
            if (state == ZYBleDeviceRequestStateResponse) {
                if(step == (fileData.length/10-1)){
                    BLOCK_EXEC(completeBlock, YES, @"JSON文件发送成功");
                } else {
                    self.sendJsonFilePageBlock(step+1, fileData, 3, completeBlock);
                }
            } else {
                // 这里处理重新发送逻辑
                if (reSendNum>0) {
                    self.sendJsonFilePageBlock(step, fileData, (reSendNum-1), completeBlock);
                }else{
                    if (state == ZYBleDeviceRequestStateTimeout){
                        BLOCK_EXEC(completeBlock, NO, @"APP设置JSON文件超时");
                    }else{
                        BLOCK_EXEC(completeBlock, NO, @"APP设置JSON文件失败");
                    }
                }
            }
        }];
    };
}

+(NSInteger)lenthWithFileInfo:(id)fileInfo{
    NSMutableData *theData;
    if ([fileInfo isKindOfClass:[NSArray class]] || [fileInfo isKindOfClass:[NSDictionary class]]) {
        theData = [NSJSONSerialization dataWithJSONObject:fileInfo options:NSJSONWritingPrettyPrinted error:nil].mutableCopy;
    } else if ([fileInfo isKindOfClass:[NSString class]]){
        theData = [((NSString *)fileInfo) dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
    } else if ([fileInfo isKindOfClass:[NSData class]]){
        theData = ((NSData *)fileInfo).mutableCopy;
    } else{
        return 0;
    }
    return theData.length;
    
}

+ (NSData *)formatFileDataToBeSend:(id)fileInfo{
    NSUInteger dataWidth = 10;
    NSMutableData *theData;
    if ([fileInfo isKindOfClass:[NSArray class]] || [fileInfo isKindOfClass:[NSDictionary class]]) {
        theData = [NSJSONSerialization dataWithJSONObject:fileInfo options:NSJSONWritingPrettyPrinted error:nil].mutableCopy;
    } else if ([fileInfo isKindOfClass:[NSString class]]){
        theData = [((NSString *)fileInfo) dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
    } else if ([fileInfo isKindOfClass:[NSData class]]){
        theData = ((NSData *)fileInfo).mutableCopy;
    } else{
        return nil;
    }
    
    NSUInteger dataLength = theData.length;
    // data数组数量
    NSUInteger dataCount = dataLength/dataWidth;
    // 需要后面追加补零的数量
    NSUInteger needAppendLength = 0;
    if (dataLength%dataWidth > 0) {
        dataCount += 1;
        needAppendLength = dataWidth-dataLength%dataWidth;
    }
    if (needAppendLength > 0) {
        for (NSUInteger idx = 0; idx < needAppendLength; idx++) {
            Byte byte[1];
            byte[0] = 0x00;
            [theData appendData:[NSData dataWithBytes:byte length:1]];
        }
    }
    return theData;
}

-(void)querySubTypeConnectionWithCount:(int)count Complete:(void(^)(BOOL success, ZYBlOtherSyncData *info))complete{
    __block int innerCount = count -1;
    @weakify(self);
    [self p_querySubTypeConnectionComplete:^(BOOL success, ZYBlOtherSyncData *info) {
        @strongify(self);
        if (success) {
            if (complete) {
                complete(YES,info);
            }
        }
        else{
            if (innerCount > 0) {
                [self querySubTypeConnectionWithCount:innerCount Complete:complete];
            }
            else{
                if (complete) {
                    complete(NO,nil);
                }
            }
            
        }
    }];
    
}
-(void)querySubTypeConnectionComplete:(void(^)(BOOL success, ZYBlOtherSyncData *info))complete{
    [self querySubTypeConnectionWithCount:3 Complete:complete];
}


-(void)p_querySubTypeConnectionComplete:(void(^)(BOOL success, ZYBlOtherSyncData *info))complete{
    ZYBlOtherSyncData *synData = [[ZYBlOtherSyncData alloc] init];
    synData.messageId = 1;
    synData.idx = 0;
    [synData createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:synData];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    @weakify(self)
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherSyncData *innaData = param;
            if (complete) {
                [self.otherSynData doUpdateValueWith:innaData];
                complete(YES,innaData);
            }
        } else {
            if (complete) {
                complete(NO,nil);
            }
        }
    }];
}
/**
 设置所搭载相机厂商
 
 @param type 相机厂商
 */
- (void)setRXCameraManufacturer:(ZYBl_CameraManufactureType)type complete:(ZYFileRequestResultBlock)complete{
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    ZYBlWiFiPhotoCameraInfoData *info = [ZYBlWiFiPhotoCameraInfoData dataForSetManufacturer:type];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        BOOL isValidResponseParam = [param isKindOfClass:[ZYBlWiFiPhotoCameraInfoData class]];
        if ((state == ZYBleDeviceRequestStateResponse) && isValidResponseParam) {
            ZYBlWiFiPhotoCameraInfoData *innaData = param;
            NSLog(@"设置所搭载相机类型   == flag = %d value =%d", innaData.flag,innaData.value);
            if ((innaData.value > 1) && (innaData.value <= ZYBl_CameraManufactureTypeCount)) {
                complete(YES, @(innaData.value));
            } else {
                complete(NO, @(0));
            }
        } else {
            NSLog(@"设备类型%@请求失败", param);
            if (complete) {
                complete(NO, @"请求失败");
            }
        }
    }];
}


/**
 获取所搭载相机厂商
 */
- (void)getRXCameraManufacturerWithComplete:(ZYFileRequestResultBlock)complete{
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:[ZYBlWiFiPhotoCameraInfoData dataForGetManufacturer]];
    [self configRequest:requestInfo];
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        BOOL isValidResponseParam = [param isKindOfClass:[ZYBlWiFiPhotoCameraInfoData class]];
        if ((state == ZYBleDeviceRequestStateResponse) && isValidResponseParam) {
            ZYBlWiFiPhotoCameraInfoData *innaData = param;
            //            NSLog(@"获取所搭载相机厂商 ===  flag = %d value =%d请求成功", innaData.flag,innaData.value);
            if ((innaData.value > 0) && (innaData.value <= ZYBl_CameraManufactureTypeCount)) {
                complete(YES, @(innaData.value));
            } else {
                complete(NO, @(0));
            }
        } else {
            NSLog(@"设备类型%@请求失败", param);
            complete(NO, @0);
        }
    }];
}

-(BOOL)p_isCCSQueryBaseMessage{
    if ([self.modelNumberString isEqualToString:modelNumberImageTransBox]) {
        return YES;
    }
    else{
        return NO;
    }
}

-(void)setWorkingState:(NSInteger)workingState{
    [super setWorkingState:workingState];
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWorkingStateChange object:nil];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kWorkingStateChange object:nil];
        });
    }
    
}

-(void)p_doHidHeart{
    if ([self supportBle_Hid] > Ble_hidTypeNoSupport) {
        if (self.hardwareUpgradeManager.upgardeStatus >= ZYUpgradeStatusUpgardeing) {
            //升级不需要发送
            return;
        }
        ZYBlOtherHeart *heart = [[ZYBlOtherHeart alloc] init];
        if (self.enableHearOther) {
            heart.heartType = ZYBlOtherHeartTypeDirectOnly;
        }
        else{
            heart.heartType = ZYBlOtherHeartTypeOrigion;
        }
        [heart createRawData];
        ZYBleMutableRequest* requestHeart = [[ZYBleMutableRequest alloc] initWithZYControlData:heart];
        [self configRequest:requestHeart];
        ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
        @weakify(self)
        requestHeart.delayMillisecond = 20;
        [client sendMutableRequest:requestHeart completionHandler:^(ZYBleDeviceRequestState state, id param) {
            @strongify(self)
            
            CGFloat time = 0.5;
            if ([self.modelNumberString isEqualToString:modelNumberCrane3S]) {
                time = 1.2;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                [self p_doHidHeart];
            });
            
        }];
    }
    
}

-(void)p_doInitSupportValueWithNumber:(NSUInteger)modelNumber{
    _functionModel = [[ZYProductSupportFunctionManager defaultManager] modelWithProductId:modelNumber];
    [self querySupportFile];
    if ([self supportBle_Hid]) {
        [self p_doHidHeart];
    }
}

-(void)setModelNumber:(NSUInteger)modelNumber{
    BOOL needInit = NO;
    if (_modelNumber != modelNumber) {
        needInit = YES;
    }
    _modelNumber = modelNumber;
    if (needInit) {
        [self p_doInitSupportValueWithNumber:modelNumber];
    }
    
}

-(NSString *)displaySoftwareVersion{
    
    return [ZYStabilizerTools softwareVersionForDisplay:[ZYDeviceManager defaultManager].stablizerDevice.softwareVersion];
}

#pragma -mark 获取进入之后的的参数
-(void)p_doSubaccessoriesQuery{
    
    if ([self.otherSynData imageBoxIsSubDevice]) {
        if (_accessory == nil) {
            _accessory = [[ZYDeviceAccessories alloc] init];
        }
        @weakify(self)
        if ([[ZYDeviceManager defaultManager].modelNumberString isEqualToString:modelNumberImageTransBox]) {
            [self sendRequestCode:ZYBleInteractCodeDeviceCategory_R data:@(0) noNeedToUpdateDataCache:YES completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                @strongify(self)
                self.accessory.modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:param];
                self.accessory.modelNumber = param;
                [self queryBatteryWithRepeatCount:1 completed:^{
                    
                }];
                [self querySupportFile];
            }];
        }
        else  if ([ZYBleDeviceDataModel likeWeebillsWithString:[ZYDeviceManager defaultManager].modelNumberString]) {
            [self.cameraWifiManager.cameraData getCameraDataWithNum:ZYCameraWifiDeviceCategory_R withCount:3 completionHandler:^(ZYBleDeviceRequestState state, id param) {
                @strongify(self)
                ZYBlCCSGetConfigData* blCCSGetConfigDataRespond = (ZYBlCCSGetConfigData*)param;
                NSString *str = blCCSGetConfigDataRespond.value;
                if (state == ZYBleDeviceRequestStateResponse) {
                    if (blCCSGetConfigDataRespond.idx == ZYCameraWifiDeviceCategory_R) {
                        self.accessory.modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:[str integerValue]];
                        self.accessory.modelNumber = [str integerValue];
                        [self queryBatteryWithRepeatCount:1 completed:^{
                            
                        }];
                        [self querySupportFile];
                    }
                }
            }];
        }
    }
    else{
        self.accessory = nil;
        [self queryBatteryWithRepeatCount:1 completed:^{
            
        }];
    }
    
}

-(void)sendActivateWithActivateState:(ActiveStatue)activeState randomData:(NSData *)randomData activateDate:(NSDate *)activateDate completionHandler:(void (^)(ZYBleDeviceRequestState, ZYBlSendActiveKeyData *))handler{
    if (self.functionModel.activate == ActivateTypeNoSupport && self.functionModel.activateAESkey.length > 0) {
        if (handler) {
            handler(ZYBleDeviceRequestStateFail,nil);
        }
        return;
    }
    NSMutableData *data = [NSMutableData data];
    BYTE byteActive[1] = {activeState};
    [data appendData:[NSData dataWithBytes:byteActive length:1]];
    BYTE byteActiveData[11] = {0};
    if (randomData.length == 11) {
        [data appendData:randomData];
    }
    else{
        [data appendData:[NSData dataWithBytes:byteActiveData length:11]];
    }
    NSInteger datadate = [self getNumberOfDaysOneYear:activateDate];
    
    uint16_t actDate = (20 << 9) + datadate;
    NSData *dataActDate = [NSData dataWithBytes:&actDate length:2];
    
    [data appendData:dataActDate];
    NSData *crcData = [self crc16WithDaya:data];
    [data appendData:crcData];
    [self sendActivateWithString:data completionHandler:handler];
}
- (NSData*)crc16WithDaya:(NSData *)data{
    const uint8_t *byte = (const uint8_t *)data.bytes;
    uint16_t length = (uint16_t)data.length;
    uint16_t res =  gen_crc16(byte, length);
    NSData *val = [NSData dataWithBytes:&res length:sizeof(res)];
    return val;
}

#define PLOY 0X1021

uint16_t gen_crc16(const uint8_t *data, uint16_t size) {
    uint16_t crc = 0;
    uint8_t i;
    for (; size > 0; size--) {
        crc = crc ^ (*data++ <<8);
        for (i = 0; i < 8; i++) {
            if (crc & 0X8000) {
                crc = (crc << 1) ^ PLOY;
            }else {
                crc <<= 1;
            }
        }
        crc &= 0XFFFF;
    }
    return crc;
}

#pragma mark - 获取某个日期所在年份的天数
-(NSInteger)getNumberOfDaysOneYear:(NSDate *)date{
    NSDateComponents*comps;
    NSCalendar *calender = [NSCalendar currentCalendar];
    comps =[calender components:(NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday |NSCalendarUnitWeekdayOrdinal|NSCalendarUnitDay|NSCalendarUnitHour) fromDate:date];
    NSInteger week = [comps weekOfYear]; // 今年的第几周
    NSInteger weekday = [comps weekday];
    
#pragma -mark 某一年的多少天
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&firstDay interval:nil forDate:date];
    NSDateComponents*compsFF =[calender components:(NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday |NSCalendarUnitWeekdayOrdinal|NSCalendarUnitDay|NSCalendarUnitHour) fromDate:firstDay];
    NSInteger weekdayFirst = [compsFF weekday];
    
    if (week >= 2) {
        return (week - 2)* 7 + (7 - weekdayFirst + 1)  + (weekday);
    }
    else{
        return weekday - weekdayFirst + 1;
    }
    
    //        NSRange range = [calender rangeOfUnit:NSCalendarUnitDay
    //                                   inUnit: NSCalendarUnitYear
    //                                  forDate: date];
    //        return range.length;
}

-(void)sendActivateWithString:(NSData *)keyData completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYBlSendActiveKeyData *sendData))handler{
    if (self.functionModel.activate == ActivateTypeNoSupport && self.functionModel.activateAESkey.length > 0) {
        if (handler) {
            handler(ZYBleDeviceRequestStateFail,nil);
        }
        return;
    }
    ZYBlSendActiveKeyData *activData = [[ZYBlSendActiveKeyData alloc] init];
    
    activData.keyData = [self.functionModel encodeEncrypt:keyData];
    @weakify(self);
    [self sendMutableRequest:activData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlSendActiveKeyData class]]) {
                self.activeState = [(ZYBlSendActiveKeyData *)param activeStatue];
                if (handler) {
                    handler(state,param);
                }
                return;
            }
        }
        if (handler) {
            handler(state,nil);
        }
    }];
}


-(void)checkActivateCompletionHandler:(void(^)(BOOL needActivate,ZYBleDeviceRequestState state, ZYBlCheckActiveInfoData *checkActive))handler{
    [self checkActivateWithCount:3 completionHandler:handler];
}

-(void)checkActivateWithCount:(int)count completionHandler:(void(^)(BOOL needActivate,ZYBleDeviceRequestState state, ZYBlCheckActiveInfoData *checkActive))handler{
    if (self.functionModel.activate == ActivateTypeNoSupport) {
        self.activeState = ActiveStatueActive;
        if (handler) {
            handler(NO,ZYBleDeviceRequestStateFail,nil);
        }
        return;
    }
    ZYBlCheckActiveInfoData *activData = [[ZYBlCheckActiveInfoData alloc] init];
    __block int blockCount = count;
    @weakify(self);
    [self sendMutableRequest:activData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlCheckActiveInfoData class]]) {
                ZYBlCheckActiveInfoData *ttData = (ZYBlCheckActiveInfoData *)param;
                if (ttData.activedata.length >= 16) {
                    ttData.activedataDecode = [self.functionModel decodeEncrypt:ttData.activedata];
                    self.activeState = ttData.activeStatue;
                }
                if (handler) {
                    handler(YES,state,ttData);
                }
                return;
            }
        }
        if (blockCount <=1) {
            if (handler) {
                handler(YES,state,nil);
            }
        }
        else{
            [self checkActivateWithCount:blockCount - 1 completionHandler:handler];
        }
        
    }];
}


-(void) sendMutableRequest:(ZYControlData*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler
{
    [request createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:request];
    [self configRequest:requestInfo];
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:requestInfo completionHandler:handler];
}
-(void)begainOneStepCalibrationCompletionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    [self sendRequestCode:ZYBleOneStepCalibration data:@(ZYBleOneStepCalibrationTypeBegain) completionHandler:handler];
}

-(void)endOneStepCalibrationCompletionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    [self sendRequestCode:ZYBleOneStepCalibration data:@(ZYBleOneStepCalibrationTypeEnd) completionHandler:handler];
}

-(void)enableLandscape:(BOOL)enableLandscape completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    ZYBleScapeCaptureCalibrationType type = ZYBleScapeCaptureCalibrationTypeLandscape;
    if (enableLandscape) {
        type = ZYBleScapeCaptureCalibrationTypeLandscape;
    }
    else{
        type = ZYBleScapeCaptureCalibrationTypePortait;
    }
    [self sendRequestCode:ZYBleLandscapeOrPortaitCalibration data:@(type) completionHandler:handler];
    
}

-(void)setContextualModel:(ZYBleContextualModelType)type completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    [self sendRequestCode:ZYBleContextualModel_W data:@(type) completionHandler:handler];
}

-(void)readContextualModelCompletionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    [self sendRequestCode:ZYBleContextualModel_R data:@(0) completionHandler:handler];
}
-(void)setControlSpeedDirect:(ZYBleControlSpeedDirectType)type completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    [self sendRequestCode:ZYBleControlSpeedDirect_W data:@(type) completionHandler:handler];
}

-(void)readControlSpeedDirectCompletionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    [self sendRequestCode:ZYBleControlSpeedDirect_R data:@(0) completionHandler:handler];
}

/// trackmode的设置和读取
/// @param isRead 0 读取 1 设置
/// @param trackMode 0 关闭 1 开启，当isRead == 0时候，无意义
/// @param handler 回调用
-(void)trackModeIsRead:(BOOL)isRead trackMode:(int)trackMode completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYCMDTrackingModeData *data))handler{
    ZYCMDTrackingModeData *trackingModeData = [[ZYCMDTrackingModeData alloc] init];
    trackingModeData.mode = trackMode;
    trackingModeData.direct = !isRead;
    
    @weakify(self);
     [self sendMutableRequest:trackingModeData completionHandler:^(ZYBleDeviceRequestState state, id param) {
         @strongify(self);
         if (state == ZYBleDeviceRequestStateResponse) {
             if ([param isKindOfClass:[ZYCMDTrackingModeData class]]) {
                 if (handler) {
                     handler(state,param);
                 }
                 return;
             }
         }
         if (handler) {
             handler(state,nil);
         }
     }];
}

/// trackAnchor的设置和读取
/// @param isRead 0 读取 1 设置
/// @param anchorX 喵点的X 0 当isRead == 0时候，无意义
/// @param anchorY 喵点的Y 0 当isRead == 0时候，无意义
/// @param handler 回调用
-(void)trackAnchorIsRead:(BOOL)isRead anchorX:(int)anchorX anchorY:(int)anchorY completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYCMDTrackingAnchorData *data))handler{
     ZYCMDTrackingAnchorData *trackingAnchorData = [[ZYCMDTrackingAnchorData alloc] init];
     trackingAnchorData.x  = anchorX;
     trackingAnchorData.y  = anchorY;
     trackingAnchorData.direct = !isRead;

     @weakify(self);
      [self sendMutableRequest:trackingAnchorData completionHandler:^(ZYBleDeviceRequestState state, id param) {
          @strongify(self);
          if (state == ZYBleDeviceRequestStateResponse) {
              if ([param isKindOfClass:[ZYCMDTrackingAnchorData class]]) {
                  if (handler) {
                      handler(state,param);
                  }
                  return;
              }
          }
          if (handler) {
              handler(state,nil);
          }
      }];
}

-(void)pitchPowerSetOrRead:(BOOL)isRead value:(int)value completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    if (isRead) {
        [self sendRequestCode:ZYBlePitchPowerSet_R data:@(0) completionHandler:handler];
    }
    else{
        [self sendRequestCode:ZYBlePitchPowerSet_W data:@(value) completionHandler:handler];
    }
}

-(void)rollPowerSetOrRead:(BOOL)isRead value:(int)value completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler
{
    if (isRead) {
       [self sendRequestCode:ZYBleRollPowerSet_R data:@(0) completionHandler:handler];
   }
   else{
       [self sendRequestCode:ZYBleRollPowerSet_W data:@(value) completionHandler:handler];
   }
}
-(void)yawPowerSetOrRead:(BOOL)isRead value:(int)value completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
     if (isRead) {
        [self sendRequestCode:ZYBleYawPowerSet_R data:@(0) completionHandler:handler];
    }
    else{
        [self sendRequestCode:ZYBleYawPowerSet_W data:@(value) completionHandler:handler];
    }
}
@end
