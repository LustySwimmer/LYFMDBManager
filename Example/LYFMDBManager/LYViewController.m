//
//  LYViewController.m
//  LYFMDBManager
//
//  Created by LustySwimmer on 03/01/2018.
//  Copyright (c) 2018 LustySwimmer. All rights reserved.
//

#import "LYViewController.h"
#import <LYFMDBManager/LYFMDBManager.h>
#import "LYTeacher.h"
#import "LYStudent.h"

#define FMDB_TEACHER @"teacher"

@interface LYViewController ()

@property (nonatomic, strong) NSArray *teachers;

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (IBAction)insert {
    for (LYTeacher *teacher in self.teachers) {
        [LYFMDBTool ly_insertDBWithModel:teacher category:FMDB_TEACHER];
    }
}

- (IBAction)update {
    LYTeacher *teacher = self.teachers[arc4random_uniform(20)];
    teacher.name = [teacher.name stringByAppendingString:@"updated"];
    BOOL success = [LYFMDBTool ly_updateDBWithModel:teacher
                                           category:FMDB_TEACHER
                                       propertyName:@"teacherId"];
    if (success) {
        NSLog(@"更新成功");
    }
}

- (IBAction)delete {
    LYTeacher *teacher = self.teachers[arc4random_uniform(20)];
    BOOL success = [LYFMDBTool ly_deleteDBWithModel:teacher
                                           category:FMDB_TEACHER
                                       propertyName:@"teacherId"];
    if (success) {
        NSLog(@"删除成功");
    }
}

- (IBAction)select {
    NSArray *result = [LYFMDBTool ly_selectFromDBWithTableName:NSStringFromClass([LYTeacher class]) category:FMDB_TEACHER];
    NSLog(@"%@",result);
}

- (IBAction)filterSelect {
    NSString *filter = @"ORDER BY teacherId DESC LIMIT 10";
    NSArray *result = [LYFMDBTool ly_selectFromDBWithTableName:NSStringFromClass([LYTeacher class]) category:FMDB_TEACHER filter:filter];
    NSLog(@"%@",result);
}
#pragma mark - Lazy
- (NSArray *)teachers {
    if (_teachers == nil) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            LYStudent *student = [LYStudent new];
            student.studentId = [NSString stringWithFormat:@"%zd",10 + i];
            student.name = [NSString stringWithFormat:@"student_%d",i];
            student.age = i % 2 == 0 ? @"16" : @"18";
            student.point = arc4random_uniform(100);
            student.position = CGRectMake(1.0, 1.0, 2.0, 3.0);
            LYTeacher *teacher = [LYTeacher new];
            teacher.teacherId = [NSString stringWithFormat:@"%d",100 + i];
            teacher.money = 200 + arc4random_uniform(5000);
            teacher.height = 165 + arc4random_uniform(30);
            teacher.name = [NSString stringWithFormat:@"teacher_%d",i];
            teacher.students = @[student,student,student];
            teacher.position = CGRectMake(2.0, 3.0, 3.0, 2.0);
            [array addObject:teacher];
        }
        _teachers = array.copy;
    }
    return _teachers;
}

@end
