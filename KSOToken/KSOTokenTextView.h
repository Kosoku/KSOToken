//
//  KSOTokenTextView.h
//  KSOToken
//
//  Created by William Towe on 6/2/17.
//  Copyright © 2021 Kosoku Interactive, LLC. All rights reserved.
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

#import <Ditko/KDITextView.h>
#import <KSOToken/KSOTokenRepresentedObject.h>
#import <KSOToken/KSOTokenCompletionModel.h>
#import <KSOToken/KSOTokenTextAttachment.h>
#import <KSOToken/KSOTokenCompletionTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KSOTokenTextViewDelegate;

/**
 KSOTokenTextView mirrors the functionality provided by NSTokenField on macOS.
 */
@interface KSOTokenTextView : KDITextView <UITextViewDelegate>

/**
 Set and get the delegate of the receiver.
 
 @see KSOTokenTextViewDelegate
 */
@property (weak,nonatomic,nullable) id<KSOTokenTextViewDelegate,UITextViewDelegate> delegate;

/**
 Set and get the represented objects of the receiver.
 
 These can either be NSString objects or custom model objects. If the client is using custom model objects, the delegate should implement `tokenTextView:representedObjectForEditingText:` and provide them.
 */
@property (copy,nonatomic,nullable) NSArray<id<KSOTokenRepresentedObject>> *representedObjects;

/**
 Set and get the character set used to delimit tokens.
 
 The default is the union of [NSCharacterSet characterSetWithCharactersInString:@","] and [NSCharacterSet newlineCharacterSet].
 */
@property (copy,nonatomic,null_resettable) NSCharacterSet *tokenizingCharacterSet;
/**
 Set and get the NSTextAttachment class name used to draw tokens. This should be a class that conforms to the KSOTokenTextAttachment protocol.
 
 The default is KSOTokenDefaultTextAttachment.class.
 */
@property (strong,nonatomic,null_resettable) Class<KSOTokenTextAttachment> tokenTextAttachmentClass;
/**
 Set and get the completion delay of the receiver.
 
 The default is 0.0.
 */
@property (assign,nonatomic) NSTimeInterval completionsDelay;
/**
 Set and get the completion table view class of the receiver. This must be a subclass of UITableView.
 
 The default is UITableView.class.
 */
@property (strong,nonatomic,null_resettable) Class completionsTableViewClass;
/**
 Set and get the completion table view cell class of the receiver. This must be the class of an object conforming to KSOTokenCompletionTableViewCell.
 
 The default is KSOTokenDefaultCompletionTableViewCell.class.
 */
@property (strong,nonatomic,null_resettable) Class<KSOTokenCompletionTableViewCell> completionsTableViewCellClass;

/**
 Returns whether the completions table view is currently showing. This can be used to determine when to call showCompletionsTableView and hideCompletionsTableView to manually control display of the completions table view.
 */
@property (readonly,nonatomic,getter=isCompletionsTableViewShowing) BOOL completionsTableViewShowing;

/**
 Attempts to tokenize the text at the selectedRange of the receiver. Returns YES, if the text was tokenized, otherwise NO. Returns by reference the range of text for which tokenization was attempted.
 
 @param tokenRange A pointer to the range of text for which tokenization was attempted
 @return YES if the text was tokenized, otherwise NO
 */
- (BOOL)tokenizeTextAndGetTokenRange:(nullable NSRangePointer)tokenRange;
/**
 Returns the token range for the selectedRange of the receiver, but does not attempt to tokenize it. This could be used to highlight the token range after an error, for example. If you want to force the receiver to attempt tokenization of its text, use tokenizeTextAndGetTokenRange: instead. This returns an NSRange with length == 0 on failure.
 
 @return The token range for the selectedRange
 */
- (NSRange)tokenRangeForSelectedRange;

/**
 Manually show the completions table view for the selected range of the receiver. If the required delegate methods are not implemented, this method does nothing.
 */
- (void)showCompletionsTableView;
/**
 Manually hide the completions table view without selecting a completion model. Calls through to hideCompletionsTableViewAndSelectCompletionModel: passing nil.
 */
- (void)hideCompletionsTableView;
/**
 Manually hide the completions table view and select the provided *completionModel* if non-nil. If the required delegate methods are not implemented, this method does nothing.
 
 @param completionModel The completion model to select
 */
- (void)hideCompletionsTableViewAndSelectCompletionModel:(nullable id<KSOTokenCompletionModel>)completionModel;

/**
 Reload the completions table view independent of the user typing. This will call the relevant delegate methods to get the completions for display. If the completions table view is not visible, this method does nothing.
 */
- (void)reloadCompletionsTableView;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_REQUIRES_SUPER;
- (void)textViewDidChange:(UITextView *)textView NS_REQUIRES_SUPER;
- (void)textViewDidChangeSelection:(UITextView *)textView NS_REQUIRES_SUPER;

@end

@protocol KSOTokenTextViewDelegate <UITextViewDelegate>
@optional
/**
 Return the represented object for the current editing text. If this method is not implemented or returns nil, the editing text is used as the represented object.
 
 @param tokenTextView The token text view that sent the message
 @param editingText The current editing text
 @return The represented object for editing text
 */
- (nullable id<KSOTokenRepresentedObject>)tokenTextView:(KSOTokenTextView *)tokenTextView representedObjectForEditingText:(NSString *)editingText;

/**
 Return the filtered array of represented objects from the array of provided represented objects that should be added to the token text view.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The representedObjects that will be added to the token text view
 @param index The index in the receiver's represented objects array that the new represented objects will be inserted
 @return The filtered array of represented objects, return nil or an empty array to prevent adding represented objects
 */
- (nullable NSArray<id<KSOTokenRepresentedObject>> *)tokenTextView:(KSOTokenTextView *)tokenTextView shouldAddRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects atIndex:(NSInteger)index;
/**
 Called when an array of represented objects are added to the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were added
 @param index The first index of the represented objects that were added
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView didAddRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects atIndex:(NSInteger)index;

/**
 Called when an array of represented objects are removed from the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were removed
 @param index The first index of the represented objects that were removed
 */
- (BOOL)tokenTextView:(KSOTokenTextView *)tokenTextView shouldRemoveRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects atIndex:(NSInteger)index;
/**
 Called when an array of represented objects are removed from the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were removed
 @param index The first index of the represented objects that were removed
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView didRemoveRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects atIndex:(NSInteger)index;

/**
 Called to determine which editing commands should be displayed by the receiver. The action parameter represents the relevant command (e.g. cut:, copy:, paste:).
 
 @param tokenTextView The token text view that sent the message
 @param action The action to perform
 @param sender The object asking to perform action
 @return YES if the token text can perform action, NO otherwise
 */
- (BOOL)tokenTextView:(KSOTokenTextView *)tokenTextView canPerformAction:(SEL)action withSender:(nullable id)sender;

/**
 Called when the cut: or copy: commands are chosen from the context menu. The delegate should return YES if it intends to handle the writing of the represented objects to the pasteboard. Otherwise, return NO and the token text view will write the display string for each represented object to the pasteboard.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that should be written to the pasteboard
 @param pasteboard The pasteboard to write to
 @return YES if the delegate handled writing to the pasteboard, NO otherwise
 */
- (BOOL)tokenTextView:(KSOTokenTextView *)tokenTextView writeRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject>> *)representedObjects pasteboard:(UIPasteboard *)pasteboard;
/**
 Called when the paste: command is chosen from the context menu. The delegate should return an array of represented objects created by reading data from pasteboard. If this method is not implemented, the token text view will read the array of strings stored on the pasteboard and create represented objects from them.
 
 @param tokenTextView The token text view that sent the message
 @param pasteboard The pasteboard to read from
 @return An array of represented objects created by reading from pasteboard
 */
- (nullable NSArray<id<KSOTokenRepresentedObject>> *)tokenTextView:(KSOTokenTextView *)tokenTextView readFromPasteboard:(UIPasteboard *)pasteboard;

/**
 Return YES if the completion table view should be shown, otherwise NO. If this method returns YES or is not implemented tokenTextView:showCompletionsTableView: is called to actually display the table view.
 
 @param tokenTextView The token text that sent the message
 @return YES if the completion table view should be shown, otherwise NO
 */
- (BOOL)tokenTextViewShouldShowCompletionsTableView:(KSOTokenTextView *)tokenTextView;
/**
 Called when the receiver's delegate should display the completions table view.
 
 The provided table view should be inserted into the view hierarchy and its frame set accordingly.
 
 @param tokenTextView The token text view that sent the message
 @param tableView The completions table view
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView showCompletionsTableView:(UITableView *)tableView;
/**
 Called when the receiver's delegate should hide the completions table view.
 
 The provided table view should be removed from the view hierarchy.
 
 @param tokenTextView The token text view that sent the message
 @param tableView The completions table view
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView hideCompletionsTableView:(UITableView *)tableView;
/**
 Return the possible completions, which should be an array of objects conforming to KSOTokenCompletionModel, for the provided substring and index.
 
 @param tokenTextView The token text view that sent the message
 @param substring The substring to provide completions for
 @param index The index of the represented object where the completion would be inserted
 @return An array of objects conforming to KSOTokenCompletionModel
 */
- (nullable NSArray<id<KSOTokenCompletionModel>> *)tokenTextView:(KSOTokenTextView *)tokenTextView completionModelsForSubstring:(NSString *)substring indexOfRepresentedObject:(NSInteger)index;
/**
 Determine the possible completions, which should be an array of objects conforming to KSOTokenCompletionModel, for the provided substring and index and invoke the completion block. If this method is implemented, it is preferred over tokenTextView:completionModelsForSubstring:indexOfRepresentedObject:.
 
 @param tokenTextView The token text view that sent the message
 @param substring The substring to provide completions for
 @param index The index of the represented object where the completion would be inserted
 @param completion The completion block to invoke with the array of completion model objects
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView completionModelsForSubstring:(NSString *)substring indexOfRepresentedObject:(NSInteger)index completion:(void(^)(NSArray<id<KSOTokenCompletionModel>> * _Nullable completionModels))completion;
/**
 Return whether the completions table view should be hidden if no completions were provided from either tokenTextView:completionModelsForSubstring:indexOfRepresentedObject: or tokenTextView:completionModelsForSubstring:indexOfRepresentedObject:completion:. If this method is not implemented or returns YES the tokenTextView:hideCompletionsTableView: method will be called to hide the completions table view.
 
 @param tokenTextView The token text view that sent the message
 @return Whether the completions table view should be hidden for an empty array of completion models
 */
- (BOOL)tokenTextViewShouldHideCompletionsTableViewForEmptyCompletionModels:(KSOTokenTextView *)tokenTextView;
/**
 Return the desired leading swipe actions configuration for the provided completion model. If you return nil no leading actions will be displayed on swipe of the row. If this method is not implemented a nil return value is assumed.
 
 @param tokenTextView The token text view that sent the message
 @param completionModel The completion model for which to return the leading swipe actions configuration
 @return The swipe actions configuration or nil
 */
- (nullable UISwipeActionsConfiguration *)tokenTextView:(KSOTokenTextView *)tokenTextView leadingSwipeActionsConfigurationForCompletionModel:(id<KSOTokenCompletionModel>)completionModel;
/**
 Return the desired trailing swipe actions configuration for the provided completion model. If you return nil no trailing actions will be displayed on swipe of the row. If this method is not implemented a nil return value is assumed.
 
 @param tokenTextView The token text view that sent the message
 @param completionModel The completion model for which to return the trailing swipe actions configuration
 @return The swipe actions configuration or nil
 */
- (nullable UISwipeActionsConfiguration *)tokenTextView:(KSOTokenTextView *)tokenTextView trailingSwipeActionsConfigurationForCompletionModel:(id<KSOTokenCompletionModel>)completionModel;
/**
 Called when the tableView:willDisplayCell:forRowAtIndexPath: method is called on the managed completion table view. The delegate can use this to perform any last minute customizations on the cell before being displayed.
 
 @param tokenTextView The token text view that sent the message
 @param completionTableViewCell The completion table view cell
 @param completionModel The completion model
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView willDisplayCompletionTableViewCell:(__kindof UITableViewCell<KSOTokenCompletionTableViewCell> *)completionTableViewCell completionModel:(id<KSOTokenCompletionModel>)completionModel;
/**
 Called when the user selects a row in the completions table view. This method should return the corresponding represented object for the selected completion object.
 
 @param tokenTextView The token text view that sent the message
 @param completionModel The completion model that was selected
 @return The represented object for the selected completion
 */
- (NSArray<id<KSOTokenRepresentedObject>> *)tokenTextView:(KSOTokenTextView *)tokenTextView representedObjectsForCompletionModel:(id<KSOTokenCompletionModel>)completionModel;

@end

NS_ASSUME_NONNULL_END
