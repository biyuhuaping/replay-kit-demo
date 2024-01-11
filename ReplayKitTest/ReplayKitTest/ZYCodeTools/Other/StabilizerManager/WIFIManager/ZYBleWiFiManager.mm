//
//  ZYBleWiFiManager.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/6/6.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleWiFiManager.h"

#import "ZYBlWiFiStatusData.h"
#import "ZYBlWiFiScanData.h"
#import "ZYBlWiFiConnectionData.h"
#import "ZYBlWiFiPhotoInfoData.h"
#import "ZYBlWiFiPhotoParamData.h"
#import "ZYBlWiFiPhotoAllParamData.h"
#import "ZYBlWiFiPhotoCtrlData.h"
#import "ZYBlWiFiDisconnetData.h"
#import "ZYBlWiFiDevCleanData.h"
#import "ZYMessageTool.h"
#include "ParamDef.h"
//#import "SPCConfiguration.h"
#import "ZYGOPROData.h"
//#import "SPCCommandDefine.h"
#import "SPCParameterLanguageDes.h"

using namespace zy::SportCamera;


typedef NSString * WiFiModeSettingCommand NS_STRING_ENUM;
static WiFiModeSettingCommand const WiFiModeSettingCommandVideo = @"128-0";
static WiFiModeSettingCommand const WiFiModeSettingCommandVideoPhoto = @"128-2";
static WiFiModeSettingCommand const WiFiModeSettingCommandVideoLoop = @"128-3";
static WiFiModeSettingCommand const WiFiModeSettingCommandPhoto = @"129-1";
static WiFiModeSettingCommand const WiFiModeSettingCommandPhotoNight = @"129-2";
static WiFiModeSettingCommand const WiFiModeSettingCommandPhotoContinuous = @"130-0";
static WiFiModeSettingCommand const WiFiModeSettingCommandDelayRecording = @"128-1";
static WiFiModeSettingCommand const WiFiModeSettingCommandDelayShoot = @"130-1";
static WiFiModeSettingCommand const WiFiModeSettingCommandDelayNight = @"130-2";

static WiFiModeSettingCommand const GPPROShutterON = @"131-1";
static WiFiModeSettingCommand const GPPROShutterOFF = @"131-0";


@interface ZYBleWiFiManager ()
/*!
 gopro设备的数据模型
 */
@property (nonatomic, readwrite) ZYBleWifiData  *wifiData;
/*!
 wifi扫描的次数
 
 */
@property (nonatomic)         NSUInteger    wiFiScaningCount;
/*!
 Wi-Fi扫描到的个数
 
 */
@property (nonatomic)         NSUInteger    wiFiScanedCount;


/*!
 Wi-Fi连接查询的次数
 
 */
@property (nonatomic)         NSUInteger    WiFiConnectingCount;



/*!
  扫描的状态
 
 */
@property (nonatomic)         ZYWiFiScanState   scanState;
@property (nonatomic, copy)   void (^scaneStatusHandle)(ZYWiFiScanState state);
@property (nonatomic, copy)   void(^devicesHandle)(NSArray *array);

@property (nonatomic, strong) NSMutableSet    *scanedDeviceSet;//集合


/**
 连接的状态
 */
@property (nonatomic)         ZYWiFiConnentState   connectState;

/**
 连接状态的回调
 */
@property (nonatomic, copy)   void (^connentStateHandler)(ZYWiFiConnentState state);
/*!
 将要连接的wifi
 
 */
//@property (nonatomic, strong) NSString            *curSSID;


@property (nonatomic, strong) NSTimer *timer ;
@property (nonatomic, strong) NSDate *begainDate;
@property (nonatomic)           CGFloat      timerInterval;//时间间隔
@property (nonatomic, copy)     void(^timerBlock)();


@property (nonatomic, strong) NSTimer *connectTimer;//连接的定时器
@property (nonatomic, strong) NSDate *connectBegainDate;
@property (nonatomic)           CGFloat      connectTimerInterval;//时间间隔
@property (nonatomic, copy)     void(^connectTimerBlock)();


@property (nonatomic, strong) NSTimer *queryConnectStateTimer;//连接状态的定时器


@property ( nonatomic ) SPCParameterLanguageDes *languageTool;
@end

@implementation ZYBleWiFiManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scanState = ZYWiFiScanStateUnknown;
        _connectState = ZYWiFiConnentStateUnknown;
        _wifiData = [ZYBleWifiData new];
        _languageTool = [SPCParameterLanguageDes new];
    }
    return self;
}
-(NSMutableSet *)scanedDeviceSet{
    if (_scanedDeviceSet == nil) {
        _scanedDeviceSet = [[NSMutableSet alloc] init];
    }
    return _scanedDeviceSet;
}

-(void)endAssistTimer{
    [self endConnectTimer];
    if (self.connectTimerBlock) {
        self.connectTimerBlock();
    }
};

-(NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timerUp:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

-(NSTimer *)connectTimer{
    if (_connectTimer == nil) {
        _connectTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(connectTimerUp:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_connectTimer forMode:NSDefaultRunLoopMode];
    }
    return _connectTimer;
}

-(NSTimer *)queryConnectStateTimer{
    if (_queryConnectStateTimer == nil) {
        _queryConnectStateTimer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(queryConnectStateTimerUp:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_queryConnectStateTimer forMode:NSDefaultRunLoopMode];
    }
    return _queryConnectStateTimer;
}

-(void)timerUp:(NSTimer *)timer{
    if ([[NSDate date] timeIntervalSinceDate:self.begainDate] > self.timerInterval) {
        [self endTimer];
        if (self.timerBlock) {
            self.timerBlock();
        }
    }
}

-(void)connectTimerUp:(NSTimer *)timer{
    if ([[NSDate date] timeIntervalSinceDate:self.connectBegainDate] > self.connectTimerInterval) {
        [self endAssistTimer];
    }
}

-(void)queryConnectStateTimerUp:(NSTimer *)timer{
    [self queryConnectState];
    
}

-(void)queryConnectState{
    
    ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
    @weakify(self)
    [self sendZYControlData:blWiFiStatusData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiStatusData class]]) {
                return ;
            }
            ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
            NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;

            
            if (wifiStatus == ZYBleInteractWifiStatusOff) {
                [self endQueryConnectStateTimer];

            } else if (wifiStatus == ZYBleInteractWifiStatusOn) {
                [self endQueryConnectStateTimer];
                
            } else if (wifiStatus == ZYBleInteractWifiStatusScan) {

            } else if (wifiStatus == ZYBleInteractWifiStatusConnect || wifiStatus == ZYBleInteractWifiStatusConnectAndScan) {
                
            } else if (wifiStatus == ZYBleInteractWifiStatusConnecting) {
                [self endQueryConnectStateTimer];
            } else if (wifiStatus == ZYBleInteractWifiStatusDisconnect) {
                [self endQueryConnectStateTimer];
                [self p_dealWiFiDisconnectWithConnectState:ZYWiFiConnentStateDisconnected];
            } else {
                [self endQueryConnectStateTimer];

            }
        } else {

        }
    }];
}

-(void)begainTimer:(CGFloat)timerInterval{
    self.timerInterval = timerInterval;
    [self endTimer];
    self.begainDate = [NSDate date];
    [self.timer fire];
}

-(void)begainConnectTimer:(CGFloat)timerInterval{
    self.connectTimerInterval = timerInterval;
    [self endConnectTimer];
    self.connectBegainDate = [NSDate date];
    [self.connectTimer fire];
}

-(void)begainQueryConnectStateTimer{
    [self endQueryConnectStateTimer];
    [self.queryConnectStateTimer fire];
}

-(void)endTimer{
    [_timer invalidate];
    _timer = nil;
}

-(void)endConnectTimer{
    [_connectTimer invalidate];
    _connectTimer = nil;
}

-(void)endQueryConnectStateTimer{
    [_queryConnectStateTimer invalidate];
    _queryConnectStateTimer = nil;
}

-(void)clearData{
    _wifiData = [ZYBleWifiData new];
    [self endQueryConnectStateTimer];
    [self endTimer];
    [self endAssistTimer];
}

-(void)doAfter:(CGFloat)timerInterval block:(void(^)())block{
    [self setTimerBlock:block];
    [self begainTimer:timerInterval];
}

-(void)doAfterConnetTime:(CGFloat)timerInterval block:(void(^)())block{
    [self setConnectTimerBlock:block];
    [self begainConnectTimer:timerInterval];
}
/*!
 开启Wi-Fi扫描
 */
-(void)p_enableWifiOn{
    ZYBlWiFiScanData* blWiFiScanData = [[ZYBlWiFiScanData alloc] init];
    blWiFiScanData.scanState = ZYBleInteractWifiON;
    @weakify(self)
    [self sendZYControlData:blWiFiScanData completionHandler:^(ZYBleDeviceRequestState state, id param) {

        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
            self.scanState = ZYWiFiScanStateWifiOn;
//            // NSLog(@"请求开启wifi扫描成功,开始轮询wifi状态");
            [self p_checkWifiDeviceState];
        } else {
//            // NSLog(@"请求开启wifi扫描失败");
            self.scanState = ZYWiFiScanStateWifiOff;
        }
    }];
}

-(void)setScanState:(ZYWiFiScanState)scanState{
//    // NSLog(@"+++++++++++++++++=scanState = %d",scanState);
    if (_scanState == ZYWiFiScanStateScanStop && !(scanState == ZYWiFiScanStateUnknown || scanState == ZYWiFiScanStateWillScan )) {
        if (self.scaneStatusHandle) {
            self.scaneStatusHandle(scanState);
        }
        return;
    }
    _scanState = scanState;
    if (self.scaneStatusHandle) {
        self.scaneStatusHandle(scanState);
    }
}

-(void)p_wifiOn{
    @weakify(self)
    ZYBlWiFiScanData* blWiFiScanData = [[ZYBlWiFiScanData alloc] init];
    blWiFiScanData.scanState = ZYBleInteractWifiON;
    [self sendZYControlData:blWiFiScanData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
//            // NSLog(@"请求开启wifi扫描成功,开始轮询wifi状态");
        } else {
//            // NSLog(@"请求开启wifi扫描失败");
        }
    }];
}

// 检测是否在已连接状态
- (void)queryWifiIsIsConnected:(void(^)(BOOL isConnected))handler{
    
    ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
    [self sendZYControlData:blWiFiStatusData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiStatusData class]]) {
                handler(NO);
                return ;
            }
            ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
            NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
            handler((wifiStatus == ZYBleInteractWifiStatusConnect || wifiStatus == ZYBleInteractWifiStatusConnectAndScan));
        } else {
            handler(NO);
        }
    }];
}

- (void)queryWifiIsIsConnectedWithTimeout:(void(^)(BOOL isConnected, BOOL isTimeout))handler{
    
    ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
    [self sendZYControlData:blWiFiStatusData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiStatusData class]]) {
                handler(NO, NO);
                return ;
            }
            ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
            NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
            handler((wifiStatus == ZYBleInteractWifiStatusConnect || wifiStatus == ZYBleInteractWifiStatusConnectAndScan), NO);
        } else {
            BOOL isTmeout = (state == ZYBleDeviceRequestStateTimeout);
            handler(NO, isTmeout);
        }
    }];
}

-(void)checkWifiDeviceStateWithWorkState:(int)workState{
    
    if (workState != 1) {
        self.connectState = ZYWiFiConnentStateDisconnected;
        [self endQueryConnectStateTimer];
        return;
    }
    
    ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
    @weakify(self)
    [self sendZYControlData:blWiFiStatusData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiStatusData class]]) {
                return ;
            }
            ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
            NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
             NSLog(@"查询wifi模块状态 %lu", wifiStatus);
            if (wifiStatus == ZYBleInteractWifiStatusOff) {
//                // NSLog(@"wifi已关闭,将要开启Wi-Fi");
                [self p_wifiOn];
            } else if (wifiStatus == ZYBleInteractWifiStatusOn) {
//                // NSLog(@"wifi已开启");
                
            } else if (wifiStatus == ZYBleInteractWifiStatusScan) {
//                // NSLog(@"wifi扫描中");
            } else if (wifiStatus == ZYBleInteractWifiStatusConnect || wifiStatus == ZYBleInteractWifiStatusConnectAndScan) {
                // NSLog(@"wifi已连接");
                [self p_dealWiFiConnected];

            } else if (wifiStatus == ZYBleInteractWifiStatusConnecting) {
                // NSLog(@"wifi连接中");
                [self p_dealWiFiConnecting];
            } else if (wifiStatus == ZYBleInteractWifiStatusDisconnect) {
                // NSLog(@"-wifi断开");
                [self p_dealWiFiDisconnectWithConnectState:ZYWiFiConnentStateDisconnected];
            } else {
                // NSLog(@"wifi出错");
            }
        } else {
            // NSLog(@"查询wifi模块状态超时");
        }
    }];
}

/*！
 发送查询Wi-Fi状态命令
 */
-(void)p_checkWifiDeviceState{
    ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
    @weakify(self)
    [self sendZYControlData:blWiFiStatusData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiStatusData class]]) {
                return ;
            }
            ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
            NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
            // NSLog(@"查询wifi模块状态 %lu", wifiStatus);
            if (wifiStatus == ZYBleInteractWifiStatusOff) {
                // NSLog(@"wifi已关闭");
                [self p_enableWifiOn];
            } else if (wifiStatus == ZYBleInteractWifiStatusOn) {
                // NSLog(@"wifi已开启");
                
            } else if (wifiStatus == ZYBleInteractWifiStatusScan) {
                // NSLog(@"wifi扫描中");
                self.scanState = ZYWiFiScanStateScaning;
                [self p_dealWiFiScaning];
            } else if (wifiStatus == ZYBleInteractWifiStatusConnect || wifiStatus == ZYBleInteractWifiStatusConnectAndScan) {
                // NSLog(@"wifi已连接");
                [self p_dealWiFiConnected];
                if (self.scaneStatusHandle) {
                    [self stopScan];
                }
            } else if (wifiStatus == ZYBleInteractWifiStatusConnecting) {
                // NSLog(@"wifi连接中");
                [self p_dealWiFiConnecting];
                if (self.scaneStatusHandle) {
                    [self stopScan];
                }
            } else if (wifiStatus == ZYBleInteractWifiStatusDisconnect) {
                // NSLog(@"wifi断开");
                [self p_dealWiFiDisconnectWithConnectState:ZYWiFiConnentStateDisconnected];
                if (self.scaneStatusHandle) {
                    [self stopScan];
                }
            } else {
                // NSLog(@"wifi出错");
            }
        } else {
            // NSLog(@"查询wifi模块状态超时");
            if (self.connectState == ZYWiFiConnentStateWillConnect || self.connectState == ZYWiFiConnentStateConnecting || self.connectState == ZYWiFiConnentStateWillDisconnect )
            {
                if (self.connectState == ZYWiFiConnentStateConnecting) {
                    self.scanState = ZYWiFiScanStateScaning;
                    [self p_dealWiFiScaning];
                }
                else{
                       [self p_dealWiFiDisconnectWithConnectState:ZYWiFiConnentStateTimeOut];
                }
                
            }
            else if (self.scanState != ZYWiFiScanStateUnknown || self.scanState != ZYWiFiScanStateScanStop) {
                self.scanState = ZYWiFiScanStateTimeOut;
                [self stopScan];
            }
//            if (state == stateConnecting) {
////                dealWiFiConnecting();
//            } else if (state == stateScaning) {
////                dealWiFiScaning();
//            } else {
////                sendWiFiStatus();
//            }
        }
    }];
}

-(void)p_dealWiFiScaning{
    if (self.scanState == ZYWiFiScanStateScanStop) {
        // NSLog(@"stop");
        return;
    }
    _wiFiScaningCount++;
    if (_wiFiScaningCount == 1) {
        // NSLog(@"第%ld次查询到WiFi状态:wifi连接中, 等待2秒后继续查询", (long)_wiFiScaningCount);
        @weakify(self)
        [self doAfter:2 block:^{
            @strongify(self)
            [self p_checkWifiDeviceState];
        }];
       
    } else if (_wiFiScaningCount > 3) {
        _wiFiScaningCount = 0;
        // NSLog(@"wifi扫描超时");
        self.scanState = ZYWiFiScanStateTimeOut;
        [self p_dealWiFiScanFinish];
    } else {
        // NSLog(@"wifi扫描p_dealWiFiScaningSerach");

        [self p_dealWiFiScaningSerach];
    }
}

-(void)p_dealWiFiScanFinish{
    // NSLog(@"found%@",self.scanedDeviceSet);
    if (self.scanState == ZYWiFiScanStateScanStop) {
        return;
    }
    [self p_checkAllWiFiDevices];
}

-(void)p_dealWiFiScaningSerach{
    if (self.scanState == ZYWiFiScanStateScanStop) {
        return;
    }
    self.scanState = ZYWiFiScanStateScaning;
    [self p_checkAllWiFiDevices];
}

/**
 获取稳定器识别到的Wi-Fi个数
 */
-(void)p_checkAllWiFiDevices{
    if (self.scanState == ZYWiFiScanStateScanStop) {
        return;
    }
    [self p_sendWiFiDevicewithIndex:0];
}

/**
 获取对应的Wi-Fi

 @param index Wi-Fi的下标
 */
-(void)p_sendWiFiDevicewithIndex:(NSInteger)index{
    if (self.scanState == ZYWiFiScanStateScanStop) {
        return;
    }
    __block NSInteger num = index;
    ZYBlWiFiDeviceData* blWiFiDeviceData = [[ZYBlWiFiDeviceData alloc] init];
    blWiFiDeviceData.num = index;
    @weakify(self)
    [self sendZYControlData:blWiFiDeviceData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiDeviceData class]]) {
                return;
            }
            ZYBlWiFiDeviceData* blWiFiDiveceDataRespond = (ZYBlWiFiDeviceData*)param;
            NSUInteger curNum = blWiFiDiveceDataRespond.num;
            if (num == 0) {
                self.wiFiScanedCount = curNum;
//                // NSLog(@"扫描到%lu台设备", curNum);
                if (curNum >= 1) {
                    [self p_sendWiFiDevicewithIndex:1];
                } else {
                    [self p_checkAllWiFiDevices];
                }
            } else {
//                // NSLog(@"第%lu台设备是%@", blWiFiDiveceDataRespond.num, blWiFiDiveceDataRespond.ssid);
                
                if (self.scanWifiNames.count > 0) {
                    for (NSString *str in self.scanWifiNames) {
                        if ([blWiFiDiveceDataRespond.ssid hasPrefix:str]) {
                            if (![self.scanedDeviceSet containsObject:blWiFiDiveceDataRespond.ssid] && blWiFiDiveceDataRespond.ssid.length > 0) {
                                [self.scanedDeviceSet addObject: blWiFiDiveceDataRespond.ssid];
                                
                                if (self.devicesHandle) {
                                    self.devicesHandle([self.scanedDeviceSet allObjects]);
                                }
                            }
                        }
                    }
                }
                else{
                    if (![self.scanedDeviceSet containsObject:blWiFiDiveceDataRespond.ssid] && blWiFiDiveceDataRespond.ssid.length > 0) {
                        [self.scanedDeviceSet addObject: blWiFiDiveceDataRespond.ssid];
                        
                        if (self.devicesHandle) {
                            self.devicesHandle([self.scanedDeviceSet allObjects]);
                        }
                    }
                }
                
                if (curNum < self.wiFiScanedCount) {
                    [self p_sendWiFiDevicewithIndex:curNum+1];
                } else {
                    self.scanState = ZYWiFiScanStateScaned;
                    [self p_dealWiFiScanFinish];
                }
            }
        } else {
            // NSLog(@"请求开启wifi扫描失败");
            [self p_againCheckWifiDeviceState];
        }
    }];
}

-(void)p_againCheckWifiDeviceState{
    if (self.connectState == ZYWiFiScanStateScanStop) {
        return;
    }
    @weakify(self)
    [self doAfter:2 block:^{
        @strongify(self);
        [self p_checkWifiDeviceState];
    }];
}

-(void) scanWiFiDevice:(void (^)(ZYWiFiScanState state))scanStatusHandler deviceHandler:(void (^)(NSArray * deviceArray))devicesHandler
{
    if (self.scanState == ZYWiFiScanStateUnknown || self.scanState == ZYWiFiScanStateScanStop || self.scanState == ZYWiFiScanStateWifiOff) {
        [self stopScan];
        [self setScaneStatusHandle:scanStatusHandler];
        [self setDevicesHandle:devicesHandler];
        self.scanState = ZYWiFiScanStateWillScan;
        [self p_enableWifiOn];
//        [self p_checkWifiDeviceState];
    }
    else{
        // NSLog(@"scaning");
    }
}

-(void)stopScan{
    self.scanState = ZYWiFiScanStateScanStop;
    [self clearScanData];
    if (self.connectState == ZYWiFiConnentStateConnected) {
        [self begainQueryConnectStateTimer];
    }
}

-(void)clearScanData{
    [self setScaneStatusHandle:nil];
    [self setDevicesHandle:nil];
    [self endTimer];
    [self.scanedDeviceSet removeAllObjects];
    self.wiFiScaningCount = 0;
    self.wiFiScanedCount = 0;
}

-(void)disConnectFinished{
    [self endAssistTimer];
    [self setConnentStateHandler:nil];
    self.WiFiConnectingCount = 0;
}

-(void)connectionWifiWithSSID:(NSString *)ssid password:(NSString *)pwd connectState:(void (^)(ZYWiFiConnentState state))connentStateHandler{
    [self setConnentStateHandler:connentStateHandler];
    self.connectState = ZYWiFiConnentStateWillConnect;
    
    ZYBlWiFiConnectionData* blWiFiConnectionData = [[ZYBlWiFiConnectionData alloc] init];
    blWiFiConnectionData.ssid = [NSString stringWithUTF8String:[ssid UTF8String]];
    blWiFiConnectionData.pwd = [NSString stringWithUTF8String:[pwd UTF8String]];
    
    @weakify(self)
    [self sendZYControlData:blWiFiConnectionData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
       
        if (state == ZYBleDeviceRequestStateResponse) {
//            // NSLog(@"flag = %@",)
            if ([param isKindOfClass:[ZYBlWiFiConnectionData class]]) {
                self.connectState = ZYWiFiConnentStateConnecting;
                ZYBlWiFiConnectionData *innerblWiFiConnectionData = (ZYBlWiFiConnectionData *)param;
                // NSLog(@"连接设备%@请求成功", [NSString stringWithUTF8String:[ssid UTF8String]]);
                self.curSSID =  [NSString stringWithUTF8String:[ssid UTF8String]];
                [self p_dealWiFiConnecting];
                //            curSSID = blWiFiConnectionData.ssid;
                //            dealWiFiConnecting();
            }
            else{
                self.connectState = ZYWiFiConnentStateConnectFail;
            }

        } else {
            self.connectState = ZYWiFiConnentStateConnectFail;
            // NSLog(@"连接设备%@请求失败", blWiFiConnectionData.ssid);
        }
    }];
}

-(void)disConnectWifiWithConnectState:(void (^)(ZYWiFiConnentState))connentStateHandler{
    [self setConnentStateHandler:connentStateHandler];
    self.connectState = ZYWiFiConnentStateWillDisconnect;
    [self p_dealWiFiDisconnect];

}
-(void)disConnectWifi{
    // NSLog(@"断开连接的方法");
    [self disConnectWifiWithConnectState:nil];
}

-(void)cleanSSID:(NSString *)ssid{
    ZYBlWiFiDevCleanData *cleanData = [[ZYBlWiFiDevCleanData alloc] init];
    cleanData.ssid = ssid;
    [self sendZYControlData:cleanData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiDevCleanData class]]) {
                ZYBlWiFiDevCleanData *innerblData = (ZYBlWiFiDevCleanData *)param;
                // NSLog(@"忽略设备%@请求成功%lu",innerblData.ssid,(unsigned long)innerblData.flag);
            }
            else{
                // NSLog(@"忽略设备请求成功");
            }
            
        } else {
            // NSLog(@"忽略设备信息失败");
        }
    
    }];
}

-(void)p_dealWiFiDisconnect{
    ZYBlWiFiDisconnetData *disConnectData = [[ZYBlWiFiDisconnetData alloc] init];
    @weakify(self)
    [self sendZYControlData:disConnectData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        
        if (state == ZYBleDeviceRequestStateResponse) {
            if ([param isKindOfClass:[ZYBlWiFiDisconnetData class]]) {
                ZYBlWiFiDisconnetData *innerblData = (ZYBlWiFiDisconnetData *)param;
                
                // NSLog(@"断开设备%d请求成功", innerblData.flag);
                if (innerblData.flag) {
                    self.connectState = ZYWiFiConnentStateDisconnected;

                }
                else{
                    [self p_checkWifiDeviceState];
                }
            }
            else{
                self.connectState = ZYWiFiConnentStateDisconnectFail;
            }
            
        } else {
            self.connectState = ZYWiFiConnentStateDisconnectFail;
        }
    }];
}

-(void)sendZYControlData:(ZYControlData*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    ZYControlData *innerData = data;
    [innerData createRawData];
    ZYBleMutableRequest* WiFiConectionRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:innerData];
    [self sendMutableRequest:WiFiConectionRequest completionHandler:handler];
}



-(void)setConnectState:(ZYWiFiConnentState)connectState{
    _connectState = connectState;
    if (connectState == ZYWiFiConnentStateConnected) {
        self.wifiData.ssid = self.curSSID;
        [self begainQueryConnectStateTimer];
    }
    else{
        if (connectState == ZYWiFiConnentStateWillDisconnect || connectState == ZYWiFiConnentStateDisconnectFail) {
            
        }
        else{
            self.wifiData.ssid = nil;
        }
    }
    if (_connentStateHandler) {
        _connentStateHandler(connectState);
        BOOL rel = connectState == ZYWiFiConnentStateConnected ||
                   connectState == ZYWiFiConnentStateConnectFail ||
                   connectState == ZYWiFiConnentStateTimeOut ||
                   connectState == ZYWiFiConnentStateDisconnected ||
                   connectState == ZYWiFiConnentStateDisconnectFail;
        if (rel) {
            _connentStateHandler = nil;
        }
    }
}

-(void)p_dealWiFiConnected{
    if (self.curSSID) {
        //成功连接后处理
        self.connectState = ZYWiFiConnentStateConnected;
        // NSLog(@"%@成功连接", self.curSSID);
        [self doConnectedQuery];
    }
    else{
        ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoData = [[ZYBlWiFiPhotoInfoData alloc] init];
        blWiFiPhotoInfoData.infoId = ZYBIWPApSsid;
        @weakify(self);
        [self sendZYControlData:blWiFiPhotoInfoData completionHandler:^(ZYBleDeviceRequestState state, id param) {
            @strongify(self);
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoDateRespond = (ZYBlWiFiPhotoInfoData*)param;
                // NSLog(@"查询设备信息%@成功", blWiFiPhotoInfoDateRespond.infoString);
                if (blWiFiPhotoInfoDateRespond.infoId == ZYBIWPApSsid) {
                    self.curSSID = blWiFiPhotoInfoDateRespond.infoString;
                    [self p_dealWiFiConnected];
                }
            } else {
                // NSLog(@"查询设备信息失败");
            }
        }];
    }

}

-(void)p_dealWiFiConnecting{
    
    if (self.curSSID == nil) {
        //重新检索设备
        //TODO 判断是否已经连上gopro
        
    } else {
        self.WiFiConnectingCount++;
        if (self.WiFiConnectingCount == 1) {
            // NSLog(@"第%ld次查询到WiFi状态:wifi连接中,等待4秒继续查询", (long)self.WiFiConnectingCount);
            @weakify(self);
            [self doAfterConnetTime:4 block:^{
                @strongify(self);
                [self p_checkWifiDeviceState];

            }];
        } else if (self.WiFiConnectingCount > 14) {
            // NSLog(@"wifi超时断开");
            [self p_dealWiFiDisconnectWithConnectState:ZYWiFiConnentStateTimeOut];
        } else {
            self.connectState = ZYWiFiConnentStateConnecting;
            @weakify(self);
            [self doAfterConnetTime:4 block:^{
                @strongify(self);
                [self p_checkWifiDeviceState];
                
            }];
            // NSLog(@"第%ld次查询到WiFi状态:wifi连接中", (long)self.WiFiConnectingCount);
        }
    }
}

-(void)p_dealWiFiDisconnectWithConnectState:(ZYWiFiConnentState)disConnectState{//连接断开后后处理
    self.connectState = disConnectState;
    self.WiFiConnectingCount = 0;
    self.curSSID = nil;
}

-(void)queryBaseGoProMessage{
    ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoData = [[ZYBlWiFiPhotoInfoData alloc] init];
    blWiFiPhotoInfoData.infoId = ZYBIWPModelName;
    @weakify(self)
    [self sendZYControlData:blWiFiPhotoInfoData completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if ((state == ZYBleDeviceRequestStateResponse) && [param isKindOfClass:[ZYBlWiFiPhotoInfoData class]]) {
            ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoDateRespond = (ZYBlWiFiPhotoInfoData*)param;
            // NSLog(@"查询设备信息%@成功", blWiFiPhotoInfoDateRespond.infoString);
            if (blWiFiPhotoInfoDateRespond.infoId == ZYBIWPModelName) {
                NSArray<NSString*>* arrayString = [blWiFiPhotoInfoDateRespond.infoString componentsSeparatedByString:@" "];
                NSString* name = [arrayString[0] uppercaseString];
                NSString* color = [arrayString[1] capitalizedString];
                self.wifiData.goproType = name;
                [[ZYMessageTool defaultTool] activeSportCameraConfig:name withColor:color];
                [self queryAllParamData];
            }
        } else {
            // NSLog(@"查询设备信息失败");
        }
    }];
}

-(void)doConnectedQuery{
    
    [self queryBaseGoProMessage];
 
}

/**
 查询相机的单条参数

 @param code 需要查询的参数code
 */
- (void)querySingleParaWithCode:(NSUInteger)code {
    
    ZYBlWiFiPhotoParamData *data = [ZYBlWiFiPhotoParamData new];
    data.paramId = code;
    [data createRawData];
    ZYBleMutableRequest *wifiResidueTimeInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
    @weakify(self)
    [self sendMutableRequest:wifiResidueTimeInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiPhotoParamData class]]) {
                return;
            }
            ZYBlWiFiPhotoParamData* blWiFiPhotoParamDataRespond = (ZYBlWiFiPhotoParamData*)param;
            [self.wifiData setCode:blWiFiPhotoParamDataRespond.paramId value:blWiFiPhotoParamDataRespond.paramValue];
        }
    }];
}
-(void)queryAllParamData{
    [self queryAllParamDataWithCount:3];
}
-(void)queryAllParamDataWithCount:(NSInteger)count{
    
//#pragma -mark 查询所的数据错误，等处理好打开
//    return;
    @weakify(self)
    __block NSInteger innerCount = count -1;
    ZYBlWiFiPhotoAllParamData* blWiFiPhotoAllParamData = [[ZYBlWiFiPhotoAllParamData alloc] init];
    
    ZYControlData *innerData = blWiFiPhotoAllParamData;
    [innerData createRawData];
    ZYBleMutableRequest* WiFiConectionRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:innerData];
    WiFiConectionRequest.delayMillisecond = 500;
    [self sendMutableRequest:WiFiConectionRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            if (![param isKindOfClass:[ZYBlWiFiPhotoAllParamData class]]) {
                return;
            }
            ZYBlWiFiPhotoAllParamData* blWiFiPhotoAllParamDataRespond = (ZYBlWiFiPhotoAllParamData*)param;
            [self.wifiData updateValueWithZYBlWiFiPhotoAllParamData:blWiFiPhotoAllParamDataRespond];
            [self querySingleParaWithCode:WiFiInquireCodeMaxVideoSecs]; // 查询剩余秒数
            [self querySingleParaWithCode:WiFiInquireCodeMaxPhotoCount]; // 查询剩余张数
            // NSLog(@"查询设备状态%d:%lu成功", 0, (unsigned long)blWiFiPhotoAllParamDataRespond.Video_Resolution);
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self setMainModeWithType:WiFiMain_modePhoto subType:WiFiPhoto_para_Sub_ModeNight completionHandler:^(ZYBleDeviceRequestState state, id param) {
//
//                }];
//
//            [self setMainModeWithType:WiFiMain_modePhoto completionHandler:^(ZYBleDeviceRequestState state, id param) {
//
//            }];
//               
//
//            });
        } else {
            // NSLog(@"查询设备状态失败");
            if (innerCount <= 0) {
                return;
            }
            [self queryAllParamDataWithCount:innerCount];
        }
    }];
}


-(NSInteger)querySpecificConfigParaWith:(WiFiMain_mode)main_mode{
    switch (main_mode) {
        case WiFiMain_modePhoto:
            return supportMode_Photo;
        case WiFiMain_modeVideo:
            return supportMode_Video;
        case WiFiMain_modeMultiShot:
            return supportMode_MultiShot;
        case WiFiMain_modeOther:
            return supportMode_Other;
        default:
            return supportMode_Other;
    }
}



/*
 设置主模式
 
 @param main_mode WiFiMain_mode
 @param handler 设置的回掉
 */

/*
-(void)setMainModeWithType:(WiFiMain_mode)main_mode completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    NSUInteger config = [self querySpecificConfigParaWith:main_mode];
    self.wifiData.current_Mode = main_mode;
    SportCameraParamModel* cameraParam = [[ZYMessageTool defaultTool] mainMode:config];
    [self setWiFiPhotoCtrlCameraParamModel:cameraParam completionHandler:handler];

}


/**
 设置主模式
 
 @param main_mode WiFiMain_mode
 @param subType 子模式
 @param handler 设置的回掉
 */

/*
-(void)setMainModeWithType:(WiFiMain_mode)main_mode subType:(NSUInteger)subType completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    NSUInteger config = [self querySpecificConfigParaWith:main_mode];
    self.wifiData.current_Mode = main_mode;
    SportCameraParamModel* cameraParam = [[ZYMessageTool defaultTool] mainMode:config subMode:subType];
    [self setWiFiPhotoCtrlCameraParamModel:cameraParam completionHandler:handler];
}
 
*/
-(void)shutter:(bool)shutter completionHandler:(void (^)(ZYBleDeviceRequestState, id))handler{
    NSString *shutterStr = GPPROShutterON;
    if (!shutter) {
        shutterStr = GPPROShutterOFF;
    }
    
    NSArray *setting = [shutterStr componentsSeparatedByString:@"-"];
    NSUInteger number = [setting[0] integerValue];
    NSUInteger value = [setting[1] integerValue];
    [self activationSerialNumber:number value:value completionHandler:handler]; 
}


-(void)setWiFiPhotoCtrlCameraParam:(NSUInteger)paramValue completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    // NSLog(@"%ld==========",paramValue);
    ZYBlWiFiPhotoCtrlData* blWiFiPhotoCtrlData = [[ZYBlWiFiPhotoCtrlData alloc] init];
    blWiFiPhotoCtrlData.num = 2;
    blWiFiPhotoCtrlData.value = 9;
    
    [self sendZYControlData:blWiFiPhotoCtrlData completionHandler:handler];
}


- (void)activationSerialNumber:(NSUInteger)number value:(NSUInteger)value completionHandler:(void (^)(ZYBleDeviceRequestState, id))handler {
    
//    [self.wifiData setCode:number value:value];
    
    ZYBlWiFiPhotoCtrlData *data = [ZYBlWiFiPhotoCtrlData new];
    data.num = number;
    data.value = value;
#if DEBUG
    NSLog(@"command = %lu-%lu",number,value);
#endif
    [self sendZYControlData:data completionHandler:handler];
}

- (void)activationCatagoryCode:(NSInteger)queryCode content:(NSString *)name completionHandler:(void (^)(ZYBleDeviceRequestState, id))handler {
    
    // 找到参数表中对应的content;
    NSString *tableName = [self.languageTool getTableName:name];
    ZYGOPROData *gopro = [ZYMessageTool defaultTool].goProData;
    NSInteger value = [gopro obtainQueryValueUsingCode:queryCode andContent:tableName];
    [self activationSerialNumber:queryCode value:value completionHandler:handler];
}



- (void)changeMode:(WiFiMode)wifiMode completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    
    NSString *settingName = @"";
    if (wifiMode == WiFiModeVideo) settingName = WiFiModeSettingCommandVideo;
    else if (wifiMode == WiFiModeDelayRecording) settingName = WiFiModeSettingCommandDelayRecording;
    else if (wifiMode == WiFiModeVideoPhoto) settingName = WiFiModeSettingCommandVideoPhoto;
    else if (wifiMode == WiFiModeVideoLoop) settingName = WiFiModeSettingCommandVideoLoop;
    else if (wifiMode == WiFiModePhoto) settingName = WiFiModeSettingCommandPhoto;
    else if (wifiMode == WiFiModePhotoNight) settingName = WiFiModeSettingCommandPhotoNight;
    else if (wifiMode == WiFiModePhotoContinuous) settingName = WiFiModeSettingCommandPhotoContinuous;
    else if (wifiMode == WiFiModeDelayShoot) settingName = WiFiModeSettingCommandDelayShoot;
    else if (wifiMode == WiFiModeDelayNight) settingName = WiFiModeSettingCommandDelayNight;
    
    assert(settingName.length);
    
    NSArray *setting = [settingName componentsSeparatedByString:@"-"];
    NSUInteger number = [setting[0] integerValue];
    NSUInteger value = [setting[1] integerValue];
    [self activationSerialNumber:number value:value completionHandler:handler];
}

- (NSString *)obtainCurrentNameWithQueryCode:(NSInteger)queryCode {
    ZYBleWifiData *data = self.wifiData;
    NSInteger val = -1;
    
#define _getVal(code,key) else if (queryCode == code) val = key
    
    // 视频模式下的查询码对应的属性值
    if (queryCode == SPCCatagoryQueryCode_videoResolution) val = data.Video_Resolution;
    _getVal(SPCCatagoryQueryCode_videoFrameRate, data.Video_Frame_Rate);
    _getVal(SPCCatagoryQueryCode_videoFOV, data.Video_FOV);
    _getVal(SPCCatagoryQueryCode_videoEVComp, data.Video_AE);
    _getVal(SPCCatagoryQueryCode_videoWhiteBlance, data.Video_White_Balance);
    _getVal(SPCCatagoryQueryCode_videoISOMax, data.Video_ISO_Max);
    _getVal(SPCCatagoryQueryCode_videoISOLimit, data.Video_ISO_limit);
    _getVal(SPCCatagoryQueryCode_videoISOMin, data.Video_ISO_Min);
    _getVal(SPCCatagoryQueryCode_videoInterval, data.Video_Interval);
    _getVal(SPCCatagoryQueryCode_videoLoopingInterval, data.Video_Loop_Interval);
    _getVal(SPCCatagoryQueryCode_videoTimelapseInterval, data.Video_Timelapse_Interval);
    _getVal(SPCCatagoryQueryCode_videoManualExposure, data.Video_Shutter);
    
    // 图片模式下的查询码对应的属性值
    _getVal(SPCCatagoryQueryCode_photoFOV, data.Photo_Fov);
    _getVal(SPCCatagoryQueryCode_photoEVComp, data.Photo_AE);
    _getVal(SPCCatagoryQueryCode_photoWhiteBlance, data.Photo_White_Balance);
    _getVal(SPCCatagoryQueryCode_photoISOMax, data.Photo_ISO_Max);
    _getVal(SPCCatagoryQueryCode_photoISOMin, data.Photo_ISO_Min);
    _getVal(SPCCatagoryQueryCode_photoShutterAuto, data.Photo_Shutter);
    _getVal(SPCCatagoryQueryCode_photoNightExposure, data.Photo_Night_Shutter);
    
    // 多拍模式下的查询码对应的属性值
    _getVal(SPCCatagoryQueryCode_multiFOV, data.MultiShot_Fov);
    _getVal(SPCCatagoryQueryCode_multiEVComp, data.MultiShot_AE);
    _getVal(SPCCatagoryQueryCode_multiWhiteBlance, data.MultiShot_White_Balance);
    _getVal(SPCCatagoryQueryCode_multiISOMax, data.MultiShot_ISO_Max);
    _getVal(SPCCatagoryQueryCode_multiISOMin, data.MultiShot_ISO_Min);
    _getVal(SPCCatagoryQueryCode_multiShutter, data.MultiShot_Shutter);
    _getVal(SPCCatagoryQueryCode_multiNightLapseInterval, data.MultiShot_Interval);
    _getVal(SPCCatagoryQueryCode_multiContinuousShootRate, data.MultiShot_Capture_Rate);
    _getVal(SPCCatagoryQueryCode_multiShotInterval, data.Photo_Delay_Interval);
    
    assert(val != -1);
    
    NSString *content = [[ZYMessageTool defaultTool].goProData obtainContentUsingCode:queryCode andQueryValue:val];
    
    return [self.languageTool languageDescripiton:content];
    
}

- (NSArray *)obtainTitlesUsingQueryCode:(NSInteger)queryCode {
    ZYBleWifiData *d = self.wifiData;
    NSString *name = [self modeString:d.wifiMode];
    
    ZYGOPROData *gopro = [ZYMessageTool defaultTool].goProData;
    NSArray *array = [gopro obtainTitlesUsingCode:queryCode
                                      subModeName:name
                                      videoFormat:d.videoFormater
                                         mainMode:d.Other_Current_Main_Mode
                                          subMode:d.Other_Current_Sub_Mode
                                       resolution:d.Video_Resolution
                                              FPS:d.Video_Frame_Rate
                                          shutter:d.MultiShot_Shutter];
    
    NSMutableArray *res = array.mutableCopy;
    
    if ([self.wifiData.goproType isEqualToString:GoPro5]) {
        
        if (queryCode == SPCCatagoryQueryCode_photoWhiteBlance) {
            if (d.Photo_Night_Shutter && d.wifiMode == WiFiModePhotoNight) {
                if ([res containsObject:@"Auto"]) {
                    [res removeObject:@"Auto"];
                }
            }
        } else if (queryCode == SPCCatagoryQueryCode_multiWhiteBlance && d.wifiMode == WiFiModeDelayNight) {
            if (d.MultiShot_Shutter) {
                if ([res containsObject:@"Auto"]) {
                    [res removeObject:@"Auto"];
                }
            }
        } else if (queryCode == SPCCatagoryQueryCode_multiISOMax) {
            if ((d.Photo_Delay_Interval == 1 || !d.Photo_Delay_Interval) && d.wifiMode == WiFiModeDelayShoot) {
                res = @[@"400",@"800"].mutableCopy;
            }
        } else if (queryCode == SPCCatagoryQueryCode_videoISOMax) {
            if (d.wifiMode == WiFiModeVideo) {
                NSMutableArray *willDel = @[].mutableCopy;
                for (int i = 0 ; i < array.count; ++i) {
                    if ([array[i] integerValue] < 400) {
                        [willDel addObject:array[i]];
                    }
                }
                [res removeObjectsInArray:willDel];
            }
        }
    }
    // gopro 6
    else {
//        if (queryCode == SPCCatagoryQueryCode_multiWhiteBlance ||
//            queryCode == SPCCatagoryQueryCode_photoWhiteBlance ||
//            queryCode == SPCCatagoryQueryCode_videoWhiteBlance) {
//            if ([res containsObject:@"5000K"]) {
//                [res removeObject:@"5000K"];
//            }
//        }
//        if (d.wifiMode == WiFiModeDelayNight && queryCode == SPCCatagoryQueryCode_multiWhiteBlance) {
//            if (d.MultiShot_Shutter) {
//                if ([res containsObject:@"Auto"]) {
//                    [res removeObject:@"Auto"];
//                }
//            }
//        }
    }
    
    return [[self.languageTool languageFilter:res] copy];
}

- (NSString *)modeString:(WiFiMode)mode {
    
    NSString *s = @"";
    if (mode == WiFiModeVideo) s = @"WiFiVideo_para_Sub_ModeVideo";
    else if (mode == WiFiModeVideoPhoto) s = @"WiFiVideo_para_Sub_ModeVideo_Photo";
    else if (mode == WiFiModeVideoLoop) s = @"WiFiVideo_para_Sub_ModeLooping";
    
    else if (mode == WiFiModePhoto) s = @"WiFiPhoto_para_Sub_ModeSingle";
    else if (mode == WiFiModePhotoNight) s = @"WiFiPhoto_para_Sub_ModeNight";
    else if (mode == WiFiModePhotoContinuous) s = @"WiFiMultiShot_para_Sub_Mode_Burst";
    
    else if (mode == WiFiModeDelayRecording) s = @"WiFiVideo_para_Sub_ModeTimeLapseVideo";
    else if (mode == WiFiModeDelayShoot) s = @"WiFiMultiShot_para_Sub_Mode_TimeLapse";
    else if (mode == WiFiModeDelayNight) s = @"WiFiMultiShot_para_Sub_Mode_Night_TimeLapse";
    
    assert(s.length);
    
    return s;
}

-(void)dealloc{
#ifdef DEBUG
    
     NSLog(@"%@",[self class]);
#endif

}

-(void) sendMutableRequest:(ZYBleMutableRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:request completionHandler:handler];
}
@end
