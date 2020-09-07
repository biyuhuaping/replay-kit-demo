//
//  ZYBaseDevice.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/5/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYBaseDevice : NSObject
/**
 产品型号
 */
@property(nonatomic, readwrite, copy) NSString* modelNumberString;
@end

NS_ASSUME_NONNULL_END
