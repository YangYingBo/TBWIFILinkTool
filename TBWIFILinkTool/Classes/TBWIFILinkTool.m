//
//  TBWIFILinkTool.m
//  Template
//
//  Created by Loser on 7/29/19.
//  Copyright © 2019 Loser. All rights reserved.
//

#import "TBWIFILinkTool.h"
#import "EasyLink.h"
#import "ESPTouchTask.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import "ESP_WifiUtil.h"
#import "ESPTouchResult.h"

@interface TBWIFILinkTool ()<EasyLinkFTCDelegate,ESPTouchDelegate>


@property (nonatomic,copy) void (^onFounfBlock) (NSNumber *client,NSString *name,NSDictionary *mataDataDict);

@property (nonatomic,copy) void (^foundByFTCBlock) (NSNumber *client,NSDictionary *configDict);

@property (nonatomic,copy) void (^disconnectBlock) (NSNumber *client,BOOL err);

/// Easylink 配置wifi
@property (nonatomic,strong) EASYLINK *EL;
/// ESPTouch 配置wifi
@property (atomic, strong) ESPTouchTask *_esptouchTask;

@property (nonatomic, strong) NSCondition *_condition;

@property (nonatomic,copy) void (^configurationWithTimeout) (NSString *msg);

@property (nonatomic,copy) void (^configurationFailure) (void);


@property (nonatomic,copy) void (^configurationSuccess) (ESPTouchResult *result);
@end

@implementation TBWIFILinkTool

+ (instancetype)sharedWiFiLinkTool
{
    static TBWIFILinkTool *configTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configTool = [[TBWIFILinkTool alloc] init];
    });
    return configTool;
}

/**
 选择EasyLink 配置wifi
 
 @param pw wifi 密码
 @param onFoundBlock 通过Bonjour服务发现 一个新设备连接wifi 成功回调
 @param foundByFTCBlock 在FTC服务器中发现一个新的设备连接wifi成功 回调
 @param disconnectBlock 断开 FTC 连接回调
 */
+ (void)selectEasyLinkConfigurationWiFiWithPassword:(NSString *)pw onFound:(void(^)(NSNumber *client,NSString *name,NSDictionary *mataDataDict))onFoundBlock onFoundByFTC:(void(^)(NSNumber *client,NSDictionary *configDict))foundByFTCBlock onDisconnectFromFTC:(void(^)(NSNumber *client,BOOL err))disconnectBlock
{
    [[self sharedWiFiLinkTool] selectEasyLinkConfigurationWiFiWithPassword:pw onFound:onFoundBlock onFoundByFTC:foundByFTCBlock onDisconnectFromFTC:disconnectBlock];
}

/// 停止当前的Easylink交付
+ (void)stopTransmitting
{
    [[self sharedWiFiLinkTool] stopTransmitting];
}

/// 清除EasyLink实例
+ (void)unInitEasyLink{
    [[self sharedWiFiLinkTool] unInitEasyLink];
}

- (void)unInitEasyLink
{
    [self.EL unInit];
}

- (void)stopTransmitting
{
    [self.EL stopTransmitting];
}

- (void)selectEasyLinkConfigurationWiFiWithPassword:(NSString *)pw onFound:(void(^)(NSNumber *client,NSString *name,NSDictionary *mataDataDict))onFoundBlock onFoundByFTC:(void(^)(NSNumber *client,NSDictionary *configDict))foundByFTCBlock onDisconnectFromFTC:(void(^)(NSNumber *client,BOOL err))disconnectBlock{
    
    self.onFounfBlock = onFoundBlock;
    self.foundByFTCBlock = foundByFTCBlock;
    self.disconnectBlock = disconnectBlock;
    
    NSMutableDictionary *linkDic = [NSMutableDictionary dictionaryWithCapacity:20];
    [linkDic setValue:[EASYLINK ssidDataForConnectedNetwork] forKey:KEY_SSID];
    [linkDic setValue:pw forKey:KEY_PASSWORD];
    [linkDic setValue:@(YES) forKey:KEY_DHCP];
    self.EL = [[EASYLINK alloc] initForDebug:YES WithDelegate:self];
    [self.EL prepareEasyLink:linkDic info:nil mode:EASYLINK_AWS];
    [self.EL transmitSettings];
}


// 通过Bonjour服务发现 一个新设备连接wifi 成功回调
- (void)onFound:(NSNumber *)client withName:(NSString *)name mataData:(NSDictionary *)mataDataDict
{
    self.onFounfBlock ? self.onFounfBlock(client,name,mataDataDict) : nil;
    
}

// 在FTC服务器中发现一个新的设备连接wifi成功 回调
- (void)onFoundByFTC:(NSNumber *)client withConfiguration:(NSDictionary *)configDict
{
    self.foundByFTCBlock ? self.foundByFTCBlock(client,configDict) : nil;
    
}

// 断开 FTC 连接
- (void)onDisconnectFromFTC:(NSNumber *)client withError:(bool)err
{
    self.disconnectBlock ? self.disconnectBlock(client,err) : nil;
}






/**
 选择ESPTouch 配置wifi
 
 @param ssid the wifi ssid
 @param apBssid wifi apBassid
 @param pw wifi password
 @param configurationSuccess wifi配置成功回调
 @param failure 配置失败
 @param timeout 配置超时
 */
+ (void)selectESPTouchConfigurationWiFiWithSSID:(NSString *)ssid apBssid:(NSString *)apBssid password:(NSString *)pw
                                        success:(void (^) (ESPTouchResult *result))configurationSuccess
                                        failure:(void(^)(void))failure
                                        timeout:(void(^)(NSString *msg))timeout
{
    [[self sharedWiFiLinkTool]selectESPTouchConfigurationWiFiWithSSID:ssid apBssid:apBssid password:pw success:configurationSuccess failure:failure timeout:timeout];
}

/// 中断 wifi配置
+ (void)interrupt
{
    [[self sharedWiFiLinkTool] interrupt];
}

- (void)interrupt
{
    [self._esptouchTask interrupt];
}

- (void)selectESPTouchConfigurationWiFiWithSSID:(NSString *)ssid apBssid:(NSString *)apBssid password:(NSString *)pw
                                        success:(void (^) (ESPTouchResult *result))configurationSuccess
                                        failure:(void(^)(void))failure
                                        timeout:(void(^)(NSString *msg))timeout
{
    
    self.configurationSuccess = configurationSuccess;
    self.configurationFailure = failure;
    self.configurationWithTimeout = timeout;
    
    
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPViewController do the execute work...");
        // execute the task
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:ssid bssid:apBssid password:pw taskCount:1 broadcast:NO];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {
                    
                    for (int i = 0; i < [esptouchResultArray count]; ++i)
                    {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        [mutableStr appendString:[resultInArray description]];
                        [mutableStr appendString:@"\n"];
                        count++;
                        if (count >= maxDisplayCount)
                        {
                            break;
                        }
                    }
                    
                    if (count < [esptouchResultArray count])
                    {
                        [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                    }
                    
                    self.configurationWithTimeout ? self.configurationWithTimeout(mutableStr) : nil;
                }
                else
                {
                    
                    
                    self.configurationFailure ? self.configurationFailure() : nil;
                }
            }
            
        });
    });
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast
{
    [self._condition lock];
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self];
    [self._esptouchTask setPackageBroadcast:broadcast];
    [self._condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

- (void)onEsptouchResultAddedWithResult:(ESPTouchResult *)result
{
    self.configurationSuccess ? self.configurationSuccess(result) : nil;
}




@end
