//
//  KSOTokenDefaultTextAttachment.m
//  KSOToken
//
//  Created by William Towe on 6/2/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
+ (CGFloat)_defaultTokenCornerRadius;
@end

@implementation KSOTokenDefaultTextAttachment

- (void)dealloc {
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenFont) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenBackgroundColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedBackgroundColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,tokenCornerRadius) context:kObservingContext];
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
    
    _tokenFont = [self _defaultTokenFont];
    _tokenTextColor = [self _defaultTokenTextColor];
    _tokenBackgroundColor = [self.class _defaultTokenBackgroundColor];
    _tokenHighlightedTextColor = [self.class _defaultTokenHighlightedTextColor];
    _tokenHighlightedBackgroundColor = [self _defaultTokenHighlightedBackgroundColor];
    _tokenCornerRadius = [self.class _defaultTokenCornerRadius];
    
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenFont) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenBackgroundColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenHighlightedBackgroundColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,tokenCornerRadius) options:0 context:kObservingContext];
    
    [self _updateImages];
    
    return self;
}

@dynamic font;
- (UIFont *)font {
    return self.tokenFont;
}
- (void)setFont:(UIFont *)font {
    [self setTokenFont:font];
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

- (void)_updateImages {
    CGFloat maxWidth = CGRectGetWidth(self.tokenTextView.frame);
    
    [self _updateImage:NO maxWidth:maxWidth];
    [self _updateImage:YES maxWidth:maxWidth];
}
- (void)_updateImage:(BOOL)highlighted maxWidth:(CGFloat)maxWidth; {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName: self.tokenFont}];
    
    CGRect rect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    CGFloat delta = 4.0;
    
    rect.size.width += delta;
    
    if (CGRectGetWidth(rect) > maxWidth) {
        rect.size.width = maxWidth;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect)), NO, 0);
    
    [highlighted ? self.tokenHighlightedBackgroundColor : self.tokenBackgroundColor setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 2.0, 1.0) cornerRadius:self.tokenCornerRadius] fill];
    
    UIFont *drawFont = self.tokenFont;
    CGSize drawSize = [self.text sizeWithAttributes:@{NSFontAttributeName: drawFont}];
    
    if (drawSize.width > CGRectGetWidth(rect)) {
        drawSize.width = CGRectGetWidth(rect) - delta;
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [style setAlignment:NSTextAlignmentCenter];
    
    [self.text drawInRect:KSTCGRectCenterInRect(CGRectMake(0, 0, drawSize.width, drawSize.height), rect) withAttributes:@{NSFontAttributeName: drawFont, NSForegroundColorAttributeName: highlighted ? self.tokenHighlightedTextColor : self.tokenTextColor, NSParagraphStyleAttributeName: style}];
    
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
+ (CGFloat)_defaultTokenCornerRadius; {
    return 0.0;
}

@end
