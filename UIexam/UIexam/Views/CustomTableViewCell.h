//
//  CustomTableViewCell.h
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DataModel;

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, assign) NSInteger cellNumber; // 用于演示Cell重用

- (void)configureWithModel:(DataModel *)model;

@end

NS_ASSUME_NONNULL_END
