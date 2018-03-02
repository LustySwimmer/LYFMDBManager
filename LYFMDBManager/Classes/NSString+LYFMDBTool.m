//
//  NSString+LYFMDBManager.m
//  LYFMDBManager
//
//  Created by Jacky on 2018/3/1.
//

#import "NSString+LYFMDBTool.h"
#import "LYFMDBManager.h"
#import <MJExtension/MJExtension.h>

@implementation NSString (LYFMDBTool)

+ (NSString *)ly_objectToJSON:(id)object {
    if (!object) {
        return nil;
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        //将存储对象模型的数组转换成json字符串
        NSMutableArray *jsonArr = [NSMutableArray array];
        if ([object isKindOfClass:[NSArray class]]) {
            for (NSObject *model in object) {
                NSString *jsonStr = [model mj_JSONString];
                [jsonArr addObject:jsonStr];
            }
            if ([NSJSONSerialization isValidJSONObject:jsonArr]) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:jsonArr options:0 error:nil];
                return [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
            } else {
                LYFMDBManagerLog(@"不能被json格式化");
                return nil;
            }
        }
        
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:object
                        options:0
                        error:&error];
    if (error) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }
}

+ (BOOL)ly_isKeyTypeArrayClass:(NSString *)string {
    if (!string || [string length] == 0) {
        return NO;
    }
    NSString *array = NSStringFromClass([NSArray class]);
    NSString *mutableArr = NSStringFromClass([NSMutableArray class]);
    return ([string containsString:array] || [string containsString:mutableArr]);
}

+ (BOOL)ly_isKeyTypeDictionaryClass:(NSString *)string {
    if (!string || [string length] == 0) {
        return NO;
    }
    NSString *dic = NSStringFromClass([NSDictionary class]);
    NSString *mutableDic = NSStringFromClass([NSMutableDictionary class]);
    return ([string containsString:dic] || [string containsString:mutableDic]);
}

@end
