//
//  ZYWifiConnection.m
//  ZYCamera
//
//  Created by lgj on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYWifiConnection.h"
#import "ZYBleMutableRequest.h"
#import "ZYBlControlCoder.h"
#import "GCDAsyncUdpSocket.h"
#import "UIDevice+WifiOpened.h"
#import "ZYStarControlCoder.h"
#import "ZYUsbControlCoder.h"
#import "ZYUsbInstructionHeartBeatData.h"
#import "ZYStablizerDefineENUM.h"
#import "ZYBlOtherHeart.h"
#define TIME_OUT_TIME 200

#define KWifiTimeOutTime 0.2

#define keyButtonMsgID 0 //按键的信息ID

#define kBindPort 18888
#define kRecivePort 8888
#define kTESTFORGUILING 0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


@interface ZYWifiConnection()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, readwrite, strong) NSMutableArray<ZYBleMutableRequest*>* asynRequestQueueArray;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSNumber*, ZYBleMutableRequest*>* asynRequestCache;

@property (nonatomic, readwrite, strong) dispatch_queue_t requestAccessQueue;

//udp相关
@property (nonatomic)         NSString *host;
@property (nonatomic)         uint16_t port;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
///*!
// 从1开始
//
// */
//@property (nonatomic)         long tag;

@property (nonatomic, readwrite) NSMutableData* recvCache;
@property (nonatomic, readwrite, strong) ZYControlCoder* recvCoder;


@property (nonatomic)         BOOL  receviceing;

@property (nonatomic)         BOOL  receviceData;
@property (nonatomic)         NSDate  *hearDate;//收到心跳的日期

@property (nonatomic,strong)  NSDate  *beforeReciveNotiDate;//收到心跳的日期

@end

@implementation ZYWifiConnection
#pragma -mark GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
//    [self didSendDataWithTag:tag];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{

    [self failSendDataWithTag:tag];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
//    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    if (msg)
//    {
//        [self logMessage:FORMAT(@"RECV: %@", msg)];
//    }
//    else
//    {
//
//
//        [self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
//    }
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    if (port == kRecivePort) {
        self.receviceData = YES;
        [self dealRecieveData:data];
    }
    else{
        //NSLog(@"port = %d",port);
    }
}
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{
//    //NSLog(@"udpSocketDidClose -----------------------------------------------%@ isclose = %d",error,sock.isClosed);
    self.udpSocket.delegate = nil;
    self.udpSocket = nil;
    self.receviceData = NO;
    [self clearData];
    @weakify(self)
    [self runInRequestAsscessQueue:^{
        @strongify(self)
        for (ZYBleMutableRequest *request in self.asynRequestCache.allValues) {
            if (request) {
#ifdef DEBUG
                
                ////NSLog(@"remove 序号:%ld",tag);
#endif
                
                [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateFail coder:self.recvCoder];
                
                //            BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateFail, 0);
            }
        }
        [self.asynRequestCache removeAllObjects];
       
//        [self processRequestQueue];
        
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupSocket];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"udpsocketClose" object:nil];
            
    });
    
}
#pragma -mark GCDAsyncUdpSocketDelegate
- (void)sendUdpData:(NSData*)data withTimeOut:(NSTimeInterval)timeout tag:(long)tag
{
    [self.udpSocket sendData:data toHost:self.host port:self.port withTimeout:timeout tag:tag];
    [self logMessage:FORMAT(@"wifi udp SENT (%li): %@", tag, data)];
   
}

- (void)sendUdpData:(NSData*)data tag:(long)tag
{
    [self sendUdpData:data withTimeOut:KWifiTimeOutTime tag:tag];
}

- (void)setupSocket
{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    if (![self.udpSocket bindToPort:kBindPort error:&error])
    {
        [self logError:FORMAT(@"Error binding: %@", error)];
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        [self logError:FORMAT(@"Error receiving: %@", error)];
        return;
    }
    self.receviceing = YES;

    [self logInfo:@"Ready"];
}

-(void)pauseReceiving{
    if (self.receviceing == NO) {
        return;
    }
    self.receviceing = NO;
    dispatch_async(_requestAccessQueue, ^{
        [self clearData];
        [self.udpSocket pauseReceiving];
    });

}

-(void)begainReceiving{
    if (self.receviceing == YES) {
        return;
    }
    dispatch_async(_requestAccessQueue, ^{
        if (self.receviceing == YES) {
            return;
        }
        [self clearData];
        NSError *error = nil;
        
        if (![self.udpSocket beginReceiving:&error])
        {
            [self logError:FORMAT(@"Error receiving: %@", error)];
            return;
        }
        self.receviceing = YES;
        [self logInfo:@"Ready"];

    });
   
}

- (void)logError:(NSString *)msg
{
//    //NSLog(@"%@",msg);
}
- (void)logInfo:(NSString *)msg
{
//    //NSLog(@"%@",msg);
}
- (void)logMessage:(NSString *)msg
{
//    //NSLog(@"%@",msg);
}

-(void)changeCoderWithRequest:(ZYBleDeviceRequest *)request{
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
#pragma -mark 以上为socket代码
-(ZYControlCoder *)sendCoder{
    if (_sendCoder == nil) {
            _sendCoder = [[ZYUsbControlCoder alloc] init];
    }
    return _sendCoder;
}

-(ZYControlCoder *)recvCoder{
    if (_recvCoder == nil) {
        _recvCoder = [[ZYUsbControlCoder alloc] init];
    }
    return _recvCoder;
}


-(NSMutableArray<ZYBleMutableRequest *> *)asynRequestQueueArray{
    if (_asynRequestQueueArray == nil) {
        _asynRequestQueueArray = [[NSMutableArray alloc] init];
    }
    return _asynRequestQueueArray;
}

-(NSMutableData *)recvCache{
    if (_recvCache == nil) {
        _recvCache = [[NSMutableData alloc] init];
    }
    return _recvCache;
}

-(NSMutableDictionary<NSNumber *,ZYBleMutableRequest *> *)asynRequestCache{
    if (_asynRequestCache == nil) {
        _asynRequestCache = [[NSMutableDictionary alloc] init];
    }
    return _asynRequestCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.host = @"192.168.2.1";
        self.port = 8888;
        _requestAccessQueue = dispatch_queue_create("com.zhiyun-tech.ZYCamera.ConnectionwifiAccessQueue", DISPATCH_QUEUE_SERIAL);
        _maxAsynRequestCount = 20;
        [self setupSocket];
        self.beforeReciveNotiDate = [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(custom:) name:@"customSendData" object:nil];
    }
    return self;
}



-(void)custom:(NSNotification *)noti{
    dispatch_async(_requestAccessQueue, ^{
        NSData *data = noti.object;
        if (data) {
            [self sendData:data tag:10000];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wifiSendData" object:data];
        }
    });
    
}

-(void)runInRequestAsscessQueue:(void(^)())block{
    dispatch_async(_requestAccessQueue, block);
}

-(void)postReciveDataNotiName{
    if ([self.beforeReciveNotiDate timeIntervalSinceNow] < -kbeforeReciveNotiDateInterVale) {
        self.beforeReciveNotiDate = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReciveDataNotiName object:nil];
    }
}
#pragma 发送指令交互

-(void)sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests
{
    for (ZYBleDeviceRequest *request in requests) {
        [self sendRequest:request];
    }
}

-(void)sendRequest:(ZYBleDeviceRequest*)request
{
#pragma -mark 判断是否可以发送数据
    if (![UIDevice isWiFiOpened]) {
        [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateFail coder:self.recvCoder];
//        BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateFail, 0)
        return;
    }
    @weakify(self)
    dispatch_async(_requestAccessQueue, ^{
        @strongify(self)
        [self dispathRequest:request atIndex:NSNotFound];
        
        [self processRequestQueue];
    });
}

-(void)dispathRequest:(ZYBleDeviceRequest*)request atIndex:(NSUInteger) idx
{
    [self.asynRequestQueueArray addObject:transferDeviceRequestToMutable(request, _sendCoder)];
}


#pragma 必须在_requestAccessQueue队列中使用
-(void) processRequestQueue
{
    [self sendAsynMessageFromRequestQueue];
}


-(void) sendAsynMessageFromRequestQueue {
    if (self.asynRequestCache.count >= self.maxAsynRequestCount || self.udpSocket.isClosed || self.udpSocket == nil) {
        return;
    }
    
    NSInteger idxSend = -1;
    for (ZYBleMutableRequest *request in self.asynRequestQueueArray) {
        idxSend ++;
        NSData* data = [request translateToBinaryWithCoder:self.sendCoder];
#ifdef DEBUG
        //NSLog(@"wifi发送有效指令 %@ %lu", request,(unsigned long)request.msgId);
#endif
        //NSLog(@"wifi发送有效指令 %@ %lu", request,(unsigned long)request.msgId);
        if ([self.asynRequestCache objectForKey:@(request.msgId)]) {
            ZYBleMutableRequest *requestBefor = [self.asynRequestCache objectForKey:@(request.msgId)];
            if (requestBefor) {
                [self.asynRequestCache removeObjectForKey:@(requestBefor.msgId)];
                [requestBefor notifyResultWithRequest:requestBefor state:ZYBleDeviceRequestStateFail coder:self.recvCoder];
            }
        }
        [self sendData:data tag:request.msgId];
        [self.asynRequestCache setObject:request forKey:@(request.msgId)];
        [self didSendDataWithTag:request.msgId];
     
        if (self.asynRequestCache.count >= self.maxAsynRequestCount) {
            break;
        }
    }
    
    if (idxSend >= 0) {
        if (idxSend < self.asynRequestQueueArray.count)
            [self.asynRequestQueueArray removeObjectsInRange:NSMakeRange(0, idxSend+1)];
    }
}



-(void)failSendDataWithTag:(long)tag{
    @weakify(self)
    
    [self runInRequestAsscessQueue:^{
        @strongify(self)
        ZYBleMutableRequest *request = [self.asynRequestCache objectForKey:@(tag)];
        if (request) {
#ifdef DEBUG
            
            //NSLog(@"remove 序号:%ld",tag);
#endif

            [self.asynRequestCache removeObjectForKey:@(tag)];
            [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateFail coder:self.recvCoder];

//            BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateFail, 0);
        }
     
        [self processRequestQueue];
    
    }];
}

-(void)didSendDataWithTag:(long)tag{
    @weakify(self)
    __block long innerTag = tag;
    [self runInRequestAsscessQueue:^{
        @strongify(self)
        ZYBleMutableRequest *request = [self.asynRequestCache objectForKey:@(innerTag)];
        //用于硬件测试
        if (kTESTFORGUILING) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (innerTag != 10000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"wifiSendData" object:[NSString stringWithFormat:@"%@",request]];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"wifiSendData" object:[NSString stringWithFormat:@"自定义数据发送成功"]];
                }
            });
            
        }

        if (request) {
            [self countDownWithRequest:request];
        }
        else{
            [self processRequestQueue];
        }
    }];

}

-(void)countDownWithRequest:(ZYBleMutableRequest *)request{
    __block long innerTagTag = request.msgId;
    @weakify(self)
    if (!request.needResponse) {
#ifdef DEBUG
        
        //NSLog(@"remove 序号不需要等回复:%d",innerTagTag);
#endif

        [self.asynRequestCache removeObjectForKey:@(request.msgId)];
        [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateIgnore coder:self.recvCoder];

//        BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateIgnore, 0);

        return;
    }
    [request startCountdown:(TIME_OUT_TIME + 20) block:^{
        @strongify(self)
        dispatch_async(self.requestAccessQueue, ^{
            [self.asynRequestCache removeObjectForKey:@(innerTagTag)];
            //BLOCK_EXEC_ON_MAINQUEUE(request.handler, ZYBleDeviceRequestStateTimeout, 0);
            [request notifyResultWithRequest:request state:ZYBleDeviceRequestStateTimeout coder:self.recvCoder];
            [self processRequestQueue];
        });        
    }];
}

/*!
 发送数据

 @param data 数据
 */
-(void)sendData:(NSData *)data tag:(long)tag{
    [self sendUdpData:data tag:tag];
}


-(void)dealWithAsynRequestNeedResponse:(ZYBleDeviceRequest*)request {
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        ZYBleMutableRequest* recvRequest = (ZYBleMutableRequest*)request;
        ZYBleMutableRequest* sendRequest = [_asynRequestCache objectForKey:@(recvRequest.msgId)];
        if (sendRequest) {
            [sendRequest finishCountdown];
            if ([recvRequest isKindOfClass:[ZYBleMutableRequest class]]) {
                ((ZYBleMutableRequest*)recvRequest).realCode = sendRequest.realCode;
            }
            if (sendRequest.noNeedToUpdateDataCache == NO) {
                [self.dataCache updateModel:recvRequest.realCode param:recvRequest.param];
            }
            
            //BLOCK_EXEC_ON_MAINQUEUE(sendRequest.handler, ZYBleDeviceRequestStateResponse, recvRequest.param);
            [recvRequest notifyResultWithRequest:sendRequest state:ZYBleDeviceRequestStateResponse coder:self.recvCoder];
            [_asynRequestCache removeObjectForKey:@(sendRequest.msgId)];
        } else {
            //NSLog(@"%@wifi no matched response %@", recvRequest, self.asynRequestCache);
        }
    }
}

-(void)changeCoderIfNeed:(NSString*)coderName clsType:(Class) cls
{
    NSObject* coder = [self valueForKey:coderName];
    if (coder && ![coder isKindOfClass:cls]) {
        //NSLog(@"Auto change coder from %@ to %@", NSStringFromClass(coder.class), NSStringFromClass(cls));
        [self setValue:[[cls alloc] init] forKey:coderName];
    }
}

/**
 协议收到数据
 
 @param data 回调数据
 */
-(void) dealRecieveData:(NSData*)data
{
//    //NSLog(@"wifi recv data:%@", data);
    //NSLog(@"wifi recv data:%@", data);
    if (kTESTFORGUILING) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wifiRecvData" object:data];
        });
        
    }
    @weakify(self);
    dispatch_async(_requestAccessQueue, ^{
        @strongify(self);
        // 防止指令被拆包
        [self.recvCache appendData:data];
        
        // 是否需要调整解码器
        if ([self.sendCoder isKindOfClass:[ZYUsbControlCoder class]]) {
            //按照usb格式封装的请求只能用usb格式解析
            [self changeCoderIfNeed:@"recvCoder" clsType:[ZYUsbControlCoder class]];
        } else {
            if ([ZYBlControlCoder canParse:self.recvCache]) {
                [self changeCoderIfNeed:@"recvCoder" clsType:[ZYBlControlCoder class]];
            } else {
                [self changeCoderIfNeed:@"recvCoder" clsType:[ZYStarControlCoder class]];
            }
        }
        
        
        while ([self.recvCoder isValid:self.recvCache]) {
            [self postReciveDataNotiName];
            ZYControlData* controlData = [self.recvCoder decode:self.recvCache];
            NSUInteger dataUsedLen = [self.recvCoder dataUsedLen];
            if (controlData) {
                ZYBleDeviceRequest* recvRequest = buildRequestWithControlData(controlData);
                if (recvRequest) {

#ifdef DEBUG

                    //NSLog(@"wifi收到有效指令 %@", recvRequest);
#endif

                    if ([recvRequest isKindOfClass:[ZYBleMutableRequest class]]) {
                        ZYBleMutableRequest *requestM =(ZYBleMutableRequest *)recvRequest;
                        if ([requestM.controlData isKindOfClass:[ZYBlOtherHeart class]]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:ZYBlOtherHeartReciveNoti object:requestM.controlData];
                        }
                        
                        
                    }
                    if ([recvRequest isKindOfClass:[ZYBleMutableRequest class]]) {

                        ZYBleMutableRequest *innerRecvRequest = (ZYBleMutableRequest *)recvRequest;
                        //NSLog(@"wifi收到有效指令 %@ %d", recvRequest,innerRecvRequest.msgId);
                        if (innerRecvRequest.msgId == keyButtonMsgID) {
                            if ([recvRequest isKeyEvent]) {
                                //按键指令的处理
                                [[NSNotificationCenter defaultCenter] postNotificationName:Device_Button_Event_Notification_ResourceData object:nil userInfo:@{@"KEY":@(recvRequest.param)}];
                            } else {
                                [innerRecvRequest postNotificationIfNeed:self.recvCoder];
                            }
                        }
                        else{
                            NSString *strClass = NSStringFromClass([innerRecvRequest.controlData class]);
                            if ([strClass isEqualToString:@"ZYUsbInstructionHeartBeatData"]) {
                                
                                ZYUsbInstructionHeartBeatData *controlData = (ZYUsbInstructionHeartBeatData *)innerRecvRequest.controlData;
//                                if (controlData.flag == 0x21 && [AppDataManager defaultAppDataManager].begainUpdate == NO) {
                                    if (controlData.flag == 0x21 ) {
#pragma -mark 0x12处理作为app的回复
                                    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
                                    ZYUsbInstructionHeartBeatData* usbInstructionHeartBeatData = [[ZYUsbInstructionHeartBeatData alloc] init];
    
                                    usbInstructionHeartBeatData.flag = 0x12;
                                    usbInstructionHeartBeatData.sec = timeNow;
                                    usbInstructionHeartBeatData.usec = (int)((timeNow-(int)timeNow)*1000000);
                                    [usbInstructionHeartBeatData createRawDataWithMsgId:controlData.uid];
                                        
                                    ZYBleMutableRequest* usbInstructionHeartBeatRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:usbInstructionHeartBeatData];
                                        
                                    ZYBleDeviceRequest *tempRequestHeart = transferDeviceRequestToMutable(usbInstructionHeartBeatRequest, self.sendCoder);
                                        NSData* data = [tempRequestHeart translateToBinaryWithCoder:self.sendCoder];
                                       
                                    [self sendData:data tag:controlData.uid];
                                //NSLog(@"---------========------%d",controlData.uid);
//                                    [self sendRequest:usbInstructionHeartBeatRequest];
#pragma -mark 发送获取到心跳的通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kWifiReciveHearBeat object:nil];
                                }

                            }
                            else{
                                if ([recvRequest needResponse]) {
                                    if (recvRequest.blocked) {
                                        //NSLog(@"同步指令");
                                    } else {
                                        //移除有响应的异步指令
                                        //                                    //NSLog(@"%@ %@",[recvRequest class],recvRequest);
                                        [self dealWithAsynRequestNeedResponse:recvRequest];
                                    }
                                }
                            }
 
                        }
                    }
                    else{
                        //NSLog(@"wifi 不是 ZYBleMutableRequest 对象");
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
        
        [self processRequestQueue];
    });
}

-(void)clearData{
    [self.recvCache setData:[NSData data]];
}
@end
