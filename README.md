# LYFMDBManager

[![CI Status](http://img.shields.io/travis/lvshi/LYFMDBManager.svg?style=flat)](https://travis-ci.org/lvshi/LYFMDBManager)
[![Version](https://img.shields.io/cocoapods/v/LYFMDBManager.svg?style=flat)](http://cocoapods.org/pods/LYFMDBManager)
[![License](https://img.shields.io/cocoapods/l/LYFMDBManager.svg?style=flat)](http://cocoapods.org/pods/LYFMDBManager)
[![Platform](https://img.shields.io/cocoapods/p/LYFMDBManager.svg?style=flat)](http://cocoapods.org/pods/LYFMDBManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How to use it

You should use it based on model, such as:
```ruby
//Insert
for (LYTeacher *teacher in self.teachers) {
        [LYFMDBTool ly_insertDBWithModel:teacher category:FMDB_TEACHER];
}

//Delete
[LYFMDBTool ly_deleteDBWithModel:teacher
                                           category:FMDB_TEACHER
                                       propertyName:@"teacherId"];

//Update
LYTeacher *teacher = self.teachers[arc4random_uniform(20)];
teacher.name = [teacher.name stringByAppendingString:@"updated"];
BOOL success = [LYFMDBTool ly_updateDBWithModel:teacher
                                           category:FMDB_TEACHER
                                       propertyName:@"teacherId"];

//Select
NSArray *result = [LYFMDBTool ly_selectFromDBWithTableName:NSStringFromClass([LYTeacher class]) category:FMDB_TEACHER];

//Filter Select
NSString *filter = @"ORDER BY teacherId DESC LIMIT 10";
    NSArray *result = [LYFMDBTool ly_selectFromDBWithTableName:NSStringFromClass([LYTeacher class]) category:FMDB_TEACHER filter:filter];
```

## Warning
You shouldn't use properties that can't be converted to json string, and as NSUInteger is not supported by Sqlite, you should use NSInteger or NSString instead.

## Requirements

## Installation

LYFMDBManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LYFMDBManager'
```

## License

LYFMDBManager is available under the MIT license. See the LICENSE file for more info.
