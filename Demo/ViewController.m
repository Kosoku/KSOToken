//
//  ViewController.m
//  Demo
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

#import "ViewController.h"

#import <KSOToken/KSOToken.h>

#import <Contacts/Contacts.h>

@interface CompletionModel : NSObject <KSOTokenCompletionModel>
@property (strong,nonatomic) CNContact *contact;
@property (assign,nonatomic) NSRange range;

- (instancetype)initWithContact:(CNContact *)contact substring:(NSString *)substring;
@end

@implementation CompletionModel

- (NSString *)tokenCompletionModelTitle {
    NSMutableArray *strs = [NSMutableArray arrayWithArray:@[self.contact.givenName,self.contact.middleName,self.contact.familyName]];
    
    for (NSString *s in [strs copy]) {
        if (s.length == 0) {
            [strs removeObject:s];
        }
    }
    
    return [[strs componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSRange)tokenCompletionModelRange {
    return self.range;
}

- (instancetype)initWithContact:(CNContact *)contact substring:(NSString *)substring {
    if (!(self = [super init]))
        return nil;
    
    _contact = contact;
    _range = [self.tokenCompletionModelTitle rangeOfString:substring options:NSCaseInsensitiveSearch];
    
    return self;
}

@end

@interface ViewController () <KSOTokenTextViewDelegate>
@property (strong,nonatomic) KSOTokenTextView *textView;

@property (strong,nonatomic) CNContactStore *contactStore;
@end

@implementation ViewController

- (NSString *)title {
    return @"Contacts";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColor.whiteColor];
    
    [self setTextView:[[KSOTokenTextView alloc] initWithFrame:CGRectZero]];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setScrollEnabled:NO];
    [self.textView setPlaceholder:@"Type a name then comma or return"];
    [self.textView setDelegate:self];
    [self.view addSubview:self.textView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]" options:0 metrics:nil views:@{@"view": self.textView, @"top": self.topLayoutGuide}]];
    
    [self setContactStore:[[CNContactStore alloc] init]];
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
    void(^fetchBlock)(void) = ^{
        NSArray *contacts = [self.contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactsMatchingName:substring] keysToFetch:@[CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey] error:NULL];
        NSMutableArray *completionModels = [[NSMutableArray alloc] init];
        
        for (CNContact *c in contacts) {
            [completionModels addObject:[[CompletionModel alloc] initWithContact:c substring:substring]];
        }
        
        completion(completionModels);
    };
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            fetchBlock();
        });
    }
    else {
        [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                fetchBlock();
            }
        }];
    }
}

@end
