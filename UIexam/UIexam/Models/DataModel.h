//
//  DataModel.h
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeText,
    CellTypeImage,
    CellTypeVideo
};

@interface DataModel : NSObject

@property (nonatomic, assign) CellType cellType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) CGFloat cellHeight;

+ (instancetype)modelWithTitle:(NSString *)title content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
