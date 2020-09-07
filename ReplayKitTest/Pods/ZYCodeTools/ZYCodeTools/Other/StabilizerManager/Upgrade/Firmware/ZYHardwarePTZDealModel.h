//
//  ZYHardwarePTZDealModel.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYHardwarePTZDealModel : NSObject


/**
 分页
 */
@property(nonatomic, assign)NSUInteger pagePos ;



/**
 分页大小
 */
@property(nonatomic, assign)NSUInteger size ;


/**
 硬件版本号
 */
@property(nonatomic, assign)NSUInteger hwVersion ;


/**
 arch版本号
 */
@property(nonatomic, assign)NSUInteger archVersion ;


/**
 crc
 */
@property(nonatomic, assign)NSUInteger crc ;



/**
 通过firmware的升级二进制创建装了ZYHardwarePTZDealModel的集合

 @param ptzData firmware的升级二进制
 @return array
 */
+(NSMutableArray  <ZYHardwarePTZDealModel*>*)getPTZsWithPTZData:(NSData *)ptzData;
@end
