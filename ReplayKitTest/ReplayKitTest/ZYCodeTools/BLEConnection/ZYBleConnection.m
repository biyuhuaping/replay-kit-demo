//
//  ZYBleConnection.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleConnection.h"
#import "BabyBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZYBleMutableRequest.h"
#import "ZYBleDeviceDataModel.h"
#import "ZYBleDeviceDispacther.h"
#import "ZYBleDeviceInfo.h"
#import "ZYBlControlCoder.h"
#import "ZYStarControlCoder.h"
//#import "NSArray+Description.h"
#import "ZYUsbControlCoder.h"
#import "ZYDeviceManager.h"
#import <UIKit/UIKit.h>


#define sendServiceUUID128 @"0000FEE9-0000-1000-8000-00805F9B34FB"
#define sendServiceUUID16 @"FEE9"
#define connectedUUID @"0000180A-0000-1000-8000-00805F9B34FB"
NSString* const WRITE_CHARACTERISTIC_UUID   = @"D44BC439-ABFD-45A2-B575-925416129600";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129601";
NSString* const RESEND_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129610";
const int max_packet_size = 20;

#define TIME_OUT_TIME 200
#define ONE_CMD_LEN 7


#define KEY_BUTTON_PRESS_MASK 0x0F
#define KEY_BUTTON_PRESS_EQUAL(val, eventVal) ((val&KEY_BUTTON_PRESS_MASK)==eventVal)

#define KEY_BUTTON_EVENT_MASK  0xF0
#define KEY_BUTTON_EVENT_PRESS_EQUAL(val, eventVal) ((val&KEY_BUTTON_EVENT_MASK)==eventVal)

#define CONNECTION_TIMEOUT      10
#define DISCONNECTION_TIMEOUT   10

@interface ZYBleConnection ()

@property (nonatomic, readwrite, weak) BabyBluetooth* refBabyble;
//@property (nonatomic, readwrite, copy) NSString* channelName;
@property (nonatomic, readwrite, strong) CBPeripheral* curPeripheral;
@property (nonatomic, readwrite, strong) ZYBleDeviceInfo* curDeviceInfo;
@property (nonatomic, readwrite, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, readwrite, strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, readwrite, strong) CBCharacteristic *commandCharacteristic;
@property (nonatomic, readwrite) NSInteger messageChannelCount;

@property (nonatomic, readwrite, copy) void (^deviceStatusHandler)(ZYBleDeviceConnectionState state);
@property (atomic, readwrite) ZYBleDeviceConnectionState connectState;

@property (nonatomic, readwrite, strong) NSMutableArray<ZYBleDeviceRequest*>* requestQueue;
@property (nonatomic, readwrite, strong) NSMutableArray<ZYBleMutableRequest*>* asynRequestQueue;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSNumber*, ZYBleMutableRequest*>* asynRequestCache;
@property (nonatomic, readwrite, strong) dispatch_queue_t requestAccessQueue;
@property (nonatomic, readwrite) NSInteger waitingRequestCount;
@property (nonatomic, readwrite) NSMutableData* recvCache;
@property (nonatomic, readwrite) NSMutableData* sendCache;
@property (nonatomic, readwrite, weak) ZYBleDeviceDispacther* eventDispather;
@property (nonatomic, readwrite, strong) NSTimer* connectionTimeoutTimer;
@property (nonatomic, readwrite, strong) NSTimer* disconnectionTimeoutTimer;
@property (nonatomic, readwrite, strong) ZYControlCoder* recvCoder;
@property (nonatomic, readwrite, strong) ZYStarControlCoder* commandCoder;
@property (nonatomic)         BOOL      inactiveNoti;//不激活通知
@property (nonatomic, readwrite) NSUInteger maximumExpectedWriteValue;//最大的发送数据包的大小
@property (nonatomic, readwrite) NSDate *beforeReciveNotiDate;//上一次接收到数据发送通知的时间间隔

@end

@implementation ZYBleConnection

-(instancetype) init
{
    if ([super init]) {
        _refBabyble = [BabyBluetooth shareBabyBluetooth];
        //_channelName = [[NSUUID UUID] UUIDString];
        _requestQueue = [NSMutableArray array];
        _asynRequestQueue = [NSMutableArray array];
        _asynRequestCache = [NSMutableDictionary dictionary];
        _maxAsynRequestCount = 20;
        _requestAccessQueue = dispatch_queue_create("com.zhiyun-tech.ZYCamera.ConnectionAccessQueue", DISPATCH_QUEUE_SERIAL);
        self.waitingRequestCount = 0;
        _recvCache = [NSMutableData data];
        _sendCache = [NSMutableData data];
        self.connectState = ZYBleDeviceStateUnknown;
        
        _sendCoder = [[ZYStarControlCoder alloc] init];
        _recvCoder = [[ZYStarControlCoder alloc] init];
        _commandCoder = [[ZYStarControlCoder alloc] init];
        
        _lastRecvTimeStamp = [NSDate date];
        _lastSendTimeStamp = [NSDate date];
        _maximumExpectedWriteValue = max_packet_size;
        _beforeReciveNotiDate = [NSDate date];
        [self addNoti];
    }
    return self;
}

-(void)postReciveDataNotiName{
    if ([self.beforeReciveNotiDate timeIntervalSinceNow] < -kbeforeReciveNotiDateInterVale) {
        self.beforeReciveNotiDate = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReciveDataNotiName object:nil];
    }
}


-(void) setWaitingRequestCount:(NSInteger)waitingRequestCount
{
    _waitingRequestCount = waitingRequestCount;
    assert(_waitingRequestCount>= 0);
}

#pragma 辅助方法
-(BOOL) isValidDevice
{
    for (CBService* service in _curPeripheral.services) {
        for (CBCharacteristic* characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A29"]) {
                NSString *value =[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                if ([value isEqualToString:@"Zhiyun"]){
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void) initPeripheral
{
    //建立专属通道
    //self.refBabyble.channel(_channelName);
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    NSString* channelNameString = self.curPeripheral.identifier.UUIDString;
    @weakify(self)
    [self.eventDispather setConnectedPeripheralBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBCentralManager *central) {
        @strongify(self)
        [self cancelConnectionTimeout];
        //NSLog(@"设备：%@--连接成功", self.curPeripheral.name);
        self.connectState = ZYBleDeviceStateConnected;
        BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateConnected);
    }];
    
    //设置设备连接失败的委托
    [self.eventDispather setFailToConnectBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBCentralManager *central, NSError *error) {
        [self cancelConnectionTimeout];
        //NSLog(@"设备：%@--连接失败",self.curPeripheral.name);
        self.connectState = ZYBleDeviceStateFail;
        BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateFail);
    }];
    
    //设置设备断开连接的委托
    [self.eventDispather setDisconnectBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBCentralManager *central, NSError *error) {
        [self cancelConnectionTimeout];
        @strongify(self)
        //NSLog(@"设备：%@--断开连接", self.curPeripheral.name);
        self.connectState = ZYBleDeviceStateMissConnected;
        [self disconnectDevice];
    }];
}

-(void) initCharacteristic
{
    //设置发现设service的Characteristics的委托
    NSString* channelNameString = self.curPeripheral.identifier.UUIDString;
    @weakify(self);
    
    [self.eventDispather setDiscoverCharacteristicsBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBService *service, NSError *error) {
        @strongify(self);
        if (self.curDeviceInfo.isRetriveDevice) {
            
            [self.eventDispather setDidDiscoverDescriptorsOnReadValueForDescriptorsBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
                CBCharacteristic *serviceInner = descriptor.characteristic;
                @strongify(self);
                
                if ([serviceInner.service.UUID.UUIDString containsString:sendServiceUUID16]) {
                    if ([serviceInner.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
                        for (CBDescriptor *descriStr in serviceInner.descriptors) {
                            NSString *strDesCriptor = [NSString stringWithFormat:@"%@",descriStr.value];
                            NSData *data = [[NSData alloc]initWithBase64EncodedString:strDesCriptor options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            BOOL valid = NO;
                            if (data.length >= 5) {
                                Byte* byteData = (Byte*)[data bytes];
                                if (byteData[0] == 0x09
                                    && byteData[1] == 0x05) {
                                    valid = YES;
                                }
                            } else {
                                valid = NO;
                            }
                            
                            if (valid && [self.curDeviceInfo.modelNumberString isEqualToString:modelNumberUnknown]) {
                                [self.curDeviceInfo updateManufacturerData:data];
                                [self p_doWithService:service andChannal:self.curPeripheral.identifier.UUIDString];
                                break;
                            }
                        }
                    }
                }
            }];
            
            //            [self.eventDispather setDidDiscoverDescriptorsForCharacteristicBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBPeripheral *peripheral, CBCharacteristic *serviceInner, NSError *error) {
            //                @strongify(self);
            //
            //                if ([serviceInner.service.UUID.UUIDString containsString:sendServiceUUID16]) {
            //                    if ([serviceInner.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            //                        for (CBDescriptor *descriStr in serviceInner.descriptors) {
            //                            //NSLog(@"---%@,%@",descriStr,descriStr.value);
            //                            NSString *strDesCriptor = [NSString stringWithFormat:@"%@",descriStr.value];
            //                            NSData *data = [[NSData alloc]initWithBase64EncodedString:strDesCriptor options:NSDataBase64DecodingIgnoreUnknownCharacters];
            //                            BOOL valid = NO;
            //                            if (data.length >= 4) {
            //                                Byte* byteData = (Byte*)[data bytes];
            //                                if (byteData[0] == 0x09
            //                                    && byteData[1] == 0x05) {
            //                                    valid = YES;
            //                                }
            //                            } else {
            //                                valid = NO;
            //                            }
            //
            //                            if (valid && [self.curDeviceInfo.modelNumberString isEqualToString:modelNumberUnknown]) {
            //                                [self.curDeviceInfo updateManufacturerData:data];
            //                                [self p_doWithService:service andChannal:self.curPeripheral.identifier.UUIDString];
            //                                break;
            //                            }
            //
            //
            //
            ////                            strDesCriptor = [strDesCriptor stringByReplacingOccurrencesOfString:@"-" withString:@""];
            ////                            if ([strDesCriptor containsString:@"0905"] && strDesCriptor.length >= 10 && [self.curDeviceInfo.modelNumberString isEqualToString:modelNumberUnknown]) {
            ////                                char *strChar= (char *)[strDesCriptor UTF8String];
            ////                                BYTE bytes[6];
            ////                                for (int i = 0; i < 10; ) {
            ////                                    uint8  valut = ((strChar[i] - 0x30) << 4) + (strChar[i + 1] - 0x30);
            ////                                    memcpy(&bytes[i/2], &valut, 1);
            ////                                    i+= 2;
            ////                                }
            ////                                NSData *data = [NSData dataWithBytes:bytes length:6];
            ////                                [self.curDeviceInfo updateManufacturerData:data];
            ////
            ////                                [self p_doWithService:service andChannal:self.curPeripheral.identifier.UUIDString];
            ////                            }
            //                        }
            //                    }
            //                }
            //
            //            }];
        }
        else{
            [self p_doWithService:service andChannal:self.curPeripheral.identifier.UUIDString];
        }
        
        
    }];
}

-(void)p_doWithService:(CBService *)service andChannal:(NSString *)channelNameString{
    @weakify(self);
    
    if ([self isMessageService:service.UUID.UUIDString]) {
        self.messageChannelCount = service.characteristics.count;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        BOOL usefullCharacteristic = YES;
        if ([characteristic.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC_UUID]) {
            self.writeCharacteristic = characteristic;
            //NSLog(@"write characteristic is found value is %@", characteristic.value);
            
        } else if ([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            self.notifyCharacteristic = characteristic;
            //NSLog(@"notify characteristic is found value is %@", characteristic.value);
            
            
        } else if ([characteristic.UUID.UUIDString isEqualToString:RESEND_CHARACTERISTIC_UUID]) {
            self.commandCharacteristic = characteristic;
            //NSLog(@"resend characteristic is found value is %@", characteristic.value);
        } else if ([characteristic.UUID.UUIDString isEqualToString:Device_SYSTEM_ID_UUID]  //systemID
                   || [characteristic.UUID.UUIDString isEqualToString:Device_FIRMWARE_UUID] //firmware
                   || [characteristic.UUID.UUIDString isEqualToString:Device_MANUFACTURER_UUID]) { //manufacuturer
            [self readCharacteristicDetails: characteristic];
        } else {
            usefullCharacteristic = NO;
        }
        if (usefullCharacteristic) {
            [self.eventDispather recordCharacteristicForPeripheral:self.curDeviceInfo.peripheral withCharacteristic:characteristic];
        }
    }
    if (self.connectState != ZYBleDeviceStateReady) {
        if ([self checkMessageChannel]) {
            
            //设置通知状态改变的block
            [self.eventDispather setDidUpdateNotificationStateForCharacteristicBlock:self.curPeripheral atChannel:channelNameString withBlock:^(CBCharacteristic *characteristic, NSError *error) {
                @strongify(self);
                //NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
                if (self.connectState != ZYBleDeviceStateReady
                    && self.notifyCharacteristic.isNotifying) {
                    [self onCommandChannelIsReady];
                }
            }];
            
            [self notify:self.notifyCharacteristic];
            [self notify:self.commandCharacteristic];
            
            self.refBabyble.characteristicDetails(self.curPeripheral, self.notifyCharacteristic);
            
            //通知状态已经就绪时在设置一次
            if (self.notifyCharacteristic.isNotifying) {
                if (self.connectState != ZYBleDeviceStateReady) {
                    [self onCommandChannelIsReady];
                    
                }
            }
        }
    }
}

- (void) onCommandChannelIsReady
{
    //NSLog(@"设备：%@--指令就绪", self.curPeripheral.name);
    self.connectState = ZYBleDeviceStateReady;
    [self initRequestQueue];
    [self initCache];
    
    
    BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateReady);
}

- (BOOL) checkMessageChannel
{
    if (self.messageChannelCount > 0) {
        BOOL result = YES;
        result &= (self.writeCharacteristic && self.notifyCharacteristic);
        if (self.messageChannelCount > 2) {
            result &= (self.commandCharacteristic != nil);
        }
        return result;
    }
    return NO;
}

- (BOOL) isMessageService:(NSString*)uuid
{
    return [uuid isEqualToString:self.curDeviceInfo.isAddress16?sendServiceUUID16:sendServiceUUID128];
    //    return [uuid isEqualToString:self.curDeviceInfo.isAddress16?sendServiceUUID16:sendServiceUUID128];
}

- (void)readCharacteristicDetails:(CBCharacteristic*)characteristic
{
    //    [self.refBabyble setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
    //        if (self.curPeripheral != peripheral) {
    //            return;
    //        }
    //        //NSLog(@"readCharacteristicDetails %@", characteristic);
    //    }];
    self.refBabyble.characteristicDetails(self.curPeripheral, characteristic);
}

+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

-(void)notify:(CBCharacteristic *)characteristic
{
    if (!characteristic) {
        return;
    }
    if (characteristic.properties & CBCharacteristicPropertyNotify || characteristic.properties & CBCharacteristicPropertyIndicate) {
        
        if(!characteristic.isNotifying) {
            
            [self.curPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            @weakify(self);
            [self.refBabyble notify:self.curPeripheral
                     characteristic:characteristic
                              block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                @strongify(self);
                if (self.curPeripheral != peripheral) {
                    return;
                }
                //NSLog(@"notify block %@ %@ %@", characteristics.UUID, characteristics.value, error);
                if (!error) {
                    if (characteristics == self.notifyCharacteristic) {
                        if (self.notifyCharacteristic.value) {
                            @autoreleasepool {
                                NSMutableData *data = [NSMutableData dataWithData:self.notifyCharacteristic.value];
                                [self dealRecieveData:data];
                                
                            }
                        }
                    }else if(characteristic == self.commandCharacteristic){
                        if (characteristic.value) {
                            @autoreleasepool {
                                NSMutableData *data = [NSMutableData dataWithData:characteristic.value];
                                
                                [self dealCommandData:data];
                            }
                        }
                    }
                }
                
            }];
        }
        else{
            return;
        }
    }
}
/**
 协议收到数据
 
 @param data 回调数据
 */
-(void) dealRecieveData:(NSData*)data
{
    //NSLog(@"recv data:%@", data);
    if (data.length == 4) {
        Byte *testByte = (Byte *)[data bytes];
        
        if (testByte[0] == 0x00 && testByte[1] == 0x00
            && testByte[2] == 0x00 && testByte[3] == 0x00) {
            //NSLog(@"=========================屏蔽开始的00000000");
            return;
        }
        
    }
    
    @weakify(self);
    dispatch_async(_requestAccessQueue, ^{
        @strongify(self);
        // 防止指令被拆包
        [self.recvCache appendData:data];
        self.lastRecvTimeStamp = [NSDate date];
        
        // 是否需要调整解码器
        if ([ZYBlControlCoder canParse:self.recvCache]) {
            [self changeCoderIfNeed:@"recvCoder" clsType:[ZYBlControlCoder class]];
        } else {
            [self changeCoderIfNeed:@"recvCoder" clsType:[ZYStarControlCoder class]];
        }
        // 解析出有效数据包
        NSMutableArray* respondRequestArray = [NSMutableArray array];
        while ([self.recvCoder isValid:self.recvCache]) {
            [self postReciveDataNotiName];
            ZYControlData* controlData = [self.recvCoder decode:self.recvCache];
            NSUInteger dataUsedLen = [self.recvCoder dataUsedLen];
            if (controlData) {
                ZYBleDeviceRequest* recvRequest = buildRequestWithControlData(controlData);
                if (recvRequest) {
                    [self logRequest:recvRequest stringType:@"收到"];
                    if ([recvRequest isKindOfClass:[ZYBleMutableRequest class]]) {
                        ZYBleMutableRequest *requestM =(ZYBleMutableRequest *)recvRequest;
                        if ([requestM.controlData isKindOfClass:[ZYBlOtherHeart class]]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:ZYBlOtherHeartReciveNoti object:requestM.controlData];
                        }
                        
                        
                    }
                    if ([recvRequest needResponse]) {
                        if (recvRequest.blocked) {
                            ZYBleDeviceRequest* sendRequest = [self dealWithSynRequestNeedResponse:recvRequest];
                            if (sendRequest) {
                                //记录有响应的同步指令
                                [respondRequestArray addObject: sendRequest];
                            }
                        } else {
                            //移除有响应的异步指令
                            [self dealWithAsynRequestNeedResponse:recvRequest];
                        }
                    } else if ([recvRequest isKeyEvent]) {
                        //按键指令的处理
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Button_Event_Notification_ResourceData object:nil userInfo:@{@"KEY":@(recvRequest.param)}];
                    } else {
                        [recvRequest postNotificationIfNeed:self.recvCoder];
                    }
                } else {
                    //NSLog(@"%@ 无法识别的数据", controlData);
                }
                
            }
            if (dataUsedLen > 0) {
                [self.recvCache setData:[self.recvCache subdataWithRange:NSMakeRange(dataUsedLen, self.recvCache.length-dataUsedLen)]];
            } else {
                break;
            }
        }
        if (respondRequestArray.count > 0) {
            assert(self.waitingRequestCount <= self.requestQueue.count);
            ////NSLog(@"Process Queue %ld sending %@", _waitingRequestCount, _requestQueue);
            
            if (self.waitingRequestCount >= respondRequestArray.count) {
                self.waitingRequestCount -= respondRequestArray.count;
            } else {
                //NSLog(@"maybe some message miss matched");
                self.waitingRequestCount = 0;
            }
            [self removeRequestsFromQueue:respondRequestArray];
            assert(self.waitingRequestCount <= self.requestQueue.count);
        }
        
        [self processRequestQueue];
    });
}

-(ZYBleDeviceRequest*)dealWithSynRequestNeedResponse:(ZYBleDeviceRequest*)recvRequest {
    //多条指令发送时，返回指令可能乱序
    ZYBleDeviceRequest* request = nil;
    int maxCount = MIN((int)_requestQueue.count, 4);
    for (int j = 0; j < maxCount; j++) {
        ZYBleDeviceRequest* sendRequest = [self.requestQueue objectAtIndex:j];
        if ([recvRequest isSameCodeWithRequest:sendRequest] && sendRequest.isWaiting) {
            [sendRequest finishCountdown];
            if ([recvRequest isKindOfClass:[ZYBleMutableRequest class]]) {
                ((ZYBleMutableRequest*)recvRequest).realCode = sendRequest.realCode;
            }
            if (sendRequest.noNeedToUpdateDataCache == NO) {
                [self.dataCache updateModel:recvRequest.realCode param:recvRequest.param];
            }
            //            //NSLog(@"响应指令 %@", sendRequest);
            //BLOCK_EXEC_ON_MAINQUEUE(sendRequest.handler, ZYBleDeviceRequestStateResponse, recvRequest.param);
            [recvRequest notifyResultWithRequest:sendRequest state:ZYBleDeviceRequestStateResponse coder:self.recvCoder];
            request = sendRequest;
            break;
        }
    }
    
    if (!request) {
        //NSLog(@"%@ no matched response %@", recvRequest, self.requestQueue);
    }
    
    return request;
}

-(void)dealWithAsynRequestNeedResponse:(ZYBleDeviceRequest*)request {
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        ZYBleMutableRequest* recvRequest = (ZYBleMutableRequest*)request;
        ZYBleMutableRequest* sendRequest = [_asynRequestCache objectForKey:@(recvRequest.msgId)];
        if (sendRequest) {
            [sendRequest finishCountdown];
            if (sendRequest.noNeedToUpdateDataCache == NO) {
                [self.dataCache updateModel:recvRequest.realCode param:recvRequest.param];
            }
            ////NSLog(@"响应指令 %@", sendRequest);
            //BLOCK_EXEC_ON_MAINQUEUE(sendRequest.handler, ZYBleDeviceRequestStateResponse, recvRequest.param);
            [recvRequest notifyResultWithRequest:sendRequest state:ZYBleDeviceRequestStateResponse coder:self.recvCoder];
            [_asynRequestCache removeObjectForKey:@(sendRequest.msgId)];
        } else {
            //NSLog(@"%@ no matched response %@", recvRequest, self.requestQueue);
        }
    }
}

-(void)dealCommandData:(NSData *)data {
    
    int lenght = (int)[data length];
    
    if (lenght==4) {
        [self.commandCoder setContentType:SCCContentTypeData];
    } else {
        [self.commandCoder setContentType:SCCContentTypeFull];
    }
    
    ZYControlData* controlData = [self.commandCoder decode:data];
    if (controlData) {
        ZYBleDeviceRequest* request = buildRequestWithControlData(controlData);
        if (request) {
            if ([request isKeyEvent]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:Device_Button_Event_Notification_ResourceData object:nil userInfo:@{@"KEY":@(request.param)}];
            }
        }
    }
}

-(void)dealWriteNotyfi:(NSData *)data{
    //NSLog(@"write notfify:%@",data);
}

-(void)changeCoderIfNeed:(NSString*)coderName clsType:(Class) cls
{
    NSObject* coder = [self valueForKey:coderName];
    if (coder && ![coder isKindOfClass:cls]) {
        //NSLog(@"Auto change coder from %@ to %@", NSStringFromClass(coder.class), NSStringFromClass(cls));
        [self setValue:[[cls alloc] init] forKey:coderName];
    }
}

-(void)changeCoderWithRequest:(ZYBleDeviceRequest *)request{
    //    //NSLog(@"%d======code=%lu",request.parseFormat,request.code);
    //    return;
    
    switch (request.parseFormat) {
        case ZYCodeParseUsb:
        {
            [self changeCoderIfNeed:@"sendCoder" clsType:[ZYUsbControlCoder class]];
            break;
        }
        case ZYCodeParseBl:
        {
            [self changeCoderIfNeed:@"sendCoder" clsType:[ZYBlControlCoder class]];
            break;
        }
        case ZYCodeParseStar:
        {
            [self changeCoderIfNeed:@"sendCoder" clsType:[ZYStarControlCoder class]];
            break;
        }
        default:
            break;
    }
    
}

/**
 协议超时
 
 @param request 蓝牙请求数据
 */
-(void) dealTimeout:(ZYBleDeviceRequest*)request
{
    //NSLog(@"dealTimeout %@", request);
    @weakify(self)
    dispatch_async(self.requestAccessQueue, ^{
        @strongify(self)
        if (self.requestQueue.count == 0) {
            //NSLog(@"%@ no message is waiting", request);
        } else {
            NSUInteger idxRequest = [self.requestQueue indexOfObject:request];
            if (idxRequest <= self.waitingRequestCount) {
                [self.requestQueue removeObjectAtIndex:idxRequest];
                self.waitingRequestCount--;
                //NSLog(@"%@ is time out@", request);
                //通知回调超时
                //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateTimeout, 0);
                [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateTimeout coder:self.recvCoder];
                assert(self.waitingRequestCount <= self.requestQueue.count);
            } else {
                //NSLog(@"waiting request %@ is not matched time out request %@", self.requestQueue.firstObject, request);
            }
        }
        [self processRequestQueue];
    });
}

-(void) dealAsynTimeout:(ZYBleMutableRequest*)request
{
    @weakify(self)
    dispatch_async(self.requestAccessQueue, ^{
        @strongify(self)
        [self.asynRequestCache removeObjectForKey:@(request.msgId)];
        //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateTimeout, 0);
        [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateTimeout coder:self.recvCoder];
        [self processRequestQueue];
    });
}



-(void) initRequestQueue
{
    dispatch_async(self.requestAccessQueue, ^{
        if (self.requestQueue.count != 0) {
            self.requestQueue = [NSMutableArray array];
        }
        self.waitingRequestCount = 0;
    });
}

-(void) initCache
{
    dispatch_async(self.requestAccessQueue, ^{
        [self.sendCache setData:[NSData data]];
        [self.recvCache setData:[NSData data]];
    });
}

-(void) cancelAllRequest
{
    @weakify(self)
    dispatch_async(self.requestAccessQueue, ^{
        @strongify(self)
        for (ZYBleDeviceRequest* request in self.requestQueue) {
            [request finishCountdown];
            //通知回调超时
            //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateTimeout, 0);
            [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateTimeout coder:self.recvCoder];
        }
        [self.requestQueue removeAllObjects];
        self.waitingRequestCount = 0;
    });
}


#pragma 蓝牙连接
-(void) connectDevice:(ZYBleDeviceInfo*)deviceInfo withDispatcher:(ZYBleDeviceDispacther*)dispacther completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler;
{
    if (self.connectState == ZYBleDeviceStateConnected
        || self.connectState == ZYBleDeviceStateConnecting
        || self.connectState == ZYBleDeviceStateReady ){
        if ([deviceInfo.name isEqualToString:self.curDeviceInfo.name]) {
            //NSLog(@"设备：%@--已经连接", self.curPeripheral.name);
            BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, self.connectState);
        } else {
            //NSLog(@"设备：%@--连接前需要断开%@", deviceInfo.name, self.curDeviceInfo.name);
            BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateFail);
        }
    } else {
        if (deviceInfo == NULL || deviceInfo.peripheral == NULL) {
            [self connectionTimeout:nil];
            return;
        }
        
        self.deviceStatusHandler = deviceStatusHandler;
        self.curPeripheral = deviceInfo.peripheral;
        self.curDeviceInfo = deviceInfo;
        self.eventDispather = dispacther;
        self.connectState = ZYBleDeviceStateConnecting;
        //NSLog(@"设备：%@--开始连接", self.curPeripheral.name);
        [self initPeripheral];
        [self initCharacteristic];
        [self beginConnectionTimeout];
        self.refBabyble.having(self.curPeripheral).then.connectToPeripherals().discoverServices().discoverCharacteristics().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        
        NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
        
        NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                         CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                         CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        
        [self.refBabyble setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    }
}

-(void) connectionTimeout:(NSTimer*)timer
{
    //NSLog(@"设备：%@--连接超时",self.curPeripheral.name);
    self.connectState = ZYBleDeviceStateFail;
    BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateFail);
    
    _connectionTimeoutTimer = nil;
}

-(void) cancelConnectionTimeout
{
    if (_connectionTimeoutTimer) {
        [_connectionTimeoutTimer invalidate];
        _connectionTimeoutTimer = nil;
    }
}

-(void) beginConnectionTimeout
{
    if (!_connectionTimeoutTimer) {
        _connectionTimeoutTimer = [NSTimer timerWithTimeInterval:CONNECTION_TIMEOUT target:self selector:@selector(connectionTimeout:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_connectionTimeoutTimer forMode:NSRunLoopCommonModes];
    }
}

-(void) disconnectionTimeout:(NSTimer*)timer
{
    //NSLog(@"设备：%@--连接超时",self.curPeripheral.name);
    self.connectState = ZYBleDeviceStateFail;
    BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateFail);
    
    _connectionTimeoutTimer = nil;
}

-(void) cancelDisconnectionTimeout
{
    if (_disconnectionTimeoutTimer) {
        [_disconnectionTimeoutTimer invalidate];
        _disconnectionTimeoutTimer = nil;
    }
}

-(void) beginDisconnectionTimeout
{
    if (!_disconnectionTimeoutTimer) {
        _disconnectionTimeoutTimer = [NSTimer timerWithTimeInterval:DISCONNECTION_TIMEOUT target:self selector:@selector(disconnectionTimeout:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_disconnectionTimeoutTimer forMode:NSRunLoopCommonModes];
    }
}

#pragma 断开蓝牙连接
-(void) disconnectDevice
{
    if ([self canDisconnect]) {
        self.connectState = ZYBleDeviceStateDisconnecting;
        //取消掉所有需要发送的指令
        [self cancelAllRequest];
        //断开当前连接
        if (self.curPeripheral
            && (self.curPeripheral.state == CBPeripheralStateConnecting
                || self.curPeripheral.state == CBPeripheralStateConnected)) {
            [self.refBabyble cancelPeripheralConnection:self.curPeripheral];
            //NSLog(@"设备：%@--准备断开",self.curPeripheral?self.curPeripheral.name:@"");
        } else {
            self.connectState = ZYBleDeviceStateMissConnected;
            [self disconnectDevice];
        }
    } else {
        //已经断开 清空数据
        //NSLog(@"设备：%@--已经断开",self.curPeripheral?self.curPeripheral.name:@"");
        [_eventDispather removeChannelForPeripheral:self.curPeripheral];
        self.curPeripheral = nil;
        self.connectState = ZYBleDeviceStateMissConnected;
        self.writeCharacteristic = nil;
        self.notifyCharacteristic = nil;
        self.commandCharacteristic = nil;
        self.messageChannelCount = -1;
        BLOCK_EXEC_ON_MAINQUEUE(self.deviceStatusHandler, ZYBleDeviceStateMissConnected)
    }
    
    [self cancelConnectionTimeout];
}

#pragma 蓝牙指令交互
-(void)sendRequest:(ZYBleDeviceRequest*)request
{
    
    if (self.connectState != ZYBleDeviceStateReady) {
        //通知回调超时
        //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateFail, 0)
        [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateFail coder:self.recvCoder];
        return;
    }
    //NSLog(@"00000");
    
    @weakify(self)
    dispatch_async(_requestAccessQueue, ^{
        @strongify(self)
        //NSLog(@"11-------%@ %@",self.requestQueue,request);
        
        if (![self.requestQueue containsObject:request] || request.mask == ZYBleDeviceRequestMaskUpdate) {
            [self dispathRequest:request atIndex:NSNotFound];
            //NSLog(@"222");
            
        } else {
            //NSLog(@"333333");
            //NSLog(@"%@",self.requestQueue);
            //NSLog(@"ignore same request %@", request);
            //NSLog(@"ignore same request %@", request);
            
            //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateIgnore, 0);
            [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateIgnore coder:self.recvCoder];
        }
        
        [self processRequestQueue];
    });
}

-(void)sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests
{
    if (self.connectState != ZYBleDeviceStateReady) {
        //通知指令失败
        for (ZYBleDeviceRequest* request in requests) {
            //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateFail, 0)
            [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateFail coder:self.recvCoder];
        }
        return;
    }
    
#pragma -mark 暂时把移动的改为单个发送
    ZYBleDeviceRequest *request = requests[0];
    if (request.mask  == ZYBleDeviceRequestMaskUpdate) {
        for (ZYBleDeviceRequest *temp  in requests) {
            [self sendRequest:temp];
        }
        return;
    }
    
    @weakify(self)
    dispatch_async(_requestAccessQueue, ^{
        @strongify(self)
        NSMutableArray<ZYBleDeviceRequest*>* noSameRequests = [NSMutableArray array];
        NSMutableArray* sameRequestIdxs = [NSMutableArray array];
        for (ZYBleDeviceRequest* request in requests) {
            NSUInteger idx = [self.requestQueue indexOfObject:request];
            if (idx == NSNotFound) {
                [noSameRequests addObject:request];
            } else {
                [sameRequestIdxs addObject:@{@"idx":@(idx), @"request":request}];
            }
        }
        if (sameRequestIdxs.count > 0) {
            for (NSDictionary* info in sameRequestIdxs) {
                NSUInteger idx = ((NSNumber*)info[@"idx"]).unsignedIntegerValue;
                ZYBleDeviceRequest* request = info[@"request"];
                ZYBleDeviceRequest* sameRequest = [self.requestQueue objectAtIndex:idx];
                if (sameRequest.mask == ZYBleDeviceRequestMaskUnique) {
                    //NSLog(@"ignore same request %@", request);
                    //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateIgnore, 0);
                    [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateIgnore coder:self.recvCoder];
                } else if (request.mask == ZYBleDeviceRequestMaskUpdate){
                    //                    [self dispathRequest:request atIndex:idx];
                    //                    BLOCK_EXEC_ON_MAINQUEUE(sameRequest.handler, ZYBleDeviceRequestStateIgnore, 0)
                } else {
                    [self dispathRequest:request atIndex:NSNotFound];
                }
            }
        }
        if (noSameRequests.count>0) {
            for (ZYBleDeviceRequest* request in noSameRequests) {
                [self dispathRequest:request atIndex:NSNotFound];
            }
        }
        
        [self processRequestQueue];
    });
}

-(void)dispathRequest:(ZYBleDeviceRequest*)request atIndex:(NSUInteger) idx
{
    [self changeCoderWithRequest:request];
    if (request.blocked) {
        if ([_sendCoder isKindOfClass:[ZYBlControlCoder class]]) {
            ZYBleMutableRequest* asynRequest = transferDeviceRequestToMutable(request, _sendCoder);
            
            if (asynRequest.needSendSoon) {
                if (_requestQueue.count > 0) {
                    [_requestQueue insertObject:asynRequest atIndex:self.waitingRequestCount];
                }
                else{
                    [_requestQueue addObject:asynRequest];
                }
                return;
            }
            if (asynRequest.blocked) {
                //bl协议的指令也可以同步发送
                if (idx == NSNotFound) {
                    [_requestQueue addObject:asynRequest];
                } else {
                    [_requestQueue replaceObjectAtIndex:idx withObject:asynRequest];
                }
            } else {
                [_asynRequestQueue addObject:asynRequest];
            }
        } else {
            if (idx == NSNotFound) {
                [_requestQueue addObject:request];
            } else {
                [_requestQueue replaceObjectAtIndex:idx withObject:request];
            }
        }
    } else {
        ZYBleMutableRequest* asynRequest = transferDeviceRequestToMutable(request, _sendCoder);
        
        if (asynRequest.needSendSoon) {
            if (_asynRequestQueue.count > 0) {
                [_asynRequestQueue insertObject:asynRequest atIndex:self.waitingRequestCount];
            }
            else{
                [_asynRequestQueue addObject:asynRequest];
            }
            return;
        }
        [_asynRequestQueue addObject:transferDeviceRequestToMutable(request, _sendCoder)];
    }
}


-(BOOL)canConnect
{
    return self.connectState != ZYBleDeviceStateConnecting && self.connectState != ZYBleDeviceStateConnected;
}

-(BOOL)canDisconnect
{
    return self.connectState == ZYBleDeviceStateConnecting || self.connectState == ZYBleDeviceStateConnected || self.connectState == ZYBleDeviceStateReady;
}

-(BOOL)canSendData
{
    return self.writeCharacteristic
    && self.curPeripheral
    && self.curPeripheral.state == CBPeripheralStateConnected;
}

-(void)sendData:(NSData*)data
{
    NSUInteger maximumWriteValue = [self.curPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
    if (maximumWriteValue >= 20) {
        self.maximumExpectedWriteValue = maximumWriteValue;
    }
    if ([self canSendData]) {
        if (data.length > self.maximumExpectedWriteValue) {
            [_sendCache appendData:data];
        }
        
        if (_sendCache.length == 0) {
            [self writeValueToPeripheral:data];
        } else {
            @weakify(self)
            void(^__block sendFragData)(void) = ^(void) {
                @strongify(self)
                
                NSUInteger sendCount = MIN(self.sendCache.length, self.maximumExpectedWriteValue);
                if (sendCount != 0 && [self canSendData]) {
                    [self writeValueToPeripheral:[self.sendCache subdataWithRange:NSMakeRange(0, MIN(self.sendCache.length, self.maximumExpectedWriteValue))]];
                    
                    [self.sendCache setData:[self.sendCache subdataWithRange:NSMakeRange(sendCount, self.sendCache.length - sendCount)]];
                    
                    if (self.sendCache.length > 0) {
                        //NSLog(@"已发送%lu剩余%lu", sendCount,(unsigned long)self.sendCache.length);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), sendFragData);
                    } else {
                        //NSLog(@"发送结束剩余%lu",(unsigned long)self.sendCache.length);
                        sendFragData = nil;
                    }
                    
                } else {
                    //NSLog(@"发送结束");
                    sendFragData = nil;
                }
            };
            sendFragData();
        }
        
    } else {
        //NSLog(@"write characteristic is not ready");
    }
}

-(void) writeValueToPeripheral:(NSData*)data
{
    _lastSendTimeStamp = [NSDate date];
    //NSLog(@"sendData :%@ 长度%lu", data, (unsigned long)data.length);
    //    //NSLog(@"curPeripheral ：%@ \n writeCharacteristic ：%@  \n  sendData :%@ 长度%lu",self.curPeripheral, self.writeCharacteristic,data, (unsigned long)data.length);
    
    if (self.notifyCharacteristic&& !self.notifyCharacteristic.isNotifying) {
        //设备不能接受到应答的时候不需要发送
        return;
    }
    [self.curPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma 必须在_requestAccessQueue队列中使用
-(void) processRequestQueue
{
    if (self.waitingRequestCount > 0) {
        //略过等待指令中的控制指令
        NSMutableArray<ZYBleDeviceRequest*>* noResponseRequest = [NSMutableArray array];
        assert(self.waitingRequestCount <= self.requestQueue.count);
        for (int i = 0; i < self.waitingRequestCount; i++) {
            ZYBleDeviceRequest* request = [self.requestQueue objectAtIndex:i];
            if (!request.needResponse) {
                [noResponseRequest addObject:request];
                
                //写入成功但是略过的指令任然需要认为是完成了
                [request finishCountdown];
                //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateResponse, 0);
                [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateResponse coder:self.recvCoder];
            }
        }
        
        if (noResponseRequest.count > 0) {
            self.waitingRequestCount -= noResponseRequest.count;
            [self removeRequestsFromQueue:noResponseRequest];
            
            assert(self.waitingRequestCount <= self.requestQueue.count);
            ////NSLog(@"process Queue %ld ignore %@", self.waitingRequestCount, noResponseRequest);
        }
        
        if (self.waitingRequestCount > 0) {
            //NSLog(@"process Queue %ld waiting %@", self.waitingRequestCount, self.requestQueue);
            return;
        }
    }
    
    [self sendSynMessageFromRequestQueue];
    [self sendAsynMessageFromRequestQueue];
}

#pragma -mark 新的发送方法
-(void)newSendSynMessageFromRequestQueue{
    if (_sendCache.length != 0) {
        return;
    }
    NSUInteger maximumWriteValue = [self.curPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
    if (maximumWriteValue >= 20) {
        self.maximumExpectedWriteValue = maximumWriteValue;
    }
    if (self.requestQueue.count >= 2) {
        NSMutableData *data = [NSMutableData data];
        NSMutableArray *array = [NSMutableArray array];
        for (ZYBleDeviceRequest* request in self.requestQueue) {
            [self changeCoderWithRequest:request];
            NSData *currentData = [request translateToBinaryWithCoder:_sendCoder];
            if (array.count == 0) {
                [data appendData:currentData];
                [array addObject:request];
            }else{
                if (data.length + currentData.length > self.maximumExpectedWriteValue) {
                    break;
                }
                else{
                    [data appendData:currentData];
                    [array addObject:request];
                }
            }
        }
        [self sendData:data];
        self.waitingRequestCount += array.count;
        for (ZYBleDeviceRequest *temp in array) {
            @weakify(self)
            [temp startCountdown:TIME_OUT_TIME block:^{
                @strongify(self)
                [self dealTimeout:temp];
            }];
            [self logRequest:temp stringType:@"package多个发送"];
            
        }
        assert(self.waitingRequestCount <= self.requestQueue.count);
        
    }
    else{
        if (_requestQueue.count >= 1) {
            
            ZYBleDeviceRequest* request = [self.requestQueue objectAtIndex:0];
            [self changeCoderWithRequest:request];
            NSData* data = [request translateToBinaryWithCoder:_sendCoder];
            [self sendData:data];
            
            self.waitingRequestCount += 1;
            
            @weakify(self)
            [request startCountdown:TIME_OUT_TIME block:^{
                @strongify(self)
                [self dealTimeout:request];
            }];
            assert(self.waitingRequestCount <= self.requestQueue.count);
            [self logRequest:request stringType:@"packeg发送"];
            
        }
    }
}
-(void)logRequest:(ZYBleDeviceRequest *)request stringType:(NSString *)str{
    return;
    if ([request isKindOfClass:[ZYBleMutableRequest class] ]) {
        ZYBleMutableRequest *requestTT = request;
        if ([requestTT.controlData isKindOfClass:[ZYBlOtherHeart class]] || [requestTT.controlData isKindOfClass:[ZYBlRdisData class]]) {
            return;
        }
    }
    NSLog(@"%@有效指令 %@",str, request);
}

-(void) sendSynMessageFromRequestQueue {
    if (self.dataCache.newSendMessagePakge) {
        [self newSendSynMessageFromRequestQueue];
        return;
    }
    if (_sendCache.length != 0) {
        return;
    }
    bool SendPacked = NO;
    
    if (_requestQueue.count >= 2) {
        ZYBleDeviceRequest* request1 = [self.requestQueue objectAtIndex:0];
        ZYBleDeviceRequest* request2 = [self.requestQueue objectAtIndex:1];
        if (!request2.packedWithNext) {
            [self changeCoderWithRequest:request1];
            
            NSMutableData* data = [NSMutableData dataWithData:[request1 translateToBinaryWithCoder:_sendCoder]];
            [data appendData:[request2 translateToBinaryWithCoder:_sendCoder]];
            [self sendData:data];
            
            self.waitingRequestCount += 2;
            
            @weakify(self)
            [request1 startCountdown:TIME_OUT_TIME block:^{
                @strongify(self)
                [self dealTimeout:request1];
            }];
            [request2 startCountdown:TIME_OUT_TIME block:^{
                @strongify(self)
                [self dealTimeout:request2];
            }];
            
            assert(self.waitingRequestCount <= self.requestQueue.count);
            //            //NSLog(@"发送有效指令 %@ %@", request1, request2);
            
            [self logRequest:request1 stringType:@"发送"];
            [self logRequest:request2 stringType:@"发送"];
            
            SendPacked = YES;
        }
    }
    if (!SendPacked) {
        if (_requestQueue.count >= 1) {
            ZYBleDeviceRequest* request = [self.requestQueue objectAtIndex:0];
            [self changeCoderWithRequest:request];
            NSData* data = [request translateToBinaryWithCoder:_sendCoder];
            [self sendData:data];
            
            self.waitingRequestCount += 1;
            
            @weakify(self)
            [request startCountdown:TIME_OUT_TIME block:^{
                @strongify(self)
                [self dealTimeout:request];
            }];
            assert(self.waitingRequestCount <= self.requestQueue.count);
            //NSLog(@"发送有效指令 %@", request);
            [self logRequest:request stringType:@"发送"];
            
        }
    }
    
    //NSLog(@"process Queue %ld sending %@", _waitingRequestCount, [_requestQueue description]);
}

-(void) sendAsynMessageFromRequestQueue {
    if (self.asynRequestCache.count >= self.maxAsynRequestCount) {
        return;
    }
    
    __block NSInteger idxSend = -1;
    @weakify(self)
    
    [self.asynRequestQueue enumerateObjectsUsingBlock:^(ZYBleMutableRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        idxSend = idx;
        [self changeCoderWithRequest:request];
        NSData* data = [request translateToBinaryWithCoder:self.sendCoder];
        [self sendData:data];
        //NSLog(@"%@",request.command);
        [request startCountdown:TIME_OUT_TIME block:^{
            @strongify(self)
            [self dealAsynTimeout:request];
        }];
        [self.asynRequestCache setObject:request forKey:@(request.msgId)];
        *stop = self.asynRequestCache.count >= self.maxAsynRequestCount;
    }];
    
    if (idxSend >= 0) {
        [self.asynRequestQueue removeObjectsInRange:NSMakeRange(0, idxSend+1)];
    }
}

-(void) removeRequestsFromQueue:(NSArray*)requests {
    for (ZYBleDeviceRequest* request in requests) {
        NSUInteger idx = [self.requestQueue indexOfObject:request];
        if (idx != NSNotFound) {
            [self.requestQueue removeObjectAtIndex:idx];
        }
    }
}

-(void)dealloc{
    [self removeNoti];
}
//移除进入后台的通知
-(void)removeNoti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ConnectLinkChange object:nil];
}

/**
 检查进入前台的通知
 */
-(void)addNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiEnableNoti:) name:ConnectLinkChange object:nil];
    
}

-(void)wifiEnableNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:ConnectLinkChange]) {
        NSNumber *enable = [noti.userInfo objectForKey:ConnectLinkChange];
        if ([enable integerValue] == ZYConnectTypeOnlyWifi) {
            _inactiveNoti = YES;
        }
        else{
            _inactiveNoti = NO;
        }
        
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        
        if (state == UIApplicationStateActive) {
            [self enterForeground];
        }
    }
}
/**
 关闭通知，防止进入后台之后有弹出打开app
 */
-(void)enterBackground{
    if (self.curPeripheral) {
        if (self.commandCharacteristic&& self.commandCharacteristic.isNotifying) {
            [self.curPeripheral setNotifyValue:NO forCharacteristic:self.commandCharacteristic];
        }
        if (self.notifyCharacteristic&& self.notifyCharacteristic.isNotifying) {
            [self.curPeripheral setNotifyValue:NO forCharacteristic:self.notifyCharacteristic];
        }
    }
}

/**
 进入前台的时候开启通知
 */
-(void)enterForeground{
    if (_inactiveNoti) {
        [self enterBackground];
    }
    else{
        if (self.curPeripheral) {
            if (self.commandCharacteristic&& !self.commandCharacteristic.isNotifying) {
                [self.curPeripheral setNotifyValue:YES forCharacteristic:self.commandCharacteristic];
            }
            if (self.notifyCharacteristic && !self.notifyCharacteristic.isNotifying) {
                [self.curPeripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
            }
        }
    }
    
}

-(void)mindBlueToothNotify{
    if (self.curPeripheral) {
        if (self.commandCharacteristic&& !self.commandCharacteristic.isNotifying) {
            [self.curPeripheral setNotifyValue:YES forCharacteristic:self.commandCharacteristic];
        }
        if (self.notifyCharacteristic && !self.notifyCharacteristic.isNotifying) {
            [self.curPeripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
        }
    }
}
@end
