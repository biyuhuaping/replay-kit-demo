//
//  SPCParameterLanguageDes.h
//  ZYCamera
//
//  Created by liuxing on 2018/11/20.
//  Copyright © 2018 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPCParameterLanguageDes : NSObject

- (NSMutableArray*)languageFilter:(NSMutableArray *)res;

- (NSString *)languageDescripiton:(NSString *)content;

- (NSString *)getTableName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
