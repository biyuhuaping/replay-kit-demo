//
//  ZYFaceTrack.m
//  VisionFaceTracking
//
//  Created by zz on 2019/10/21.
//  Copyright © 2019 zz. All rights reserved.
//

#import "ZYFaceTrack.h"
#import <Vision/Vision.h>

@interface ZYFaceTrack()
{
    void *user;
    VNSequenceRequestHandler *handler;
    ZYFaceTrackCallBack trackCallBack;
    VNDetectedObjectObservation *target;
    bool lost;
}

@end
@implementation ZYFaceTrack
- (instancetype)initWithCallBack:(ZYFaceTrackCallBack)callBack pUser:(void *)pUser
{
    self = [super init];
    if (!self) return nil;
    trackCallBack = callBack;
    user = pUser;
    handler = [[VNSequenceRequestHandler alloc] init];
    return self;
}

- (void)checkFaceArr:(CVPixelBufferRef)pixelBuffer completion:(void(^)(NSArray *))completion{
    VNDetectFaceRectanglesRequest *faceRequest = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error)
    {
        NSArray *observations = request.results;
        
        if (completion) {
            completion(observations);
        }
    }];
    
    [handler performRequests:@[faceRequest] onCVPixelBuffer:pixelBuffer error:nil];
}

- (void)checkFace:(CVPixelBufferRef)pixelBuffer
{
    VNDetectFaceRectanglesRequest *faceRequest = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error)
    {
        ZYFaceInfo *infos = NULL;
        if (request.results.count > 0)
            infos = calloc(1, sizeof(ZYFaceInfo)*request.results.count);
        
        for (int i = 0; i < request.results.count; ++i)
        {
            VNFaceObservation *tmp = request.results[i];
            strcpy(infos[i].faceID, [tmp.uuid.UUIDString UTF8String]);
            infos[i].rect = tmp.boundingBox;
            
            if (self->lost)
            {
                self->target = tmp;
                self->lost = false;
            }
        }
        
        if (self->trackCallBack && !self->lost)
            self->trackCallBack(infos, (int)request.results.count, self->user);
        
        if (request.results.count > 0)
            self->lost = false;
        
        if (infos) free(infos);
    }];
    
    [handler performRequests:@[faceRequest] onCVPixelBuffer:pixelBuffer error:nil];
}

bool mark;
- (void)startTrack:(ZYFaceInfo)info
{
    target = nil;
    mark = true;
    target = [VNDetectedObjectObservation observationWithBoundingBox:info.rect];
}

- (void)trackFace:(CVPixelBufferRef)pixelBuffer
{
//    mark = !mark;
//    if (mark) return;
 
    if (lost) [self checkFace:pixelBuffer];
    

    static bool err;
    VNTrackObjectRequest *trackRequest = [[VNTrackObjectRequest alloc] initWithDetectedObjectObservation:target completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error)
    {
        if (error)
        {
            err = true;
            return;
        }
        if (request.results.count < 1)
        {
            self->lost = true;
            mark = true;
            return;
        }
        ZYFaceInfo *infos = NULL;
        if (request.results.count > 0)
            infos = calloc(1, sizeof(ZYFaceInfo)*request.results.count);
        
        for (int i = 0; i < request.results.count; ++i)
        {
            VNDetectedObjectObservation *tmp = request.results[i];
            strcpy(infos[i].faceID, [tmp.uuid.UUIDString UTF8String]);
            infos[i].rect = tmp.boundingBox;
            
            if (tmp.confidence < 0.2)
            {
                self->lost = true;
                mark = true;
                if (infos) free(infos);
                if (self->trackCallBack)
                self->trackCallBack(infos, 0, self->user);
                return;
            }
            
            self->target = tmp;
        }
        if (self->trackCallBack)
            self->trackCallBack(infos, (unsigned int)request.results.count, self->user);
        
        if (infos) free(infos);
    }];
    trackRequest.trackingLevel = VNRequestTrackingLevelAccurate;
    if (err)
    {
        handler = [[VNSequenceRequestHandler alloc] init];
        err = false;
    }
    [handler performRequests:@[trackRequest] onCVPixelBuffer:pixelBuffer error:nil];
}

- (void)dealloc
{
    user = NULL;
    trackCallBack = NULL;
}
@end
