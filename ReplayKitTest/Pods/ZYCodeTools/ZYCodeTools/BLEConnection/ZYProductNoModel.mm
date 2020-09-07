//
//  ZYProductNoModel.mm
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYProductNoModel.h"
#import "StarMessage.h"

@implementation ZYProductNoModel

-(void)update:(NSUInteger)value1 value2:(NSUInteger)value2 value3:(NSUInteger)value3 value4:(NSUInteger)value4
{
    zy::productSerialNo serialNo;
    serialNo.data[0] = value1;
    serialNo.data[1] = value2;
    serialNo.data[2] = value3;
    serialNo.data[3] = value4;
    
    _runningNo = serialNo.serial.runningNo;
    _customCode = serialNo.serial.customCode;
    _model = serialNo.serial.model;
    _type = serialNo.serial.type;
    _batchNo = serialNo.serial.batchNo;
    _date = serialNo.serial.date;
    
    _content = [NSString stringWithFormat:@"%03x%03x%02x%01x%02x%04x", (int)_date, (int)_batchNo, (int)_type, (int)_model, (int)_customCode, (int)_runningNo];
}

-(void)updateContent:(NSString *)content{
    _content = content;
}
@end
