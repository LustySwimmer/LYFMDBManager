//
//  NSString+LYFMDBManager.h
//  LYFMDBManager
//
//  Created by Jacky on 2018/3/1.
//

#import <Foundation/Foundation.h>

@interface NSString (LYFMDBTool)


/**
 将对象转换成json字符串
 */
+ (NSString *)ly_objectToJSON:(id)object;

/**
 判断属性类型是否是数组类型
 */
+ (BOOL)ly_isKeyTypeArrayClass:(NSString *)string;

/**
 判断属性类型是否是字典类型
 */
+ (BOOL)ly_isKeyTypeDictionaryClass:(NSString *)string;

@end
