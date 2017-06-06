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

@interface KSOTokenDefaultTextAttachment ()
@property (readwrite,weak,nonatomic) KSOTokenTextView *tokenTextView;
@property (readwrite,strong,nonatomic) id<KSOTokenRepresentedObject> representedObject;
@property (copy,nonatomic) NSString *text;
@property (strong,nonatomic) UIImage *highlightedImage;

- (void)_updateImage:(BOOL)highlighted maxWidth:(CGFloat)maxWidth;
@end

@implementation KSOTokenDefaultTextAttachment

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    return NSLocationInRange(charIndex, self.tokenTextView.selectedRange) ? self.highlightedImage : self.image;
}
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect retval = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    retval.origin.y = ceil(self.tokenFont.descender);
    
    return retval;
}

- (instancetype)initWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text tokenTextView:(KSOTokenTextView *)tokenTextView; {
    if (!(self = [super initWithData:nil ofType:nil]))
        return nil;
    
    NSParameterAssert(representedObject != nil);
    NSParameterAssert(tokenTextView != nil);
    
    _representedObject = representedObject;
    _tokenTextView = tokenTextView;
    _text = [text copy];
    
    _tokenFont = _tokenTextView.typingFont;
    _tokenTextColor = _tokenTextView.tintColor;
    _tokenBackgroundColor = UIColor.clearColor;
    _tokenHighlightedTextColor = UIColor.whiteColor;
    _tokenHighlightedBackgroundColor = _tokenTextView.tintColor;
    _tokenCornerRadius = 3.0;
    
    CGFloat maxWidth = CGRectGetWidth(tokenTextView.frame);
    
    [self _updateImage:NO maxWidth:maxWidth];
    [self _updateImage:YES maxWidth:maxWidth];
    
    return self;
}

- (void)_updateImage:(BOOL)highlighted maxWidth:(CGFloat)maxWidth; {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName: self.tokenFont}];
    
    CGRect rect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    CGFloat delta = 6.0;
    
    rect.size.width += delta;
    
    if (CGRectGetWidth(rect) > maxWidth) {
        rect.size.width = maxWidth;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect)), NO, 0);
    
    [highlighted ? self.tokenHighlightedBackgroundColor : self.tokenBackgroundColor setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 2.0, 1.0) cornerRadius:self.tokenCornerRadius] fill];
    
    UIFont *drawFont = [UIFont fontWithName:self.tokenFont.fontName size:self.tokenFont.pointSize];
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

@end
