//
//  ZYFirmwareUpgradeModel_WiFi.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2018/7/16.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYFirmwareUpgradeModel_WiFi : NSObject

/**
 文件数据
 */
@property(nonatomic, strong)NSData *data;


/**
 是否传输成功
 */
@property(nonatomic, assign)BOOL isSuccess ;


/**
 下标
 */
@property(nonatomic, assign)NSInteger index ;


/**
 地址
 */
@property(nonatomic, assign)NSInteger address ;


/**
 重发次数
 */
@property(nonatomic, assign)int repeatCount ;

@end
