//
//  CustomViewController.m
//  KSOToken
//
//  Created by William Towe on 6/6/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "CustomViewController.h"

#import <KSOToken/KSOToken.h>

@interface WordCompletion : NSObject <KSOTokenCompletionModel>
@property (copy,nonatomic) NSString *word;
@property (copy,nonatomic) NSIndexSet *indexes;

- (instancetype)initWithWord:(NSString *)word indexes:(NSIndexSet *)indexes;
@end

@implementation WordCompletion

- (NSString *)tokenCompletionModelTitle {
    return self.word;
}
- (NSIndexSet *)tokenCompletionModelIndexes {
    return self.indexes;
}

- (instancetype)initWithWord:(NSString *)word indexes:(NSIndexSet *)indexes {
    if (!(self = [super init]))
        return nil;
    
    _word = [word copy];
    _indexes = [indexes copy];
    
    return self;
}

@end

@interface CustomViewController () <KSOTokenTextViewDelegate>
@property (strong,nonatomic) KSOTokenTextView *textView;

@property (copy,nonatomic) NSArray<NSString *> *words;
@end

@implementation CustomViewController

- (NSString *)title {
    return @"Words";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColor.whiteColor];
    
    [self setTextView:[[KSOTokenTextView alloc] initWithFrame:CGRectZero]];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setScrollEnabled:NO];
    [self.textView setPlaceholder:@"Type a word then comma or return"];
    [self.textView setDelegate:self];
    [self.view addSubview:self.textView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]" options:0 metrics:nil views:@{@"view": self.textView, @"top": self.topLayoutGuide}]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)tokenTextView:(KSOTokenTextView *)tokenTextView showCompletionsTableView:(UITableView *)tableView {
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview][view]|" options:0 metrics:nil views:@{@"view": tableView, @"subview": self.textView}]];
}
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView hideCompletionsTableView:(UITableView *)tableView {
    [tableView removeFromSuperview];
}
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView completionModelsForSubstring:(NSString *)substring indexOfRepresentedObject:(NSInteger)index completion:(void (^)(NSArray<id<KSOTokenCompletionModel>> * _Nullable))completion {
    if (substring.length <= 1) {
        completion(nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (self.words == nil) {
            NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"words" withExtension:@"txt"] options:NSDataReadingMappedIfSafe error:NULL];
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [self setWords:[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        }
        
        NSMutableString *pattern = [[NSMutableString alloc] init];
        
        for (NSUInteger i=0; i<substring.length; i++) {
            NSString *ss = [NSRegularExpression escapedPatternForString:[substring substringWithRange:NSMakeRange(i, 1)]];
            
            [pattern appendFormat:@"[^%@]*(%@)",ss,ss];
        }
        
        [pattern appendString:@".*"];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
        NSMutableArray *models = [[NSMutableArray alloc] init];
        
        for (NSString *word in self.words) {
            NSTextCheckingResult *result = [regex firstMatchInString:word options:0 range:NSMakeRange(0, word.length)];
            
            if (result == nil) {
                continue;
            }
            
            NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
            
            for (NSUInteger i=1; i<result.numberOfRanges; i++) {
                [indexes addIndexesInRange:[result rangeAtIndex:i]];
            }
            
            [models addObject:[[WordCompletion alloc] initWithWord:word indexes:indexes]];
        }
        
        completion(models);
    });
}

@end
