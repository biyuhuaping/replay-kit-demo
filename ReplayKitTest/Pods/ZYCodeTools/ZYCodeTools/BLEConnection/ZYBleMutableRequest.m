//
//  ZYBleFirmwareRequest.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/17.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleMutableRequest.h"
#import "ZYBleProtocol.h"
#import "ZYCrcCheck.h"
#import "ZYControlCoder.h"
#import "ZYStarControlCoder.h"
#import "ZYBlControlCoder.h"
#import "ZYAllControlData.h"
#import "ZYBlHandleData.h"
#import "ZYUsbControlCoder.h"
#import "ZYAllControlData.h"

//检测block是否可用
#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };
#define BLOCK_EXEC_ON_MAINQUEUE(block, ...) dispatch_async(dispatch_get_main_queue(), ^{ \
    if (block) { block(__VA_ARGS__); }; \
    });

const NSUInteger MSG_MIN_LEN = 6;
const NSUInteger MSG_BODY_START = 4;

static unsigned char cmd_idx = 0;

#define ZYBLEMakeFirmwareCode(adr, cmd) ((address & 0x0F) << 4) | (cmd & 0x0F)
#define ZYBLEStarCodeFromInternal(bytesValue) (((bytesValue)[1])|((bytesValue)[2]<<8))
#define swap(a,b) {a=a^b;b=a^b;a=a^b;}

static ZYStarControlCoder* defaultStarCoder = nil;
static ZYBlControlCoder* defaultBlCoder = nil;
static ZYUsbControlCoder* defaultUsbCoder = nil;

@interface ZYBleMutableRequest()

@property (nonatomic, readwrite) NSUInteger code;
@property (nonatomic, readwrite) NSUInteger param;
@property (nonatomic, readwrite) NSData* buffer;
@property (nonatomic, readwrite) BOOL firmFormat;
@property (nonatomic, readwrite) BOOL blocked;

@property (nonatomic, readwrite) NSUInteger event;
@property (nonatomic, readwrite, strong) NSData* eventData;
@property (nonatomic, readwrite, copy) ZYControlData* controlData;


@end

@implementation ZYBleMutableRequest

@synthesize code = _code;
@synthesize param = _param;
@synthesize realCode = _realCode;
@synthesize blocked = _blocked;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStarCoder = [[ZYStarControlCoder alloc]init];
        defaultBlCoder = [[ZYBlControlCoder alloc]init];
        defaultUsbCoder = [[ZYUsbControlCoder alloc]init];
    });
}
/**
 外部配置msgid
 
 @param msgId 消息ID用于回复稳定器
 */
-(void)configMsgId:(NSUInteger)msgId{
    _msgId = msgId;
}


-(instancetype) init
{
    if ([super init]) {
        self.blocked = YES;
        _event = 0;
        _eventData = nil;
        _msgId = 0;
    }
    return self;
}

-(instancetype) initWithCodeAndParam:(NSUInteger)address withCommand:(NSUInteger)aCommand;
{
    ZYBlData* blData = [[ZYBlData alloc]init];
    blData.headCode = BL_HEAD_CODE_SEND;
    blData.address = address;
    blData.command = aCommand;
    if ([self initWithZYControlData:blData]) {
        _code = ZYBLEMakeFirmwareCode(address, aCommand);
        _param = 0;
        _firmFormat = YES;
        blData.content = _buffer;
        blData.lenght = 2 + (_buffer == nil ? 0 : _buffer.length);
    }
    return self;
}

-(instancetype) initWithCodeAndParamWith4BytesData:(NSUInteger)address withCommand:(NSUInteger)aCommand param:(NSUInteger)aParam;
{
    ZYBlData* blData = [[ZYBlData alloc]init];
    blData.headCode = BL_HEAD_CODE_SEND;
    blData.address = address;
    blData.command = aCommand;
    
    if ([self initWithZYControlData:blData]) {
        _code = ZYBLEMakeFirmwareCode(address, aCommand);
        _param = 0;
        _buffer = [NSData dataWithBytes:&aParam length:4];
        _firmFormat = YES;
        blData.content = _buffer;
        blData.lenght = 2 + (_buffer == nil ? 0 : _buffer.length);
    }
    return self;
}

-(instancetype) initWithCodeAndParamWith2BytesDataAndBuffer:(NSUInteger)address withCommand:(NSUInteger)aCommand param:(NSUInteger)aParam buffer:(NSData*)buff;
{
    ZYBlData* blData = [[ZYBlData alloc]init];
    blData.headCode = BL_HEAD_CODE_SEND;
    blData.address = address;
    blData.command = aCommand;
    
    if ([self initWithZYControlData:blData]) {
        self.code = ZYBLEMakeFirmwareCode(address, aCommand);
        self.param = 0;
        
        unsigned long totalLen = 2+buff.length;
        unsigned char* szBuff = (unsigned char*)calloc(totalLen, sizeof(unsigned char));
        memcpy(szBuff, &aParam, 2);
        memcpy(szBuff+2, buff.bytes, buff.length);
        _buffer = [NSData dataWithBytesNoCopy:szBuff length:totalLen freeWhenDone:YES];
        
        _firmFormat = YES;
        blData.content = _buffer;
        blData.lenght = 2 + (_buffer == nil ? 0 : _buffer.length);
    }
    return self;
}

-(instancetype) initWithHandlerCodeAndParam:(NSUInteger)aCommand param:(NSUInteger)aParam
{    
    ZYBlHandleData* hData = [[ZYBlHandleData alloc] init];
    hData.cmdCode = aCommand;
    hData.cmdArg = aParam;
    [hData createRawData];
    
    return [[ZYBleMutableRequest alloc] initWithZYControlData:hData];
}

-(BOOL) needResponse
{
    if (self.event == ZYBleInteractEventAsyn) {
        return !([self isKeyEvent] || (self.event == ZYBleInteractEventAsyn && (ZYBLEMakeInteractCodeToCmd(self.realCode) == ZYBLE_CMD_CONTR)));
    } else if (self.event == ZYBleInteractEventHandle) {
        return YES;
    } else if (self.event == ZYBleInteractEventWifi
               ||self.event == ZYBleInteractEventCCS
               ||self.event == ZYBleInteractEventOther) {
        if ([self.controlData isKindOfClass:[ZYBlWiFiPhotoNoticeData class]]) {
            return NO;
        }
#pragma -mark ZYBlOtherSyncData
        else if ([self.controlData isKindOfClass:[ZYBlOtherSyncData class]]) {
            ZYBlOtherSyncData *data = (ZYBlOtherSyncData *)self.controlData;
            if (data.messageId != 0) {
                return YES;
            }
            return NO;
        }
        else if ([self.controlData isKindOfClass:[ZYUsbInstructionBlData class]]) {
            ZYUsbInstructionBlData *usbdata = (ZYUsbInstructionBlData *)self.controlData;
            if ([usbdata.blData isKindOfClass:[ZYBlOtherSyncData class]]) {
                ZYBlOtherSyncData *data = (ZYBlOtherSyncData *)usbdata.blData;
                if (data.messageId != 0) {
                    return YES;
                }
                return NO;
            }
        }
        else if ([self.controlData isKindOfClass:[ZYBlOtherHeart class]]) {
#pragma -mark 心跳不需要响应
            return YES;
        }
        return YES;
    } else if (self.command == ZYBleInteractSync
               || self.command == ZYBleInteractUpdateWrite
               || self.command == ZYBleInteractCheck
               || self.command == ZYBleInteractByPass
               || self.command == ZYBleInteractReset
               || self.command == ZYBleInteractAppgo
               || self.command == ZYBleInteractBootReset) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) isNeedNotify:(ZYControlData*) controlData
{
#pragma -mark ZYUsbInstructionMediaStreamData需要通知
    if ([controlData isKindOfClass:[ZYUsbInstructionMediaStreamData class]]) {
        return YES;
    }
    if (self.event == ZYBleInteractEventAsyn
        || self.event == ZYBleInteractEventHandle) {
        return NO;
    } else if (self.event == ZYBleInteractEventRdis) {
        if ([controlData isKindOfClass:[ZYBlRdisData class]]) {
            return YES;
        }
        return NO;
    } else if (self.event == ZYBleInteractEventWifi) {
        if ([controlData isKindOfClass:[ZYBlWiFiPhotoNoticeData class]]) {
            return YES;
        }
        return NO;
    } else if (self.event == ZYBleInteractEventCCS) {
        if ([controlData isKindOfClass:[ZYBlCCSGetConfigData class]]
            || [controlData isKindOfClass:[ZYBlCCSSetConfigData class]]) {
            return YES;
        }
        return NO;
    } else if (self.event == ZYBleInteractEventOther) {
        if ([controlData isKindOfClass:[ZYBlOtherSyncData class]]) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
}

-(BOOL) postNotificationIfNeed:(ZYControlCoder*)coder
{
    ZYControlData* controlData = _controlData;
    
    if ([_controlData isKindOfClass:[ZYUsbInstructionBlData class]]) {
        ZYUsbInstructionBlData* usbInstructionBlData = (ZYUsbInstructionBlData*)_controlData;
        controlData = usbInstructionBlData.blData;
    }
    if ([self isNeedNotify:controlData]){
        if ([controlData isKindOfClass:[ZYUsbInstructionMediaStreamData class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:Device_State_Event_Notification_ResourceData object:self->_controlData userInfo:@{@"type":NSStringFromClass([self->_controlData class]), @"Data":self->_controlData.toDictionary}];
            });
        }
        else if ([_controlData isKindOfClass:[ZYUsbInstructionBlData class]]) {
            ZYUsbInstructionBlData* usbInstructionBlData = (ZYUsbInstructionBlData*)_controlData;
            ZYBlData* blData = usbInstructionBlData.blData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:Device_State_Event_Notification_ResourceData object:blData userInfo:@{@"type":NSStringFromClass([blData class]), @"Data":self->_controlData.toDictionary}];
            });
        } else {
            //TODO zyusb协议通知数据临时处理一下
            dispatch_async(dispatch_get_main_queue(), ^{

                [[NSNotificationCenter defaultCenter] postNotificationName:Device_State_Event_Notification_ResourceData object:self->_controlData userInfo:@{@"type":NSStringFromClass([self->_controlData class]), @"Data":self->_controlData.toDictionary}];
            });

        }
        return YES;
    }
    return NO;
}

+(BOOL) parseDataToCodeAndParam:(NSData*)data adr:(NSUInteger*)address command:(NSUInteger*)command;
{
    if (data.length > MSG_MIN_LEN) {
        Byte* bytes = (Byte*)data.bytes;
        
        if ((*(unsigned short*)bytes) == ZYBLE_FIRM_RECV_HEAD_REVERSE) {
            NSUInteger aCode;
            NSUInteger aParam;
            aCode = bytes[MSG_BODY_START];
            aParam = bytes[MSG_BODY_START+1];
            *address = aCode>>4;
            *command = aCode&0x0F;
            return YES;
        }
    }
    return NO;
}

-(instancetype) initWithZYControlData:(ZYControlData*)data
{
    if ([self init]) {
        _controlData = data;
        if ([data isKindOfClass:[ZYBlData class]]) {
            ZYBlData* blData = (ZYBlData*)data;
            self = [self initWithZYBlData:blData];
        } else if ([data isKindOfClass:[ZYUsbData class]]) {
            ZYUsbData* usbData = (ZYUsbData*)data;
            if ([data isKindOfClass:[ZYUsbInstructionBlData class]]) {
                ZYUsbInstructionBlData* usbBlData = (ZYUsbInstructionBlData*)data;
                self = [self initWithZYBlData:usbBlData.blData];
            }
            _blocked = NO;
            _msgId = usbData.uid;
        }
    }
    return self;
}

-(instancetype) initWithZYBlData:(ZYBlData*)blData
{
    if ([self init]) {
        NSUInteger address = blData.address;
        NSUInteger command = blData.command;
        
        self.code = ZYBLEMakeFirmwareCode(address, command);
        self.param = 0;
        
        if (self.command == ZYBleInteractEvent) {
            self.event = blData.status;
            if (self.event == ZYBleInteractEventAsyn) {
                //self.blocked = NO;
                ZYBlAsynStarData* asData = (ZYBlAsynStarData*)blData;
                self.realCode = asData.code;
                self.param = asData.param;
                _msgId = asData.cmdId;
            } else if (self.event == ZYBleInteractEventHandle) {
                self.eventData = blData.content;
                ZYBlHandleData* hData = (ZYBlHandleData*)blData;
                self.realCode = hData.cmdCode;
                self.param = hData.cmdArg;
                _msgId = hData.cmdId;
            } else if (self.event == ZYBleInteractEventWifi) {
                
            }
        } else if (self.command == ZYBleInteractSync
                   || self.command == ZYBleInteractUpdateWrite
                   || self.command == ZYBleInteractCheck
                   || self.command == ZYBleInteractByPass
                   || self.command == ZYBleInteractReset
                   || self.command == ZYBleInteractAppgo
                   || self.command == ZYBleInteractBootReset){
            _firmFormat = YES;
        }
    }
    return self;
}

-(NSUInteger) address
{
    return ZYBLAdressFromCode(self.code);
}

-(NSUInteger) command
{
    return ZYBLCommandFromCode(self.code);
}

-(void) translateToWithCoder:(ZYControlCoder*)coder
{
    if ([coder isKindOfClass:[ZYUsbControlCoder class]]) {
        //使用Wifi/usb协议解析时
        if ([_controlData isKindOfClass:[ZYBlData class]]) {
            ZYUsbInstructionBlData* usbBlData = [[ZYUsbInstructionBlData alloc] init];
            usbBlData.blData = (ZYBlData*)_controlData;
            _controlData = usbBlData;
        }
    }
}

-(NSData*) translateToBinaryWithCoder:(ZYControlCoder*)coder
{
    if ([coder isKindOfClass:[ZYStarControlCoder class]]) {
        coder = defaultBlCoder;
    }
    NSData* data = [coder encode:_controlData];
    if ([_controlData isKindOfClass:[ZYUsbData class]]){
        unsigned short msgId = 0;
        [data getBytes:&msgId range:NSMakeRange(2, 2)];
        _msgId = msgId;
    }
    return data;
}

-(NSData*) queryBinaryWithCoder:(ZYControlCoder*)coder
{
    NSUInteger originalDataType = _controlData.dataType;
    _controlData.dataType = 1;
    NSData* value = [self translateToBinaryWithCoder:coder];
    _controlData.dataType = originalDataType;
    return value;
}

-(NSString*) description
{
    NSString* string;
//    if (_firmFormat) {
//        string = [NSString stringWithFormat:@"<%@ cmd:0x%02lx addr:0x%02lx status 0x%02lx Param %@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], (_code & 0xF0)>>4, (_code & 0x0F), (_param & 0xFF), _buffer, [ZYBlControlCoder descriptionForBlData:(ZYBlData*)_controlData]];
//    } else
    if ([_controlData isKindOfClass: [ZYUsbData class]]) {
        string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYUsbControlCoder alloc] init]], [ZYUsbControlCoder descriptionForUsbData:(ZYUsbData*)_controlData]];
    } else if (self.command == ZYBleInteractEvent) {
        if (self.event == ZYBleInteractEventBle) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], @"蓝牙控制事件"];
        } else if (self.event == ZYBleInteractEventAsyn) {
            string = [NSString stringWithFormat:@"<%@ cmd:0x%02lx addr:0x%02lx status 0x%02lx Param %lu %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], (_code & 0xF0)>>4, (_code & 0x0F), (_param & 0xFF), (unsigned long)self.param, starCodeToNSString(_realCode)];
        } else if (self.event == ZYBleInteractEventJoystick) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], @"摇杆/拨轮事件"];
        } else if (self.event == ZYBleInteractEventAngle) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], @"角度/拨轮事件"];
        } else if (self.event == ZYBleInteractEventRdis) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], @"RDIS控制数据事件"];
        } else if (self.event == ZYBleInteractEventHandle) {
            string = [NSString stringWithFormat:@"<%@ cmd:0x%02lx addr:0x%02lx status 0x%02lx Param %lu %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], (_code & 0xF0)>>4, (_code & 0x0F), (_param & 0xFF), (unsigned long)self.param, @"手柄事件"];
        } else if (self.event == ZYBleInteractEventWifi) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], [ZYBlControlCoder descriptionForBlData:(ZYBlData*)_controlData]];
        } else if (self.event == ZYBleInteractEventTrack) {
            string = [NSString stringWithFormat:@"<%@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], @"跟踪事件"];
        } else {
            string = [NSString stringWithFormat:@"<%@ cmd:0x%02lx addr:0x%02lx status 0x%02lx Param %@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], (_code & 0xF0)>>4, (_code & 0x0F), (_param & 0xFF), _buffer, [ZYBlControlCoder descriptionForBlData:(ZYBlData*)_controlData]];
        }
    } else if (self.command == ZYBleInteractSync
               || self.command == ZYBleInteractUpdateWrite
               || self.command == ZYBleInteractCheck
               || self.command == ZYBleInteractByPass
               || self.command == ZYBleInteractReset
               || self.command == ZYBleInteractAppgo
               || self.command == ZYBleInteractBootReset){
        string = [NSString stringWithFormat:@"<%@ cmd:0x%02lx addr:0x%02lx status 0x%02lx Param %@ %@>", [self queryBinaryWithCoder:[[ZYBlControlCoder alloc] init]], (_code & 0xF0)>>4, (_code & 0x0F), (_param & 0xFF), _buffer, [ZYBlControlCoder descriptionForBlData:(ZYBlData*)_controlData]];
    } else {
        string = [super description];
    }
    
    return string;
}

+(NSDictionary*) parseData:(NSData*)data
{
    Byte* bytes = (Byte*)data.bytes;
    unsigned short dataLen = 0;
    memcpy(&dataLen, bytes+2, 2);
    
    if (dataLen >= data.length - MSG_MIN_LEN) {

        NSUInteger aCode = bytes[MSG_BODY_START];
        NSUInteger aParam = bytes[MSG_BODY_START+1];
        //NSUInteger address = aCode>>4;
        NSUInteger command = aCode&0x0F;
        if (command == ZYBleInteractSync) {
            //数据区第6字节开始
            NSUInteger idx = MSG_BODY_START + 6;
            NSUInteger size = 0;
            NSUInteger count = 0;
            NSUInteger archVersion = 0;
            NSUInteger hwVersion = 0;
            memcpy(&size, bytes+idx, 2);  //2+4~6
            idx += 2;
            memcpy(&count, bytes+idx, 2);  //2+6~8
            //跳过2字节数据
            idx += 4;
            memcpy(&archVersion, bytes+idx, 2); //2+10~12
            idx += 2;
            memcpy(&hwVersion, bytes+idx, 2); //2+12~14
            idx += 2;
            
            return @{@"status":@(aParam), @"size":@(size), @"count":@(count), @"archVersion":@(archVersion), @"hwVersion":@(hwVersion)};
        } else if (command == ZYBleInteractCheck) {
            NSUInteger idx = MSG_BODY_START + 2;
            int crc = 0;
            memcpy(&crc, bytes+idx, 2);
            idx += 2;
            return @{@"status":@(aParam), @"crc":@(crc)};
        } else if (command == ZYBleInteractUpdateWrite) {
            NSUInteger idx = MSG_BODY_START + 2;
            unsigned int nPage = 0;
            memcpy(&nPage, bytes+idx, 2);
            idx += 2;
            return @{@"status":@(aParam), @"page":@(nPage)};
        } else if (command == ZYBleInteractByPass) {
            NSUInteger idx = MSG_BODY_START + 2;
            unsigned int code = 0;
            memcpy(&code, bytes+idx, 2);
            idx += 2;
            return @{@"status":@(aParam), @"code":@(code)};
        } else {
            return @{@"status":@(aParam)};
        }
    }
    return nil;
}

-(void) startCountdown:(NSUInteger)millisecond block:(void (^)(void))block
{
    if (self.command == ZYBleInteractUpdateWrite || self.command == ZYBleInteractCheck) {
        millisecond = 10000;
        if (self.command == ZYBleInteractUpdateWrite) {
#pragma -mark 升级要把延时提高
            self.delayMillisecond = 3200;
        }
    } else if (self.command == ZYBleInteractEvent || self.realCode == ZYBleInteractSysReset) {
        millisecond = 500;
    }
   
    [super startCountdown:millisecond block:block];
}

-(BOOL) isEvent
{
    return self.command == ZYBleInteractEvent;
}

-(BOOL) isKeyEvent
{
    NSUInteger code = ZYBleInteractButtonEvent;
    return [self isEvent] && self.event == ZYBleInteractEventAsyn && ZYBLEMakeInteractCodeWithoutAdrCmp(self.realCode, code);
}

-(BOOL) isSameWithCode:(NSUInteger)code
{
    return self.command == ZYBLCommandFromCode(code);
}

-(BOOL) isSameCodeWithRequest:(ZYBleDeviceRequest*)request
{
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        ZYBleMutableRequest* mutableRequest = (ZYBleMutableRequest*)request;
        if ([self isSameWithCode:request.code] && (self.event == mutableRequest.event)) {
            if (self.event == ZYBleInteractEventAsyn) {
                return ZYBLEMakeInteractCodeWithoutAdrCmp(self.realCode, request.realCode);
            } else {
                if ([NSStringFromClass([self.controlData class]) isEqualToString:NSStringFromClass([mutableRequest.controlData class])]) {
                    return YES;
                }
                else{
                    return NO;
                }
            }
        } else {
            return NO;
        }
    } else {
        return [super isSameCodeWithRequest:request];
    }
}

- (BOOL)isEqualToRequest:(ZYBleMutableRequest *)request
{
    if (!request) {
        return NO;
    }
    
    return [self isSameCodeWithRequest:request] && [self.eventData isEqualToData:request.eventData];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ZYBleDeviceRequest class]]) {
        return NO;
    }
    
    if ([object isKindOfClass:[ZYBleMutableRequest class]]) {
        return [self isEqualToRequest:object];
    } else if ([object isKindOfClass:[ZYBleDeviceRequest class]]) {
        ZYBleDeviceRequest* request = (ZYBleDeviceRequest*)object;
        return (self.realCode == request.realCode) && (self.param == request.param) && (self.handler == request.handler);
    } else {
        return NO;
    }
}

-(void) notifyResultWithRequest:(ZYBleDeviceRequest*)request state:(ZYBleDeviceRequestState)state coder:(ZYControlCoder*)coder
{
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        ZYBleMutableRequest* mutableRequest = (ZYBleMutableRequest*)request;
        if (mutableRequest.paramsHandler) {
            if (_firmFormat) {
                id param = nil;
                if (state == ZYBleDeviceRequestStateResponse) {
                    param = [_controlData toDictionary];
                }
                
                if ([param isKindOfClass:[NSDictionary class]]) {
                    NSNumber *dataParse = [(NSDictionary*)param objectForKey:kDataParseSuccess];
                    if (dataParse) {
#pragma -mark 数据解析失败的时候，先识别为发送错误,后续处理为错误码
                        if ([dataParse boolValue] == NO) {
                            state = ZYBleDeviceRequestStateFail;
                        }
                    }
                }
                BLOCK_EXEC_ON_MAINQUEUE(mutableRequest.paramsHandler, state, param);
            } else {
                if ([_controlData isKindOfClass:[ZYUsbInstructionBlData class]]) {
                    ZYUsbInstructionBlData* usbInstructionBlData = (ZYUsbInstructionBlData*)_controlData;
                    BLOCK_EXEC_ON_MAINQUEUE(mutableRequest.paramsHandler, state, usbInstructionBlData.blData);
                } else {
                    BLOCK_EXEC_ON_MAINQUEUE(mutableRequest.paramsHandler, state, _controlData);
                }
            }
        } else {
            BLOCK_EXEC_ON_MAINQUEUE(mutableRequest.handler, state, self.param);
        }
    } else {
        [super notifyResultWithRequest:request state:state coder:coder];
    }
}

@end


ZYBleMutableRequest* transferDeviceRequestToMutable(ZYBleDeviceRequest* request, ZYControlCoder* coder)
{
    ZYBleMutableRequest* newRequest = nil;
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        newRequest = (ZYBleMutableRequest*)request;
        [newRequest translateToWithCoder:coder];
    } else {
        ZYControlData* data = nil;
        ZYBlAsynStarData* asData = [[ZYBlAsynStarData alloc] init];
        asData.code = request.code;
        asData.param = request.param;
        [asData createRawData];
        
        if ([coder isKindOfClass:[ZYUsbControlCoder class]]) {
            //使用Wifi/usb协议解析时
            if ([asData isKindOfClass:[ZYBlData class]]) {
                ZYUsbInstructionBlData* usbBlData = [[ZYUsbInstructionBlData alloc] init];
                usbBlData.blData = asData;
                data = usbBlData;
            }
        } else {
            data = asData;
        }
        
        newRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
        newRequest.handler = request.handler;
        newRequest.timeouProcessing = request.timeouProcessing;
        newRequest.packedWithNext = request.packedWithNext;
        newRequest.realCode = request.realCode;
        newRequest.mask = request.mask;
        newRequest.parseFormat = request.parseFormat;
        newRequest.trasmissionType = request.trasmissionType;
        newRequest.delayMillisecond = request.delayMillisecond;
        newRequest.noNeedToUpdateDataCache = request.noNeedToUpdateDataCache;
        newRequest.needSendSoon = request.needSendSoon;
        
    }
    return newRequest;
}
