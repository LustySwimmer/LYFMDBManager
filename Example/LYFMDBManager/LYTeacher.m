//
//  LYTeacher.m
//  LYFMDBManager_Example
//
//  Created by Jacky on 2018/3/1.
//  Copyright © 2018年 lvshi. All rights reserved.
//

#import "LYTeacher.h"
#import <LYFMDBManager/LYFMDBManager.h>
#import <MJExtension/MJExtension.h>

@implementation LYTeacher

+ (NSArray *)ly_FMDBAllowedPropertyNames {
    return @[@"name",
             @"age",
             @"teacherId",
             @"students",
             @"money",
             @"height",
             @"tags",
             @"dic"];
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"students" : @"LYStudent"};
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[
             @"position"
             ];
}

@end
