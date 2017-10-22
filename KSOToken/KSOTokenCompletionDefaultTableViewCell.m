//
//  KSOTokenCompletionDefaultTableViewCell.m
//  KSOToken
//
//  Created by William Towe on 6/5/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOTokenCompletionDefaultTableViewCell.h"

#import <Stanley/KSTScopeMacros.h>

static void *kObservingContext = &kObservingContext;

@interface KSOTokenCompletionDefaultTableViewCell ()
@property (strong,nonatomic) UILabel *titleLabel;

@property (copy,nonatomic) NSArray<NSLayoutConstraint *> *activeConstraints;

- (void)_updateTitleLabel;

+ (UIFont *)_defaultTitleFont;
+ (UIColor *)_defaultTitleTextColor;
+ (UIColor *)_defaultHighlightedBackgroundColor;
@end

@implementation KSOTokenCompletionDefaultTableViewCell

- (void)dealloc {
    [self removeObserver:self forKeyPath:@kstKeypath(self,titleFont) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,titleTextColor) context:kObservingContext];
    [self removeObserver:self forKeyPath:@kstKeypath(self,highlightBackgroundColor) context:kObservingContext];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;
    
    _titleFont = [self.class _defaultTitleFont];
    _titleTextColor = [self.class _defaultTitleTextColor];
    _highlightBackgroundColor = [self.class _defaultHighlightedBackgroundColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:_titleLabel];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(>=height@priority)]" options:0 metrics:@{@"height": @44.0, @"priority": @(UILayoutPriorityDefaultHigh)} views:@{@"view": self.contentView}]];
    
    [self addObserver:self forKeyPath:@kstKeypath(self,titleFont) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,titleTextColor) options:0 context:kObservingContext];
    [self addObserver:self forKeyPath:@kstKeypath(self,highlightBackgroundColor) options:0 context:kObservingContext];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kObservingContext) {
        [self _updateTitleLabel];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)updateConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": _titleLabel}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=top-[view]->=bottom-|" options:0 metrics:@{@"top": @(self.layoutMargins.top), @"bottom": @(self.layoutMargins.bottom)} views:@{@"view": _titleLabel}]];
    
    [self setActiveConstraints:constraints];
    
    [super updateConstraints];
}

- (void)layoutMarginsDidChange {
    [super layoutMarginsDidChange];
    
    [self setNeedsUpdateConstraints];
}

+ (CGFloat)estimatedRowHeight {
    return 44.0;
}

@synthesize completionModel=_completionModel;
- (void)setCompletionModel:(id<KSOTokenCompletionModel>)completionModel {
    _completionModel = completionModel;
    
    [self _updateTitleLabel];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont ?: [self.class _defaultTitleFont];
}
- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor ?: [self.class _defaultTitleTextColor];
}
- (void)setHighlightBackgroundColor:(UIColor *)highlightBackgroundColor {
    _highlightBackgroundColor = highlightBackgroundColor ?: [self.class _defaultHighlightedBackgroundColor];
}

- (void)_updateTitleLabel; {
    if (self.completionModel == nil) {
        return;
    }
    
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:self.completionModel.tokenCompletionModelTitle attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0], NSForegroundColorAttributeName: self.titleTextColor}];
    
    if ([self.completionModel respondsToSelector:@selector(tokenCompletionModelIndexes)]) {
        [self.completionModel.tokenCompletionModelIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
            [temp addAttributes:@{NSBackgroundColorAttributeName: self.highlightBackgroundColor} range:range];
        }];
    }
    else if ([self.completionModel respondsToSelector:@selector(tokenCompletionModelRange)]) {
        [temp addAttributes:@{NSBackgroundColorAttributeName: self.highlightBackgroundColor} range:self.completionModel.tokenCompletionModelRange];
    }
    
    [self.titleLabel setAttributedText:temp];
}

+ (UIFont *)_defaultTitleFont; {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIColor *)_defaultTitleTextColor; {
    return UIColor.blackColor;
}
+ (UIColor *)_defaultHighlightedBackgroundColor; {
    return UIColor.yellowColor;
}

- (void)setActiveConstraints:(NSArray<NSLayoutConstraint *> *)activeConstraints {
    [NSLayoutConstraint deactivateConstraints:_activeConstraints];
    
    _activeConstraints = activeConstraints;
    
    [NSLayoutConstraint activateConstraints:_activeConstraints];
}

@end
