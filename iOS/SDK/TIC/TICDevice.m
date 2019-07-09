//
//  TICDevice.m
//  TICSDK
//
//  Created by kennethmiao on 2018/12/11.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TICDevice.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <sys/utsname.h>
#import "TICKeychainItemWrapper.h"
#import "TICReachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@implementation TICDevice
+ (NSString *)getSystemVersion
{
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] systemVersion];
#else
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
#endif
}

+ (NSString *)getDevType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

+ (NSString *)getUUID
{
    NSString *key = @"com.tencent.tic.keychain.uuid";
    TICKeychainItemWrapper *keychainItem = [[TICKeychainItemWrapper alloc] initWithIdentifier:key accessGroup:nil];
    
    NSString *strUUID = [keychainItem objectForKey:(__bridge id)kSecValueData];
    
    if (strUUID.length <= 0) {
#if TARGET_OS_IPHONE
        strUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#else
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        strUUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
#endif
        
        [keychainItem setObject:@"uuid" forKey:(__bridge id)kSecAttrAccount];
        [keychainItem setObject:strUUID forKey:(__bridge id)kSecValueData];
    }
    return strUUID;
}

+ (TICNetType)getNetype{
    
    TICNetType netType = TICNet_None;
    TICReachability *reach = [TICReachability reachabilityWithHostName:@"www.qq.com"];
    switch ([reach currentReachabilityStatus]) {
        case TIC_NotReachable:// 没有网络
            break;
        case TIC_ReachableViaWiFi:// Wifi
            netType = TICNet_Wifi;
            break;
#if TARGET_OS_IPHONE
        case TIC_ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                netType = TICNet_2G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                netType = TICNet_2G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                netType = TICNet_2G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                netType = TICNet_3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                netType = TICNet_4G;
            }
        }
            break;
#endif
        default:
            break;
    }
    return netType;
}
@end
