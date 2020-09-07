//
//  ZYDeviceStabilizer+OfflineMoveDelay.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer+OfflineMoveDelay.h"
#import <objc/runtime.h>

@implementation ZYDeviceStabilizer (OfflineMoveDelay)
static NSString *offlineMoveProgressArrayKey = @"offlineMoveProgressArrayKey";

-(void)setOfflineMoveProgressArray:(NSArray *)offlineMoveProgressArray{
    objc_setAssociatedObject(self, &offlineMoveProgressArrayKey, offlineMoveProgressArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)offlineMoveProgressArray{
    return objc_getAssociatedObject(self, &offlineMoveProgressArrayKey);
}



/**
 设置离线延时摄影
 
 @param status 设置的值
 @param complete 回掉
 */
-(void)setOffMovelineWithStatus:(ZYBlOtherCmdMoveLineStatueType)status Cmd:(void(^)(BOOL success, ZYBlOtherCmdMoveLineStatueData *info))complete{
    if (![self supportOffLineMoveDelay]) {
        if (complete) {
            complete(NO,nil);
        }
        return;
    }
    
    ZYBlOtherCmdMoveLineStatueData* requestInfo = [[ZYBlOtherCmdMoveLineStatueData alloc] init];
    requestInfo.moveLineStatus = status;
    
    [requestInfo createRawData];
    ZYBleMutableRequest* sendMoveLine = [[ZYBleMutableRequest alloc] initWithZYControlData:requestInfo];
    [self configRequest:sendMoveLine];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    [client sendMutableRequest:sendMoveLine completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCmdMoveLineStatueData *innaData = param;
            if (complete) {
                complete(YES,innaData);
            }
        } else {
            if (complete) {
                complete(NO,nil);
            }
        }
    }];
}

/**
 
 @param complete 回掉
 */
-(void)readOffMovelineCompleteHandle:(void(^)(BOOL success, ZYBlOtherCmdMoveLineStatueData *info))complete{
    ZYBlOtherCmdMoveLineStatueData* requestInfo = [[ZYBlOtherCmdMoveLineStatueData alloc] init];
    requestInfo.moveLineStatus = ZYBlOtherCmdMoveLineStatueTypeReadStatue;
    
    [requestInfo createRawData];
    ZYBleMutableRequest* sendMoveLine = [[ZYBleMutableRequest alloc] initWithZYControlData:requestInfo];
    [self configRequest:sendMoveLine];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    
    [client sendMutableRequest:sendMoveLine completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlOtherCmdMoveLineStatueData *innaData = param;
            if (complete) {
                complete(YES,innaData);
            }
        } else {
            if (complete) {
                complete(NO,nil);
            }
        }
    }];
}
@end
