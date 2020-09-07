//
//  ZYBlWiFiHotspotSetGetChannel.h
//  ZYCamera
//
//  Created by zz on 2019/11/20.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlWiFiHotspotSetGetChannel : ZYBlData

// opt: 0代表获取 1代表设置
@property (nonatomic, assign) uint8_t opt;

// status: 0代表未知 1代表为手动信道 2代表自动信道模式
@property (nonatomic, assign) uint8_t channel_status;

// chn_info: chn_info表示信道，为字符串，信道范围是0～255 当设置自动自动信道是chn_info为空
@property (nonatomic, copy) NSString *channel;

@end

NS_ASSUME_NONNULL_END
