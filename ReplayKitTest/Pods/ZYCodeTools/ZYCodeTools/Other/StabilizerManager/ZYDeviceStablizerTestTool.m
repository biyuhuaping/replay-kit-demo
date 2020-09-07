//
//  ZYDeviceStablizerTestTool.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStablizerTestTool.h"
#import "ZYBleDeviceClient.h"
#import "ZYMessageTool.h"
#import "ZYAllControlData.h"
//#import "OSSUtil.h"
#import "ZYDeviceManager.h"
#import "ZYBlOtherDeviceTypeData.h"
#import "ZYBlWiFiPhotoCameraInfoData.h"
#import "ZYBlOtherCustomFileData.h"
#import "ZYBlOtherSyncData.h"

#define kSup @"pathShot"

static NSMutableData *jsonData;

typedef void(^ requestCompleteBlock)(ZYBleDeviceRequestState state, NSUInteger param);

@implementation ZYDeviceStablizerTestTool

+(void)configRequest:(ZYBleDeviceRequest *)request{
    request.trasmissionType = ZYTrasmissionTypeWIFI;
    request.parseFormat = ZYCodeParseBl;
}

+(void)testSynData{
    ZYBlOtherSyncData *synData = [[ZYBlOtherSyncData alloc] init];
    synData.messageId = 1;
    synData.idx = 0;
    [synData createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:synData];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherSyncData *innaData = param;
            
            for (CCSConfigSynItem* item in innaData.configs) {
                NSLog(@"CCSConfigSynItemdata = %@",item);

            }
            NSLog(@"ZYBlOtherSyncDatasupport %@请求成功", innaData);
            
        } else {
            NSLog(@"ZYBlOtherSyncDatasupport %@请求失败", param);
        }
    }];
}
+(void)testCrameM{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self doTest];
        [self testSynData];
    });
}
+(void)doCustomFile{
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = 0x00;
    info.page = 0xffff;
    info.data = [kSup dataUsingEncoding:NSUTF8StringEncoding];
    [info createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCustomFileData *innaData = param;
            NSString *str = [NSString stringWithFormat:@"%s",innaData.data.bytes];
//            NSString * str  =[[NSString alloc] initWithData:innaData.data encoding:NSUTF8StringEncoding];
            NSLog(@"查询是否支持support =%d page = %d 请求成功%@pppp,%@",innaData.direction,innaData.isSupport,innaData.supportStr,str);
            [self doCustomFileCount];
            
        } else {
            NSLog(@"查询是否支持support %@请求失败", param);
        }
    }];
    return;
}

+(NSArray *)pathArr{
    return @[@{@"type":@"point",@"yaw":@(6000)},@{@"type":@"transition",@"func":@"linezr",@"elapsedTime":@(60000),@"shotInterval":@(1000),@"exposureTime":@(1000)},@{@"type":@"point",@"yaw":@(8000)},@{@"type":@"transition",@"func":@"linezr",@"elapsedTime":@(60000),@"shotInterval":@(1000),@"exposureTime":@(1000)},@{@"type":@"point",@"yaw":@(5000)}];
}

+(void)doCustomFileCount{
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = 0x01;
    info.page = 0x0000;
    NSArray *array = [self pathArr];
    NSData *tempData = [NSJSONSerialization  dataWithJSONObject:array options:NSJSONWritingPrettyPrinted  error:nil];
    NSMutableString *json = [[NSMutableString  alloc]initWithData:tempData encoding:NSUTF8StringEncoding];
    
    long lenth =  json.length;
    
    NSLog(@"----%d",lenth);
    uint32 count = lenth;
    uint32 rent = ((count << 24) & 0xff000000) | ((count << 8)& 0x00ff0000)|((count >> 8) & 0x0000ff00) | ((count >> 24)& 0xff);
    NSLog(@"----------%x---",rent);
    BYTE data[10];
    memset(data, 0, 10);
    memcpy(data, &rent, sizeof(uint32));
    
    info.data = [NSData dataWithBytes:data length:10];
    [info createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCustomFileData *innaData = param;
            NSString *str = [NSString stringWithFormat:@"%s",innaData.data.bytes];
            //            NSString * str  =[[NSString alloc] initWithData:innaData.data encoding:NSUTF8StringEncoding];
            NSLog(@"direction =%d page = %ld 请求成功%@pppp,%@",innaData.direction,innaData.count,innaData.supportStr,str);
//             jsonData = [NSMutableData data];
            
            NSArray *array = [self pathArr];
            jsonData = [NSJSONSerialization  dataWithJSONObject:array options:NSJSONWritingPrettyPrinted  error:nil];
            NSMutableString *json =[[NSMutableString  alloc]initWithData:tempData encoding:NSUTF8StringEncoding];
            
            long lenth =  json.length;
            
//            for (int i = 0; i < ceil(lenth / 10.0); i ++) {
//
//                NSLog(@"i = %d",i);
//                int len = 10;
//                if (lenth % 10 > 0 && ceil(lenth / 10.0) - 1 == i) {
//                    len = lenth % 10;
//                }
            
                [self doCustomFileCountWithCount:0 withTotalCount:ceil(lenth / 10.0)];
                

//            }
            
        } else {
            NSLog(@"获取页码数  %@请求失败", param);
        }
    }];
    return;
}

+(void)doCustomFileCountWithCount:(int)count withTotalCount:(NSInteger)totalCount{
    
    
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = 0x01;
    info.page = count + 1;
    int lenth = 10;
    if(count == totalCount - 1){
        NSArray *array = [self pathArr];
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted  error:nil];
        NSMutableString *json = [[NSMutableString alloc]initWithData:tempData encoding:NSUTF8StringEncoding];
        
        long lenthJson =  json.length;
        
        if (lenthJson % 10 > 0) {
            lenth = lenthJson % 10;
        }
        
    }
    info.data = [jsonData subdataWithRange:NSMakeRange(count * 10, lenth)];
    [info createRawData];
    NSLog(@"%d--%d--%@",count,lenth,info.data);

    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    __block int countBlock = count;
    __block NSInteger innertotalCount = totalCount;
    @weakify(self)
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            @strongify(self);
            ZYBlOtherCustomFileData *innaData = param;
            if (countBlock  == totalCount - 1) {
                NSLog(@"数据发送完成");
//                NSMutableData *data = [[NSMutableData alloc] initWithData:blockData];
//                BYTE byte[1];
//                byte[0] = 0x00;
//                [data appendData:[NSData dataWithBytes:byte length:1]];
//                NSString *str = [NSString stringWithFormat:@"%s",data.bytes];
//                NSLog(@"str = %@",str);
//                return ;
            }
            else{
                [self doCustomFileCountWithCount:countBlock + 1 withTotalCount:innertotalCount];
            }
            //            NSString * str  =[[NSString alloc] initWithData:innaData.data encoding:NSUTF8StringEncoding];
            NSLog(@"请求成功%@",innaData.data);
            
            
            
        } else {
            
            NSLog(@"设备类型%@请求失败", param);
        }
    }];
    return;
}

+(void)doCustomFileCountWithCount:(int)page data:(NSMutableData *)data withTotalCount:(NSInteger)totalCount{
    
    
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = 0x00;
    info.page = page;
    info.data = [kSup dataUsingEncoding:NSUTF8StringEncoding];
    [info createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    __block NSMutableData *blockData = data;
    __block NSInteger innertotalCount = totalCount;
    __block NSInteger nextPage = page;
    @weakify(self)
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            @strongify(self);
            ZYBlOtherCustomFileData *innaData = param;
            [blockData appendData:innaData.data];
            if (page == totalCount) {
                NSMutableData *data = [[NSMutableData alloc] initWithData:blockData];
                BYTE byte[1];
                byte[0] = 0x00;
                [data appendData:[NSData dataWithBytes:byte length:1]];
                NSString *jsonStr = [NSString stringWithFormat:@"%s",data.bytes];
                NSData *originData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:originData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&error];
                NSLog(@"json文件字符串：%@\n, 字典：%@", jsonStr, retDict);
                
                return ;
            }
            else{
                [self doCustomFileCountWithCount:nextPage + 1 data:blockData withTotalCount:innertotalCount];
            }
            //            NSString * str  =[[NSString alloc] initWithData:innaData.data encoding:NSUTF8StringEncoding];
            NSLog(@"获取文件数据 == 请求成功%@",innaData.supportStr);
            
            
            
        } else {
            
            NSLog(@"设备类型%@请求失败, state == %ld", param, state);
        }
    }];
    return;
}

+(void)p_doCameraInfoData{
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    ZYBlWiFiPhotoCameraInfoData *info = [[ZYBlWiFiPhotoCameraInfoData alloc] init];
    info.flag = 0x00;
    info.value = 0x00;
    [info createRawData];
    ZYBleMutableRequest* requestInfo = [[ZYBleMutableRequest alloc] initWithZYControlData:info];
    [self configRequest:requestInfo];
    [client sendMutableRequest:requestInfo completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlWiFiPhotoCameraInfoData *innaData = param;
            NSLog(@"flag = %d value =%d请求成功", innaData.flag,innaData.value);
            
        } else {
            NSLog(@"设备类型%@请求失败", param);
        }
    }];
}

+(void)doTest{
    [self doCustomFile];
    return;
    NSLog(@"testCrameM");
    
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    ZYBlOtherDeviceTypeData *data = [[ZYBlOtherDeviceTypeData alloc] init];
    data.direct = 0x80;
    data.type = 0x01;
    [data createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
    [self configRequest:request];
    [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherDeviceTypeData *innaData = param;
            NSLog(@"设备类型type = %d direct =%d请求成功", innaData.type,innaData.direct);
            
        } else {
            NSLog(@"设备类型%@请求失败", param);
        }
    }];
}
#pragma mark - Test
+(void) testFirmRequest
{
    
    //    NSData * writeData =  [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SmoothFirmwareV1.51" ofType:@"ptz"]]];
    //    NSArray *ptzArray = [ZYHardwarePTZDealModel getPTZsWithPTZData:writeData];
    //    for (ZYHardwarePTZDealModel *model in ptzArray) {
    //        NSLog(@"model%@",model);
    //    }
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    //复位->同步1号设备->ByPass->同步其他设备->reset->
    [[ZYDeviceManager defaultManager] scanStabalizerDevice:^(ZYBleState state) {
        
    } deviceHandler:^(ZYDeviceStabilizer *deviceInfo) {
        static bool using = false;
        //        NSString* deviceName = @"Smooth361D1";
        //        NSString* deviceName = @"Smooth313C3";
        NSString* deviceName = @"Crane2E2EB";
        //        NSString* deviceName = @"Smooth2AFE";
        if ([deviceInfo.deviceInfo.name isEqualToString:deviceName] && !using) {
            using = true;
            [[ZYDeviceManager defaultManager] connectDevice:deviceInfo completionHandler:^(ZYBleDeviceConnectionState state) {
                if (ZYBleDeviceStateReady == state) {
                    [NSThread sleepForTimeInterval:5];
                    //step 1 系统复位
                    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleInteractSysReset data:@(ZYBLE_DATA_RESET) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                        if (state == ZYBleDeviceRequestStateResponse
                            || state == ZYBleDeviceRequestStateTimeout) {
                            NSLog(@"系统复位成功");
                            //[self notifyStabilizerOffLine:@(1)];
                            [NSThread sleepForTimeInterval:1];
                            
                            __block int n = 1;
                            ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:n withCommand:ZYBleInteractSync];
                            __block NSDate* now = [NSDate date];
                            
                            void(^__block syncDevice)(ZYBleDeviceRequestState state, id param) = ^(ZYBleDeviceRequestState state, id param) {
                                if (state == ZYBleDeviceRequestStateResponse) {
                                    NSLog(@"第%d台设备同步成功 %@", n, param);
                                    if (n==1) {
                                        //step 2.2 第一台设备ByPass
                                        ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:n withCommand:ZYBleInteractByPass];
                                        [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
                                            if (state == ZYBleDeviceRequestStateResponse) {
                                                NSLog(@"第%d台设备ByPass", n);
                                                n+=1;
                                                now = [NSDate date];
                                                ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:n withCommand:ZYBleInteractSync];
                                                [client sendMutableRequest:request completionHandler:syncDevice];
                                            } else {
                                                NSLog(@"第%d台设备ByPass失败", n);
                                                syncDevice = nil;
                                            }
                                        }];
                                        
                                    } else {
                                        n+=1;
                                        now = [NSDate date];
                                        //step 2.3 依次同步其他设备
                                        ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:n withCommand:ZYBleInteractSync];
                                        [client sendMutableRequest:request completionHandler:syncDevice];
                                    }
                                } else {
                                    //step 3 同步至无其他设备
                                    if ([[NSDate date] timeIntervalSinceDate:now] > 5.0f) {//超时5秒没响应
                                        NSLog(@"第%d台设备同步成功超时, 一共同步了%d台设备", n, n-1);
                                        syncDevice = nil;
                                        if (n==1) {//没有同步成功设备，终止
                                            return;
                                        }
                                        //step 4 进入reset模式
                                        ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:1 withCommand:ZYBleInteractBootReset];
                                        [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param){
                                            //step 5 写入固件
                                            //step 5.1 同步设备
                                            __block int m = 1;
                                            void(^__block flashDevice)(ZYBleDeviceRequestState state, id param) = ^(ZYBleDeviceRequestState state, id param) {
                                                if (state == ZYBleDeviceRequestStateResponse) {
                                                    NSLog(@"第%d台设备烧写同步成功 数据%@", m, param);
                                                    NSDictionary* paramDict = (NSDictionary*) param;
                                                    int PageSize = ((NSNumber*)paramDict[@"size"]).intValue;
                                                    int PageNums = ((NSNumber*)paramDict[@"count"]).intValue;
                                                    __block int PageIdx = 0;
                                                    //step 5.2 烧写前检查
                                                    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:m withCommand:ZYBleInteractCheck];
                                                    [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param){
                                                        if (state == ZYBleDeviceRequestStateResponse) {
                                                            NSLog(@"第%d台设备烧写前检查成功", m);
                                                            
                                                        } else {
                                                            NSLog(@"第%d台设备烧写前检查失败", m);
                                                        }
                                                    }];
                                                } else {
                                                    if (m==1 && [[NSDate date] timeIntervalSinceDate:now] < 5.0f) {
                                                        ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:m withCommand:ZYBleInteractSync];
                                                        [client sendMutableRequest:request completionHandler:flashDevice];
                                                    } else {
                                                        NSLog(@"第%d台设备烧写同步失败", m);
                                                    }
                                                }
                                            };
                                            if (state == ZYBleDeviceRequestStateResponse) {
                                                NSLog(@"节点硬件复位成功");
                                                now = [NSDate date];
                                                ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:m withCommand:ZYBleInteractSync];
                                                [client sendMutableRequest:request completionHandler:flashDevice];
                                            } else if (state == ZYBleDeviceRequestStateTimeout) {
                                                NSLog(@"节点硬件复位超时");
                                                now = [NSDate date];
                                                ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:1 withCommand:ZYBleInteractSync];
                                                [client sendMutableRequest:request completionHandler:flashDevice];
                                            } else {
                                                NSLog(@"节点硬件复位失败");
                                            }
                                            
                                        }];
                                    } else {//继续同步
                                        //step 2.3 依次同步其他设备
                                        ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:n withCommand:ZYBleInteractSync];
                                        [client sendMutableRequest:request completionHandler:syncDevice];
                                    }
                                }
                            };
                            //step 2.1 同步第一台设备
                            [client sendMutableRequest:request completionHandler:syncDevice];
                        } else {
                            NSLog(@"系统复位失败");
                        }
                    }];
                }
            }];
        }
    }];
    
}


+(void) testZYBlWiFiCode
{
    
    //    [self.wifiManager scanWiFiDevice:^(ZYWiFiScanState state) {
    //
    //    } deviceHandler:^(ZYBlWiFiDeviceData *deviceData) {
    //
    //    }];
    //    return;
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYMessageTool* tool = [ZYMessageTool defaultTool];
    NSDictionary* gopropwds = @{
                                @"GP24729305":@"swim5479",
                                @"GP24907848":@"hike3337",
                                };
    __block NSString* targetDevice = @"GP24907848";
    
    __block SportCameraParamModel* CurrentModeCodeMap = nil;
    __block SportCameraParamModel* CurrentSubModeCodeMap = nil;
    
    static void(^sendWiFiStatus)(void) = nil;
    static void(^sendWiFiScan)(void) = nil;
    static void(^sendWiFiDevice)(int num) = nil;
    static void(^sendWiFiConnection)(const char* szName, const char* szPwd) = nil;
    static void(^sendWiFiPhotoInfo)(void) = nil;
    static void(^sendWiFiPhotoParam)(int paramId, void(^completeCB)(int value)) = nil;
    static void(^sendWiFiPhotoAllParam)(void) = nil;
    static void(^sendWiFiPhotoCtrl)(int paramId, void(^completeCB)(int value)) = nil;
    static void(^dealWiFiScaning)(void) = nil;
    static void(^dealWiFiConnecting)(void) = nil;
    static void(^dealWiFiConnect)(void) = nil;
    static void(^dealWiFiDisconnect)(void) = nil;
    static void(^dealWiFiScanFinish)(BOOL flag) = nil;
    static void(^dealWiFiScaningSerach)(BOOL flag) = nil;
    static void(^CheckQueryCommand)(int supportMode) = nil;
    static void(^CheckSetCommand)(int workingMode) = nil;
    
    __block NSInteger WiFiScaningCount = 0;
    __block NSInteger WiFiConnectingCount = 0;
    __block NSMutableArray<NSString*>* deviceArray = [NSMutableArray array];
    __block NSString* curSSID = nil;
    __block NSString* curPwd = nil;
    __block NSUInteger deviceMaxCount = 0;
    __block ZYBlWiFiPhotoAllParamData* allParamData = nil;
    
    typedef enum {
        stateUnknown = 0,
        stateScaning,
        stateConnecting,
        stateConnect,
        stateDisconnect,
    } stateDef;
    
    __block stateDef state = stateUnknown;
    
    sendWiFiStatus = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiStatusData* blWiFiStatusData = [[ZYBlWiFiStatusData alloc] init];
            [blWiFiStatusData createRawData];
            ZYBleMutableRequest* WiFiStatusRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiStatusData];
            [client sendMutableRequest:WiFiStatusRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiStatusData* blWiFiStatusDataRespond = (ZYBlWiFiStatusData*)param;
                    NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
                    NSLog(@"查询wifi模块状态 %lu", wifiStatus);
                    if (wifiStatus == ZYBleInteractWifiStatusOff) {
                        NSLog(@"wifi已关闭");
                    } else if (wifiStatus == ZYBleInteractWifiStatusOn) {
                        NSLog(@"wifi已开启");
                    } else if (wifiStatus == ZYBleInteractWifiStatusScan) {
                        NSLog(@"wifi扫描中");
                        dealWiFiScaning();
                    } else if (wifiStatus == ZYBleInteractWifiStatusConnect) {
                        NSLog(@"wifi已连接");
                        dealWiFiConnect();
                    } else if (wifiStatus == ZYBleInteractWifiStatusConnecting) {
                        NSLog(@"wifi连接中");
                        dealWiFiConnecting();
                    } else if (wifiStatus == ZYBleInteractWifiStatusDisconnect) {
                        NSLog(@"wifi断开");
                        dealWiFiDisconnect();
                    } else {
                        NSLog(@"wifi出错");
                    }
                } else {
                    NSLog(@"查询wifi模块状态超时");
                    if (state == stateConnecting) {
                        dealWiFiConnecting();
                    } else if (state == stateScaning) {
                        dealWiFiScaning();
                    } else {
                        sendWiFiStatus();
                    }
                }
            }];
        });
    };
    
    sendWiFiScan = ^(void) {
        state = stateScaning;
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiScanData* blWiFiScanData = [[ZYBlWiFiScanData alloc] init];
            blWiFiScanData.scanState = ZYBleInteractWifiON;
            [blWiFiScanData createRawData];
            ZYBleMutableRequest* WiFiScanRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiScanData];
            [client sendMutableRequest:WiFiScanRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    NSLog(@"请求开启wifi扫描成功,开始轮询wifi状态");
                    sendWiFiStatus();
                } else {
                    NSLog(@"请求开启wifi扫描失败");
                }
            }];
        });
    };
    
    sendWiFiDevice = ^(int num) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiDeviceData* blWiFiDeviceData = [[ZYBlWiFiDeviceData alloc] init];
            blWiFiDeviceData.num = num;
            [blWiFiDeviceData createRawData];
            ZYBleMutableRequest* WiFiDeviceRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiDeviceData];
            [client sendMutableRequest:WiFiDeviceRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiDeviceData* blWiFiDiveceDataRespond = (ZYBlWiFiDeviceData*)param;
                    int curNum = blWiFiDiveceDataRespond.num;
                    if (num == 0) {
                        deviceMaxCount = curNum;
//                        NSLog(@"扫描到%lu台设备", deviceMaxCount);
                        if (deviceMaxCount >= 1) {
                            sendWiFiDevice(1);
                        } else {
                            dealWiFiScaningSerach(YES);
                        }
                    } else {
//                        NSLog(@"第%lu台设备是%@", blWiFiDiveceDataRespond.num, blWiFiDiveceDataRespond.ssid);
                        [deviceArray addObject: blWiFiDiveceDataRespond.ssid];
                        if (curNum < deviceMaxCount) {
                            sendWiFiDevice(curNum+1);
                        } else {
                            dealWiFiScanFinish(YES);
                        }
                    }
                } else {
                    NSLog(@"请求开启wifi扫描失败");
                    dealWiFiScaningSerach(NO);
                }
            }];
        });
    };
    
    sendWiFiConnection = ^(const char* szName, const char* szPwd) {
        state = stateConnecting;
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiConnectionData* blWiFiConnectionData = [[ZYBlWiFiConnectionData alloc] init];
            blWiFiConnectionData.ssid = [NSString stringWithUTF8String:szName];
            blWiFiConnectionData.pwd = [NSString stringWithUTF8String:szPwd];
            [blWiFiConnectionData createRawData];
            ZYBleMutableRequest* WiFiConectionRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiConnectionData];
            [client sendMutableRequest:WiFiConectionRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    NSLog(@"连接设备%@请求成功", blWiFiConnectionData.ssid);
                    curSSID = blWiFiConnectionData.ssid;
                    dealWiFiConnecting();
                } else {
                    NSLog(@"连接设备%@请求失败", blWiFiConnectionData.ssid);
                }
            }];
        });
    };
    
    sendWiFiPhotoInfo = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoData = [[ZYBlWiFiPhotoInfoData alloc] init];
            blWiFiPhotoInfoData.infoId = ZYBIWPModelName;
            [blWiFiPhotoInfoData createRawData];
            ZYBleMutableRequest* WiFiPhotoInfoRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiPhotoInfoData];
            [client sendMutableRequest:WiFiPhotoInfoRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiPhotoInfoData* blWiFiPhotoInfoDateRespond = (ZYBlWiFiPhotoInfoData*)param;
                    NSLog(@"查询设备信息%@成功", blWiFiPhotoInfoDateRespond.infoString);
                    if (blWiFiPhotoInfoDateRespond.infoId == ZYBIWPModelName) {
                        NSArray<NSString*>* arrayString = [blWiFiPhotoInfoDateRespond.infoString componentsSeparatedByString:@" "];
                        NSString* name = arrayString[0];
                        NSString* color = arrayString[1];
                        [tool activeSportCameraConfig:name withColor:color];
                        
                        sendWiFiPhotoAllParam();
                        CheckQueryCommand(supportMode_Other);
                        CheckQueryCommand(supportMode_Video);
                        CheckQueryCommand(supportMode_Photo);
                        CheckQueryCommand(supportMode_MultiShot);
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            //                            if (<#condition#>) {
                            //                                <#statements#>
                            //                            }
//                            CheckSetCommand(allParamData.Current_Mode);
                        });
                        //                        NSArray<SportCameraParamModel*>* CurrentModeCodeMaps = [tool querySpecificConfig:(0x01 << 3) type:@"Current_Mode" name:@""];
                        //                        CurrentModeCodeMap = [CurrentModeCodeMaps firstObject];
                        //                        NSArray<SportCameraParamModel*>* CurrentSubModeCodeMaps = [tool querySpecificConfig:(0x01 << 3) type:@"Current_SubMode" name:@""];
                        //                        CurrentSubModeCodeMap = [CurrentSubModeCodeMaps firstObject];
                        //                        sendWiFiPhotoParam((int)CurrentModeCodeMap.queryCode);
                        //                        sendWiFiPhotoParam((int)CurrentSubModeCodeMap.queryCode);
                    }
                } else {
                    NSLog(@"查询设备信息失败");
                }
            }];
        });
    };
    
    sendWiFiPhotoParam = ^(int paramId, void(^completeCB)(int value)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiPhotoParamData* blWiFiPhotoParamData = [[ZYBlWiFiPhotoParamData alloc] init];
            blWiFiPhotoParamData.paramId = paramId;
            [blWiFiPhotoParamData createRawData];
            ZYBleMutableRequest* WiFiPhotoDataRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiPhotoParamData];
            [client sendMutableRequest:WiFiPhotoDataRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiPhotoParamData* blWiFiPhotoParamDataRespond = (ZYBlWiFiPhotoParamData*)param;
                    NSLog(@"查询设备状态%lu:%d成功", (unsigned long)blWiFiPhotoParamDataRespond.paramId, blWiFiPhotoParamDataRespond.paramValue);
                    completeCB((int)blWiFiPhotoParamDataRespond.paramValue);
                } else {
                    NSLog(@"查询设备状态失败");
                }
            }];
        });
    };
    
    sendWiFiPhotoAllParam = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiPhotoAllParamData* blWiFiPhotoAllParamData = [[ZYBlWiFiPhotoAllParamData alloc] init];
            [blWiFiPhotoAllParamData createRawData];
            ZYBleMutableRequest* WiFiPhotoAllParamRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiPhotoAllParamData];
            [client sendMutableRequest:WiFiPhotoAllParamRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiPhotoAllParamData* blWiFiPhotoAllParamDataRespond = (ZYBlWiFiPhotoAllParamData*)param;
//                    NSLog(@"查询设备状态%d:%d成功", blWiFiPhotoAllParamDataRespond.paramId, blWiFiPhotoAllParamDataRespond.Video_Resolution);
                    allParamData = blWiFiPhotoAllParamDataRespond;
                } else {
                    NSLog(@"查询设备状态失败");
                }
            }];
        });
    };
    
    sendWiFiPhotoCtrl = ^(int paramValue, void(^completeCB)(int value)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiPhotoCtrlData* blWiFiPhotoCtrlData = [[ZYBlWiFiPhotoCtrlData alloc] init];
            blWiFiPhotoCtrlData.value = paramValue;
            [blWiFiPhotoCtrlData createRawData];
            ZYBleMutableRequest* WiFiPhotoCtrlRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiPhotoCtrlData];
            [client sendMutableRequest:WiFiPhotoCtrlRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiPhotoCtrlData* blWiFiPhotoCtrlDataRespond = (ZYBlWiFiPhotoCtrlData*)param;
                    NSLog(@"设置设备状态%lu成功", blWiFiPhotoCtrlDataRespond.value);
                    completeCB((int)blWiFiPhotoCtrlDataRespond.value);
                } else {
                    NSLog(@"设置设备状态失败");
                }
            }];
        });
    };
    
    dealWiFiScaning = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WiFiScaningCount++;
            if (WiFiScaningCount == 1) {
                NSLog(@"第%ld次查询到WiFi状态:wifi连接中, 等待2秒后继续查询", (long)WiFiScaningCount);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    sendWiFiStatus();
                });
            } else if (WiFiScaningCount > 3) {
                WiFiScaningCount = 0;
                NSLog(@"wifi扫描超时");
                dealWiFiScanFinish(NO);
            } else {
                dealWiFiScaningSerach(YES);
            }
        });
    };
    
    dealWiFiConnecting = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (curSSID == nil) {
                //重新检索设备
                //TODO 判断是否已经连上gopro
                sendWiFiScan();
            } else {
                WiFiConnectingCount++;
                if (WiFiConnectingCount == 1) {
                    NSLog(@"第%ld次查询到WiFi状态:wifi连接中,等待4秒继续查询", (long)WiFiConnectingCount);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        sendWiFiStatus();
                    });
                } else if (WiFiConnectingCount > 4) {
                    WiFiConnectingCount = 0;
                    NSLog(@"wifi超时断开");
                    dealWiFiDisconnect();
                } else {
                    NSLog(@"第%ld次查询到WiFi状态:wifi连接中,等待2秒继续查询", (long)WiFiConnectingCount);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        sendWiFiStatus();
                    });
                }
            }
        });
    };
    
    dealWiFiConnect = ^(void) {
        //成功连接后处理
        state = stateConnect;
        NSLog(@"%@成功连接", curSSID);
        sendWiFiPhotoInfo();
    };
    
    dealWiFiDisconnect = ^(void) {
        //连接断开后后处理
        state = stateDisconnect;
        NSLog(@"%@失去连接", curSSID);
        curSSID = nil;
        if (curSSID == nil) {
            //重新检索设备
            sendWiFiScan();
        }
    };
    
    dealWiFiScanFinish = ^(BOOL flag) {
        if (flag) {
            NSLog(@"device %@ found", deviceArray);
            if (curSSID == nil && deviceArray.count > 0) {
                //当前无设备连接上，选择一个连接
                [deviceArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj hasPrefix:@"GP"]) {
                        targetDevice = obj;
                        *stop = YES;
                    }
                }];
                NSString* pwd = [gopropwds objectForKey:targetDevice];
                if (pwd != NULL) {
                    sendWiFiConnection([targetDevice UTF8String], [pwd UTF8String]);
                } else {
                    NSLog(@"%@ 没有找到密码记录", curSSID);
                }
            }
        } else {
            NSLog(@"扫描设备失败");
        }
    };
    
    dealWiFiScaningSerach = ^(BOOL flag) {
        if (flag) {
            sendWiFiDevice(0);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                sendWiFiStatus();
            });
        }
    };
    
    CheckQueryCommand = ^(int mode){
        NSArray<NSString*>* CatagoryArray = [tool activeParamCatagory:mode];
        if (CatagoryArray.count>0) {
            for (NSString* Catagory in CatagoryArray) {
                NSArray<SportCameraParamModel*>* catagoryMaps = [tool querySpecificConfig:mode type:Catagory name:@""];
                SportCameraParamModel* cameraParam = [catagoryMaps firstObject];
                sendWiFiPhotoParam((int)cameraParam.queryCode, ^(int value){
                    BOOL valid = [tool validateValue:mode type:cameraParam.type value:value];
                    BOOL same = NO;
                    NSUInteger paramValue = 0;
                    if ([allParamData respondsToSelector:NSSelectorFromString(cameraParam.mappingName)]) {
                        paramValue = [allParamData performSelector:NSSelectorFromString(cameraParam.mappingName)];
                        same = (paramValue == value);
                    };
                    
                    NSLog(@"状态%@:%lu%@ %@", cameraParam.type, (unsigned long)paramValue, valid?@"有效":@"无效", same?@"一致":[NSString stringWithFormat:@"不一致(%lu:%lu)", paramValue, (unsigned long)value]);
                });
            }
        }
    };
    
    CheckSetCommand = ^(int workingMode){
        int supportMode = (int)[tool workingModeToSupportMode:workingMode];
        NSArray<NSString*>* CatagoryArray = [tool activeParamCatagory:supportMode];
        if (CatagoryArray.count>0) {
            for (NSString* Catagory in [CatagoryArray subarrayWithRange:NSMakeRange(0, 1)]) {
                NSArray<SportCameraParamModel*>* catagoryMaps = [tool querySpecificConfig:supportMode type:Catagory name:@""];
                SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
                sendWiFiPhotoCtrl((int)cameraParam.setVal, ^(int value){
                    
                });
            }
        }
    };
    
    sendWiFiStatus();
    
}




+(void) testZYBlCCSCode
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
//    @weakify(self)
//    [[NSNotificationCenter defaultCenter] addObserverForName:Device_State_Event_Notification_ResourceData object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        @strongify(self)
//        NSDictionary* userInfo = [note userInfo];
//        if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlCCSGetConfigData class]) ]) {
//            ZYBlCCSGetConfigData* data = (ZYBlCCSGetConfigData*)[note object];
//            NSLog(@"查询设备通知=====%lu:%@%@", data.idx, data.configs, data.value);
//            if (data.idx == 125) {
//                //相机名
//                NSString* modleValue = data.value;
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    NSString* urlStr = [NSString stringWithFormat:@"http://192.168.2.1/%@.json", modleValue];
//                    urlStr = [urlStr urlString];
//                    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
//                    if (jsonData) {
//                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//                        NSLog(@"当前相机配置%@", jsonDic);
//                    }
//                });
//            }
//        } else if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlCCSSetConfigData class]) ]) {
//            ZYBlCCSSetConfigData* data = (ZYBlCCSSetConfigData*)[note object];
//            NSLog(@"设置设备通知%lu:%@", data.idx, data.value);
//        }
//    }];
//    
    
    static void(^sendGetConfig)(int num) = nil;
    static void(^sendSetConfig)(int num, const char* value) = nil;
    
    //    ZYBlCCSGetAvailableConfigData* blCCSGetAvailableConfigData = [[ZYBlCCSGetAvailableConfigData alloc] init];
    //    blCCSGetAvailableConfigData.idx = 125;
    //    [blCCSGetAvailableConfigData createRawData];
    //    ZYBleMutableRequest* CCSGetAvailableConfigRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blCCSGetAvailableConfigData];
    //    [client sendMutableRequest:CCSGetAvailableConfigRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
    //        if (state == ZYBleDeviceRequestStateResponse) {
    //            ZYBlCCSGetAvailableConfigData* blCCSGetAvailableConfigDataRespond = (ZYBlCCSGetAvailableConfigData*)param;
    //            NSLog(@"查询设备状态%lu成功", blCCSGetAvailableConfigDataRespond.idx);
    //        } else {
    //            NSLog(@"查询设备状态失败");
    //        }
    //    }];
    
    
    sendGetConfig = ^(int num) {
        ZYBlCCSGetConfigData* blCCSGetConfigData = [[ZYBlCCSGetConfigData alloc] init];
        blCCSGetConfigData.idx = num;
        [blCCSGetConfigData createRawData];
        ZYBleMutableRequest* blCCSGetConfigRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blCCSGetConfigData];
        [client sendMutableRequest:blCCSGetConfigRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlCCSGetConfigData* blCCSGetConfigDataRespond = (ZYBlCCSGetConfigData*)param;
                NSLog(@"查询设备状态%lu成功", blCCSGetConfigDataRespond.idx);
            } else {
                NSLog(@"查询设备状态失败");
            }
        }];
    };
    
    sendSetConfig = ^(int num, const char* value) {
        ZYBlCCSSetConfigData* blCCSSetConfigData = [[ZYBlCCSSetConfigData alloc] init];
        blCCSSetConfigData.idx = num;
        blCCSSetConfigData.value = [NSString stringWithUTF8String:value];
        [blCCSSetConfigData createRawData];
        ZYBleMutableRequest* blCCSSetConfigRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blCCSSetConfigData];
        [client sendMutableRequest:blCCSSetConfigRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlCCSSetConfigData* blCCSSetConfigDataRespond = (ZYBlCCSSetConfigData*)param;
                NSLog(@"设置设备状态%lu成功", blCCSSetConfigDataRespond.idx);
            } else {
                NSLog(@"设置设备状态失败");
            }
        }];
    };
    
    sendGetConfig(125);
    sendGetConfig(2);
    sendGetConfig(126);
    sendSetConfig(2, "1000");
    sendSetConfig(4, "Automatic");
}

+(void) testZYBlOtherCode
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    ZYBlOtherFileAsynData* blOtherFileAsynData = [[ZYBlOtherFileAsynData alloc] init];
    [blOtherFileAsynData createRawData];
    ZYBleMutableRequest* blOtherFileAsynRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blOtherFileAsynData];
    [client sendMutableRequest:blOtherFileAsynRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherFileAsynData* blOtherFileAsynDataRespond = (ZYBlOtherFileAsynData*)param;
            NSLog(@"文件是否异步传输%lu成功", blOtherFileAsynDataRespond.flag);
        } else {
            NSLog(@"文件是否异步传输失败");
        }
    }];
    
    ZYBlOtherCheckMD5Data* blOtherCheckMD5Data = [[ZYBlOtherCheckMD5Data alloc] init];
    [blOtherFileAsynData createRawData];
    ZYBleMutableRequest* blOtherCheckMD5Request = [[ZYBleMutableRequest alloc] initWithZYControlData:blOtherCheckMD5Data];
    [client sendMutableRequest:blOtherCheckMD5Request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCheckMD5Data* blOtherCheckMD5DataRespond = (ZYBlOtherCheckMD5Data*)param;
            NSLog(@"MD5值校验%lu成功", blOtherCheckMD5DataRespond.flag);
        } else {
            NSLog(@"MD5值校验失败");
        }
    }];
}

+(void) testZYUSBCode
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    ZYUsbInstructionMediaStreamData* usbInstructionMediaStreamData = [[ZYUsbInstructionMediaStreamData alloc] init];
    usbInstructionMediaStreamData.flag = 1; //UMCMediaStreamStatusOpen;
    [usbInstructionMediaStreamData createRawData];
    ZYBleMutableRequest* usbInstructionMediaStreamRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:usbInstructionMediaStreamData];
    [client sendMutableRequest:usbInstructionMediaStreamRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYUsbInstructionMediaStreamData* usbInstructionMediaStreamDataRespond = (ZYUsbInstructionMediaStreamData*)param;
            NSLog(@"打开视频流:%lu:%lu", (unsigned long)usbInstructionMediaStreamDataRespond.cmdStatus, (unsigned long)usbInstructionMediaStreamDataRespond.flag);
        } else {
            NSLog(@"打开视频流超时");
        }
    }];
    
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    ZYUsbInstructionHeartBeatData* usbInstructionHeartBeatData = [[ZYUsbInstructionHeartBeatData alloc] init];
    usbInstructionHeartBeatData.sec = timeNow;
    usbInstructionHeartBeatData.usec = (timeNow-(int)timeNow);
    [usbInstructionHeartBeatData createRawData];
    ZYBleMutableRequest* usbInstructionHeartBeatRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:usbInstructionHeartBeatData];
    [client sendMutableRequest:usbInstructionHeartBeatRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYUsbInstructionHeartBeatData* usbInstructionMediaStreamDataRespond = (ZYUsbInstructionHeartBeatData*)param;
            NSLog(@"心跳指令:%lu:%lu", (unsigned long)usbInstructionMediaStreamDataRespond.sec, (unsigned long)usbInstructionMediaStreamDataRespond.usec);
        } else {
            NSLog(@"心跳指令失败");
        }
    }];
}

+(void) testZYBLWiFiHotspotCode
{
    static void(^sendWiFiStatus)(void) = nil;
    static void(^sendWiFiEnable)(void) = nil;
    static void(^sendWiFiDisable)(void) = nil;
    static void(^sendWiFiRestart)(void) = nil;
    static void(^sendWiFiCleanDHCP)(void) = nil;
    static void(^sendWiFiSSID)(void) = nil;
    static void(^sendWiFiPWD)(void) = nil;
    static void(^outputWiFiStatus)(NSUInteger wifiStatus) = nil;
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    
    sendWiFiStatus = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZYBlWiFiHotspotStatusData* blWiFiHotspotStatusData = [[ZYBlWiFiHotspotStatusData alloc] init];
            [blWiFiHotspotStatusData createRawData];
            ZYBleMutableRequest* WiFiHotspotStatusRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotStatusData];
            [client sendMutableRequest:WiFiHotspotStatusRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    ZYBlWiFiHotspotStatusData* blWiFiStatusDataRespond = (ZYBlWiFiHotspotStatusData*)param;
                    NSUInteger wifiStatus = blWiFiStatusDataRespond.wifiStatus;
                    NSLog(@"查询wifi模块");
                    outputWiFiStatus(wifiStatus);
                    if (wifiStatus == ZYBleInteractWifiHotspotStatusOff) {
                        sendWiFiEnable();
                    } else if (wifiStatus == ZYBleInteractWifiHotspotStatusOn) {
                        //sendWiFiSSID();
                        //sendWiFiPWD();
                        //sendWiFiDisable();
                        sendWiFiCleanDHCP();
                        sendWiFiRestart();
                    } else if (wifiStatus == ZYBleInteractWifiHotspotStatusErr) {
                    }
                }
            }];
        });
    };
    
    sendWiFiEnable = ^(void) {
        ZYBlWiFiHotspotEnableData* blWiFiHotspotEnableData = [[ZYBlWiFiHotspotEnableData alloc] init];
        [blWiFiHotspotEnableData createRawData];
        ZYBleMutableRequest* WiFiHotspotEnableRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotEnableData];
        [client sendMutableRequest:WiFiHotspotEnableRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotEnableData* blWiFiEnableDataRespond = (ZYBlWiFiHotspotEnableData*)param;
                NSUInteger wifiStatus = blWiFiEnableDataRespond.wifiStatus;
                NSLog(@"开启wifi模块");
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    sendWiFiDisable = ^(void) {
        ZYBlWiFiHotspotDisableData* blWiFiHotspotDisableData = [[ZYBlWiFiHotspotDisableData alloc] init];
        [blWiFiHotspotDisableData createRawData];
        ZYBleMutableRequest* WiFiHotspotDisableRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotDisableData];
        [client sendMutableRequest:WiFiHotspotDisableRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotDisableData* blWiFiDisableDataRespond = (ZYBlWiFiHotspotDisableData*)param;
                NSUInteger wifiStatus = blWiFiDisableDataRespond.wifiStatus;
                NSLog(@"关闭wifi模块");
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    sendWiFiSSID = ^(void) {
        ZYBlWiFiHotspotGetSSIDData* blWiFiHotspotGetSSIDData = [[ZYBlWiFiHotspotGetSSIDData alloc] init];
        [blWiFiHotspotGetSSIDData createRawData];
        ZYBleMutableRequest* WiFiHotspotGetSSIDRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotGetSSIDData];
        [client sendMutableRequest:WiFiHotspotGetSSIDRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotGetSSIDData* blWiFiGetSSIDDataRespond = (ZYBlWiFiHotspotGetSSIDData*)param;
                NSUInteger wifiStatus = blWiFiGetSSIDDataRespond.wifiStatus;
                NSLog(@"WiFi SSID %@", blWiFiGetSSIDDataRespond.SSID);
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    sendWiFiPWD = ^(void) {
        ZYBlWiFiHotspotPSWData* blWiFiHotspotPSWData = [[ZYBlWiFiHotspotPSWData alloc] init];
        [blWiFiHotspotPSWData createRawData];
        ZYBleMutableRequest* WiFiHotspotDisableRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotPSWData];
        [client sendMutableRequest:WiFiHotspotDisableRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotPSWData* blWiFiPSWDataRespond = (ZYBlWiFiHotspotPSWData*)param;
                NSUInteger wifiStatus = blWiFiPSWDataRespond.wifiStatus;
                NSLog(@"WiFi PWD %@", blWiFiPSWDataRespond.PSW);
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    sendWiFiRestart = ^(void) {
        ZYBlWiFiHotspotResetData* blWiFiHotspotResetData = [[ZYBlWiFiHotspotResetData alloc] init];
        [blWiFiHotspotResetData createRawData];
        ZYBleMutableRequest* WiFiHotspotResetRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotResetData];
        [client sendMutableRequest:WiFiHotspotResetRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotResetData* blWiFiResetDataRespond = (ZYBlWiFiHotspotResetData*)param;
                NSLog(@"重启wifi模块");
                NSUInteger wifiStatus = blWiFiResetDataRespond.wifiStatus;
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    sendWiFiCleanDHCP = ^(void) {
        ZYBlWiFiHotspotDHCPCleanData* blWiFiHotspotDHCPCleanData = [[ZYBlWiFiHotspotDHCPCleanData alloc] init];
        [blWiFiHotspotDHCPCleanData createRawData];
        ZYBleMutableRequest* WiFiHotspotDHCPCleanRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blWiFiHotspotDHCPCleanData];
        [client sendMutableRequest:WiFiHotspotDHCPCleanRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                ZYBlWiFiHotspotDHCPCleanData* blWiFiDHCPCleanDataRespond = (ZYBlWiFiHotspotDHCPCleanData*)param;
                NSLog(@"清除DHCP");
                NSUInteger wifiStatus = blWiFiDHCPCleanDataRespond.wifiStatus;
                outputWiFiStatus(wifiStatus);
            }
        }];
    };
    
    outputWiFiStatus = ^(NSUInteger wifiStatus) {
        if (wifiStatus == ZYBleInteractWifiHotspotStatusOff) {
            NSLog(@"wifi已关闭");
        } else if (wifiStatus == ZYBleInteractWifiHotspotStatusOn) {
            NSLog(@"wifi已开启");
        } else if (wifiStatus == ZYBleInteractWifiHotspotStatusErr) {
            NSLog(@"wifi错误");
        }
    };
    
    sendWiFiStatus();
}


+ (void)sendCraneM2Request:(NSUInteger)params requestCompleteBlock:(requestCompleteBlock)complete
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleInteractButtonEvent data:@(params) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"zzzzzz params:0x%lx", (unsigned long)param);
        } else {
            NSLog(@"message %lx", value);
        }
    }];
}

+ (void)testCraneM2Request
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[ZYDeviceManager defaultManager].stablizerDevice zoomStatusChanged:YES isStart:YES result:^(BOOL success) {
//            NSLog(@"testCraneM2Request == %ld", success);
//
//        }];
//
//        [[ZYDeviceManager defaultManager].stablizerDevice setStabilizerCarryDeviceTypeIsMobile:YES complete:^(BOOL success, ZYBlOtherDeviceTypeData *info) {
//            NSLog(@"testCraneM2 === %ld, %ld", success, info);
//
//
//            [[ZYDeviceManager defaultManager].stablizerDevice zoomStatusChanged:YES isStart:YES result:^(BOOL success) {
//
//            }];
//
//
//        }];
    });
}


#pragma 测试代码
+(void) testAllRequest
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    
    NSUInteger code = ZYBleInteractCodeDeviceCategory_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"产品序列号 0x%lx %@", (unsigned long)param, value.modelNumberString);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeVersion_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"软件版本 0x%lx %lu", (unsigned long)param, value.softwareVersion);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeSystemStatus_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"系统状态 0x%lx 欠压%d ICU掉线%d Z电机掉线%d Y电机掉线%d X电机掉线%d IMU异常%d 回头模式标志%d 开机状态标志%d", (unsigned long)param, value.bLowVoltage, value.bLowVoltage, value.bZOffLine, value.bYOffLine, value.bXOffLine, value.bIMUExeption, value.bTurnRound, value.bPower);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeBatteryVoltage_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"电池电压 0x%lx %.2fV", (unsigned long)param, value.fBatteryVoltage);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePower_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"开关机状态 0x%lx %lu", (unsigned long)param, value.powerStatus);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeDebug_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"调试模式 0x%lx %lu", (unsigned long)param, value.debugMode);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUControlRegister_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"IMU控制寄存器 0x%lx", (unsigned long)param);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUStateRegister_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"IMU状态寄存器 0x%lx", (unsigned long)param);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeGyroStandardDeviation_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"陀螺标准差 0x%lx", (unsigned long)param);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeGyroStandardDeviation_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"陀螺标准差 0x%lx", (unsigned long)param);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUAX_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"X轴加速度原始数据 0x%lx %lu", (unsigned long)param, value.IMUAX);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUAY_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"Y轴加速度原始数据 0x%lx %lu", (unsigned long)param, value.IMUAY);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUAZ_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"Z轴加速度原始数据 0x%lx %lu", (unsigned long)param, value.IMUAZ);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUGX_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"X轴陀螺仪原始数据 0x%lx %lu", (unsigned long)param, value.IMUGX);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUGY_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"Y轴陀螺仪原始数据 0x%lx %lu", (unsigned long)param, value.IMUGY);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeIMUGZ_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"Z轴陀螺仪原始数据 0x%lx %lu", (unsigned long)param, value.IMUGZ);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchAngle_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰角度 0x%lx %.2f", (unsigned long)param, value.pitchAngle);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollAngle_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚角度 0x%lx %.2f", (unsigned long)param, value.rollAngle);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeYawAngle_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"航向角度 0x%lx %.2f", (unsigned long)param, value.yawAngle);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchSharpTurning_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰微调 0x%lx %.2f", (unsigned long)param, value.pitchSharpTurning);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollSharpTurning_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚微调 0x%lx %.2f", (unsigned long)param, value.rollSharpTurning);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeWorkMode_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"工作模式 0x%lx %lu", (unsigned long)param, value.workMode);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchDeadArea_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰跟随死区 0x%lx %.2f", (unsigned long)param, value.pitchDeadArea);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollDeadArea_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚跟随死区 0x%lx %.2f", (unsigned long)param, value.rollDeadArea);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeYawDeadArea_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"航向跟随死区 0x%lx %.2f", (unsigned long)param, value.yawDeadArea);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchFollowMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰最大跟随速率 0x%lx %.3f", (unsigned long)param, value.pitchFollowMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollFollowMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚最大跟随速率 0x%lx %.3f", (unsigned long)param, value.rollFollowMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeYawFollowMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"航向最大跟随速率 0x%lx %.3f", (unsigned long)param, value.yawFollowMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchSmoothness_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰平滑度 0x%lx %.3f", (unsigned long)param, value.pitchSmoothness);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollSmoothness_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚平滑度 0x%lx %.3f", (unsigned long)param, value.rollSmoothness);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeYawSmoothness_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"航向平滑度 0x%lx %.3f", (unsigned long)param, value.yawSmoothness);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodePitchControlMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"俯仰最大控制速率 0x%lx %.3f", (unsigned long)param, value.pitchControlMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRollControlMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"横滚最大控制速率 0x%lx %.3f", (unsigned long)param, value.rollControlMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeYawControlMaxRate_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"航向最大控制速率 0x%lx %.3f", (unsigned long)param, value.yawControlMaxRate);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeRockerDirectionConfig_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"摇杆方向配置 0x%lx 俯仰反向%d 俯仰反向%d 横滚反向%d", (unsigned long)param, value.bControllerXAnti, value.bControllerYAnti, value.bControllerZAnti);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeCameraManufacturer_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"相机厂商 0x%lx %@", (unsigned long)param, value.cameraManufacturerString);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractCodeMotorForce_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"电机力度 0x%lx %lu", (unsigned long)param, value.motorForceMode);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractXMotorState_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBleDeviceMotorModel* model = [value.motorStatus objectAtIndex:0];
            NSLog(@"X电机状态 0x%lx 节点掉线%d 过热%d 电源故障%d 零点异常%d 反馈异常%d 运行%d 就绪%d", (unsigned long)param, model.bOffLine, model.bOverheat, model.bPowerTrouble, model.bZeroException, model.bFeedbackException, model.bWorking, model.bReady);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractXMotorVersion_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            
            NSLog(@"X电机软件版本号 0x%lx %lu", (unsigned long)param, [[value.motorStatus objectAtIndex:0] softwareVersion]);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractYMotorState_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBleDeviceMotorModel* model = [value.motorStatus objectAtIndex:1];
            NSLog(@"Y电机状态 0x%lx 节点掉线%d 过热%d 电源故障%d 零点异常%d 反馈异常%d 运行%d 就绪%d", (unsigned long)param, model.bOffLine, model.bOverheat, model.bPowerTrouble, model.bZeroException, model.bFeedbackException, model.bWorking, model.bReady);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractYMotorVersion_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            
            NSLog(@"Y电机软件版本号 0x%lx %lu", (unsigned long)param, [[value.motorStatus objectAtIndex:1] softwareVersion]);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractZMotorState_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBleDeviceMotorModel* model = [value.motorStatus objectAtIndex:2];
            NSLog(@"Z电机状态 0x%lx 节点掉线%d 过热%d 电源故障%d 零点异常%d 反馈异常%d 运行%d 就绪%d", (unsigned long)param, model.bOffLine, model.bOverheat, model.bPowerTrouble, model.bZeroException, model.bFeedbackException, model.bWorking, model.bReady);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
    
    code = ZYBleInteractZMotorVersion_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            
            NSLog(@"Z电机软件版本号 0x%lx %lu", (unsigned long)param, [[value.motorStatus objectAtIndex:2] softwareVersion]);
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
}

+(void) testWriteRequest
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    
    NSUInteger code = ZYBleInteractCodeWorkMode_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"工作模式 0x%02lx %lu", (unsigned long)param, value.workMode);
            if (value.workMode != ZYBleDeviceWorkModeLock) {
                [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleInteractCodeWorkMode_W data:@(ZYBleDeviceWorkModeLock) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        NSLog(@"写入工作模式成功 %lu", ZYBleDeviceWorkModeLock);
                        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                            if (state == ZYBleDeviceRequestStateResponse) {
                                NSLog(@"测试工作模式 %lu", value.workMode);
                            }
                        }];
                    }
                }];
            }
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
}

+(void) testNewMotion
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    
    
    void(^motionCall)(void) = ^(void) {
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleLocaltionSetPointControlRegister data:@(ZYBleLocationSetPointControlRegisterTypeClean) completionHandler:nil];
        
        //        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBlePitchRotateAngleControl data:@(0) completionHandler:nil];
        //        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleRollRotateAngleControl data:@(0) completionHandler:nil];
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleYawRotateAngleControl data:@(30) completionHandler:nil];
        
        int nTime = 10000;
        
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleSetPointMotionTimeLowBit data:@(nTime) completionHandler:nil];
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleSetPointMotionTimeHighBit data:@(nTime) completionHandler:nil];
        
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleLocaltionSetPointControlRegister data:@(ZYBleLocationSetPointControlRegisterTypeStart) completionHandler:nil];
        
        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleLocaltionSetPointPowered data:@(ZYBleLocationSetPointPoweredOn) completionHandler:nil];
        
        
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleLocaltionSetPointStateRegister_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                if (state == ZYBleDeviceRequestStateResponse) {
#define CheckBit(val, pos) ((val&(0x0001<<pos))==(0x0001<<pos))
                    NSMutableString* stateString = [NSMutableString string];
                    for (int i = 0; i < 7; i++) {
                        if (CheckBit(param, i)) {
                            if (i == 0) {
                                [stateString appendString:@"使能"];
                            } else if (i == 1) {
                                [stateString appendString:@"开始"];
                            } else if (i == 2) {
                                [stateString appendString:@"完成"];
                            } else if (i == 3) {
                                [stateString appendString:@"暂停"];
                            } else if (i == 4) {
                                [stateString appendString:@"俯仰"];
                            } else if (i == 5) {
                                [stateString appendString:@"横滚"];
                            } else if (i == 6) {
                                [stateString appendString:@"航向"];
                            }
                        }
                    }
                    NSLog(@"定点状态 %lx %@", param, stateString);
                } else {
                }
            }];
        }];
    };
    
    NSUInteger code = ZYBleInteractCodeWorkMode_R;
    [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"工作模式 0x%02lx %lu", (unsigned long)param, value.workMode);
            if (value.workMode != ZYBleDeviceWorkModeLock) {
                [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:ZYBleInteractCodeWorkMode_W data:@(ZYBleDeviceWorkModeLock) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        NSLog(@"写入工作模式成功 %lu", ZYBleDeviceWorkModeLock);
                        [[ZYDeviceManager defaultManager].stablizerDevice sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                            if (state == ZYBleDeviceRequestStateResponse) {
                                NSLog(@"测试工作模式 %lu", value.workMode);
                                motionCall();
                            }
                        }];
                    }
                }];
            } else {
                motionCall();
            }
        } else {
            NSLog(@"message %lx", (unsigned long)code);
        }
    }];
}
@end
