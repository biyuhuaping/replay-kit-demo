//
//  ZYLUTHelper.h
//  ZYImageTools
//
//  Created by Frost Zhang on 2017/1/23.
//  Copyright © 2017年 Frost Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT UIImage* UIImageFromLUTSource(NSURL *url, int* row, int* column);

FOUNDATION_EXPORT NSData* CubeDataFromLUTSource(NSURL *url);

FOUNDATION_EXPORT UIImage* convertBitmapRGBA8ToUIImage(unsigned char *buffer, int width, int height);
