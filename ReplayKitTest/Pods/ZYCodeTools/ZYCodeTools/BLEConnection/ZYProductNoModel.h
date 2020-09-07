//
//  ZYProductNoModel.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYProductNoModel : NSObject

/**
 流水号
 */
@property(nonatomic, readonly) NSUInteger runningNo;

/**
 定制码
 */
@property(nonatomic, readonly) NSUInteger  customCode;

/**
 型号
 */
@property(nonatomic, readonly) NSUInteger  model;

/**
 类别
 */
@property(nonatomic, readonly) NSUInteger  type;

/**
 批次号
 */
@property(nonatomic, readonly) NSUInteger  batchNo;

/**
 年月
 */
@property(nonatomic, readonly) NSUInteger  date;

/**
 文本内容
 */
@property(nonatomic, readonly, strong) NSString*  content;

-(void)update:(NSUInteger)value1 value2:(NSUInteger)value2 value3:(NSUInteger)value3 value4:(NSUInteger)value4;

/**
 ccs的设备需要调用这个方法更新

 @param content 内容
 */
-(void)updateContent:(NSString *)content;

@end
