//
//  CustomHitTestView.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "CustomHitTestView.h"

@implementation CustomHitTestView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hitTestExpansion = 20; // 默认扩大20点
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 扩大点击区域
    CGRect expandedBounds = CGRectInset(self.bounds, -self.hitTestExpansion, -self.hitTestExpansion);
    
    // 判断点是否在扩大后的区域内
    if (CGRectContainsPoint(expandedBounds, point)) {
        // 先检查子视图
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [self convertPoint:point toView:subview];
            UIView *hitView = [subview hitTest:convertedPoint withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
        // 如果没有子视图响应，返回自己
        return self;
    }
    
    // 点不在扩大后的区域内，返回nil
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // 扩大点击区域
    CGRect expandedBounds = CGRectInset(self.bounds, -self.hitTestExpansion, -self.hitTestExpansion);
    return CGRectContainsPoint(expandedBounds, point);
}

@end
