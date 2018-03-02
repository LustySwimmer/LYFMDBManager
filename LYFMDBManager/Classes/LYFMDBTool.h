//
//  LYFMDBTool.h
//  LYFMDBManager
//
//  Created by Jacky on 2018/3/1.
//

#import <Foundation/Foundation.h>

@protocol LYFMDBKeyValue <NSObject>

@optional

/**
 允许存储到数据库的属性
 */
+ (nonnull NSArray *)ly_FMDBAllowedPropertyNames;

@end

@interface NSObject (LYFMDBKeyValue) <LYFMDBKeyValue>

@end

@interface LYFMDBTool : NSObject

/**
 判断表是否存在
 
 @param tableName 表名
 @return YES:存在
 */
+ (BOOL)ly_isTableExist:(nullable NSString *)tableName;

+ (nonnull NSMutableArray *)ly_getPropertyList:(nonnull NSString *)className;

/**
 创建表
 
 @param tableName 模型名称(必须是模型名称)
 @param category  表后缀名(用来区别以同一个模型创建的不同表名)
 */
+ (BOOL)ly_createTableName:(nonnull NSString *)tableName category:(nonnull NSString *)category;

/**
 插入模型到指定表中
 @param model 模型名称(必须是模型名称)
 @param category  表后缀名(用来区别以同一个模型创建的不同表名)
 */
+ (BOOL)ly_insertDBWithModel:(nonnull NSObject *)model category:(nonnull NSString *)category;
/**
 插入模型到指定表中
 @param model 模型名称(必须是模型名称)
 @param tableName 表名
 @param category  表后缀名(用来区别以同一个模型创建的不同表名)
 */
+ (BOOL)ly_insertDBWithModel:(nonnull NSObject *)model tableName:(nullable NSString *)tableName category:(nonnull NSString *)category;
/**
 删除表中包含的模型
 @param model 模型名称(必须是模型名称)
 @param category  表后缀名(用来区别以同一个模型创建的不同表名)
 @param propertyName  根据模型的哪个属性名来更新，如果不指定，就默认取第一个不为空的属性
 */
+ (BOOL)ly_deleteDBWithModel:(nonnull NSObject *)model category:(nonnull NSString *)category propertyName:(nonnull NSString *)propertyName;
+ (BOOL)ly_deleteDBWithModel:(nonnull NSObject *)model tableName:(nullable NSString *)tableName category:(nonnull NSString *)category propertyName:(nonnull NSString *)propertyName;
/**
 更新表中指定的模型
 @param model 模型名称(必须是模型名称)
 @param category  表后缀名(用来区别以同一个模型创建的不同表名)
 @param propertyName  根据模型的哪个属性名来更新，如果不指定，就默认取第一个不为空的属性
 */
+ (BOOL)ly_updateDBWithModel:(nonnull NSObject *)model category:(nonnull NSString *)category propertyName:(nonnull NSString *)propertyName;
+ (BOOL)ly_updateDBWithModel:(nonnull NSObject *)model tableName:(nullable NSString *)tableName category:(nonnull NSString *)category propertyName:(nonnull NSString *)propertyName;

/**
 查找指定表名的数据(会返回所有结果，没有过滤)
 
 @param tableName 模型名称(必须是模型名称)
 @param category 表后缀名(用来区别以同一个模型创建的不同表名)
 */
+ (nullable NSMutableArray *)ly_selectFromDBWithTableName:(nonnull NSString *)tableName category:(nonnull NSString *)category;
/**
 查找指定表名的数据
 
 @param tableName 模型名称(必须是模型名称)
 @param category 表后缀名(用来区别以同一个模型创建的不同表名)
 @param filter 过滤条件
 */
+ (nullable NSMutableArray *)ly_selectFromDBWithTableName:(nonnull NSString *)tableName category:(nonnull NSString *)category filter:(nullable NSString *)filter;

@end
