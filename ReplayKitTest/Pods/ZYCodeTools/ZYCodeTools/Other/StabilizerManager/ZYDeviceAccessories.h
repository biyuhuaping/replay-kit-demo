//
//  ZYDeviceAccessories.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/10/13.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYProductSupportFunctionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYDeviceAccessories : NSObject
/**
 产品型号
 */
@property(nonatomic, readwrite, copy) NSString* modelNumberString;

/**
 产品型号
 */
@property(nonatomic, assign) NSUInteger modelNumber;


/**
 获取支持的设备类型
 */
@property(nonatomic, strong)  ZYProductSupportFunctionModel *functionModel;
@end

NS_ASSUME_NONNULL_END
