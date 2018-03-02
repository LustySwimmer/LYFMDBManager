//
//  LYFMDBTool.m
//  LYFMDBManager
//
//  Created by Jacky on 2018/3/1.
//

#import "LYFMDBTool.h"
#import "LYFMDBManager.h"
#import <FMDB/FMDB.h>
#import <MJExtension/MJExtension.h>
#import <objc/runtime.h>

@implementation NSObject (LYFMDBKeyValue)

static NSMutableArray *_allowedProperties;
+ (NSArray *)ly_FMDBAllowedPropertyNames {
    if (_allowedProperties.count) {
        return _allowedProperties;
    }
    NSMutableArray *propertyList =  [LYFMDBTool ly_getPropertyList:NSStringFromClass([self class])];
    if (!_allowedProperties) {
        _allowedProperties = [NSMutableArray array];
    }
    for (MJProperty *property in propertyList) {
        [_allowedProperties addObject:property.name];
    }
    return _allowedProperties;
}

@end

@implementation LYFMDBTool

FMDatabaseQueue *_queue;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/nayundb.sqlite"];
        _queue = [[FMDatabaseQueue alloc] initWithPath:path];
    });
}

+ (BOOL)ly_isTableExist:(NSString *)tableName {
    __block BOOL ret = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            if (count != 0) {
                ret = YES;
            }
        }
    }];
    
    return ret;
}

/*
 tableName:数据模型对应的类名
 */
+ (BOOL)ly_createTableName:(NSString *)tableName category:(NSString *)category {
    NSString *name = [NSString stringWithFormat:@"%@%@",tableName,category];
    if ([self ly_isTableExist:name]) {
        return YES;
    }
    NSString *sql1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@%@ ",tableName,category];
    NSArray * propertyArr = [self ly_getPropertyList:tableName];
    NSMutableString * sql2 = [NSMutableString string];
    [sql2 stringByAppendingString:@"id INTEGER PRIMARY KEY AUTOINCREMENT,"];
    for (int i = 0; i < propertyArr.count; i++) {
        MJProperty *property = propertyArr[i];
        (i == 0)?[sql2 appendFormat:@"%@ TEXT",property.name]
        :[sql2 appendFormat:@",%@ TEXT",property.name];
    }
    NSString *sql = [NSString stringWithFormat:@"%@(%@)",sql1,sql2];
    __block BOOL successed = YES;
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql]) {
            LYFMDBManagerLog(@"create table %@ error",tableName);
            successed = NO;
        }
    }];
    return successed;
}

+ (BOOL)ly_insertDBWithModel:(NSObject *)model category:(NSString *)category {
    return [self ly_insertDBWithModel:model tableName:nil category:category];
}

+ (BOOL)ly_insertDBWithModel:(NSObject *)model tableName:(NSString *)tableName category:(NSString *)category {
    if (!model) { return NO; }
    NSString *className = NSStringFromClass(object_getClass(model));
    className = (tableName == nil) ? className : tableName;
    __block BOOL successed = YES;
    if (![self ly_createTableName:className category:category]) {
        successed = NO;
        return successed;
    }
    tableName = [className stringByAppendingString:category];
    NSArray *propertyArr = [self ly_getPropertyList:className];
    NSArray *allowedProperties = [model.class ly_FMDBAllowedPropertyNames];
    NSString *sql1 = [NSString stringWithFormat:@"INSERT INTO %@%@ ",className,category];
    __block NSMutableString *keyStr = [NSMutableString string];
    __block NSMutableString *valueStr = [NSMutableString string];
    __block NSMutableArray *argumentsArr = [NSMutableArray array];
    for (int i = 0; i < propertyArr.count; i++) {
        __block MJProperty *property = propertyArr[i];
        __block MJPropertyType *type = property.type;
        if (![allowedProperties containsObject:property.name]) {
            continue;
        }
        [_queue inDatabase:^(FMDatabase *db) {
            if (![db columnExists:property.name inTableWithName:tableName]) {
                NSString *alterStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",tableName,property.name];
                BOOL added = [db executeUpdate:alterStr];
                if (!added) {
                    successed = NO;
                }
            }
            NSUInteger length = keyStr.length;
            (!length)?[keyStr appendFormat:@"%@",property.name]
            :[keyStr appendFormat:@",%@",property.name];
            (!length)?[valueStr appendString:@"?"]
            :[valueStr appendString:@",?"];
            id value = [model valueForKey:property.name];
            if (value) {
                //数组、字典、模型对象转json字符串存储
                if ([self _isKeyTypeValidateJSON:type]) {
                    NSString *jsonStr = [self _switchValue:value toJSON:type];
                    [argumentsArr addObject:jsonStr ?:@""];
                } else {
                    [argumentsArr addObject:value];
                }
            } else {
                [argumentsArr addObject:@""];
            }
        }];
        if (!successed) {
            return successed;
        }
    }
    NSString *sql = [NSString stringWithFormat:@"%@(%@) VALUES (%@)",sql1,keyStr,valueStr];
    
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withArgumentsInArray:argumentsArr]) {
            successed = NO;
        }
    }];
    return successed;
}

+ (NSMutableArray *)ly_selectFromDBWithTableName:(NSString *)tableName category:(NSString *)category {
    return [self ly_selectFromDBWithTableName:tableName category:category filter:nil];
}

+ (NSMutableArray *)ly_selectFromDBWithTableName:(NSString *)tableName category:(NSString *)category filter:(NSString *)filter {
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@%@",tableName,category];
    if (filter.length) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@%@ %@",tableName,category,filter];
    }
    if (![self ly_createTableName:tableName category:category]) {
        return nil;
    }
    NSArray *propertyArr = [self ly_getPropertyList:tableName];
    __block NSMutableArray *arr = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:sql];
        while ([set next]) {
            id obj = [[NSClassFromString(tableName) alloc] init];
            for (int i = 0; i < propertyArr.count; i++) {
                MJProperty *property = propertyArr[i];
                MJPropertyType *type = property.type;
                NSString *columnStr = [set stringForColumn:property.name];
                if (columnStr.length) {
                    if ([self _isKeyTypeValidateJSON:type]) {
                        id value = [self _switchValidateJSON:columnStr
                                                        type:type];
                        [obj setValue:value forKey:property.name];
                    } else {
                        [obj setValue:columnStr forKey:property.name];
                    }
                }
            }
            [arr addObject:obj];
        }
    }];
    return arr;
}

+ (BOOL)ly_updateDBWithModel:(NSObject *)model category:(NSString *)category propertyName:(NSString *)propertyName {
    return [self ly_updateDBWithModel:model tableName:nil category:category propertyName:propertyName];
}

+ (BOOL)ly_updateDBWithModel:(NSObject *)model tableName:(NSString *)tableName category:(NSString *)category propertyName:(NSString *)propertyName {
    if (!model) { return NO; }
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    className = (tableName == nil) ? className : tableName;
    tableName = [className stringByAppendingString:category];
    NSArray *propertyArr = [self ly_getPropertyList:className];
    NSArray *allowedProperties = [model.class ly_FMDBAllowedPropertyNames];
    NSString *sql1 = [NSString stringWithFormat:@"UPDATE %@%@ SET ",className,category];
    __block NSMutableString *key = [NSMutableString string];
    __block NSMutableArray *argumentsArr = [NSMutableArray array];
    __block BOOL successed = YES;
    for (int i = 0; i < propertyArr.count; i++) {
        __block MJProperty *property = propertyArr[i];
        __block MJPropertyType *type = property.type;
        if (![allowedProperties containsObject:property.name]) {
            continue;
        }
        [_queue inDatabase:^(FMDatabase *db) {
            if (![db columnExists:property.name inTableWithName:tableName]) {
                NSString *alterStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",tableName,property.name];
                BOOL added = [db executeUpdate:alterStr];
                if (!added) {
                    successed = NO;
                }
            }
            NSUInteger length = key.length;
            (!length)?[key appendFormat:@"%@=?",property.name]:[key appendFormat:@",%@=?",property.name];
            id value = [model valueForKey:property.name];
            if (value) {
                if ([self _isKeyTypeValidateJSON:type]) {
                    NSString *jsonStr = [self _switchValue:value toJSON:type];
                    [argumentsArr addObject:jsonStr ?:@""];
                } else {
                    [argumentsArr addObject:value];
                }
            } else {
                [argumentsArr addObject:@""];
            }
        }];
        if (!successed) {
            return successed;
        }
    }
    __block NSString *updateName = @"";
    if (propertyName.length > 0 && [model valueForKey:propertyName]) {
        updateName = propertyName;
        [argumentsArr addObject:[model valueForKey:updateName]];
    } else {
        [propertyArr enumerateObjectsUsingBlock:^(MJProperty *property, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![allowedProperties containsObject:property.name]) {
                return;
            }
            if ([model valueForKey:property.name]) {
                updateName = property.name;
                [argumentsArr addObject:[model valueForKey:property.name]];
                *stop = YES;
            }
        }];
    }
    NSString * sql = [NSString stringWithFormat:@"%@%@ WHERE %@=?",sql1,key,updateName];
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withArgumentsInArray:argumentsArr]) {
            successed = NO;
        }
    }];
    return successed;
}

+ (BOOL)ly_deleteDBWithModel:(NSObject *)model category:(NSString *)category propertyName:(NSString *)propertyName {
    return [self ly_deleteDBWithModel:model tableName:nil category:category propertyName:propertyName];
}

+ (BOOL)ly_deleteDBWithModel:(NSObject *)model tableName:(NSString *)tableName category:(NSString *)category propertyName:(NSString *)propertyName {
    if (!model) { return NO; }
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    className = (tableName == nil) ? className : tableName;
    NSArray *propertyArr = [self ly_getPropertyList:className];
    __block NSString *updateName = @"";
    __block BOOL successed = YES;
    if (propertyName.length > 0) {
        updateName = propertyName;
    } else {
        [propertyArr enumerateObjectsUsingBlock:^(MJProperty *property, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model valueForKey:property.name]) {
                [_queue inDatabase:^(FMDatabase *db) {
                    if ([db columnExists:property.name inTableWithName:className]) {
                        updateName = property.name;
                        *stop = YES;
                    }
                }];
            }
        }];
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@%@ WHERE %@=?",className,category,updateName];
    NSString *updateValue = @"";
    if ([model valueForKey:updateName]) {
        updateValue = [model valueForKey:updateName];
    }
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql,updateValue]) {
            LYFMDBManagerLog(@"delete error");
            successed = NO;
        }
    }];
    return successed;
}

/**
 获取模型的所有属性名、属性类型
 */
+ (NSMutableArray *)ly_getPropertyList:(NSString *)className
{
    unsigned int outCount;
    Class class = NSClassFromString(className);
    NSMutableArray *propertyArr = [NSMutableArray array];
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (int i = 0; i < outCount; i++) {
        MJProperty *mjProperty = [MJProperty cachedPropertyWithProperty:properties[i]];
        [propertyArr addObject:mjProperty];
    }
    free(properties);
    return propertyArr;
}

#pragma mark - Private

/**
 判断key对应的值是否可以被json格式化，如果可以需要转化为json格式字符串存储
 */
+ (BOOL)_isKeyTypeValidateJSON:(MJPropertyType *)type {
    //数组、字典、模型对象可以被格式化为json字符串
    if ([NSString ly_isKeyTypeArrayClass:type.code]
        || [NSString ly_isKeyTypeDictionaryClass:type.code]
        || (!type.isFromFoundation && type.typeClass)) {
        return YES;
    }
    return NO;
}
/**
 将字典、数组或者模型对象转换为json字符串
 */
+ (NSString *)_switchValue:(id)value toJSON:(MJPropertyType *)type {
    if ([NSString ly_isKeyTypeArrayClass:type.code]
        || [NSString ly_isKeyTypeDictionaryClass:type.code]) {
        return [NSString ly_objectToJSON:value];
    } else if (!type.isFromFoundation && type.typeClass) {
        return [[value mj_keyValues] mj_JSONString];
    } else {
        return @"";
    }
}

/**
 将json字符串转换为字典、数组或者模型对象
 */
+ (id)_switchValidateJSON:(NSString *)jsonStr type:(MJPropertyType *)type {
    id value = [jsonStr mj_JSONObject];
    if (!type.isFromFoundation && type.typeClass) {
        //模型对象，做映射处理
        if ([NSString ly_isKeyTypeArrayClass:type.code]) {
            //数组
            value = [type.typeClass mj_keyValuesArrayWithObjectArray:value];
        } else {
            value = [type.typeClass mj_objectWithKeyValues:value];
        }
    }
    return value;
}

@end
