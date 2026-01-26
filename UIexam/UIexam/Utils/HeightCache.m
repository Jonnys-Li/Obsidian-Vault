//
//  HeightCache.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "HeightCache.h"

@interface HeightCache ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *cache;

@end

@implementation HeightCache

- (instancetype)init {
    if (self = [super init]) {
        _cache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self keyForIndexPath:indexPath];
    self.cache[key] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self keyForIndexPath:indexPath];
    NSNumber *cachedHeight = self.cache[key];
    return cachedHeight ? [cachedHeight floatValue] : 0;
}

- (void)invalidateCache {
    [self.cache removeAllObjects];
}

- (void)invalidateCacheForIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self keyForIndexPath:indexPath];
    [self.cache removeObjectForKey:key];
}

- (NSString *)keyForIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
}

@end
