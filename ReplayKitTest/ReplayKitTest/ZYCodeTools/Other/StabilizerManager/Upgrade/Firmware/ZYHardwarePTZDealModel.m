//
//  ZYHardwarePTZDealModel.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYHardwarePTZDealModel.h"

@implementation ZYHardwarePTZDealModel

/**
 通过firmware的升级二进制创建装了ZYHardwarePTZDealModel的集合

 @param ptzData firmware的升级二进制
 @return array
 */
+(NSMutableArray  <ZYHardwarePTZDealModel*>*)getPTZsWithPTZData:(NSData *)ptzData{
    ZYHardwarePTZDealModel *m = [ZYHardwarePTZDealModel new];
    return [m ptzsWithPTZData:ptzData];
}

-(NSMutableArray  <ZYHardwarePTZDealModel*>*)ptzsWithPTZData:(NSData *)ptzData{
    NSMutableArray *mPtzFileArray = [NSMutableArray new];
        int count;
        int sizePos = 16;
        ZYHardwarePTZDealModel *ptzFileData;
        count = [self charWithByteData:ptzData atIndex:8];
        for (int i=0; i<count; i++) {//循环创建ptzfile对象，并给予结构图赋值
            ptzFileData = [[ZYHardwarePTZDealModel alloc] init];
            ptzFileData.pagePos = sizePos + 8;
            ptzFileData.size = [self intWithByteData:ptzData atIndex:sizePos] - 10;
            ptzFileData.hwVersion = [self charWithByteData:ptzData atIndex:sizePos + 4];
            ptzFileData.archVersion = [self charWithByteData:ptzData atIndex:12];
            ptzFileData.crc = [self charWithByteData:ptzData atIndex:sizePos + ptzFileData.size + 8];
            [mPtzFileArray addObject:ptzFileData];
            sizePos += (ptzFileData.size + 10);
        }
    return mPtzFileArray;
}

-(int)charWithByteData:(NSData*)bytesData atIndex:(NSUInteger)start{//整理数据返回长度为2字节
    NSUInteger len = [bytesData length];//获取长度
    Byte *bytes = (Byte*)malloc(len);//根据长度创建字节
    memcpy(bytes, [bytesData bytes], len);//拷贝字节
    return (0xff & bytes[start]) |
    (0xff00 & (bytes[start + 1] << 8));//拼接高低位,长度为2个字节
}

-(int)intWithByteData:(NSData*)bytesData atIndex:(NSUInteger)start{//整理数据返回长度为4字节
    NSUInteger len = [bytesData length];
    Byte *bytes = (Byte*)malloc(len);
    memcpy(bytes, [bytesData bytes], len);
    return (0xff & bytes[start]) |
    (0xff00 & (bytes[start + 1] << 8)) |
    (0xff0000 & (bytes[start + 2] << 16)) |
    (0xff000000 & (bytes[start + 3] << 24));//长度位4个字节
}

@end
