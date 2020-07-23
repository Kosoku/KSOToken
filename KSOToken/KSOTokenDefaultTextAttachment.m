//
//  KSOTokenDefaultTextAttachment.m
//  KSOToken
//
//  Created by William Towe on 6/2/17.
//  Copyright © 2020 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "KSOTokenDefaultTextAttachment.h"
#import "KSOTokenTextView.h"

#import <Stanley/KSTGeometryFunctions.h>
#import <Stanley/KSTScopeMacros.h>

static void *kObservingContext = &kObservingContext;

@interface KSOTokenDefaultTextAttachment ()
@property (readwrite,weak,nonatomic) KSOTokenTextView *tokenTextView;
@property (readwrite,strong,nonatomic) id<KSOTokenRepresentedObject> representedObject;
@property (copy,nonatomic) NSString *text;
@property (strong,nonatomic) UIImage *highlightedImage;

- (void)_updateImages;
- (void)_updateImage:(BOOL)highlighted maxWidth:(CGFloat)maxWidth;
- (UIFont *)_defaultTokenFont;
- (UIColor *)_defaultTokenTextColor;
+ (UIColor *)_defaultTokenBackgroundColor;
+ (UIColor *)_defaultTokenHighlightedTextColor;
- (UIColor *)_defaultTokenHighlightedBackgroundColor;
- (UIColor *)_defaultTokenDisabledTextColor;
+ (UIColor *)_defaultTokenDisabledBackgroundColor;
+ (CGFloat)_defaultTokenCornerRadius;
@end

@implementation KSOTokenDefaultTextAttachment

- (void)dealloc {
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenFont) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenBackgroundColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedBackgroundColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenDisabledTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenDisabledBackgroundColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenCornerRadius) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenEdgeInsets) context:kObservingContext];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    return NSLocationInRange(charIndex, self.tokenTextView.selectedRange) ? self.highlightedImage : self.image;
}
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect retval = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    retval.origin.y = ceil(self.tokenFont.descender);
    
    return retval;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kObservingContext) {
        [self _updateImages];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (instancetype)initWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text tokenTextView:(KSOTokenTextView *)tokenTextView; {
    if (!(self = [super initWithData:nil ofType:nil]))
        return nil;
    
    NSParameterAssert(representedObject != nil);
    NSParameterAssert(tokenTextView != nil);
    
    _representedObject = representedObject;
    _tokenTextView = tokenTextView;
    _text = [text copy];
    
    _respondsToTintColorChanges = YES;
    _tokenFont = [self _defaultTokenFont];
    _tokenTextColor = [self _defaultTokenTextColor];
    _tokenBackgroundColor = [self.class _defaultTokenBackgroundColor];
    _tokenHighlightedTextColor = [self.class _defaultTokenHighlightedTextColor];
    _tokenHighlightedBackgroundColor = [self _defaultTokenHighlightedBackgroundColor];
    _tokenDisabledTextColor = [self _defaultTokenDisabledTextColor];
    _tokenDisabledBackgroundColor = [self.class _defaultTokenDisabledBackgroundColor];
    _tokenCornerRadius = [self.class _defaultTokenCornerRadius];
    
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenFont) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenBackgroundColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedBackgroundColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenDisabledTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenDisabledBackgroundColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenCornerRadius) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenEdgeInsets) options:0 context:kObservingContext];
    
    [self _updateImages];
    
    return self;
}

@dynamic enabled;
- (BOOL)isEnabled {
    return self.tokenTextView.isUserInteractionEnabled;
}
- (void)setEnabled:(BOOL)enabled {
    [self _updateImages];
}
@dynamic font;
- (UIFont *)font {
    return self.tokenFont;
}
- (void)setFont:(UIFont *)font {
    [self setTokenFont:font];
}
@dynamic tintColor;
- (UIColor *)tintColor {
    return self.tokenTextView.tintColor;
}
- (void)setTintColor:(UIColor *)tintColor {
    if (!self.respondsToTintColorChanges) {
        return;
    }
    
    [self setTokenTextColor:tintColor];
    [self setTokenHighlightedBackgroundColor:tintColor];
}

- (void)setTokenFont:(UIFont *)tokenFont {
    _tokenFont = tokenFont ?: [self _defaultTokenFont];
}
- (void)setTokenTextColor:(UIColor *)tokenTextColor {
    _tokenTextColor = tokenTextColor ?: [self _defaultTokenTextColor];
}
- (void)setTokenBackgroundColor:(UIColor *)tokenBackgroundColor {
    _tokenBackgroundColor = tokenBackgroundColor ?: [self.class _defaultTokenBackgroundColor];
}
- (void)setTokenHighlightedTextColor:(UIColor *)tokenHighlightedTextColor {
    _tokenHighlightedTextColor = tokenHighlightedTextColor ?: [self.class _defaultTokenHighlightedTextColor];
}
- (void)setTokenHighlightedBackgroundColor:(UIColor *)tokenHighlightedBackgroundColor {
    _tokenHighlightedBackgroundColor = tokenHighlightedBackgroundColor ?: [self _defaultTokenHighlightedBackgroundColor];
}
- (void)setTokenDisabledTextColor:(UIColor *)tokenDisabledTextColor {
    _tokenDisabledTextColor = tokenDisabledTextColor ?: [self _defaultTokenDisabledTextColor];
}
- (void)setTokenDisabledBackgroundColor:(UIColor *)tokenDisabledBackgroundColor {
    _tokenDisabledBackgroundColor = tokenDisabledBackgroundColor ?: [self.class _defaultTokenDisabledBackgroundColor];
}

- (void)_updateImages {
    CGFloat maxWidth = CGRectGetWidth(self.tokenTextView.frame);
    
    if (isnan(maxWidth) ||
        maxWidth <= 0.0) {
        
        maxWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    }
    
    [self _updateImage:NO maxWidth:maxWidth];
    [self _updateImage:YES maxWidth:maxWidth];
}
- (void)_updateImage:(BOOL)highlighted maxWidth:(CGFloat)maxWidth; {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName: self.tokenFont}];
    CGRect rect = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    
    rect.size.width += self.tokenEdgeInsets.left + self.tokenEdgeInsets.right;
    rect.size.height += self.tokenEdgeInsets.top + self.tokenEdgeInsets.bottom;
    
    if (CGRectGetWidth(rect) > maxWidth) {
        rect.size.width = maxWidth;
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    UIColor *color = self.tokenBackgroundColor;
    
    if (highlighted) {
        color = self.tokenHighlightedBackgroundColor;
    }
    else if (!self.isEnabled) {
        color = self.tokenDisabledBackgroundColor;
    }
    
    [color setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 2.0, 1.0) cornerRadius:self.tokenCornerRadius] fill];
    
    UIFont *drawFont = self.tokenFont;
    CGSize drawSize = [self.text sizeWithAttributes:@{NSFontAttributeName: drawFont}];
    
    if (drawSize.width > CGRectGetWidth(rect)) {
        drawSize.width = CGRectGetWidth(rect) - (self.tokenEdgeInsets.left + self.tokenEdgeInsets.right);
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [style setAlignment:NSTextAlignmentCenter];
    
    if (highlighted) {
        color = self.tokenHighlightedTextColor;
    }
    else if (!self.isEnabled) {
        color = self.tokenDisabledTextColor;
    }
    else {
        color = self.tokenTextColor;
    }
    
    [self.text drawInRect:KSTCGRectCenterInRect(CGRectMake(0, 0, drawSize.width, drawSize.height), rect) withAttributes:@{NSFontAttributeName: drawFont, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: style}];
    
    UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (highlighted) {
        [self setHighlightedImage:retval];
    }
    else {
        [self setImage:retval];
    }
}

- (UIFont *)_defaultTokenFont; {
    return self.tokenTextView.font;
}
- (UIColor *)_defaultTokenTextColor; {
    return self.tokenTextView.tintColor;
}
+ (UIColor *)_defaultTokenBackgroundColor; {
    return UIColor.clearColor;
}
+ (UIColor *)_defaultTokenHighlightedTextColor; {
    return UIColor.whiteColor;
}
- (UIColor *)_defaultTokenHighlightedBackgroundColor; {
    return self.tokenTextView.tintColor;
}
- (UIColor *)_defaultTokenDisabledTextColor; {
    return self.tokenTextView.textColor;
}
+ (UIColor *)_defaultTokenDisabledBackgroundColor; {
    return UIColor.clearColor;
}
+ (CGFloat)_defaultTokenCornerRadius; {
    return 0.0;
}

@end
