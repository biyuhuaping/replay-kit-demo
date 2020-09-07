//
//  ZYDeviceManager.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/19.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceManager.h"
#import "ZYStabilizerConnectManager.h"
#pragma -mark 本地化去掉
//#import "ZYCustomerHabbitTool.h"
//#import "NSDate+Extension.h"
#import "UIDevice+WifiOpened.h"
#define ZWBIdentifier @"ZW-B"
//#import "ZYStabilizerConnectManager.h"
NSString * const ConnectLinkChange = @"ConnectLinkChange";

@interface ZYDeviceManager()

//@property(nonatomic,strong)ZYCustomerHabbitModel *mod;

@property (nonatomic, strong) ZYBleManager   *bleManager;//蓝牙扫描连接的类

@property (nonatomic, strong) ZYBleDeviceInfo *workDeviceInfo;//连接过的设备，只对支持Wi-Fi的设备使用

@property (nonatomic, strong) NSDate         *rdisDate;
@property (nonatomic, strong) NSTimer        *rdisRunTime;
@property (nonatomic)         BOOL           timeRun;

@end


@implementation ZYDeviceManager


static  ZYDeviceManager  *shareSingleton = nil;

-(ZYHardwareUpgradeManager *)upgradeManager{
    if (self.stablizerDevice) {
        return self.stablizerDevice.hardwareUpgradeManager;

    }else if (self.remoteControlDevice){
        return self.remoteControlDevice.hardwareUpgradeManager;

    }
    return nil;
}

-(ZYBleManager *)bleManager{
    if (_bleManager == nil) {
        _bleManager = [ZYBleManager bleManagerWithBleConnection:[ZYBleDeviceClient defaultClient].stablizerConnection] ;
    }
    return _bleManager;
}

+( instancetype ) defaultManager{
    static  dispatch_once_t  onceToken;
    dispatch_once ( &onceToken, ^ {

        shareSingleton  =  [[super allocWithZone:NULL] init] ;
        shareSingleton.connectType = ZYConnectTypeBle;
        [shareSingleton addNoti];
    } );
    return shareSingleton;
}

- (BOOL)isConnected{

    return self.bleManager.curDeviceInfo || self.stablizerDevice.cameraWifiManager.isWifiReady == ZYWifiStatusIsReady;
}

+(id) allocWithZone:(struct _NSZone *)zone {

    return [self defaultManager] ;

}

-(id) copyWithZone:(struct _NSZone *)zone {

    return [ZYDeviceManager defaultManager]  ;

}

-(void)wifiMessage:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYDC_CameraArgumentCallback]) {
        id obj = [noti.userInfo objectForKey:@"type"];
        if ([obj isKindOfClass:[NSNumber class]]) {
            ZYCameraWifiParaCode code = (ZYCameraWifiParaCode)[obj integerValue];
            if (code == ZYCameraWifiParaCodeCameraName) {
                NSString *str = self.stablizerDevice.cameraWifiManager.cameraData.cameraName;
                if (str.length > 0) {
                    _stablizerDevice.connectedDeviceInfo.camera = str;
                    [self p_doUpdateConnectMessage];
//                    self.mod.camera = self.stablizerDevice.cameraWifiManager.cameraData.cameraName;
                }
            } else {
            }
        } else {

        }
        
        
    }
}

-(void)p_doUpdateConnectMessage{
    if (_stablizerDevice.connectedDeviceInfo) {
        [[ZYConnectedDeviceInfoDataBase sharedDataBase] updateConnectedDeviceInfo:_stablizerDevice.connectedDeviceInfo];
    }
    if (_updateConnectMessageBlock) {
        _updateConnectMessageBlock();
    }
}

-(void)sersionNO:(NSNotification *)noti{
    if (self.stablizerDevice.serialNo.length > 0) {
        _stablizerDevice.connectedDeviceInfo.serial_num = self.stablizerDevice.serialNo;
        [self p_doUpdateConnectMessage];
    }
}

-(void)addNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToUse:) name:Device_PTZReadyToUse object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToUse:) name:Device_PTZOffLine object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToUse:) name:CameraWIFIEnable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiConnectRDISConnect:) name:ZYDeviceRDISReciveNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiMessage:) name:ZYDC_CameraArgumentCallback object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sersionNO:) name:SerialNumberGetNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceDataNoti:) name:kReciveDataNotiName object:nil];

}

-(void)reviceDataNoti:(NSNotification *)noti{
    if (_stablizerDevice.workingState == 1 && _stablizerDevice.connectedDeviceInfo) {
        
        [[ZYConnectedDeviceInfoDataBase sharedDataBase] updateConnectedDeviceInfo:_stablizerDevice.connectedDeviceInfo];
    }
}

-(void)enterForeground{
    if (self.rdisDate) {
        self.rdisDate = [NSDate date];
    }
}

-(void)enterBackground{
    if (self.rdisDate) {
        self.rdisDate =  [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 3];
    }
}



-(void)wifiConnectRDISConnect:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYDeviceRDISReciveNoti]) {
        if (self.stablizerDevice.cameraWifiManager.wifiEnable) {
            self.rdisDate = [NSDate date];
            [self startTimer];
            
        }
        
    }
}

-(void)startTimer{
    if (!self.timeRun) {
        [self endTimer];
        [[NSRunLoop mainRunLoop] addTimer:self.rdisRunTime forMode:NSRunLoopCommonModes];
        self.timeRun = YES;
    }
}

-(void)endTimer{
    [_rdisRunTime invalidate];
    _rdisRunTime = nil;
    _timeRun = NO;
    _rdisDate = nil;
}
-(NSTimer *)rdisRunTime{
    if (_rdisRunTime == nil) {
        _rdisRunTime = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerUp:) userInfo:nil repeats:YES];
    }
    return _rdisRunTime;
}

-(void)timerUp:(NSTimer *)timer{
#pragma -mark监测网络断开的处理
    if (self.enableOnlyWifi && self.stablizerDevice.cameraWifiManager.wifiEnable) {

        if (![self.stablizerDevice.cameraWifiManager checkWifiSustain]) {
            [ZYDeviceManager defaultManager].stablizerDevice.cameraWifiManager.wifiEnable = NO;
            [self endTimer];
            return;
        }
    }
    
    if (self.rdisDate && [[NSDate date] timeIntervalSinceDate:self.rdisDate] > 3.5) {
        if ([self.stablizerDevice.cameraWifiManager checkWifiSustain]) {
            self.rdisDate = [NSDate date];

        }
        else{
            if (!self.deviceReady) {
                if (self.enableOnlyWifi || self.stablizerDevice.hardwareUpgradeManager.isUpgradeing || self.remoteControlDevice.hardwareUpgradeManager.isUpgradeing) {
                    if (self.enableOnlyWifi) {
                        [ZYDeviceManager defaultManager].stablizerDevice.cameraWifiManager.wifiEnable = NO;
                        [self endTimer];
                    }
                    
                }
                else{
                    [self disconnectDevice:^{
                        
                    }];
                }
               
            }else{
                self.rdisDate = [NSDate date];
            }
        }
       
    }
}

/**
 切换到ble连接
 return BLE是否Ready
 */
-(BOOL)changToBlConnect{
    self.connectType = ZYConnectTypeBle;
    [[ZYBleDeviceClient defaultClient] pauseReceiving];
    self.stablizerDevice.cameraWifiManager.wifiEnable = NO;
    BOOL isReady = self.bleManager.deviceReady;
    if (!isReady) {
        [self disconnectDevice:^{
            
        }];
    }
    [self endTimer];
    return isReady;
    
}

-(void)readyToUse:(NSNotification *)noti{
    if ([noti.name isEqualToString:Device_PTZReadyToUse]) {
        if ([self.modelNumberString isEqualToString:modelNumberImageTransBox]) {
            return ;
        }
        if ([ZYCameraWiFIManager supportCameraSetting]) {
            self.workDeviceInfo = self.bleManager.curDeviceInfo;
        }
        else{
            self.workDeviceInfo = nil;
        }
    }
    else if ([noti.name isEqualToString:Device_PTZOffLine]) {
        self.workDeviceInfo = nil;
    }
    else if ([noti.name isEqualToString:CameraWIFIEnable]) {
       BOOL wifiEnable =  [[noti.userInfo objectForKey:CameraWIFIEnable] boolValue];
        if (wifiEnable) {
            if (self.enableOnlyWifi) {
                self.connectType = ZYConnectTypeOnlyWifi;
            }
            else{
                self.connectType = ZYConnectTypeBleAndWifi;
            }
        }
        
    }
}

-(void)setEnableOnlyWifi:(BOOL)enableOnlyWifi{
    
    if (_enableOnlyWifi != enableOnlyWifi && enableOnlyWifi == NO) {
        if (self.deviceReady == NO && self.stablizerDevice.cameraWifiManager.wifiEnable == NO) {
            [self disconnectDevice:^{
                
            }];
        }
        
    }
    _enableOnlyWifi = enableOnlyWifi;
    if (self.connectType == ZYConnectTypeBleAndWifi) {
        self.connectType = ZYConnectTypeOnlyWifi;
    }
    
    
}

-(BOOL)deviceReady{
    return self.bleManager.deviceReady;
}

-( ZYBleState)deviceState{
    return self.bleManager.deviceState;
}

-(ZYBleDeviceInfo*)curDeviceInfo
{
    if (self.bleManager.curDeviceInfo) {
        return self.bleManager.curDeviceInfo;
    }
    else{
        return self.workDeviceInfo;
    }
}

-(void)setModelNumberString:(NSString *)modelNumberString{
    _modelNumberString = modelNumberString;
    if (_stablizerDevice && _stablizerDevice.workingState == 1 && _modelNumberString != nil) {
        if (_stablizerDevice.dateConnect) {
            NSLog(@"已经加入进去过了");
        }
        else{
            _stablizerDevice.dateConnect = [NSDate date];
            if (self.dicUserMessageBlock) {
                NSDictionary *dic = self.dicUserMessageBlock();
                _stablizerDevice.connectedDeviceInfo = [[ZYConnectedDeviceInfoDataBase sharedDataBase] addDeviceInfoWithUserDic:dic refID:_stablizerDevice.modelNumber deviceName:_stablizerDevice.deviceName ];
            }
            if (_stablizerDevice.dateConnect && _connectMessageBlock) {
                _connectMessageBlock();
            }
        }
    }

}

/**
  扫描蓝牙状态及其周围可用的蓝牙外设

 @param bleStatusHandler 蓝牙状态扫描结果
 @param deviceHandler 周围外设捕获结果
 */
-(void) scanStabalizerDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceStabilizer* deviceInfo))deviceHandler{
    [self.bleManager scanDevice:bleStatusHandler deviceHandler:^(ZYBleDeviceInfo *deviceInfo) {
        if ([deviceInfo.name localizedCaseInsensitiveContainsString:ZWBIdentifier]) {
            return ;
        }
        BLOCK_EXEC(deviceHandler,[ZYDeviceStabilizer deviceBaseWithdDeviceInfo:deviceInfo]);

    }];
}

-(void) scanRemoteControlDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceRemoteControl* deviceInfo))deviceHandler{
    [self.bleManager scanDevice:bleStatusHandler deviceHandler:^(ZYBleDeviceInfo *deviceInfo) {

        if ([deviceInfo.name localizedCaseInsensitiveContainsString:ZWBIdentifier]) {
            BLOCK_EXEC(deviceHandler,[ZYDeviceRemoteControl deviceBaseWithdDeviceInfo:deviceInfo]);
        }
    }];

}

-(void) scanStabalizerAndRemoteControlDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceBase* deviceInfo))deviceHandler{
    [self.bleManager scanDevice:bleStatusHandler deviceHandler:^(ZYBleDeviceInfo *deviceInfo) {
        if ([deviceInfo.name localizedCaseInsensitiveContainsString:ZWBIdentifier]) {
            BLOCK_EXEC(deviceHandler,[ZYDeviceRemoteControl deviceBaseWithdDeviceInfo:deviceInfo]);
        }else{
            BLOCK_EXEC(deviceHandler,[ZYDeviceStabilizer deviceBaseWithdDeviceInfo:deviceInfo]);

        }
    }];


}

-(void)retriveConnecting{
    [self.bleManager  retriveConnecting];
}

-(void) stopScan{
#ifdef DEBUG
    
    NSLog(@"stop scan -xxxxxx");
#endif

    [self.bleManager stopScan];
}

- (void)setConnectType:(ZYConnectType)connectType{
    
    _connectType = connectType;
    if (connectType == ZYConnectTypeOnlyWifi) {
        [self.bleManager disconnectDevice:^{

        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectLinkChange object:nil];
}

-(void) connectDevice:(ZYDeviceBase*) deviceInfo completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler{
    if (self.bleManager.curDeviceInfo) {
        @weakify(self)
        [self disconnectDevice:^{
            @strongify(self)
            [self connectDevice:deviceInfo completionHandler:deviceStatusHandler];
        }];
        return;
    }
    if ([deviceInfo isKindOfClass:[ZYDeviceStabilizer class]]) {
        _stablizerDevice = (ZYDeviceStabilizer *)deviceInfo;
    }else if  ([deviceInfo isKindOfClass:[ZYDeviceRemoteControl class]]) {
        _remoteControlDevice = (ZYDeviceRemoteControl *)deviceInfo;

    }

    

    @weakify(self);
    @weakify(deviceInfo);
    [self.bleManager connectDevice:deviceInfo.deviceInfo completionHandler:^(ZYBleDeviceConnectionState state) {
//        NSLog(@"---回调C:%@  state:%ld",deviceInfo.name,(long)state);
        @strongify(self)
        @strongify(deviceInfo)
        if (state == ZYBleDeviceStateReady) {
//            self.mod = [ZYCustomerHabbitModel new];
//            self.mod.deviceid = [deviceInfo deviceName];
//            self.mod.bts = [[NSDate dateWithTimeIntervalSinceNow:0] stringValue];
            
            [ZYStabilizerConnectManager resetIsNeedAutoConnectFromOrignalName:deviceInfo.deviceName isNeedAutoConnect:YES];
        }else if((state == ZYBleDeviceStateFail) ||(state == ZYBleDeviceStateMissConnected)||(state == ZYBleDeviceStateUnknown)){
            
            if ([ZYCameraWiFIManager supportCameraSetting] && self.connectType >= ZYConnectTypeBleAndWifi) {
                return ;
            }
            [self p_doModUpdate];
            if ([[deviceInfo deviceName] isEqualToString:[self.stablizerDevice deviceName]]) {
                [self clearData];

            }else if ([[deviceInfo deviceName] isEqualToString:[self.remoteControlDevice deviceName]]){
                [self clearData];
            }

            [self postDisconnectNotiAndRecordMod];
        }else if (state == ZYBleDeviceStateConnected){
            [self connectProgress];

        }
        BLOCK_EXEC(deviceStatusHandler,state);
    }];
}

-(void)postDisconnectNotiAndRecordMod{
    [[NSNotificationCenter defaultCenter] postNotificationName:Deivce_Disconnected object:self userInfo:nil];
}

-(void)p_doModUpdate{
    
    if (_stablizerDevice.dateConnect) {
        _stablizerDevice.dateDisconnect = [NSDate date];
        if (_stablizerDevice.connectedDeviceInfo) {
            [[ZYConnectedDeviceInfoDataBase sharedDataBase] updateConnectedDeviceInfo:_stablizerDevice.connectedDeviceInfo];
        }
        if (_disConnectMessageBlock) {
            _disConnectMessageBlock();
            _stablizerDevice.dateConnect = nil;
        }
    }
   
//    if (self.mod) {
//        self.mod.ets = [[NSDate dateWithTimeIntervalSinceNow:0] stringValue];
////        [ZYCustomerHabbitTool updateLocalCustomerHabbit:self.mod];
//        self.mod = nil;
//    }

}

-(void) disconnectDevice:(void (^)(void))handler{
    @weakify(self)
    _connectType = ZYConnectTypeBle;
    [self endTimer];
    [self p_doModUpdate];
    [self.bleManager disconnectDevice:^{
        @strongify(self)
#pragma -mark为什么要把我的注释掉
        [self clearData];

        BLOCK_EXEC(handler);
    }];
}

-(ZYDeviceBase *)connectingDevice{
    if (_stablizerDevice) {
        return _stablizerDevice;
    }else if (_remoteControlDevice){
        return _remoteControlDevice;
    }
    return nil;
}

-(BOOL)isZWB_Device{
    return self.remoteControlDevice;
}

-(NSInteger)workingState{
    if (self.stablizerDevice) {
        return self.stablizerDevice.workingState;
    }else if (self.remoteControlDevice){
        return self.remoteControlDevice.workingState;
    }
    return -1;
}

-(void)clearData{
    //TODO 如果wifi通道是开启状态但是无应答 暂时不认为断开
    if (self.stablizerDevice) {
        if (self.connectType <= ZYConnectTypeBle) {
            [self.stablizerDevice clearDataSource];
            self.stablizerDevice = nil;
            _modelNumberString = nil;
            [[ZYBleDeviceClient defaultClient] pauseReceiving];
        }
    }else if (self.remoteControlDevice){
        [self.remoteControlDevice clearDataSource];
        self.remoteControlDevice = nil;
        _modelNumberString = nil;
    }
}

-(void)connectProgress{
    if (self.stablizerDevice) {
        [self.stablizerDevice connectSetup];
    }else if (self.remoteControlDevice){
        [self.remoteControlDevice connectSetup];

    }
}

-(void)setChoiceConnectType:(ZYChoiceConnectType)choiceConnectType{
    if (choiceConnectType != _choiceConnectType) {
        if (choiceConnectType == ZYChoiceConnectTypeBle) {
            [self disconnectDevice:^{
                
            }];
        }
    }
    
    if (choiceConnectType == ZYChoiceConnectTypeWifi && [ZYDeviceManager defaultManager].stablizerDevice.cameraWifiManager.isWifiReady < ZYWifiStatusIsReady) {
        ZYBleDeviceInfo *info = [[ZYBleDeviceInfo alloc] init];
        info.modelNumberString = modelNumberImageTransBox;
        self.modelNumberString = modelNumberImageTransBox;
        self.workDeviceInfo  = info;
        [info configName:[UIDevice getWifiName]];
        _stablizerDevice = [ZYDeviceStabilizer deviceBaseWithdDeviceInfo:info];
        self.connectType = ZYConnectTypeOnlyWifi;
        [_stablizerDevice connectSetup];
    }
    
    
    _choiceConnectType = choiceConnectType;
}
@end
