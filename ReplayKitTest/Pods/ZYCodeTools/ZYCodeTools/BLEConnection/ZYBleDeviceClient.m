//
//  ZYBleDeviceClient.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceClient.h"
#import "ZYBleConnection.h"
#import "BabyBluetooth.h"
#import "ZYBleDeviceDispacther.h"
#import "ZYBleDeviceInfo_internal.h"
#import "ZYWifiConnection.h"

@interface ZYBleDeviceClient ()
@property (nonatomic, strong,readwrite) ZYBleConnection* stablizerConnection;
#pragma mark Connection连接接对象
@property (nonatomic, strong)  ZYWifiConnection* wifiConnection;


@end

@implementation ZYBleDeviceClient

/**
 暂停接受数据
 */
-(void)pauseReceiving{
    [_wifiConnection pauseReceiving];
}

/**
 开始接受数据
 */
-(void)begainReceiving{
    [self.wifiConnection begainReceiving];
}
#pragma -mark lazy loding
-(ZYWifiConnection *)wifiConnection{
    if (_wifiConnection == nil) {
        _wifiConnection = [[ZYWifiConnection alloc] init];
    }
    return _wifiConnection;
}
-(id<ZYConnection>)connectionWithRequest:(ZYBleDeviceRequest *)request{
    if (request.trasmissionType == ZYTrasmissionTypeBLE) {
        return self.stablizerConnection;
    }
    else{
        [self begainReceiving];
        return self.wifiConnection;
    }
}

+(instancetype) defaultClient
{
    static ZYBleDeviceClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

-(instancetype) init
{
    if ([super init]) {
        _stablizerConnection = [[ZYBleConnection alloc] init];
    }
    return self;
}

#pragma accessor

-(void)setDataCache:(ZYBleDeviceDataModel *)dataCache{
    _dataCache = dataCache;
    self.stablizerConnection.dataCache = dataCache;
    self.wifiConnection.dataCache = dataCache;
}

-(void)sendBLERequest:(ZYBleDeviceRequest *)request completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler{
    request.handler = handler;
    [self p_sendRequest:request];
}

-(void) sendDeviceRequest:(ZYBleDeviceRequest*)request
{
    [self p_sendRequest:request];

}
-(void) sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests completionHandler:(void(^)(BOOL success))completionHandler
{
    if (completionHandler) {
        
        int requestTotalCounts = (int)requests.count;
        __block int requestCount = 0;
        __block BOOL success = YES;
        
        void(^handler)(ZYBleDeviceRequestState state, NSUInteger param) = ^(ZYBleDeviceRequestState state, NSUInteger param) {
            success &= (state == ZYBleDeviceRequestStateResponse);
            requestCount++;
            if (requestCount == requestTotalCounts) {
                BLOCK_EXEC_ON_MAINQUEUE(completionHandler, success);
            }
        };
        
        for (ZYBleDeviceRequest* request in requests) {
            request.handler = handler;
        }
    }
    [self p_sendRequests:requests];
}

-(void) sendMutableRequest:(ZYBleMutableRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler
{
    request.paramsHandler = handler;
    [self p_sendRequest:request];

}

-(BOOL) isIdle
{
    return _stablizerConnection.waitingRequestCount == 0;
}

-(NSTimeInterval) idleTime
{
    NSTimeInterval timeElapse = [[NSDate date] timeIntervalSinceDate:_stablizerConnection.lastRecvTimeStamp];
    //NSLog(@"idleTime %.3f", timeElapse);
    return timeElapse;
}



#pragma -mark sendRequest
-(void)p_sendRequest:(ZYBleDeviceRequest *)request{
    [[self connectionWithRequest:request] sendRequest:request];
}

-(void)p_sendRequests:(NSArray<ZYBleDeviceRequest*>*)requestss{

    if (requestss.count > 0) {
        ZYBleDeviceRequest *request = requestss[0];
        [[self connectionWithRequest:request] sendRequests:requestss];
    }
}

/**
 开启蓝牙链路的通知
 */
-(void)mindBluetoothNotify{
//    return;
    [self.stablizerConnection mindBlueToothNotify];
}

@end
