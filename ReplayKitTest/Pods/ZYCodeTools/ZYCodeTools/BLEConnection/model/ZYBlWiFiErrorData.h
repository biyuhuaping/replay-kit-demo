//
//  ZYBlHandleData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiErrorData : ZYBlData

/**
 <#Description#>错误码 对应查询错误状态中的ERR_REASON
 */
@property (nonatomic, readonly) NSUInteger errCode;


@end
