//
//  HeightCache.h
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeightCache : NSObject

- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCache;
- (void)invalidateCacheForIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
