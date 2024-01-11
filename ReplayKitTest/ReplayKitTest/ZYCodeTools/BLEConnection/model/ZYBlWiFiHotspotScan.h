//
//  ZYBlWiFiHotspotScan.h
//  ZYCamera
//
//  Created by zz on 2019/11/20.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlWiFiHotspotScan : ZYBlData

//  opt: 0代表扫描 1代表获取
@property (nonatomic, assign) uint8_t opt;

// 返回格式为"信道状态，信道，信道强度，ssid名称"
// 信道状态：0为空闲，1为繁忙，2表示未知
@property (nonatomic, copy) NSArray<NSString *> *array;

@end

NS_ASSUME_NONNULL_END
