//
//  ZYDeviceStablizerTestTool.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYDeviceStablizerTestTool : NSObject

+(void)testFirmRequest;

+(void)testZYBlWiFiCode;

+(void)testZYBlCCSCode;

+(void)testZYBlOtherCode;

+(void)testZYUSBCode;

+(void)testZYBLWiFiHotspotCode;


#pragma 测试代码
+(void) testAllRequest;
+(void) testNewMotion;
+(void) testWriteRequest;



+ (void)testCraneM2Request;

#pragma 测试Crame_M代码
+(void)testCrameM;

+(void)testSynData;

+(void)doCustomFileCount;
+(void)doCustomFile;
@end
