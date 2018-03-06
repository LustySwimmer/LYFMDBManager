//
//  LYStudent.h
//  LYFMDBManager_Example
//
//  Created by LustySwimmer on 2018/3/1.
//  Copyright © 2018年 LustySwimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LYStudentType) {
    LYStudentTypeFirst,
    LYStudentTypeSecond,
    LYStudentTypeThird
};

@interface LYStudent : NSObject

@property (nonatomic, copy) NSString *studentId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *age;

@property (nonatomic, assign) LYStudentType studentType;

@property (nonatomic, assign) long money;

@property (nonatomic, assign) CGFloat point;

@property (nonatomic, assign) CGRect position;

@property (nonatomic, copy) NSArray *tags;

@property (nonatomic, copy) NSDictionary *dic;

@end
