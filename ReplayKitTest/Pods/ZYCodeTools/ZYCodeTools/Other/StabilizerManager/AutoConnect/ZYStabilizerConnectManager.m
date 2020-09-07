//
//  ZYStabilizerConnectManager.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/14.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//
#define kConnectedDevicesKey @"New_CONNECTED_DEVICES_ZYStabilizerConnectManager"
#define kOldConnectedDevicesKey @"CONNECTED_DEVICES"


#import "ZYStabilizerConnectManager.h"


@interface ZYStabilizerConnectManager()

@property(nonatomic, strong)NSMutableDictionary *dataSources;

@end


@implementation ZYStabilizerConnectManager

static  ZYStabilizerConnectManager  *shareSingleton = nil;

+( instancetype ) defaultManager{
    static  dispatch_once_t  onceToken;
    dispatch_once ( &onceToken, ^ {

        shareSingleton  =  [[super allocWithZone:NULL] init] ;

    } );
    return shareSingleton;
}


+(id) allocWithZone:(struct _NSZone *)zone {

    return [self defaultManager] ;

}

-(id) copyWithZone:(struct _NSZone *)zone {

    return [ZYStabilizerConnectManager defaultManager]  ;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSources = [self getLocalDataSource];
        if (_dataSources == nil ||![_dataSources isKindOfClass:[NSDictionary class]]) {
            _dataSources = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(NSMutableDictionary*)getLocalDataSource{
   NSDictionary *dic = [[NSUserDefaults  standardUserDefaults] objectForKey:kConnectedDevicesKey];

    if ((!dic) ||(![dic isKindOfClass:[NSDictionary class]])) {
        dic = [NSMutableDictionary new];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kConnectedDevicesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [[NSMutableDictionary alloc] initWithDictionary:dic];
}

-(void)saveLocalDataSourceWithDic:(NSMutableDictionary *)dic{
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kConnectedDevicesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(ZYConectModel *)getConnectModelFromName:(NSString *)name{
    if ([self.dataSources respondsToSelector:@selector(objectForKey:)]) {
        NSMutableDictionary *modDic = [self.dataSources objectForKey:name];
        if (modDic) {
            return [ZYConectModel connectModelWithDictionory:modDic];
        }
    } else {
        self.dataSources = [[NSMutableDictionary alloc] init];
    }
    
    return nil;
}

-(void)saveLoacalSourceWithModel:(ZYConectModel*)model{
    NSMutableDictionary *dic = [model toDictionary];
    [self.dataSources setValue:dic forKey:model.orignalName];
    [self saveLocalDataSourceWithDic:self.dataSources];
}

+(NSString *)getDisplayNameFromOrignalName:(NSString *)orignalName{
    if (orignalName.length == 0 || orignalName == nil) {
        return @"Unknow";
    }
    ZYStabilizerConnectManager *manager  =  [ZYStabilizerConnectManager defaultManager];
    ZYConectModel *mod  = [manager getConnectModelFromName:orignalName];
    if (!mod) {
        mod = [ZYConectModel connectModelWithOrignalName:orignalName];
        [manager saveLoacalSourceWithModel:mod];
    }
    return mod.displayName;
}

+(BOOL)getIsNeedAutoConnectFromOrignalName:(NSString *)orignalName{
    if (orignalName.length == 0) {
        return NO;
    }
    ZYStabilizerConnectManager *manager  =  [ZYStabilizerConnectManager defaultManager];
    ZYConectModel *mod  = [manager getConnectModelFromName:orignalName];
    if (!mod) {
        mod = [ZYConectModel connectModelWithOrignalName:orignalName];
        [manager saveLoacalSourceWithModel:mod];
    }
    return [mod.isNeedAutoConnect isEqualToString:@"Ture"]?YES:NO;
}

+(void)resetDisplayNameFromOrignalName:(NSString *)orignalName changeName:(NSString *)changeName{
    if (orignalName.length == 0 || orignalName ==nil  ) {
        return  ;
    }
    ZYStabilizerConnectManager *manager  =  [ZYStabilizerConnectManager defaultManager];
    ZYConectModel *mod  = [manager getConnectModelFromName:orignalName];
    if (!mod) {
        mod = [ZYConectModel connectModelWithOrignalName:orignalName];
    }
    mod.displayName = changeName;
    [manager saveLoacalSourceWithModel:mod];

}

+(void)resetIsNeedAutoConnectFromOrignalName:(NSString *)orignalName  isNeedAutoConnect:(BOOL)isNeedAutoConnect{
    if (orignalName == nil || orignalName.length ==0) {
        return;
    }
    ZYStabilizerConnectManager *manager  =  [ZYStabilizerConnectManager defaultManager];
    ZYConectModel *mod  = [manager getConnectModelFromName:orignalName];
    if (!mod) {
        mod = [ZYConectModel connectModelWithOrignalName:orignalName];
    }
    mod.isNeedAutoConnect = isNeedAutoConnect?@"Ture":@"False";
    [manager saveLoacalSourceWithModel:mod];

}
+(NSInteger)getSaveBlueToothCount{
    ZYStabilizerConnectManager *mg = [ZYStabilizerConnectManager defaultManager];
    return mg.dataSources.count;
}
@end
