//
//  ZYUsbControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYControlCoder.h"

@class ZYUsbData;

@interface ZYUsbControlCoder : ZYControlCoder

+(NSString*) descriptionForUsbData:(ZYUsbData*)data;

+(BOOL) canParse:(NSData*)data;

@end
