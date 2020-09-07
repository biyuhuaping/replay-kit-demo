//
//  ZYBlCCSGetConfigData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlOtherCheckMD5Data : ZYBlData

/**
 MD5码
 */
@property (nonatomic, readwrite) NSString* md5;

/**
 状态标志
 */
@property (nonatomic, readonly) NSUInteger flag;

@end
