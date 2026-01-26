//
//  CustomCollectionViewCell.h
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)configureWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
