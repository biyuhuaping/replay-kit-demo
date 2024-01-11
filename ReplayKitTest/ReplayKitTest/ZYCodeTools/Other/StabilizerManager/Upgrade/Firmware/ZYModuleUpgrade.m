//
//  ZYModuleUpgrade.m
//  ZYCamera
//
//  Created by 吴伟祥 on
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYModuleUpgrade.h"

#import <mach/mach.h>
#import "CommonCrypto/CommonDigest.h"
#import "CommonCrypto/CommonHMAC.h"
int32_t const CHUNK_SIZE_ZY = 8 * 1024;

#define kLooTimeTnterval 0.25

#import "ZYModuleUpgrade.h"
#import "ZYBleDeviceClient.h"
#import "ZYHardwareUpgradeSyncModel.h"
#import "ZYHardwarePTZDealModel.h"
#import "ZYDeviceManager.h"
#import "ZYFirmwareUpgradeModel_WiFi.h"
#import "ZYBlOtherFileAsynData.h"
#import "ZYBlOtherCheckMD5Data.h"
#import <pthread.h>

#define kWifiPaging   1024
#define kBlePaging    256
//#import "OSSUtil.h"

@interface ZYModuleUpgrade  ()
{
    pthread_mutex_t _lock;
}
/**
 二进制数据
 */
@property(nonatomic, strong)NSData *firmwareData;

/**
 ptz数组
 */
@property(nonatomic, strong)NSMutableArray *mPtzFileArray;

/**
 同步数组
 */
@property(nonatomic, strong)NSMutableArray *mSyncArray;

/**
 WIFI写入失败
 */
@property(atomic, assign)BOOL wifiWriteFailed ;

/**
 WIFI写入的数组
 */
@property(atomic, strong)NSMutableArray *wifiWriteMArray;


/**
 进度条
 */
@property(nonatomic, copy)void (^progressBlock)(float progress) ;

/**
 进度条
 */
@property(nonatomic, copy)void (^waitingForUpgradeCompletdBlock)(float progress) ;

/**
 成功回调Block
 */
@property(nonatomic, copy)void (^successBlock)(void) ;

@property(nonatomic, copy)void (^failureBlock)(NSError *error);

/**
 发送成功总数
 */
@property(atomic, assign)float sendSuccessCount ;

/**
 升级模型
 */
@property(nonatomic, strong)ZYUpgradableInfoModel * mod;

@property(nonatomic, strong)NSTimer *waitingTimer;

@property(nonatomic, assign)BOOL isNeedToWaitingForOTACompleted ;

@property (nonatomic)         dispatch_semaphore_t signal;

@property(atomic, assign) NSUInteger completeCount ;//完成的个数


@end

@implementation ZYModuleUpgrade

-(instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitingNotifi:) name:ZYOtherSynDataOneUpgradeOfTheWaitingNotifi object:nil];
        self.signal = dispatch_semaphore_create(10);

        pthread_mutex_init(&_lock, NULL);

    }
    return self;
}

/**
 转换模型
 
 @param mod 模型
 @return 本类型
 */
+(instancetype)upgradeWithMod:(ZYUpgradableInfoModel *)mod{
    ZYModuleUpgrade *m = [ZYModuleUpgrade new];
    m.mod = mod;
    m.channel = mod.channel;
    m.firmwareData = mod.data;
    //NSLog(@" 升级对象创建====%@",m);
    return m;
}

-(void)clearData{
    if (self.waitingTimer) {
        self.failureBlock =  nil;
       [self.waitingTimer invalidate];
       _waitingTimer = nil;
       self.successBlock = nil;
       self.progressBlock = nil;
    }
}

/**
 设置二进制数据
 
 @param firmwareData <#firmwareData description#>
 */
-(void)setFirmwareData:(NSData *)firmwareData{
    _firmwareData = firmwareData;
}


-(NSMutableArray *)wifiWriteMArray{
    if (!_wifiWriteMArray) {
        _wifiWriteMArray = [NSMutableArray new];
    }
    return _wifiWriteMArray;
}

-(NSMutableArray *)mPtzFileArray{
    if (!_mPtzFileArray) {
        _mPtzFileArray = [NSMutableArray new];
    }
    return _mPtzFileArray;
}

-(NSMutableArray *)mSyncArray{
    if (!_mSyncArray) {
        _mSyncArray = [NSMutableArray new];
    }
    return _mSyncArray ;
}

/**
 通过模型创建对象
 
 @param data <#data description#>
 @return <#return value description#>
 */
+(instancetype)upgradeWithData:(NSData *)data{
    ZYModuleUpgrade *fm  = [ZYModuleUpgrade new];
    fm.firmwareData = data;
    return fm;
}

/**
 检查OTA是否需要等待
 */
- (void)checkIsOTANeedWait:(void (^)(BOOL success, BOOL needWait))handler{
    if (!handler) {
        return;
    }
    if (self.isNeedCheckWaiting == NO) {
        BLOCK_EXEC(handler,NO,NO);
        return;
    }
    ZYBlOtherOTAWaitData *otaWaitData = [ZYBlOtherOTAWaitData bleOtherOTAWaitData];
    ZYBleMutableRequest *blOtherFileAsynRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:otaWaitData];
    [self sendMutableRequest:blOtherFileAsynRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherOTAWaitData *otaResponse = (ZYBlOtherOTAWaitData*)param;
            handler(YES, otaResponse.needWait);
        } else {
            handler(NO, NO);
        }
    }];
}

/**
 开始升级
 
 @param progress 进度
 @param successed 成功
 @param failure 失败
 */
-(void)beginUpgradeProgress:(void (^)(float progress))progress Successed:(void (^)(void))successed failure:(void (^)(NSError *error))failure waitingForUpgradeCompletd:(void(^)(float progress))waitingForUpgradeCompletd{
    self.progressBlock =  progress;
    self.waitingForUpgradeCompletdBlock = waitingForUpgradeCompletd;
    [self.mSyncArray removeAllObjects];
    
    //NSLog(@"开始升级模块%@", _mod);
    
    @weakify(self)
    
    [self prepareUpgradeSuccessed:^{
        //NSLog(@"prepareUpgradeSuccessed successed!");
        @strongify(self)
        //NSLog(@"=======准备数据已完成，开始写入数据");
        
        [self writeDataSuccessed:^{
            //NSLog(@"文件写入完成");
            @strongify(self)
            
            [self finalCheckWithSuccessed:successed failure:failure];
            
            
        } failure:^(NSError *error) {
            
            BLOCK_EXEC(failure,error);
            
            //NSLog(@"文件写入失败 error :%@",error);
        }];
        
    } failure:^(NSError *error){
        BLOCK_EXEC(failure,error);
        //NSLog(@"prepareUpgradeSuccessed failure!:%@",error);
    }];
    
}

/**
 准备升级
 
 @param successed 成功
 @param failure 失败
 */
-(void)prepareUpgradeSuccessed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    //    self.temp = YES;
    
    @weakify(self)
    [self checkIsOTANeedWait:^(BOOL success, BOOL needWait) {
        @strongify(self)
        //NSLog(@":%d------needWait:%d   ",success,needWait);
        if (success) {
            self.isNeedToWaitingForOTACompleted = needWait;
        }else{
            self.isNeedToWaitingForOTACompleted = NO;
        }
        
        [self systemReset:^{//复位
            NSInteger deviceOne = 1;
            //NSLog(@"调用 同步 设备");
            
            @strongify(self)
            [self syncWithAddress:deviceOne resendCount:0 successed:^(ZYHardwareUpgradeSyncModel *syncResult) {//sync 1 device
                [NSThread sleepForTimeInterval:1];
                @strongify(self)
                [self.mSyncArray addObject:syncResult];
                
                [self bypassWithSuccessed:^(ZYHardwareUpgradeSyncModel *syncModel) {//bypass
                    @strongify(self)
                    
                    [self loopSyncOtherCompleted:^{//loop sync devices
                        @strongify(self)
                        
                        [self firmwareResetWithAddress:deviceOne successed:^{//rest 不带参数.
                            BLOCK_EXEC(successed);
                            
                        } failure:failure];
                    }];
                } failure:failure];
                
            } failure:failure];
        } failure:failure];
    }];
    
}

/**
 写入数据
 
 @param successed 成功
 @param failure 失败
 */
-(void)writeDataSuccessed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    __block NSInteger deviceIndext = 1;
    ZYBleDeviceRequest *request = [[ZYBleDeviceRequest alloc] init];
    [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    if (request.parseFormat == ZYCodeParseUsb  && self.mod.channel == ZYUpgradableChannelWiFi) {
        self.wifiWriteFailed = NO;
        [self.wifiWriteMArray removeAllObjects];
        self.sendSuccessCount = 0.;
        @weakify(self)
        [self checkAsyncTypeWithASuccessed:^(BOOL async) {
            @strongify(self)
            [self writeFileFor_WiFi_WithAddress:1 async:async successed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    BLOCK_EXEC(successed);
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BLOCK_EXEC(failure,error);
                });
            }];
        } failure:failure];
        
    }else{
        [self loopToWriteDataWithDeviceIndext:deviceIndext successed:successed failure:failure];
        
    }
    
}



/**
 循环写入数据
 
 @param deviceInedet 设备下标
 @param successed 成功
 @param failure 失败
 */
-(void)loopToWriteDataWithDeviceIndext:(NSInteger)deviceInedet successed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    
    
//    ZYHardwarePTZDealModel *ptz = [self.mPtzFileArray objectAtIndex:(deviceInedet-1)];
    @weakify(self)
    [self checkAndWriteWithAddress:deviceInedet ptzDeviceIndextSize:0 crcCode:0 successed:^{
        @strongify(self)
        
        NSInteger nextDeviceIndext = deviceInedet + 1;
        
        if (nextDeviceIndext>[self.mPtzFileArray count] || nextDeviceIndext>[self.mSyncArray count]) {
            //NSLog(@"loopToWriteDataWithDeviceIndext return");
            BLOCK_EXEC(successed)
            return ;
        }
        [self loopToWriteDataWithDeviceIndext:nextDeviceIndext successed:successed failure:failure];
        
    } failure:^(NSError *error) {
        NSError *err = [NSError errorWithDomain:[NSString stringWithFormat:@"loopToWriteDataWithDeviceIndext farilure! index:%ld code:%ld",deviceInedet,error.code] code:error.code userInfo:nil];
        BLOCK_EXEC(failure,err)
        
    }];
}

/**
 系统复位
 
 @param successed 成功
 @param failure 失败
 */
-(void)systemReset:(void(^)())successed failure:(void(^)(NSError *error))failure{
    
    [self sendRequest:ZYBleInteractSysReset data:@(ZYBLE_DATA_RESET) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            //NSLog(@"MD 系统复位成功");
            BLOCK_EXEC(successed);
        } else if (([[ZYDeviceManager defaultManager] isZWB_Device] ) && (state == ZYBleDeviceRequestStateTimeout)) {
            //NSLog(@"MD 系统复位失败 回调成功");
            
            BLOCK_EXEC(successed);
            
        }else {
            NSError *error = [NSError errorWithDomain:@"System reset farilure" code:0 userInfo:nil];
            BLOCK_EXEC(failure,error);
            //NSLog(@"MD 系统复位失败 ！！！");
            
        }
    }];
}

/**
 发送指令
 
 @param code 指令
 @param handler 回调
 */
-(void) sendRequest:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    [self sendRequest:code data:@(0) completionHandler:handler];
}

/**
 发送指令
 
 @param code 指令
 @param data 二进制
 @param handler 回调
 */
-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    [self configRequest:request];
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}

-(void)configRequest:(ZYBleDeviceRequest *)request{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    
    if (_mod.channel == ZYUpgradableChannelWiFi) {
        request.trasmissionType = ZYTrasmissionTypeWIFI;
        request.parseFormat = ZYCodeParseUsb;
    } else {
        request.trasmissionType = ZYTrasmissionTypeBLE;
        request.parseFormat = ZYCodeParseBl;
    }
}

/**
 同步设备， 连续3次sync，没响应表示该设备不存在.
 @param address 设备号
 @param resendCount 发送失败后，重复发送的次数
 
 */
-(void)syncWithAddress:(NSInteger)address resendCount:(NSInteger)resendCount successed:(void(^)(ZYHardwareUpgradeSyncModel *syncResult))successed failure:(void(^)(NSError *error))failure{
    //NSLog(@"开始同步%ld设备",(long)address);
    
    if (address == 1) {
        @weakify(self)
        
        [self sendOrderToFirmwareWithAddress:address command:ZYBleInteractSync delayTime:1 successed:^(id param) {
            ZYHardwareUpgradeSyncModel *syncResult =  [ZYHardwareUpgradeSyncModel UpgradeSyncModelWithDictionary:param];
            //NSLog(@"同步%ld成功",(long)address);
            BLOCK_EXEC(successed,syncResult);
        } failure:^(NSError *error){
            @strongify(self)
            if (resendCount<10) {//1号设备如果同步失败，重复同步10次，间隔1秒
                NSInteger tempResendCount = resendCount+1;
                [self syncWithAddress:address resendCount:tempResendCount successed:successed failure:failure];
                //NSLog(@"同步%ld 失败 resend:%ld",address,resendCount);
                
                return ;
            }
            NSError *err = [NSError errorWithDomain:[NSString stringWithFormat:@"sync %ld failure resendCount:%ld",address,resendCount] code:0 userInfo:nil];
            BLOCK_EXEC(failure,err);
        }];
        return;
    }
    @weakify(self)
    
    [self sendOrderToFirmwareWithAddress:address command:ZYBleInteractSync successed:^(id param) {
        ZYHardwareUpgradeSyncModel *syncResult =  [ZYHardwareUpgradeSyncModel UpgradeSyncModelWithDictionary:param];
        if (syncResult) {
            //NSLog(@"同步%ld成功",(long)address);
            BLOCK_EXEC(successed,syncResult);
        } else {
            NSError *err = [NSError errorWithDomain:[NSString stringWithFormat:@"sync %ld failure resendCount:%ld",address,resendCount] code:0 userInfo:nil];
            BLOCK_EXEC(failure,err);
        }
    } failure:^(NSError *error){
        
        @strongify(self)
        if (resendCount<3) {//2号及以上设备如果同步失败，重复同步3次，间隔0.25秒
            NSInteger tempResendCount = resendCount+1;
            [self syncWithAddress:address resendCount:tempResendCount successed:successed failure:failure];
            //NSLog(@"同步%ld 失败 resend:%ld",address,resendCount);
            return ;
        }
        NSError *err = [NSError errorWithDomain:[NSString stringWithFormat:@"sync %ld failure resendCount:%ld",address,resendCount] code:0 userInfo:nil];
        BLOCK_EXEC(failure,err);
    }];
}




/**
 Bypass 1号设备通信完成后要与其他设备通信时需要发送BYPASS指令，使1号设备将数据指令下发至其他节点
 */
-(void)bypassWithSuccessed:(void(^)(ZYHardwareUpgradeSyncModel *syncModel))successed failure:(void(^)(NSError *error))failure{//
    [self sendOrderToFirmwareWithAddress:1 command:ZYBleInteractByPass successed:^(id param) {
        ZYHardwareUpgradeSyncModel *syncResult =  [ZYHardwareUpgradeSyncModel UpgradeSyncModelWithDictionary:param];
        //NSLog(@"bypass 成功");
        
        BLOCK_EXEC(successed,syncResult);
    } failure:^(NSError *error){
        NSError *err = [NSError errorWithDomain:@"bypassWithAddress %d failure" code:error.code userInfo:nil];
        BLOCK_EXEC(failure,err);
    }];
}

/**
 WIFI写写文件
 
 @param address 地址
 @param async 同步
 @param successed 成功
 @param failure 失败
 */
-(void)writeFileFor_WiFi_WithAddress:(NSInteger)address async:(BOOL)async successed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    
    NSInteger maxSendSize =  kWifiPaging;
    NSInteger count = _firmwareData.length / maxSendSize;
    //NSLog(@"toatalCount =========%ld",count);
    __block NSInteger tempCount = count;
    if (maxSendSize * count  < _firmwareData.length ) {
        tempCount += 1;
    }
    self.completeCount = 0;
    
    __block void(^successedBlock)(void) = successed;
    __block void(^failureBlock)(NSError *) = failure;
    @weakify(self)
    dispatch_queue_t queuet = dispatch_queue_create([@"DISPATCH_QUEUE_CONCURRENT_kkkkk" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queuet, ^{
        dispatch_queue_t queueTT = dispatch_queue_create([@"DISPATCH_QUEUE_CONCURRENT_kkkkk22" UTF8String], DISPATCH_QUEUE_CONCURRENT);
        @strongify(self);
        self.wifiWriteFailed = NO;
        for (int a = 0; a < tempCount; a++) {
                __block int pageIndex = a + 1;//页码
                NSData * subdata;
                if (a >= count) {
                    NSInteger  lastSize =  self.firmwareData.length - ( count * maxSendSize ) ;
                    subdata = [self->_firmwareData subdataWithRange:NSMakeRange(count  * maxSendSize , lastSize)];
                }else{
                    subdata = [self->_firmwareData subdataWithRange:NSMakeRange(a  * maxSendSize ,maxSendSize)];
                }
            dispatch_async(queueTT, ^{
                
//                [self setAsync:async withCount:a handler:^{
                    @strongify(self)
                    //NSLog(@"%d pageIndex",pageIndex);
                    //NSLog(@"pageIndex =========%ld",pageIndex);
                    //            //NSLog(@"写入下标:%d 元素总数:%d :%ld",a,[self.wifiWriteMArray count],count);
                    //            int pageIndex = a+1;
                    [self sendData:subdata address:address pageIndex:pageIndex repeats:3 completed:^(BOOL isSuccess) {
                        @strongify(self)
                        if (self.wifiWriteFailed == NO) {
                            if (isSuccess == NO) {
                                //NSLog(@"发送数据失败了");
                                pthread_mutex_lock(&self->_lock);
                                self.wifiWriteFailed = YES;
                                pthread_mutex_unlock(&self->_lock);
                            }
                            else{
                                pthread_mutex_lock(&self->_lock);
                                self.completeCount ++;
                                pthread_mutex_unlock(&self->_lock);

                                //NSLog(@"-------------完成%d %d",self.completeCount,isSuccess);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    @strongify(self)
                                    
                                    BLOCK_EXEC(self.progressBlock,(self.completeCount * 1.0)/tempCount);
                                    
                                });
                            }
                        }
                        if (self.wifiWriteFailed) {
                            if (failureBlock) {
                                //NSLog(@"-------------失败%d %d",self.completeCount,isSuccess);
                                
                                BLOCK_EXEC(failureBlock,[NSError errorWithDomain:@"WIFI Send DATA Failure!" code:kSendDataErrorCode userInfo:nil]);
                                failureBlock = nil;
                                
                            }
                            
                        }
                        else{
                            if (self.completeCount == tempCount) {
                                //NSLog(@"%ld 完成",(long)self.completeCount);
                                if (successedBlock) {
                                    BLOCK_EXEC(successedBlock);
                                    successedBlock = nil;
                                }
                            }
                            else{
                                //NSLog(@"%ld 完成",(long)self.completeCount);
                            }
                            
                        }
                        dispatch_semaphore_signal(self.signal);
                        
                    }];
//                }];
            });

                dispatch_semaphore_wait(self.signal, DISPATCH_TIME_FOREVER);
                if (self.wifiWriteFailed) {
                    break;
                }
            
        };
    });
    
    
}


/**
 同步
 
 @param async 同步
 @param count 总数
 @param handler 回调
 */
-(void)setAsync:(BOOL)async withCount:(int)count handler:(void (^)())handler{
    if (async) {
        NSString *str = [NSString stringWithFormat:@"WriteDataForWIFI%d",count];
        
        //        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create([str UTF8String], DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            BLOCK_EXEC(handler);
            
        });
        //        dispatch_group_async(group,queue,^{
        //            BLOCK_EXEC(handler);
        //        });
        
    }else{
        BLOCK_EXEC(handler);
    }
    
}

/**
 发送数据
 
 @param data 数据
 @param address 地址
 @param pageIndex 分页下标
 @param completed 完成
 */
-(void)sendData:(NSData*)data address:(NSInteger)address pageIndex:(NSInteger)pageIndex  completed:(void(^)(BOOL isSuccess))completed {
    
    //NSLog(@"WIFI写入：address:%ld  pageIndex:%ld  ",address,pageIndex);
    
    ZYBleMutableRequest *req = [[ZYBleMutableRequest alloc]initWithCodeAndParamWith2BytesDataAndBuffer:address withCommand:ZYBleInteractUpdateWrite param:pageIndex buffer:data];
    @weakify(self);
    [self sendMutableRequest:req completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse ) {
             if ([param isKindOfClass:[NSDictionary class]]) {
                                NSNumber *dataParse = [(NSDictionary*)param objectForKey:kDataParseSuccess];
                                if (dataParse) {
            #pragma -mark 数据解析失败的时候，先识别为发送错误
                                    if ([dataParse boolValue] == NO) {
                                        state = ZYBleDeviceRequestStateFail;
                                    }
                                }
                            }
            //NSLog(@"----写入数据响应 成功 index:%ld ",pageIndex);
            BLOCK_EXEC(completed,YES);
        } else {
            [self sendData:data address:address pageIndex:pageIndex  completed:completed];
            
            //NSLog(@"写入数据 失败 XXX:%ld ",pageIndex);
            BLOCK_EXEC(completed,NO);
            
        }
    }];
}

/**
 发送二进制
 
 @param data 二进制
 @param address 地址
 @param pageIndex 分页下标
 @param repeats 重复次数
 @param completed 完成
 */
-(void)sendData:(NSData*)data address:(NSInteger)address pageIndex:(NSInteger)pageIndex repeats:(int)repeats completed:(void(^)(BOOL isSuccess))completed {
    if (self.wifiWriteFailed) {
        //NSLog(@"WIFI 升级失败中断");

        //NSLog(@"WIFI 升级失败中断");
        BLOCK_EXEC(completed,NO);
        return;
    }
    
    __block int repeatsCount = repeats - 1;
    //NSLog(@"WIFI写入：address:%ld  pageIndex:%ld  repeats:%d",address,pageIndex,repeatsCount);
    
    ZYBleMutableRequest *req = [[ZYBleMutableRequest alloc]initWithCodeAndParamWith2BytesDataAndBuffer:address withCommand:ZYBleInteractUpdateWrite param:pageIndex buffer:data];
    @weakify(self);
    [self sendMutableRequest:req completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse ) {
            //NSLog(@"----写入数据响应 成功 index:%ld repeats:%d",pageIndex,repeatsCount);
            BLOCK_EXEC(completed,YES);
        } else {
            if (repeatsCount > 0 && self.wifiWriteFailed == NO) {
                [self sendData:data address:address pageIndex:pageIndex repeats:repeatsCount completed:completed];
                return ;
            }
            //NSLog(@"写入数据 失败 XXX:%ld repeats:%d",pageIndex,repeatsCount);
            BLOCK_EXEC(completed,NO);
            
        }
    }];
}

/**
 检查写入
 
 @param address 地址
 @param size 尺寸
 @param crcCode CRC
 @param successed 成功
 @param failure 失败
 */
-(void)checkAndWriteWithAddress:(NSInteger)address ptzDeviceIndextSize:(NSInteger)size crcCode:(NSInteger)crcCode successed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    @weakify(self)
    [self writeDataToFirmwareWithsendAddress:address pageIndex:0 repeatCount:0 completed:^(BOOL isSuccess){
        if (isSuccess) {
            //NSLog(@"设备%ld号写入完毕！",address);
            BLOCK_EXEC(successed);
        }else{
            BLOCK_EXEC(failure, [NSError errorWithDomain:@"写入文件失败，升级失败" code:-1 userInfo:nil]);
            
        }
        
    }];
    
}

/**
 检查
 
 @param address 地址
 @param size 尺寸
 @param successed 成功
 @param failure 失败
 */
-(void)checkWithAddress:(NSInteger)address ptzDeviceIndextSize:(NSInteger)size successed:(void(^)(NSInteger crc))successed failure:(void(^)(NSError *error))failure{
    [self sendOrderToFirmwareWithAddress:address withCommand:ZYBleInteractCheck param:size successed:^(id param) {
        NSNumber *crc = [(NSDictionary *)param objectForKey:@"crc"];
        if (crc) {
            //NSLog(@"check firwmare:%ld 成功",address);
            NSInteger tempCrc = [crc integerValue];
            BLOCK_EXEC(successed,tempCrc);
        }else{
            NSError *error = [NSError errorWithDomain:@"crc do not fit" code:0 userInfo:nil];
            BLOCK_EXEC(failure,error);
        }
    } failure:^(NSError *error){
        //NSLog(@"check firwmare:%ld 失败",address);
        NSError *err = [NSError errorWithDomain:@"Check fIrmware Failure" code:error.code userInfo:nil];
        BLOCK_EXEC(failure,err);
    }];
}

/**
 发送成功检查
 
 @param successed 成功
 @param failure 失败
 */
-(void)finalCheckWithSuccessed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    @weakify(self)
    
    [self sendMD5DataWithASuccessed:^{
        @strongify(self)
        [self appGoWithSuccessed:^{
            @strongify(self)
            if (self.isNeedToWaitingForOTACompleted) {
                self.successBlock = successed;
                self.failureBlock = failure;
                int timeOut = 180;
                self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(waitingTimeOut) userInfo:nil repeats:NO];
            }else{
                BLOCK_EXEC(successed);
            }
        }  failure:failure];
        
    } failure:failure];
    
    
}

/**
 APP GO
 
 @param successed 成功
 @param failure 失败
 */
-(void)appGoWithSuccessed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    
    
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:1 withCommand:ZYBleInteractAppgo];
    //NSLog(@"发送 appGo");
    [self sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateFail) {
            //NSLog(@"appGo 失败");
            
            NSError *error = [NSError errorWithDomain:@"appGo farilure" code:kAPPGOAlreadySendCode userInfo:nil];
            BLOCK_EXEC(failure,error);
            return ;
        }
        //NSLog(@"appGo 成功");
        BLOCK_EXEC(successed);
    }];
    
}

/**
 APP GO
 
 @param successed 成功
 @param failure 失败
 */
-(void)appGoJumpWithHandler:(void(^)())successed failure:(void(^)(NSError *error))failure{
    [self.waitingTimer invalidate];
    _waitingTimer = nil;
    self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(waitingTimeOut) userInfo:nil repeats:NO];
    self.successBlock = successed;
    self.failureBlock = failure;
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:1 withCommand:ZYBleInteractAppgo];
    //NSLog(@"发送 appGo");
    [self sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        
    }];
    
}

-(void)queryIsNeedToWaitSuccess:(void(^)())success failure:(void (^)(NSError *error))failure{}

/**
 rest之后.给第一台设备的sync10秒都没响应表示升级失败.超时10秒内重复发送.间隔1秒
 */
-(void)firmwareResetWithAddress:(NSUInteger)address successed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    
    [self sendOrderToFirmwareWithAddress:address command:ZYBleInteractBootReset successed:^(id param) {
        //NSLog(@"ZYBleInteractBootReset success!");
        BLOCK_EXEC(successed);
    } failure:^(NSError *error) {
        if (error.code == 2) {// reset 不响应，code = 2代表超时.
            BLOCK_EXEC(successed);
            return ;
        }
        //NSLog(@"ZYBleInteractBootReset error!");
        
        NSError *err = [NSError errorWithDomain:@"ZYBleInteractBootReset Failure" code:error.code userInfo:nil];
        BLOCK_EXEC(failure,err);
    }];
}

/**
 MD5
 
 @param successed 成功
 @param failure 失败
 */
-(void)sendMD5DataWithASuccessed:(void(^)())successed failure:(void(^)(NSError *error))failure{
    ZYBlOtherCheckMD5Data* blOtherCheckMD5Data = [[ZYBlOtherCheckMD5Data alloc] init];
    NSString *md5 = [[self class] dataMD5String:self.firmwareData];
    blOtherCheckMD5Data.md5 = md5;
    [blOtherCheckMD5Data createRawData];
    ZYBleMutableRequest* blOtherCheckMD5Request = [[ZYBleMutableRequest alloc] initWithZYControlData:blOtherCheckMD5Data];
    [self sendMutableRequest:blOtherCheckMD5Request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCheckMD5Data* blOtherCheckMD5DataRespond = (ZYBlOtherCheckMD5Data*)param;
            
            if (blOtherCheckMD5DataRespond.flag==1) {
                //NSLog(@"MD5值校验失败");
                BLOCK_EXEC(failure,[NSError errorWithDomain:@"send MD5 Data failure" code:0 userInfo:nil]);
                return ;
            }
        }
        
        if (state == ZYBleDeviceRequestStateTimeout) {
            //NSLog(@"MD5值校验失败 超时");
            //            BLOCK_EXEC(failure,[NSError errorWithDomain:@"send MD5 Data failure time out" code:0 userInfo:nil]);
            //            return ;
            
        }else if(state == ZYBleDeviceRequestStateFail){
            //NSLog(@"MD5值校验失败");
            //            BLOCK_EXEC(failure,[NSError errorWithDomain:@"send MD5 Data failure" code:0 userInfo:nil]);
            //            return ;
        }
        //NSLog(@"MD5值校验 成功");
        
        BLOCK_EXEC(successed);
    }];
}

/**
 检查同步
 
 @param successed 成功
 @param failure 失败
 */
-(void)checkAsyncTypeWithASuccessed:(void(^)(BOOL async))successed failure:(void(^)(NSError *error))failure{
    
    ZYBlOtherFileAsynData* blOtherFileAsynData = [[ZYBlOtherFileAsynData alloc] init];
    [blOtherFileAsynData createRawData];
    ZYBleMutableRequest* blOtherFileAsynRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:blOtherFileAsynData];
    [self sendMutableRequest:blOtherFileAsynRequest completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherFileAsynData* blOtherFileAsynDataRespond = (ZYBlOtherFileAsynData*)param;
            if (blOtherFileAsynDataRespond.flag) {
                //NSLog(@"文件检查 是否需要 异步传输 成功");
                BLOCK_EXEC(successed, YES);
                return ;
            }
        }
        //NSLog(@"文件检查 是否需要 异步传输 失败 使用同步传输");
        BLOCK_EXEC(successed, NO);
        //BLOCK_EXEC(failure,[NSError errorWithDomain:@"check Async Type failure" code:0 userInfo:nil]);
    }];
    
}

/**
 循环同步
 
 @param completed 回调
 */
-(void)loopSyncOtherCompleted:(void(^)())completed{
    @weakify(self)
    int nextAddress = [self.mSyncArray count]+1;
    //NSLog(@"loopSyncOtherCompleted %d",nextAddress);
    
    [self syncWithAddress:nextAddress resendCount:0 successed:^(ZYHardwareUpgradeSyncModel *syncResult){
        @strongify(self)
        [self.mSyncArray addObject:syncResult];
        [self loopSyncOtherCompleted:completed];
    } failure:^(NSError *error) {
        //NSLog(@"loopSyncOtherCompleted!");
        BLOCK_EXEC(completed)
    }];
}


/**
 写入数据
 
 @param address 地址
 @param pageIndex 分页下标
 @param repeatCount 重复次数
 @param completed 完成
 */
-(void)writeDataToFirmwareWithsendAddress:(NSInteger)address pageIndex:(NSInteger)pageIndex repeatCount:(int)repeatCount completed:(void(^)(BOOL success))completed{
    
    NSInteger count ;
    NSData *subdata;
    if ([ZYHardwareUpgradeManager isCanUpgradeDevice]) {
        
        NSInteger maxSendSize = kBlePaging;
        count = _firmwareData.length / maxSendSize;
        if (maxSendSize * pageIndex  <= _firmwareData.length - maxSendSize) {
            subdata = [_firmwareData subdataWithRange:NSMakeRange(pageIndex  * maxSendSize ,maxSendSize)];
            
        }else{
            NSInteger  lastSize =  _firmwareData.length - ( pageIndex * maxSendSize ) ;
            subdata = [_firmwareData subdataWithRange:NSMakeRange(pageIndex  * maxSendSize , lastSize)];
        }
    }else{
        ZYHardwarePTZDealModel *ptz = [self.mPtzFileArray objectAtIndex:(address-1)];
        ZYHardwareUpgradeSyncModel *sync = [self.mSyncArray objectAtIndex:(address-1)];
        //NSLog(@"%@",ptz);
        count = ptz.size/sync.size;
        
        if (pageIndex<count) {
            subdata = [_firmwareData subdataWithRange:NSMakeRange(ptz.pagePos+pageIndex*sync.size, sync.size)];
            
        }else{
            subdata = [_firmwareData subdataWithRange:NSMakeRange(ptz.pagePos+pageIndex*sync.size, ptz.size%sync.size)];
        }
    }
    float p = pageIndex ;
    float c = count ;
    
    BLOCK_EXEC(self.progressBlock,p / c);
    
    
    //    }else{
    //        subdata = [_firmwareData subdataWithRange:NSMakeRange(ptz.pagePos+pageIndex*sync.size, ptz.size%sync.size)];
    //    }
    
    ZYBleMutableRequest *req = [[ZYBleMutableRequest alloc]initWithCodeAndParamWith2BytesDataAndBuffer:address withCommand:ZYBleInteractUpdateWrite param:pageIndex buffer:subdata];
    @weakify(self)
    [self sendMutableRequest:req completionHandler:^(ZYBleDeviceRequestState state, id param) {
        //NSLog(@"---indext:%ld  count:%ld",pageIndex,count);
        @strongify(self);
        
        if (state == ZYBleDeviceRequestStateResponse ) {
            if ((pageIndex==count)) {
                //                if ((pageIndex==count) && (ptz.size%sync.size==0)) {
                //NSLog(@"address:%ld 写入二进制成功，完成！",address);
                BLOCK_EXEC(completed,YES);
                return ;
            }
            //NSLog(@"device:%ld 写入二进制成功，进入下一页！",address);
            NSInteger nextPageIdex = pageIndex+1;
            
            
            [self writeDataToFirmwareWithsendAddress:address pageIndex:nextPageIdex repeatCount:repeatCount completed:completed];
        }else if(state == ZYBleDeviceRequestStateFail || state == ZYBleDeviceRequestStateTimeout ){
            if (repeatCount > 2) {
                //NSLog(@"device:%ld 重复写入3次失败！升级失败!",address);
                //NSLog(@"pageIndex ===%d",pageIndex);
                
                BLOCK_EXEC(completed,NO);
                return;
            }
            if (req.parseFormat == ZYCodeParseUsb) {
                //如果是通过wifi/usb传输 写入失败首先尝试重新写入本帧
                //NSLog(@"device:%ld 写入失败！重新发送",address);
                [self writeDataToFirmwareWithsendAddress:address pageIndex:pageIndex repeatCount:repeatCount + 1 completed:completed];
                
            } else {
                //NSLog(@"device:%ld 写入失败！重新从头开始发送",address);
#pragma -mark 失败从当前页面开始
                //NSLog(@"pageIndex ===%d",pageIndex);
                //                NSInteger originPage = 0;
                [self writeDataToFirmwareWithsendAddress:address pageIndex:pageIndex repeatCount:repeatCount + 1 completed:completed];
                
            }
            
        }
    }];
}

#pragma mark - Oringal Function

/**
 发送指令
 
 @param address 地址
 @param command 指令
 @param successed 成功
 @param failure 失败
 */
-(void)sendOrderToFirmwareWithAddress:(NSUInteger)address command:(NSUInteger)command successed:(void(^)(id param))successed failure:(void(^)(NSError *error))failure{
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:address withCommand:command];
    [self sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse || state == ZYBleDeviceRequestStateTimeout) {
            BLOCK_EXEC(successed,param);
        } else if(state == ZYBleDeviceRequestStateFail ){
            //NSLog(@"sendOrderToFirmwareWithAddress error state:%ld param:%@",state,param);
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%s Error:%ld",__func__,state] code:state userInfo:nil];
            BLOCK_EXEC(failure,error)
        }
    }];
}

/**
 发送指令
 
 @param address 地址
 @param command 评论
 @param delayTime 延迟（无效）
 @param successed 成功
 @param failure 失败
 */
-(void)sendOrderToFirmwareWithAddress:(NSUInteger)address command:(NSUInteger)command delayTime:(NSInteger)delayTime successed:(void(^)(id param))successed failure:(void(^)(NSError *error))failure{
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParam:address withCommand:command];
    [self sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(successed,param);
        } else {
            //NSLog(@"sendOrderToFirmwareWithAddress error state:%ld param:%@",state,param);
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%s Error:%ld",__func__,state] code:state userInfo:nil];
            BLOCK_EXEC(failure,error)
        }
    }];
}

/**
 发送数据
 
 @param address 地址
 @param aCommand 指令
 @param aParam 参数
 @param successed 成功
 @param failure 失败
 */
-(void)sendOrderToFirmwareWithAddress:(NSInteger)address withCommand:(NSUInteger)aCommand param:(NSUInteger)aParam successed:(void(^)(id param))successed failure:(void(^)(NSError *error))failure{
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithCodeAndParamWith4BytesData:address withCommand:aCommand param:aParam];
    [self sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(successed,param);
        } else {
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%s Error:%ld",__func__,state] code:state userInfo:nil];
            BLOCK_EXEC(failure,error);
        }
    }];
}

/**
 发送可变指令请求
 
 @param request 请求
 @param handler 回调
 */
-(void) sendMutableRequest:(ZYBleMutableRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    [self configRequest:request];
#pragma -mark 针对云鹤2做特殊的处理
    if (request.parseFormat == ZYCodeParseStar) {
        request.parseFormat = ZYCodeParseBl;
    }
    request.delayMillisecond = 1500;
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:request completionHandler:handler];
    
}

-(void)waitingTimeOut{
    NSError *error = [NSError errorWithDomain:@"WaitingProgressTimeOut" code:kAPPGOTimeOut userInfo:nil];
    self.successBlock =  nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BLOCK_EXEC(self.failureBlock,error);
    //NSLog(@"Waiting 失败！！！！");
    
}

-(void)waitingNotifi:(NSNotification *)noti{
    NSString *progerss = [noti.userInfo objectForKey:ZYOtherSynDataProgress];
    if ([progerss isKindOfClass:[NSString class]]) {
        int pInt = [progerss intValue];
        
        switch (pInt) {
            case kAPPGOUpgradeFinish://写入完成
                BLOCK_EXEC(self.waitingForUpgradeCompletdBlock,pInt / 100.);
                
            case kAPPGOSkipSuccess://跳过成功
                self.failureBlock =  nil;
                [self.waitingTimer invalidate];
                _waitingTimer = nil;
                BLOCK_EXEC(self.successBlock);
                self.successBlock = nil;
                self.progressBlock = nil;
                return;
                break;
                
            case kAPPGOUpgradeFail://升级失败
            case kAPPGOSkipFail://跳过失败
                BLOCK_EXEC(self.failureBlock,[NSError errorWithDomain:@"APP GO跳过失败" code:pInt userInfo:nil]);
                self.failureBlock = nil;
                self.successBlock = nil;
                self.progressBlock = nil;
                [self.waitingTimer invalidate];
                _waitingTimer = nil;
                return;
                break;
                
            default:
                BLOCK_EXEC(_waitingForUpgradeCompletdBlock,pInt / 100.);
                
                break;
        }
        
        
    }
}

-(void)dealloc{
    pthread_mutex_destroy(&_lock);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //NSLog(@"%@升级对象被销毁了 ！！！！！！！！！！！！！！！！！！！！",self);
}


#pragma -mark md5

+ (NSString *)dataMD5String:(NSData *)data {
    unsigned char * md5Bytes = (unsigned char *)[[self dataMD5:data] bytes];
    return [self convertMd5Bytes2String:md5Bytes];
}
+ (NSData *)dataMD5:(NSData *)data {
    if(data == nil) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    for (int i = 0; i < data.length; i += CHUNK_SIZE_ZY) {
        NSData *subdata = nil;
        if (i <= ((long)data.length - CHUNK_SIZE_ZY)) {
            subdata = [data subdataWithRange:NSMakeRange(i, CHUNK_SIZE_ZY)];
            CC_MD5_Update(&md5, [subdata bytes], (CC_LONG)[subdata length]);
        } else {
            subdata = [data subdataWithRange:NSMakeRange(i, data.length - i)];
            CC_MD5_Update(&md5, [subdata bytes], (CC_LONG)[subdata length]);
        }
    }
    unsigned char digestResult[CC_MD5_DIGEST_LENGTH * sizeof(unsigned char)];
    CC_MD5_Final(digestResult, &md5);
    return [NSData dataWithBytes:(const void *)digestResult length:CC_MD5_DIGEST_LENGTH * sizeof(unsigned char)];
}

+ (NSString *)convertMd5Bytes2String:(unsigned char *)md5Bytes {
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            md5Bytes[0], md5Bytes[1], md5Bytes[2], md5Bytes[3],
            md5Bytes[4], md5Bytes[5], md5Bytes[6], md5Bytes[7],
            md5Bytes[8], md5Bytes[9], md5Bytes[10], md5Bytes[11],
            md5Bytes[12], md5Bytes[13], md5Bytes[14], md5Bytes[15]
            ];
}
@end
