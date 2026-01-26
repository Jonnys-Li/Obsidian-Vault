//
//  DataModel.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "DataModel.h"

@implementation DataModel

+ (instancetype)modelWithTitle:(NSString *)title content:(NSString *)content {
    DataModel *model = [[DataModel alloc] init];
    model.title = title;
    model.content = content;
    model.cellType = CellTypeText;
    return model;
}

@end
