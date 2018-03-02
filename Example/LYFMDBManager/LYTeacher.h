//
//  LYTeacher.h
//  LYFMDBManager_Example
//
//  Created by Jacky on 2018/3/1.
//  Copyright © 2018年 lvshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYStudent;
@interface LYTeacher : NSObject

@property (nonatomic, copy) NSString *teacherId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *age;

@property (nonatomic, strong) NSArray <LYStudent *>*students;

@property (nonatomic, assign) long money;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGRect position;

@property (nonatomic, copy) NSArray *tags;

@property (nonatomic, copy) NSDictionary *dic;

@end
