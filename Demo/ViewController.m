//
//  ViewController.m
//  Demo
//
//  Created by William Towe on 6/2/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
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

#import "ViewController.h"
#import "UIBarButtonItem+DemoExtensions.h"

#import <KSOToken/KSOToken.h>
#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>

#import <Contacts/Contacts.h>

@interface CompletionModel : NSObject <KSOTokenCompletionModel>
@property (strong,nonatomic) CNContact *contact;

- (instancetype)initWithContact:(CNContact *)contact substring:(NSString *)substring;
@end

@implementation CompletionModel

- (NSString *)tokenCompletionModelTitle {
    return [CNContactFormatter stringFromContact:self.contact style:CNContactFormatterStyleFullName];
}

- (instancetype)initWithContact:(CNContact *)contact substring:(NSString *)substring {
    if (!(self = [super init]))
        return nil;
    
    _contact = contact;
    
    return self;
}

@end

@interface ViewController () <KSOTokenTextViewDelegate>
@property (strong,nonatomic) KSOTokenTextView *textView;

@property (strong,nonatomic) CNContactStore *contactStore;
@end

@implementation ViewController

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (NSString *)title {
    return @"Contacts";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColor.whiteColor];
    
    [self setTextView:[[KSOTokenTextView alloc] initWithFrame:CGRectZero]];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setScrollEnabled:NO];
    [self.textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textView setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.textView setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.textView setTextContentType:UITextContentTypeEmailAddress];
    [self.textView setPlaceholder:@"Type a contact name then comma or return"];
    [self.textView setDelegate:self];
    [self.view addSubview:self.textView];
    
    [NSObject KDI_registerDynamicTypeObject:self.textView forTextStyle:UIFontTextStyleBody];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]" options:0 metrics:nil views:@{@"view": self.textView, @"top": self.topLayoutGuide}]];
    
    [self setContactStore:[[CNContactStore alloc] init]];
    
    [self.navigationItem setRightBarButtonItems:@[[UIBarButtonItem iosd_changeTintColorBarButtonItemWithViewController:self],[UIBarButtonItem KDI_barButtonSystemItem:UIBarButtonSystemItemCompose block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        NSRange tokenRange;
        if (![self.textView tokenizeTextAndGetTokenRange:&tokenRange]) {
            [self.textView setSelectedRange:tokenRange];
        }
    }]]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (NSArray<id<KSOTokenRepresentedObject>> *)tokenTextView:(KSOTokenTextView *)tokenTextView shouldAddRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects atIndex:(NSInteger)index {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    for (id<KSOTokenRepresentedObject> object in representedObjects) {
        if ([object.tokenRepresentedObjectDisplayName containsString:@"@"]) {
            [retval addObject:[object.tokenRepresentedObjectDisplayName stringByAppendingString:@","]];
        }
    }
    
    if (retval.count == 0) {
        [UIAlertController KDI_presentAlertControllerWithTitle:nil message:@"Enter a valid email address!" cancelButtonTitle:nil otherButtonTitles:nil completion:nil];
    }
    
    return retval;
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
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        void(^fetchBlock)(void) = ^{
            NSArray *contacts = [self.contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactsMatchingName:substring] keysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactEmailAddressesKey] error:NULL];
            NSMutableArray *completionModels = [[NSMutableArray alloc] init];
            
            for (CNContact *c in contacts) {
                if (c.emailAddresses.count == 0) {
                    continue;
                }
                
                [completionModels addObject:[[CompletionModel alloc] initWithContact:c substring:substring]];
            }
            
            completion(completionModels);
        };
        
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
            fetchBlock();
        }
        else {
            [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    fetchBlock();
                }
            }];
        }
    });
}
- (NSArray<id<KSOTokenRepresentedObject>> *)tokenTextView:(KSOTokenTextView *)tokenTextView representedObjectsForCompletionModel:(id<KSOTokenCompletionModel>)completionModel {
    if ([completionModel isKindOfClass:CompletionModel.class]) {
        return [[(CompletionModel *)completionModel contact].emailAddresses valueForKey:@"value"];
    }
    else {
        return @[completionModel.tokenCompletionModelTitle];
    }
}

@end
