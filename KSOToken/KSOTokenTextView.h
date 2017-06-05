//
//  KSOTokenTextView.h
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

#import <Ditko/KDITextView.h>
#import <KSOToken/KSOTokenRepresentedObject.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KSOTokenTextViewDelegate;

/**
 KSOTokenTextView mirrors the functionality provided by NSTokenField on macOS.
 */
@interface KSOTokenTextView : KDITextView

/**
 Set and get the delegate of the receiver.
 
 @see KSOTokenTextViewDelegate
 */
@property (weak,nonatomic,nullable) id<KSOTokenTextViewDelegate,UITextViewDelegate> delegate;

/**
 Set and get the represented objects of the receiver.
 
 These can either be NSString objects or custom model objects. If custom model objects are provided, the delegate should implement `tokenTextView:representedObjectForEditingText:`.
 */
@property (copy,nonatomic,nullable) NSArray<id<KSOTokenRepresentedObject> > *representedObjects;

/**
 Set and get the character set used to delimit tokens.
 
 The default is [NSCharacterSet characterSetWithCharactersInString:@","] unioned with [NSCharacterSet newlineCharacterSet].
 */
@property (copy,nonatomic,null_resettable) NSCharacterSet *tokenizingCharacterSet;
/**
 Set and get the NSTextAttachment class name used to draw tokens.
 
 The default is @"KSOTokenDefaultTextAttachment".
 */
@property (copy,nonatomic,null_resettable) NSString *tokenTextAttachmentClassName UI_APPEARANCE_SELECTOR;
/**
 Set and get the completion delay of the receiver.
 
 The default is 0.0.
 */
@property (assign,nonatomic) NSTimeInterval completionDelay;

/**
 Set and get the typing font of the receiver. Set this instead of the font of the receiver.
 
 The default is [UIFont systemFontOfSize:17.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *typingFont UI_APPEARANCE_SELECTOR;
/**
 Set and get the typing text color of the receiver. Set this instead of the text color of the receiver.
 
 The default is UIColor.blackColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *typingTextColor UI_APPEARANCE_SELECTOR;

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
 @return The filtered array of represented objects, return an empty array to prevent adding represented objects
 */
- (NSArray<id<KSOTokenRepresentedObject> > *)tokenTextView:(KSOTokenTextView *)tokenTextView shouldAddRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject> > *)representedObjects atIndex:(NSInteger)index;
/**
 Called when an array of represented objects are added to the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were added
 @param index The first index of the represented objects that were added
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView didAddRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject> > *)representedObjects atIndex:(NSInteger)index;

/**
 Called when an array of represented objects are removed from the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were removed
 @param index The first index of the represented objects that were removed
 */
- (BOOL)tokenTextView:(KSOTokenTextView *)tokenTextView shouldRemoveRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject> > *)representedObjects atIndex:(NSInteger)index;
/**
 Called when an array of represented objects are removed from the receiver at the provided index.
 
 @param tokenTextView The token text view that sent the message
 @param representedObjects The array of represented objects that were removed
 @param index The first index of the represented objects that were removed
 */
- (void)tokenTextView:(KSOTokenTextView *)tokenTextView didRemoveRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject> > *)representedObjects atIndex:(NSInteger)index;

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
- (BOOL)tokenTextView:(KSOTokenTextView *)tokenTextView writeRepresentedObjects:(NSArray<id<KSOTokenRepresentedObject> > *)representedObjects pasteboard:(UIPasteboard *)pasteboard;
/**
 Called when the paste: command is chosen from the context menu. The delegate should return an array of represented objects created by reading data from pasteboard. If this method is not implemented, the token text view will read the array of strings stored on the pasteboard and create represented objects from them.
 
 @param tokenTextView The token text view that sent the message
 @param pasteboard The pasteboard to read from
 @return An array of represented objects created by reading from pasteboard
 */
- (nullable NSArray<id<KSOTokenRepresentedObject> > *)tokenTextView:(KSOTokenTextView *)tokenTextView readFromPasteboard:(UIPasteboard *)pasteboard;

@end

NS_ASSUME_NONNULL_END
