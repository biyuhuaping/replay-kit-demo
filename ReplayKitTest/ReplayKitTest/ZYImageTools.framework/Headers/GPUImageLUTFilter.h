//
//  GPUImageLUTFilter.h
//  Pods
//
//  Created by Frost Zhang on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
#import "GPUImageTwoInputFilter.h"

@interface GPUImageLUTFilter : GPUImageTwoInputFilter
{
    GLint intensityUniform;
    GLint quadDimensionUniform;
}

// Opacity/intensity of lookup filter ranges from 0.0 to 1.0, with 1.0 as the normal setting
@property(readwrite, nonatomic) CGFloat intensity;
@property(readwrite, nonatomic) CGPoint quadDimension;

@end
