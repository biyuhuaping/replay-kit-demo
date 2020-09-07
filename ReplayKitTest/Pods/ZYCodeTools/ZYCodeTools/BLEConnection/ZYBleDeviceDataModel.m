//
//  ZYBleDeviceDataModel.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceDataModel.h"

NSString* const modelNumberUnknown      = @"Undefined";
NSString* const modelNumberPround       = @"Pround";
NSString* const modelNumberEvolution    = @"Evolution";
NSString* const modelNumberEvolution2   = @"EVO2";
NSString* const modelNumberEvolution3   = @"EV103";

NSString* const modelNumberSmooth       = @"Smooth";
NSString* const modelNumberSmooth2      = @"Smooth2";
NSString* const modelNumberSmooth3      = @"Smooth3";
NSString* const modelNumberSmoothQ      = @"SmoothQ";
NSString* const modelNumberSmoothQ2     = @"SmoothQ2";
NSString* const modelNumberSmoothX      = @"SmoothX";//sm108
NSString* const modelNumberSmoothXS     = @"SmoothXS";//sm110
NSString* const modelNumberLiveStabilizer   = @"SM111";//sm111直播云台

NSString* const modelNumberSmoothP1     = @"P1";
NSString* const modelNumberSmoothC11    = @"C11";

NSString* const modelNumberSmooth4      = @"Smooth4";

NSString* const modelNumberRider        = @"Rider";
NSString* const modelNumberRiderM       = @"Rider-M";
NSString* const modelNumberCrane        = @"Crane";
NSString* const modelNumberCraneM       = @"Crane-M";
NSString* const modelNumberCraneS       = @"Crane-S";
NSString* const modelNumberCraneL       = @"Crane-L";

NSString* const modelNumberCraneH       = @"Crane-H";

NSString* const modelNumberCraneTwo     = @"Crane 2";
NSString* const modelNumberCraneTwoS    = @"Crane 2S";
NSString* const modelNumberCranePlus    = @"Crane Plus";

//NSString* const modelNumberCrane3       = @"Crane 3";
NSString* const modelNumberCrane3S      = @"Crane 3S";
NSString* const modelNumberCrane3Lab    = @"Crane 3 Lab";
NSString* const modelNumberWeebillLab   = @"Weebill Lab";
NSString* const modelNumberWeebillS     = @"Weebill-S";
NSString* const modelNumberWeebill      = @"Weebill";
NSString* const modelNumberImageTransBox = @"TransMount Image Transmission Transmitter";
NSString* const modelNumberImageTransBoxTwo = @"TransMount Image Transmission Transmitter";
NSString* const modelNumberImageTransBoxRecive = @"TransMount Image Transmission Reciver";

NSString* const modelNumberCraneM2      = @"Crane-M2";

NSString* const modelNumberShining      = @"Shining";

NSString* const cameraManufacturerNone          = @"close";
NSString* const cameraManufacturerPreserve      = @"preserve";
NSString* const cameraManufacturerSony          = @"sony";
NSString* const cameraManufacturerPanasonic     = @"panasonic";

NSString* const modelNumberCraneZWB     = @"ZW-B";
NSString* const modelNumberCraneEngineering  = @"CR";


#define CheckBit(val, pos) ((val&(0x00000001<<pos))==(0x00000001<<pos))
#define UInt2Float(val, factor) (val*factor)
#define Int2Float(val, factor) ((*((short*)(&val)))*factor)
#define UInt2Int(val) (*((short*)(&val)))

@interface ZYBleDeviceDataModel()
{
    NSUInteger _productionNoField1;
    NSUInteger _productionNoField2;
    NSUInteger _productionNoField3;
    NSUInteger _productionNoField4;
}
@end

@implementation ZYBleDeviceDataModel

-(instancetype) init
{
    if ([super init]) {
        _motorStatus = [NSArray arrayWithObjects:[[ZYBleDeviceMotorModel alloc] init], [[ZYBleDeviceMotorModel alloc] init], [[ZYBleDeviceMotorModel alloc] init], nil];
        _productionNo = [[ZYProductNoModel alloc] init];
        _productionNoField1 = 0;
        _productionNoField2 = 0;
        _productionNoField3 = 0;
        _productionNoField4 = 0;
    }
    return self;
}

#pragma 更新模型及其辅助函数

-(void) updateModel:(NSUInteger)aCode param:(NSUInteger)aParam
{
    switch (aCode) {
        case ZYBleInteractCodeDeviceCategory_R:
        {
            _modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:aParam];
            _modelNumber = aParam;
            
            if ([ZYBleDeviceDataModel likeSmoothXWithString:_modelNumberString]) {
                _newSendMessagePakge = YES;
            }
            else{
                _newSendMessagePakge = NO;
            }
        }
            break;
            
        case ZYBleInteractCodeVersion_R:
        {
            _softwareVersion = aParam;
        }
            break;
            
        case ZYBleInteractCodeSystemStatus_R:
        {
            [self updateSystemStatus:aParam];
        }
            break;
            
        case ZYBleInteractCodeBatteryVoltage_R:
        {
            _fBatteryVoltage = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodePower_R:
        {
            _powerStatus = (ZYBleInteractMotorPower)aParam;
        }
            break;
            
        case ZYBleInteractCodeDebug_R:
        {
            _debugMode = (ZYBleInteractDeviceDebugMode)aParam;
        }
            break;
            
        case ZYBleInteractCodeIMUControlRegister_R:
        {
            //_IMUAX = (ZYBleInteractDeviceDebugMode)aParam;
        }
            break;
            
        case ZYBleInteractCodeIMUStateRegister_R:
        {
            //_IMUAX = (ZYBleInteractDeviceDebugMode)aParam;
        }
            break;
            
        case ZYBleInteractCodeGyroStandardDeviation_R:
        {
            _gyroStandardDeviation = UInt2Int(aParam);
        }
            break;
            
        case ZYBleInteractCodeIMUAX_R:
        {
            _IMUAX = UInt2Int(aParam);
        }
            break;
            
        case ZYBleInteractCodeIMUAY_R:
        {
            _IMUAY = UInt2Int(aParam);
        }
            break;
            
        case ZYBleInteractCodeIMUAZ_R:
        {
            _IMUAZ = UInt2Int(aParam);
        }
            break;
            
        case ZYBleInteractCodeIMUGX_R:
        {
            _IMUGX = aParam;
        }
            break;
            
        case ZYBleInteractCodeIMUGY_R:
        {
            _IMUGY = aParam;
        }
            break;
            
        case ZYBleInteractCodeIMUGZ_R:
        {
            _IMUGZ = aParam;
        }
            break;
            
        case ZYBleInteractCodePitchAngle_R:
        {
            _pitchAngle = Int2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRollAngle_R:
        {
            _rollAngle = Int2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeYawAngle_R:
        {
            _yawAngle = Int2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodePitchSharpTurning_R:
        {
            _pitchSharpTurning = Int2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRollSharpTurning_R:
        {
            _rollSharpTurning = Int2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeWorkMode_R:
        {
            _workMode = (ZYBleDeviceWorkMode)aParam;
        }
            break;
            
        case ZYBleInteractCodePitchDeadArea_R:
        {
            _pitchDeadArea = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRollDeadArea_R:
        {
            _rollDeadArea = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeYawDeadArea_R:
        {
            _yawDeadArea = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodePitchFollowMaxRate_R:
        {
            _pitchFollowMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRollFollowMaxRate_R:
        {
            _rollFollowMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeYawFollowMaxRate_R:
        {
            _yawFollowMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodePitchSmoothness_R:
        {
            _pitchSmoothness = UInt2Float(aParam, 1.0);
        }
            break;
            
        case ZYBleInteractCodeRollSmoothness_R:
        {
            _rollSmoothness = UInt2Float(aParam, 1.0);
        }
            break;
            
        case ZYBleInteractCodeYawSmoothness_R:
        {
            _yawSmoothness = UInt2Float(aParam, 1.0);
        }
            break;
         
        case ZYBleInteractCodePitchControlMaxRate_R:
        {
            _pitchControlMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRollControlMaxRate_R:
        {
            _rollControlMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeYawControlMaxRate_R:
        {
            _yawControlMaxRate = UInt2Float(aParam, 0.01);
        }
            break;
            
        case ZYBleInteractCodeRockerDirectionConfig_R:
        {
            [self updateRockerDirectionConfig:aParam];
        }
            break;
            
        case ZYBleInteractCodeCameraManufacturer_R:
        {
            _cameraManufacturerString = [ZYBleDeviceDataModel translateToCameraManufacturer:aParam];
        }
            break;
            
        case ZYBleInteractCodeMotorForce_R:
        {
            _motorForceMode = (ZYBleDeviceMotorForceMode)aParam;
        }
            break;
        
        case ZYBleInteractXMotorState_R:
        {
            [self updateMotorState:aParam index:0];
        }
            break;
            
        case ZYBleInteractXMotorVersion_R:
        {
            [self updateMotorVersion:aParam index:0];
        }
            break;
            
        case ZYBleInteractYMotorState_R:
        {
            [self updateMotorState:aParam index:1];
        }
            break;
            
        case ZYBleInteractYMotorVersion_R:
        {
            [self updateMotorVersion:aParam index:1];
        }
            break;
            
        case ZYBleInteractZMotorState_R:
        {
            [self updateMotorState:aParam index:2];
        }
            break;
            
        case ZYBleInteractZMotorVersion_R:
        {
            [self updateMotorVersion:aParam index:2];
        }
            break;
            
        case ZYBleInteractProductionNo1_R:
        {
            _productionNoField1 = aParam;
            [_productionNo update:_productionNoField1 value2:_productionNoField2 value3:_productionNoField3 value4:_productionNoField4];
        }
            break;
            
        case ZYBleInteractProductionNo2_R:
        {
            _productionNoField2 = aParam;
            [_productionNo update:_productionNoField1 value2:_productionNoField2 value3:_productionNoField3 value4:_productionNoField4];
        }
            break;
            
        case ZYBleInteractProductionNo3_R:
        {
            _productionNoField3 = aParam;
            [_productionNo update:_productionNoField1 value2:_productionNoField2 value3:_productionNoField3 value4:_productionNoField4];
        }
            break;
            
        case ZYBleInteractProductionNo4_R:
        {
            _productionNoField4 = aParam;
            [_productionNo update:_productionNoField1 value2:_productionNoField2 value3:_productionNoField3 value4:_productionNoField4];
        }
            break;
            
        default:
            break;
    }
}

#pragma 辅助函数
+(NSString*) translateToModelNumber:(NSUInteger)aParam
{
    switch (aParam) {
        case 0x0200:
            return modelNumberPround;
            break;
            
        case 0x0300:
            return modelNumberEvolution;
            break;
        case 0x0310:
            return modelNumberEvolution2;
        case 0x0320:
            return modelNumberEvolution3;
        case 0x0210:
            return modelNumberSmooth;
            break;
            
        case 0x0220:
            return modelNumberSmooth2;
            break;
        
        case 0x0221:
            return modelNumberSmoothQ;
            break;
        case 0x0222:
            return modelNumberSmoothP1;
        case 0x0223:
            return modelNumberSmoothQ2;
        case 0x0224:
            return modelNumberSmoothC11;
        case 0x0226:
            return modelNumberSmoothX;
        case 0x0227:
            return modelNumberSmoothXS;
        case 0x0230:
            return modelNumberSmooth3;
        case 0x0231:
            return modelNumberCraneH;

        case 0x0240:
            return modelNumberSmooth4;
        case 0x0400:
            return modelNumberRiderM;
        case 0x0410:
            return modelNumberLiveStabilizer;
            
        case 0x0500:
        case 0x0501:
            return modelNumberCrane;
            break;

        case 0x0502:
        case 0x0503:

            return modelNumberCranePlus;

        case 0x0510:
        case 0x0511:
            return modelNumberCraneM;
            break;
        case 0x0512:
            return modelNumberCraneM2;
            break;
        case 0x0520:
            return modelNumberCraneTwo;
        case 0x0521:
            return modelNumberCraneTwoS;
            break;
            
        case 0x0530:
            return modelNumberCrane3Lab;
            break;
        
        case 0x0531:
            return modelNumberWeebillLab;
            break;
        case 0x0533:
            return modelNumberWeebillS;
            break;
        case 0x0600://修改这个值时需要搜索这个值，将网络请求值一并修改
            return modelNumberImageTransBox;
        case 0x0602://修改这个值时需要搜索这个值，将网络请求值一并修改
            return modelNumberImageTransBoxTwo;
        case 0x0601://修改这个值时需要搜索这个值，将网络请求值一并修改
            return modelNumberImageTransBoxRecive;
            break;
        case 0x053A:
#pragma -mark weebills的更改
            return modelNumberCrane3S;
            break;
        
        case 0x1000:
            return modelNumberShining;
            break;
            
        default:
            return modelNumberUnknown;
            break;
    }
}

+(NSString*) translateToCameraManufacturer:(NSUInteger)aParam
{
    switch (aParam) {
        case 0:
            return cameraManufacturerNone;
            break;
            
        case 1:
            return cameraManufacturerPreserve;
            break;
            
        case 2:
            return cameraManufacturerSony;
            break;
            
        case 3:
            return cameraManufacturerPanasonic;
            break;
        
        default:
            return cameraManufacturerNone;
            break;
    }
}

+(NSArray<NSString*>*) supportWIFIModelList
{
    return @[modelNumberCrane3S,
             modelNumberCrane3Lab,
             modelNumberWeebill,
             modelNumberWeebillLab,
             modelNumberWeebillS,
             modelNumberCraneTwoS,
             modelNumberImageTransBox,
             modelNumberImageTransBoxTwo
             ];
}

+(BOOL) isModelSupportWIFI:(NSString*)modelString;
{
    NSArray<NSString*>* list = [[self class] supportWIFIModelList];
    __block BOOL isSupport = NO;
    [list enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj localizedCaseInsensitiveCompare:modelString] == NSOrderedSame) {
            isSupport = YES;
            *stop = YES;
        }
    }];
    return isSupport;
}

-(void) updateSystemStatus:(NSUInteger)aParam
{
    _bLowVoltage = CheckMask(aParam, ZYBleInteractSysStateMaskLowVoltage);
    _bICUOffLine = CheckMask(aParam, ZYBleInteractSysStateMaskICUOffLine);
    _bZOffLine = CheckMask(aParam, ZYBleInteractSysStateMaskZOffLine);
    _bYOffLine = CheckMask(aParam, ZYBleInteractSysStateMaskYOffLine);
    _bXOffLine = CheckMask(aParam, ZYBleInteractSysStateMaskXOffLine);
    _bIMUExeption = CheckMask(aParam, ZYBleInteractSysStateMaskIMUExeption);
    _bTurnRound = CheckMask(aParam, ZYBleInteractSysStateMaskTurnRound);
    _bPower = CheckMask(aParam, ZYBleInteractSysStateMaskPower);
}

-(void) updateRockerDirectionConfig:(NSUInteger)aParam
{
    _bControllerXAnti = CheckBit(aParam, 0);
    _bControllerYAnti = CheckBit(aParam, 1);
    _bControllerZAnti = CheckBit(aParam, 2);
}

-(void) updateMotorState:(NSUInteger)aParam index:(NSUInteger)idx
{
    ZYBleDeviceMotorModel* model = [_motorStatus objectAtIndex:idx];
    model.bOffLine = CheckMask(aParam, ZYBleInteractMotorStateOffLine);
    model.bOverheat = CheckMask(aParam, ZYBleInteractMotorStateOverheat);
    model.bPowerTrouble = CheckMask(aParam, ZYBleInteractMotorStatePowerTrouble);
    model.bZeroException = CheckMask(aParam, ZYBleInteractMotorStateZeroException);
    model.bFeedbackException = CheckMask(aParam, ZYBleInteractMotorStateFeedbackException);
    model.bWorking = CheckMask(aParam, ZYBleInteractMotorStateWorking);
    model.bReady = CheckMask(aParam, ZYBleInteractMotorStateReady);
}

-(void) updateMotorVersion:(NSUInteger)aParam index:(NSUInteger)idx
{
    ZYBleDeviceMotorModel* model = [_motorStatus objectAtIndex:idx];
    model.softwareVersion = aParam;
}

/**
 是否是支持HID的设备，如果是HID的设备需要屏蔽掉volume
 
 @return 设备
 */
+(BOOL)isHIDSupportDeviceWithModelString:(NSString *)modelNameString{
    NSArray *hidArray = @[modelNumberSmoothQ2,modelNumberSmoothX,modelNumberSmoothXS];
    for (NSString *modelS in hidArray) {
        if ([modelS isEqualToString:modelNameString]) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)likeSmoothXWithString:(NSString *)modelString
{
    if([modelString isEqualToString:modelNumberSmoothX] || [modelString isEqualToString:modelNumberSmoothXS] || [modelString isEqualToString:modelNumberLiveStabilizer]){
        return YES;
    }
    return NO;
}

+(BOOL)likeWeebillsWithString:(NSString *)modelString
{
    if([modelString isEqualToString:modelNumberWeebillS] || [modelString isEqualToString:modelNumberCrane3S] || [modelString isEqualToString:modelNumberCraneTwoS]){
        return YES;
    }
    return NO;
}

+ (BOOL)likeImageTransBoxWithString:(NSString *)modelString{
    if([modelString isEqualToString:modelNumberImageTransBox] || [modelString isEqualToString:modelNumberImageTransBoxTwo]){
          return YES;
      }
      return NO;
}
@end
