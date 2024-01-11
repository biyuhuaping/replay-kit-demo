//
//  ZYHardwareUpgradeManager.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/9.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//


//老的数据库地址需要删除
#define kHardwareUpgrade @"Hardware_Upgrade"
//老的数据库地址需要删除
#define kNew_HardwareUpgrade @"kNew_HardwareUpgrade"

#import "ZYHardwareUpgradeManager.h"
//#import "ZYNetwrokManager.h"
#import "ZYHardwareUpgradeModel.h"
#import "ZYBleDeviceClient.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZYDeviceManager.h"
//#import "OSSUtil.h"
#import "ZYModuleUpgrade.h"

#import "SSZipArchive.h"


//#import "NSString+StringLength.h"
#import "ZYStabilizerTools.h"

#import "ZYProductSupportFunctionManager.h"

#import "ZYUpgradeServerTool.h"


NSString* const HardwareUpgrade_StatusDidChange              = @"HardwareUpgrade_StatusDidChange";

NSString* const HardwareUpgrade_IsNeedToUpgrade              = @"HardwareUpgrade_IsNeedToUpgrade";


@interface ZYHardwareUpgradeManager ()




/**
 模块升级的对象模型
 */
@property(nonatomic, strong)ZYModuleUpgrade *moduleUpgrade;


/**
 进度回调Block
 */
@property(nonatomic, copy)void (^progressBlock)(float progress,NSInteger count, NSInteger currentIndex,ZYUpgradeStatus progressType) ;

/**
 需要升级的数组
 */
@property(nonatomic, strong)NSMutableArray *needDownloadArray;



@property(nonatomic, copy)NSString *deviceName;


@property(nonatomic, assign)NSInteger deviceCode ;
@end

@implementation ZYHardwareUpgradeManager


#pragma mark - Public function

/**
 创建硬件升级对象

 @param softwareVersion 软件版本号
 @param modelNumberString 设备类型
 @return 对象
 */
+(instancetype)hardwareUpgradeManagerWithSoftwareVersion:(NSString *)softwareVersion  modelNumberString:(NSString *)modelNumberString{
    ZYHardwareUpgradeManager *hardware = [[ZYHardwareUpgradeManager alloc] init];
    return hardware;
}

/**
 清除内存数据
 */
-(void)clearData{
    
    if (_upgradeArray) {
        [_upgradeArray removeAllObjects];
    }
    _upgradeArray = nil;
    _jsonNewModel = nil;
    _isUpgradeing = NO;
    _moduleUpgradeInfos = nil;
}

#pragma mark - Privatey function

/**
 初始化

 @return
 */
-(instancetype)init{
    if (self = [super init]) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *oldPath =[cacheDirectory stringByAppendingPathComponent:kHardwareUpgrade];
        if ([fileManager fileExistsAtPath:oldPath]) {
            [fileManager removeItemAtPath:oldPath error:nil];
        }
        oldPath =[cacheDirectory stringByAppendingPathComponent:kNew_HardwareUpgrade];
        if ([fileManager fileExistsAtPath:oldPath]) {
            [fileManager removeItemAtPath:oldPath error:nil];
        }
        _upgradeArray = [NSMutableArray new];
    }
    return self;
}



/**
 设置升级状态

 @param upgardeStatus 状态
 */
-(void)setUpgardeStatus:(ZYUpgradeStatus)upgardeStatus{
    _upgardeStatus = upgardeStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:HardwareUpgrade_StatusDidChange object:nil userInfo:nil];
}

/**
 检查是否是升级设备

 @return
 */
+(BOOL)isCanUpgradeDevice{
    NSString *modelNumberString = [ZYDeviceManager defaultManager].stablizerDevice.modelNumberString ;
   return  [self p_canUpgradeDeviceWithString:modelNumberString];

}

+(BOOL)p_canUpgradeDeviceCode:(NSUInteger)deviceCode{
    NSString *modelString = [ZYBleDeviceDataModel translateToModelNumber:deviceCode];
     if ([@[modelNumberPround,
              modelNumberEvolution,
              modelNumberSmooth,
              modelNumberSmooth2,
              modelNumberSmoothQ,
              modelNumberRider,
              modelNumberRiderM,
              modelNumberCrane,
              modelNumberCraneM,
              modelNumberCraneS,
              modelNumberCraneL,
              modelNumberCraneH,
              modelNumberCranePlus,
              modelNumberShining,
              modelNumberUnknown]
            containsObject:modelString]) {
           return NO;
     }
     else{
         ZYProductSupportFunctionModel *model =[[ZYProductSupportFunctionManager defaultManager] modelWithProductId:deviceCode];
         return model.update != UpdateTypeNoSupport;
     }

}

+(BOOL)p_canUpgradeDeviceWithString:(NSString *)modelString{

    if ([@[modelNumberPround,
           modelNumberEvolution,
           modelNumberSmooth,
           modelNumberSmooth2,
           modelNumberSmoothQ,
           modelNumberRider,
           modelNumberRiderM,
           modelNumberCrane,
           modelNumberCraneM,
           modelNumberCraneS,
           modelNumberCraneL,
           modelNumberCraneH,
           modelNumberCranePlus,
           modelNumberShining,
           modelNumberUnknown]
         containsObject:modelString]) {
        return NO;
    }
    else{
        return [ZYDeviceManager defaultManager].stablizerDevice.functionModel.update != UpdateTypeNoSupport;
    }
}

#pragma mark - Upgrade

/**
 循环模块升级

 @param Models 数据
 @param total 总数
 @param callback 回调
 @param progress 进度
 */
-(void)p_loopModuleUpgradeWithModels:(NSArray *)module index:(NSInteger)index Callback:(void (^)(BOOL isSuccess,NSInteger successCount))callback progress:(void(^)(float progress,NSInteger count, NSInteger currentIndex,ZYUpgradeStatus prgressType))progress{
    int sourceCount = [module count];
    if (sourceCount == 0) {
        BLOCK_EXEC(callback,NO,sourceCount);
        return;
    }else if (sourceCount <= index) {
       BLOCK_EXEC(callback,YES,sourceCount );
        return;

   }
    [self p_confignilFw];
    ZYUpgradableInfoModel *mod = [module objectAtIndex:index];
    self.moduleUpgrade = [ZYModuleUpgrade upgradeWithMod:mod];
    self.moduleUpgrade.isNeedCheckWaiting = self.jsonNewModel;
    self.moduleUpgrade.sendDelegate = self.sendDelegate;

    if (self.moduleUpgrade.channel == ZYUpgradableChannelBle) {
        BOOL bleIsReady =  [[ZYDeviceManager defaultManager]  changToBlConnect];
        if (!bleIsReady) {
            NSLog(@"切换到蓝牙时 不可用！！！！！！");
            self.isUpgradeing = NO;
            BLOCK_EXEC(callback,NO,index);
            return;
        }
        [ [ZYBleDeviceClient defaultClient ]mindBluetoothNotify];
    }
    @weakify(self)
    self.upgardeStatus = ZYUpgradeStatusSendingData;

    __block BOOL modDependency = mod.dependency;
   
    if (sourceCount - 1 == index) {
#pragma -mark 最后一台设备一定有依赖关系
        modDependency = YES;
        
    }

#pragma -mark 不需要升级的需要跳过
    if (mod.needUpdate == NO) {
        [self.moduleUpgrade appGoJumpWithHandler:^{
                   @strongify(self);
                   [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];

               } failure:^(NSError *error) {
                   @strongify(self);
                   if (error.code == kAPPGOSkipFail) {
                        BLOCK_EXEC(callback,NO,sourceCount);
                   }
                   else{
                       [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];
                   }
               }];
        return;
    }
    
    [self.moduleUpgrade beginUpgradeProgress:^(float progressValue) {
        @strongify(self)

        dispatch_async(dispatch_get_main_queue(), ^{
             @strongify(self)
          if (self.upgardeStatus != ZYUpgradeStatusSendingData) {
                 self.upgardeStatus = ZYUpgradeStatusSendingData;
             }
         });
        BLOCK_EXEC(progress,progressValue,sourceCount,index,ZYUpgradeStatusSendingData);
    } Successed:^{
        @strongify(self)

        NSLog(@"ZYModuleUpgrade next Device !");
        [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];

    } failure:^(NSError *merror) {
        @strongify(self)
        if (modDependency) {
           BLOCK_EXEC(callback,NO,sourceCount);
           return ;
        }
        
#pragma -mark 已经发送过appgo，直接下一步
        if (merror.code == kAPPGOAlreadySendCode || merror.code == kAPPGOTimeOut || merror.code == kAPPGOUpgradeFail) {
            [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];
            return;
        }
        
        [self.moduleUpgrade appGoJumpWithHandler:^{
            @strongify(self);
            [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];

        } failure:^(NSError *error) {
            @strongify(self);
            if (error.code == kAPPGOSkipFail) {
                BLOCK_EXEC(callback,NO,sourceCount);
            }
            else{
                [self p_loopModuleUpgradeWithModels:module index:index + 1  Callback:callback progress:progress];
            }
        }];
        NSLog(@"ZYModuleUpgrade failure");
    } waitingForUpgradeCompletd:^(float progressValue) {
        @strongify(self)
        if (self.upgardeStatus != ZYUpgradeStatusUpgardeing) {
            self.upgardeStatus = ZYUpgradeStatusUpgardeing;

        }
        BLOCK_EXEC(progress,progressValue,[module count],index,ZYUpgradeStatusUpgardeing);

    }];
}

-(void)configUpgradeData:(NSUInteger)deviceCode softVersion:(NSString *)softVersion{
    [ZYUpgradeServerTool upgratedataURLByModules:self.moduleUpgradeInfos ByRefId:deviceCode softVersion:softVersion];
}

-(void)p_confignilFw{
    [self.moduleUpgrade clearData];
    self.moduleUpgrade.sendDelegate = nil;
    self.moduleUpgrade = nil;
}
/**
 开始升级

 @param callback 回调
 @param progress 进度
 */
-(void)beginUpgrade:(void (^)(BOOL success))callback progress:(void(^)(float progress,NSInteger count, NSInteger currentIndex,ZYUpgradeStatus prgressType))progress{
    [self p_confignilFw];
    if ([self.moduleUpgradeInfos count]) {
        self.progressBlock =  progress;
        self.upgardeStatus = ZYUpgradeStatusSendingData;
        self.isUpgradeing = YES;

        BLOCK_EXEC(self.progressBlock,0.0,[self.moduleUpgradeInfos count],1,ZYUpgradeStatusSendingData);
        @weakify(self)
        [self p_loopModuleUpgradeWithModels:self.moduleUpgradeInfos index:0 Callback:^(BOOL isSuccess,NSInteger successCount) {
            @strongify(self)
            self.upgardeStatus = isSuccess ? ZYUpgradeStatusUpgardeSuccessed : ZYUpgradeStatusUpagrdeFailure;
            self.isUpgradeing = NO;
            BLOCK_EXEC(callback,isSuccess);
            [self p_confignilFw];
        } progress:^(float progress, NSInteger count, NSInteger currentIndex, ZYUpgradeStatus prgressType) {
            @strongify(self)
            BLOCK_EXEC(self.progressBlock,progress,count,currentIndex + 1,prgressType);
        }];
    }else{
        self.progressBlock = nil;
        self.isUpgradeing = NO;
        self.upgardeStatus = ZYUpgradeStatusUpagrdeFailure;
        BLOCK_EXEC(callback,NO);

    }

}

-(void)dealloc{
#ifdef DEBUG

    NSLog(@"dealloc  dealloc %@",[self class]);
#endif

}

@end
