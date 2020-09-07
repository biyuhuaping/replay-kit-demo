//
//  ZYBlWiFiHotspotGetCHNList.h
//  ZYCamera
//
//  Created by zz on 2019/11/19.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlWiFiHotspotGetCHNList : ZYBlData

// 返回的支持的信道信息数组
@property (nonatomic, readonly) NSArray<NSString *> *array;

@end

NS_ASSUME_NONNULL_END
