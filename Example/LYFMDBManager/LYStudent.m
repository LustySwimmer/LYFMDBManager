//
//  LYStudent.m
//  LYFMDBManager_Example
//
//  Created by LustySwimmer on 2018/3/1.
//  Copyright © 2018年 LustySwimmer. All rights reserved.
//

#import "LYStudent.h"
#import <LYFMDBManager/LYFMDBManager.h>
#import <MJExtension/MJExtension.h>

@implementation LYStudent

+ (NSArray *)ly_FMDBAllowedPropertyNames {
    return @[@"name",
             @"age",
             @"studentId",
             @"studentType",
             @"money",
             @"point",
             @"tags",
             @"dic",
             @"position"];
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[
             @"position"
             ];
}
@end
