//
//  ZYProductSupportFunctionManager.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/8/30.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYProductSupportFunctionModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface ZYProductSupportModel : NSObject
@property (nonatomic, copy)   NSString              * _Nullable productId;//paraID
@property (nonatomic)         int         productIdNumber;//paraID

@property (nonatomic, copy)   NSString              * _Nullable jsonName;//json的名字

@property (nonatomic,strong, readonly)   ZYProductSupportFunctionModel   * _Nullable functionModel;//支持功能的模型对象

@end

@interface ZYProductSupportFunctionManager : NSObject

+( instancetype ) defaultManager;

/**
 获取对应产品的本地配置

 @param productIdNumber productIdNumber
 @return 配置对象
 */
-(ZYProductSupportFunctionModel *)modelWithProductId:(NSUInteger)productIdNumber;

@end

NS_ASSUME_NONNULL_END
