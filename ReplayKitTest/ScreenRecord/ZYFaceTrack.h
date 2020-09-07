//
//  ZYFaceTrack.h
//  VisionFaceTracking
//
//  Created by zz on 2019/10/21.
//  Copyright © 2019 zz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// faceID:人脸ID
// rect:人脸区域(坐标原点在左下角 范围为0.0-1.0)
typedef struct ZYFaceInfo
{
    char faceID[128];
    CGRect rect;
} ZYFaceInfo;


/**
 ZYFaceTrackCallBack:人脸检测及跟踪回调
 infos:人脸信息数组
 count:人脸信息数组个数
 pUser:使用者
 */
typedef void(*ZYFaceTrackCallBack)(ZYFaceInfo *infos, unsigned int count, void *pUser);
@interface ZYFaceTrack : NSObject
// 注册人脸检测回调及使用者
- (instancetype)initWithCallBack:(ZYFaceTrackCallBack)callBack pUser:(void *)pUser;

// 开始检测人脸 人脸信息会由ZYFaceTrackCallBack返回
- (void)checkFace:(CVPixelBufferRef)pixelBuffer;
- (void)checkFaceArr:(CVPixelBufferRef)pixelBuffer completion:(void(^)(NSArray *))completion;

// 开启跟踪人脸 需要传入ZYFaceInfo中的rect区域
- (void)startTrack:(ZYFaceInfo)info;

// 开启跟踪功能后 需要不断传入视频流数据(如果出现跟踪丢失 sdk内部无法找回目标 会随机找到人脸进行跟踪, ps:可以重新调用startTrack传入跟踪区域后开启新目标跟踪)
- (void)trackFace:(CVPixelBufferRef)pixelBuffer;
@end

NS_ASSUME_NONNULL_END
