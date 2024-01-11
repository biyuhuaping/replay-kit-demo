//
//  ZYBleManager.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/9/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleManager.h"

#import "BabyBluetooth.h"
#import "ZYBleDeviceDispacther.h"
@interface ZYBleManager()

@property (nonatomic, strong)    NSMutableDictionary<NSString*, ZYBleDeviceInfo*>* deviceDict;
@property (nonatomic, readwrite, strong) ZYBleDeviceInfo* curDeviceInfo;
@property (nonatomic, readwrite, copy) NSString* needConnectDeviceInfo;
@property (nonatomic, readwrite, strong) ZYBleDeviceDispacther* bleDeviceDispather;
@property (nonatomic, readwrite, copy) void (^disConnecthandler)(void);
@property (nonatomic, readwrite, copy) void (^connecthandler)(ZYBleDeviceConnectionState state);
@property (nonatomic, readwrite) BOOL deviceReady;


@property (nonatomic, strong) ZYBleConnection* stablizerConnection;
@property (nonatomic, copy)   void (^deviceHandler)(ZYBleDeviceInfo* deviceInfo) ;


@end

@implementation ZYBleManager
+ (instancetype)bleManagerWithBleConnection:(ZYBleConnection *)connection{
    
    ZYBleManager *mag = [[ZYBleManager alloc] init];
    mag.stablizerConnection = connection;
    return mag;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceDict = [[NSMutableDictionary alloc] init];
        _deviceReady = NO;
        _bleDeviceDispather = [[ZYBleDeviceDispacther alloc] init];
        _virtualConnect = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrivevConnected:) name:@"retrieveConnectedPeripherals" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)retrivevConnected:(NSNotification *)noti{
    if ([noti.name isEqualToString:        @"retrieveConnectedPeripherals"
         ]) {
        NSArray *array = noti.object;
        for (CBPeripheral *peripheral in array) {
            NSString *localName;
            NSData *manufacturerData;
            localName = peripheral.name;

            NSLog(@"retrieveConnected 到了设备:%@", localName);
            
            if (!localName || [localName isEqualToString:@""]) {
                //未知设备
                return;
            }

            ZYBleDeviceInfo* info = [[ZYBleDeviceInfo alloc] initWithNamePeripheralAndRSSI:localName withPeripheral:peripheral withRSSI:peripheral.RSSI];
            if (info.nameValid) {
//                manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
                if (manufacturerData) {
                    [info updateManufacturerData:manufacturerData];
                }
                info.isRetriveDevice = YES;
            }

            if (info.nameValid) {
                if([self updateDeviceInfo:info]) {
                    //NSLog(@"搜索到了设备:%@", info.name);
                    BLOCK_EXEC_ON_MAINQUEUE(self.deviceHandler, info);
                }
            }
        }
    }
    
}

-(ZYBleState) deviceState
{
    return (ZYBleState)[[BabyBluetooth shareBabyBluetooth] centralManager].state;
}
#pragma 辅助方法

-(BOOL) updateDeviceInfo:(ZYBleDeviceInfo*)info
{
    ZYBleDeviceInfo* oldValue = [_deviceDict objectForKey:info.name];
    if (!oldValue || [oldValue isDataNeedUpdate:info]) {
        [_deviceDict setObject:info forKey:info.name];
        [info recordUpdateDataTime];
        return YES;
    }
    return NO;
}

-(BOOL) isVaildDeviceName:(NSString*)name
{
    for (ZYBleDeviceInfo* info in _deviceDict.allValues) {
        if ([info.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}


#pragma 扫描连接蓝牙设备

-(void)retriveConnecting{
    BabyBluetooth* baby = [BabyBluetooth shareBabyBluetooth];
    [baby retriveConnecting];
}

-(void) scanDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYBleDeviceInfo* deviceInfo))deviceHandler;
{
    BabyBluetooth* baby = [BabyBluetooth shareBabyBluetooth];
    if (baby.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.bleDeviceDispather prepare];
        [self beginScan:deviceHandler];
    } else {
        @weakify(self);
        
        [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
            @strongify(self);
            
            if (central.state == CBCentralManagerStatePoweredOn) {
                NSLog(@"设备打开成功，开始扫描设备");
                [self.bleDeviceDispather prepare];
                [self beginScan:deviceHandler];
            } else if (central.state == CBCentralManagerStatePoweredOff) {
                NSLog(@"蓝牙设备已经关闭");
            }
            BLOCK_EXEC_ON_MAINQUEUE(bleStatusHandler, (ZYBleState)central.state);
        }];
    }
}

-(void) beginScan:(void (^)(ZYBleDeviceInfo* deviceInfo))deviceHandler;
{
    BabyBluetooth* baby = [BabyBluetooth shareBabyBluetooth];
    [_deviceDict removeAllObjects];
    if (self.curDeviceInfo) {
        [self updateDeviceInfo:self.curDeviceInfo];
    }
    self.deviceHandler = deviceHandler;
    @weakify(self);
    
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        @strongify(self);
        
        //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
        NSString *localName;
        NSData *manufacturerData;
//        NSLog(@"------%@",advertisementData);

        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
            localName = [NSString stringWithFormat:@"%@", [advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else{
            localName = peripheral.name;
        }
//        NSLog(@"搜索到了设备:%@", localName);
        
        if (!localName || [localName isEqualToString:@""]) {
            //未知设备
            return;
        }
        
        ZYBleDeviceInfo* info = [[ZYBleDeviceInfo alloc] initWithNamePeripheralAndRSSI:localName withPeripheral:peripheral withRSSI:RSSI];
        if (info.nameValid) {
            manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            if (manufacturerData) {
                [info updateManufacturerData:manufacturerData];
            }
        }
        
        if (info.nameValid) {
            if([self updateDeviceInfo:info]) {
                //NSLog(@"搜索到了设备:%@", info.name);
                BLOCK_EXEC_ON_MAINQUEUE(deviceHandler, info);
            }
        }
    }];
    
    // 在连接设备的同时一直扫描设备,但是不连接
    [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        @strongify(self);
        
        if ([peripheralName isEqualToString:self.needConnectDeviceInfo]) {
            if ([self.stablizerConnection canConnect]) {
                if ([self isVaildDeviceName:peripheralName]) {
                    return YES;
                }
            }
        }
        //NSLog(@"不能连接%@ 当前连接的设备是%@", peripheralName, self.stablizerConnection.curPeripheral.name);
        return NO;
    }];
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    //停止之前的连接
    //    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();
}

-(void) stopScan
{
    BabyBluetooth* baby = [BabyBluetooth shareBabyBluetooth];
    [baby cancelScan];
}

-(void)connectWithState:(ZYBleDeviceConnectionState)state{
    
}


-(void) connectDevice:(ZYBleDeviceInfo*) deviceInfo completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler;
{
    
    if ([BabyBluetooth shareBabyBluetooth].centralManager.state != CBManagerStatePoweredOn) {
        NSLog(@"设备：%@--连接失败蓝牙未开启", deviceInfo.peripheral.name);
        BLOCK_EXEC_ON_MAINQUEUE(deviceStatusHandler, ZYBleDeviceStateFail);
        return;
    }
    @weakify(self)
    
    void (^connect)(void) = ^(){
        @strongify(self)
        
        self.connecthandler = deviceStatusHandler;
        self.needConnectDeviceInfo = deviceInfo.name;
        [self.stablizerConnection connectDevice:deviceInfo withDispatcher:self.bleDeviceDispather completionHandler:^
         (ZYBleDeviceConnectionState state) {
             
             @strongify(self)
             if (state==ZYBleDeviceStateConnected) {
                 self.curDeviceInfo = deviceInfo;
             } else if (state==ZYBleDeviceStateMissConnected
                        || state==ZYBleDeviceStateFail
                        || state==ZYBleDeviceStateUnknown) {
                 BOOL sameDevice = NO;
                 if (self.curDeviceInfo.identifier && deviceInfo.identifier) {
                     sameDevice = [self.curDeviceInfo.identifier isEqualToString:deviceInfo.identifier];
                 } else {
                     sameDevice = [self.curDeviceInfo.peripheral.name isEqualToString:deviceInfo.peripheral.name];
                 }
                 if (sameDevice) {
                     NSLog(@"设备：%@--成功断开设备", self.curDeviceInfo.peripheral.name);
                     
                     self.curDeviceInfo = nil;
                 } else {
                     
                     NSLog(@"设备：%@--已经断开 当前连接的是%@", deviceInfo.peripheral.name, self.curDeviceInfo.peripheral.name);
                 }
                 self.deviceReady = NO;
                 self.needConnectDeviceInfo = nil;
                 [self notifyOffline];
             }
             
             self.deviceReady = (state==ZYBleDeviceStateReady);
             if (self.deviceReady) {
                 [self.curDeviceInfo updateConnectedDeviceInfo];
                 self.curDeviceInfo.maxSendWithOutRespondLenth = [self.curDeviceInfo.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
                 [[NSNotificationCenter defaultCenter] postNotificationName:Device_BLEReadyToUse object:self];
             }
             
             BLOCK_EXEC_ON_MAINQUEUE(deviceStatusHandler, state);
         }];
    };
    
    if ([_stablizerConnection canConnect]) {
        connect();
    } else {
        [self disconnectDevice:connect];
    }
}

-(void) disconnectDevice:(void (^)(void))handler
{
    self.disConnecthandler = handler;
    
    if ([self.stablizerConnection canDisconnect]) {
        [_stablizerConnection disconnectDevice];
    } else {
        if (self.curDeviceInfo) {
            //设备正在断开中
            NSLog(@"设备：%@--重复断开 正在断开", self.curDeviceInfo.peripheral.name);
        } else {
            //设备已经断开
            NSLog(@"设备：%@--重复断开 已经断开", self.curDeviceInfo.peripheral.name);
            [self notifyOffline];
            
            BLOCK_EXEC_ON_MAINQUEUE(self.connecthandler, ZYBleDeviceStateMissConnected);
        }
    }
}

-(void) notifyOffline
{
    BLOCK_EXEC_ON_MAINQUEUE(self.disConnecthandler);
    [[NSNotificationCenter defaultCenter] postNotificationName:Device_BLEOffLine object:self];
}
@end
