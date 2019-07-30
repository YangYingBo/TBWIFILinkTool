//
//  TBWIFILinkTool.h
//  Template
//
//  Created by Loser on 7/29/19.
//  Copyright © 2019 Loser. All rights reserved.
//

@class ESPTouchResult;

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface TBWIFILinkTool : NSObject
/**
 选择EasyLink 配置wifi
 
 @param pw wifi 密码
 @param onFoundBlock 通过Bonjour服务发现 一个新设备连接wifi 成功回调
 @param foundByFTCBlock 在FTC服务器中发现一个新的设备连接wifi成功 回调
 @param disconnectBlock 断开 FTC 连接回调
 */
+ (void)selectEasyLinkConfigurationWiFiWithPassword:(NSString *)pw onFound:(void(^)(NSNumber *client,NSString *name,NSDictionary *mataDataDict))onFoundBlock onFoundByFTC:(void(^)(NSNumber *client,NSDictionary *configDict))foundByFTCBlock onDisconnectFromFTC:(void(^)(NSNumber *client,BOOL err))disconnectBlock;
/// 停止当前的Easylink交付
+ (void)stopTransmitting;
/// 清除EasyLink实例 请务必调用该API
+ (void)unInitEasyLink;



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
                                        timeout:(void(^)(NSString *msg))timeout;
/// 中断 wifi配置
+ (void)interrupt;
@end

NS_ASSUME_NONNULL_END
