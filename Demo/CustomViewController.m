//
//  CustomViewController.m
//  KSOToken
//
//  Created by William Towe on 6/6/17.
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

#import "CustomViewController.h"
#import "UIBarButtonItem+DemoExtensions.h"

#import <KSOToken/KSOToken.h>
#import <Ditko/Ditko.h>

@interface TokenTextAttachment : KSOTokenDefaultTextAttachment

@end

@implementation TokenTextAttachment

- (instancetype)initWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text tokenTextView:(KSOTokenTextView *)tokenTextView {
    if (!(self = [super initWithRepresentedObject:representedObject text:text tokenTextView:tokenTextView]))
        return nil;
    
    [self setRespondsToTintColorChanges:NO];
    [self setTokenTextColor:tokenTextView.textColor];
    [self setTokenBackgroundColor:tokenTextView.tintColor];
    [self setTokenHighlightedTextColor:tokenTextView.tintColor];
    [self setTokenHighlightedBackgroundColor:tokenTextView.textColor];
    [self setTokenCornerRadius:3.0];
    self.tokenEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    
    return self;
}

@synthesize tintColor=_tintColor;
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    
    [self setTokenBackgroundColor:tintColor];
    [self setTokenHighlightedTextColor:tintColor];
}

@end

@interface CompletionTableViewCell : KSOTokenDefaultCompletionTableViewCell

@end

@implementation CompletionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;
    
    [self setBackgroundColor:UIColor.blackColor];
    [self setTitleTextColor:UIColor.whiteColor];
    
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview != nil) {
        [self setHighlightBackgroundColor:[self.superview.tintColor colorWithAlphaComponent:0.75]];
    }
}

@end

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
//    _indexes = [indexes copy];
    
    return self;
}

@end

@interface CustomViewController () <KSOTokenTextViewDelegate>
@property (strong,nonatomic) KSOTokenTextView *textView;

@property (copy,nonatomic) NSArray<NSString *> *words;
@property (strong,nonatomic) dispatch_semaphore_t wordsSemaphore;
@end

@implementation CustomViewController

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (NSString *)title {
    return @"Words";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setWordsSemaphore:dispatch_semaphore_create(0)];
    
    [self.view setBackgroundColor:UIColor.blackColor];
    
    [self setTextView:[[KSOTokenTextView alloc] initWithFrame:CGRectZero]];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setScrollEnabled:NO];
    [self.textView setBackgroundColor:UIColor.blackColor];
    [self.textView setTextColor:UIColor.whiteColor];
    [self.textView setTokenTextAttachmentClass:TokenTextAttachment.class];
    [self.textView setCompletionsTableViewCellClass:CompletionTableViewCell.class];
    [self.textView setPlaceholder:@"Type a word then comma or return"];
    [self.textView setDelegate:self];
    [self.view addSubview:self.textView];
    
    [NSObject KDI_registerDynamicTypeObject:self.textView forTextStyle:UIFontTextStyleBody];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]" options:0 metrics:nil views:@{@"view": self.textView, @"top": self.topLayoutGuide}]];
    
    [self.navigationItem setRightBarButtonItems:@[[UIBarButtonItem iosd_changeTintColorBarButtonItemWithViewController:self]]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)tokenTextView:(KSOTokenTextView *)tokenTextView showCompletionsTableView:(UITableView *)tableView {
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [tableView setBackgroundColor:UIColor.blackColor];
    [tableView setSeparatorColor:UIColor.whiteColor];
    [self.view addSubview:tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview][view][bottom]" options:0 metrics:nil views:@{@"view": tableView, @"subview": self.textView, @"bottom": self.bottomLayoutGuide}]];
}
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView hideCompletionsTableView:(UITableView *)tableView {
    [tableView removeFromSuperview];
}
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView completionModelsForSubstring:(NSString *)substring indexOfRepresentedObject:(NSInteger)index completion:(void (^)(NSArray<id<KSOTokenCompletionModel>> * _Nullable))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            if (self.words == nil) {
                NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"words" withExtension:@"txt"] options:NSDataReadingMappedIfSafe error:NULL];
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                [self setWords:[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
            }
            
            dispatch_semaphore_signal(self.wordsSemaphore);
        });
        
        dispatch_semaphore_wait(self.wordsSemaphore, DISPATCH_TIME_FOREVER);
        
        NSMutableArray *models = [[NSMutableArray alloc] init];
        
        for (NSString *word in self.words) {
            NSRange range = [word rangeOfString:substring options:NSCaseInsensitiveSearch];
            
            if (range.length == 0) {
                continue;
            }
            
            [models addObject:[[WordCompletion alloc] initWithWord:word indexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
        }
        
        completion(models);
    });
}

@end
