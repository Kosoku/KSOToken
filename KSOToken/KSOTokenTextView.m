//
//  KSOTokenTextView.m
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

#import "KSOTokenTextView.h"
#import "KSOTokenDefaultTextAttachment.h"
#import "KSOTokenDefaultCompletionTableViewCell.h"
#import "KSOTokenCompletionOperation.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

#import <objc/runtime.h>

@interface KSOTokenTextViewGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>
@property (copy,nonatomic) NSArray *gestureRecognizers;
@property (weak,nonatomic) UITextView *textView;

- (instancetype)initWithGestureRecognizers:(NSArray *)gestureRecognizers textView:(UITextView *)textView;
@end

@implementation KSOTokenTextViewGestureRecognizerDelegate
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [self.gestureRecognizers containsObject:gestureRecognizer] && self.textView.text.length > 0;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [self.gestureRecognizers containsObject:gestureRecognizer] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [self.gestureRecognizers containsObject:gestureRecognizer];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithGestureRecognizers:(NSArray *)gestureRecognizers textView:(UITextView *)textView; {
    if (!(self = [super init]))
        return nil;
    
    _gestureRecognizers = [gestureRecognizers copy];
    _textView = textView;
    
    for (UIGestureRecognizer *gr in _gestureRecognizers) {
        [gr setDelegate:self];
    }
    
    return self;
}
@end

@interface KSOTokenTextViewInternalDelegate : NSObject <KSOTokenTextViewDelegate>
@property (weak,nonatomic) id<KSOTokenTextViewDelegate> delegate;
@property (assign,nonatomic) unsigned int delegateMethodsCount;
@property (assign,nonatomic) struct objc_method_description *delegateMethods;
@end

@implementation KSOTokenTextViewInternalDelegate

- (void)dealloc {
    free(_delegateMethods);
}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _delegateMethods = protocol_copyMethodDescriptionList(@protocol(KSOTokenTextViewDelegate), NO, YES, &_delegateMethodsCount);
    
    return self;
}

// does the real delegate respond to the selector and is the selector part of the UITextFieldDelegate protocol
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        for (unsigned int i=0; i<self.delegateMethodsCount; i++) {
            if (self.delegateMethods[i].name == aSelector) {
                return YES;
            }
        }
        return NO;
    }
    return [super respondsToSelector:aSelector];
}
// only forward if the selector is part of the UITextField protocol
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        for (unsigned int i=0; i<self.delegateMethodsCount; i++) {
            if (self.delegateMethods[i].name == aSelector) {
                return self.delegate;
            }
        }
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retval = [(id<UITextViewDelegate>)textView textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (retval &&
        [self.delegate respondsToSelector:_cmd]) {
        
        retval = [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    return retval;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [(id<UITextViewDelegate>)textView textViewDidChangeSelection:textView];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate textViewDidChangeSelection:textView];
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    [(id<UITextViewDelegate>)textView textViewDidChange:textView];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate textViewDidChange:textView];
    }
}

@end

@interface KSOTokenTextView () <UITextViewDelegate,NSTextStorageDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) KSOTokenTextViewInternalDelegate *internalDelegate;
@property (strong,nonatomic) KSOTokenTextViewGestureRecognizerDelegate *gestureRecognizerDelegate;

@property (copy,nonatomic) NSIndexSet *selectedTextAttachmentRanges;

@property (strong,nonatomic) UITableView *tableView;
@property (copy,nonatomic) NSArray<id<KSOTokenCompletionModel> > *completionModels;
@property (strong,nonatomic) NSOperationQueue *completionOperationQueue;

- (void)_KSOTokenTextViewInit;

- (BOOL)_tokenizeTextInRange:(NSRange)range tokenRange:(NSRangePointer)tokenRange;
- (NSRange)_tokenRangeForRange:(NSRange)range;
- (NSUInteger)_indexOfTokenTextAttachmentInRange:(NSRange)range textAttachment:(id<KSOTokenTextAttachment> *)textAttachment;
- (NSArray *)_copyTokenTextAttachmentsInRange:(NSRange)range;
- (NSTextAttachment<KSOTokenTextAttachment> *)_textAttachmentWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text;

- (void)_showCompletionsTableView;
- (void)_hideCompletionsTableViewAndSelectCompletionModel:(id<KSOTokenCompletionModel>)completionModel;

+ (NSCharacterSet *)_defaultTokenizingCharacterSet;
+ (Class<KSOTokenTextAttachment>)_defaultTokenTextAttachmentClass;
+ (NSTimeInterval)_defaultCompletionDelay;
+ (Class<KSOTokenCompletionTableViewCell>)_defaultCompletionTableViewCellClass;
+ (UIColor *)_defaultTextColor;
@end

@implementation KSOTokenTextView
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (!(self = [super initWithFrame:frame textContainer:textContainer]))
        return nil;
    
    [self _KSOTokenTextViewInit];
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _KSOTokenTextViewInit];
    
    return self;
}
#pragma mark -
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tokenTextView:canPerformAction:withSender:)]) {
        return [self.delegate tokenTextView:self canPerformAction:action withSender:sender];
    }
    return [super canPerformAction:action withSender:sender];
}
#pragma mark -
- (void)cut:(id)sender {
    NSRange range = self.selectedRange;
    NSArray *representedObjects = [self _copyTokenTextAttachmentsInRange:range];
    
    if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldRemoveRepresentedObjects:atIndex:)]) {
        NSInteger index = [self _indexOfTokenTextAttachmentInRange:range textAttachment:NULL];
        
        if (![self.delegate tokenTextView:self shouldRemoveRepresentedObjects:representedObjects atIndex:index]) {
            return;
        }
    }
    
    [self.textStorage deleteCharactersInRange:range];
    
    [self setSelectedRange:NSMakeRange(range.location, 0)];
    
    [self textViewDidChangeSelection:self];
    
    if ([self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.delegate textViewDidChangeSelection:self];
    }
    
    [self textViewDidChange:self];
    
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
    
    if (representedObjects.count > 0) {
        if ([self.delegate respondsToSelector:@selector(tokenTextView:didRemoveRepresentedObjects:atIndex:)]) {
            NSInteger index = [self _indexOfTokenTextAttachmentInRange:range textAttachment:NULL];
            
            [self.delegate tokenTextView:self didRemoveRepresentedObjects:representedObjects atIndex:index];
        }
    }
}
- (void)copy:(id)sender {
    [self _copyTokenTextAttachmentsInRange:self.selectedRange];
}
- (void)paste:(id)sender {
    NSArray *representedObjects;
    NSInteger index = [self _indexOfTokenTextAttachmentInRange:self.selectedRange textAttachment:NULL];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if ([self.delegate respondsToSelector:@selector(tokenTextView:readFromPasteboard:)]) {
        representedObjects = [self.delegate tokenTextView:self readFromPasteboard:pasteboard];
    }
    else {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        NSCharacterSet *characterSet = self.tokenizingCharacterSet;
        
        for (NSString *string in pasteboard.strings) {
            for (NSString *subString in [string componentsSeparatedByCharactersInSet:characterSet]) {
                NSString *tokenText = [subString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                id representedObject = tokenText;
                
                if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectForEditingText:)]) {
                    representedObject = [self.delegate tokenTextView:self representedObjectForEditingText:tokenText];
                }
                
                [temp addObject:representedObject];
            }
        }
        
        if (temp.count > 0) {
            if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)]) {
                representedObjects = [self.delegate tokenTextView:self shouldAddRepresentedObjects:temp atIndex:index];
            }
            else {
                representedObjects = temp;
            }
        }
    }
    
    if (representedObjects.count > 0) {
        NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
        
        // loop through each represented object and ask the delegate for the display text for each one
        for (id<KSOTokenRepresentedObject> representedObject in representedObjects) {
            NSString *displayText = representedObject.tokenRepresentedObjectDisplayName;
            
            [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[self _textAttachmentWithRepresentedObject:representedObject text:displayText]]];
        }
        
        NSMutableArray *deletedRepresentedObjects = [[NSMutableArray alloc] init];
        
        if (self.selectedRange.length > 0) {
            [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:self.selectedRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id<KSOTokenTextAttachment> _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                if (value.representedObject != nil) {
                    [deletedRepresentedObjects addObject:value.representedObject];
                }
            }];
        }
        
        NSRange newSelectedRange = NSMakeRange(self.selectedRange.location + temp.length, 0);
        
        // replace all characters in token range with the text attachments
        [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:temp];
        
        [self setSelectedRange:newSelectedRange];
        
        // hide the completion table view if it was visible
        [self _hideCompletionsTableViewAndSelectCompletionModel:nil];
        
        if ([self.delegate respondsToSelector:@selector(tokenTextView:didAddRepresentedObjects:atIndex:)]) {
            [self.delegate tokenTextView:self didAddRepresentedObjects:representedObjects atIndex:index];
        }
        
        if (deletedRepresentedObjects.count > 0) {
            if ([self.delegate respondsToSelector:@selector(tokenTextView:didRemoveRepresentedObjects:atIndex:)]) {
                [self.delegate tokenTextView:self didRemoveRepresentedObjects:deletedRepresentedObjects atIndex:MAX(0, index - 1)];
            }
        }
    }
}
#pragma mark -
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value respondsToSelector:@selector(setTintColor:)]) {
            [value setTintColor:self.tintColor];
        }
    }];
}
#pragma mark -
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value respondsToSelector:@selector(setFont:)]) {
            [value setFont:self.font];
        }
    }];
}
- (UIColor *)textColor {
    return [super textColor] ?: [self.class _defaultTextColor];
}
- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor ?: [self.class _defaultTextColor]];
}
#pragma mark NSTextStorageDelegate
- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    // fix up our attributes so that everything, including the attachments, use our desired font and text color
    [textStorage addAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor} range:editedRange];
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:self.tokenizingCharacterSet].length > 0) {
        [self _tokenizeTextInRange:range tokenRange:NULL];
        return NO;
    }
    // delete
    else if (text.length == 0) {
        if (self.text.length > 0) {
            NSMutableArray *representedObjects = [[NSMutableArray alloc] init];
            
            // enumerate text attachments in the range to be deleted and add their represented object to the array
            [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id<KSOTokenTextAttachment> value, NSRange range, BOOL *stop) {
                if (value) {
                    [representedObjects addObject:value.representedObject];
                }
            }];
            
            if (representedObjects.count > 0) {
                NSInteger index = [self _indexOfTokenTextAttachmentInRange:range textAttachment:NULL];
                
                if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldRemoveRepresentedObjects:atIndex:)] &&
                    ![self.delegate tokenTextView:self shouldRemoveRepresentedObjects:representedObjects atIndex:index]) {
                    
                    return NO;
                }
            }
            
            NSAttributedString *temp = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
            
            [self.textStorage replaceCharactersInRange:range withAttributedString:temp];
            
            [self setSelectedRange:NSMakeRange(range.location, 0)];
            
            [self textViewDidChangeSelection:self];
            
            if ([self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
                [self.delegate textViewDidChangeSelection:self];
            }
            
            [self textViewDidChange:self];
            
            if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
                [self.delegate textViewDidChange:self];
            }
            
            // if there are text attachments, call tokenTextView:didRemoveRepresentedObjects:atIndex: if its implemented
            if (representedObjects.count > 0) {
                if ([self.delegate respondsToSelector:@selector(tokenTextView:didRemoveRepresentedObjects:atIndex:)]) {
                    NSInteger index = [self _indexOfTokenTextAttachmentInRange:range textAttachment:NULL];
                    
                    [self.delegate tokenTextView:self didRemoveRepresentedObjects:representedObjects atIndex:index];
                }
            }
            
            return NO;
        }
    }
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self setTypingAttributes:@{NSFontAttributeName: self.font,
                                NSForegroundColorAttributeName: self.textColor}];
    
    if (self.selectedRange.length == 0) {
        [self setSelectedTextAttachmentRanges:nil];
    }
    else {
        NSMutableIndexSet *temp = [[NSMutableIndexSet alloc] init];
        
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:self.selectedRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                [temp addIndexesInRange:range];
            }
        }];
        
        [self setSelectedTextAttachmentRanges:temp];
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showCompletionsTableView) object:nil];
    
    [self performSelector:@selector(_showCompletionsTableView) withObject:nil afterDelay:self.completionDelay];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.completionModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<KSOTokenCompletionTableViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.completionTableViewCellClass)];
    
    if (cell == nil) {
        cell = [[(id)self.completionTableViewCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.completionTableViewCellClass)];
    }
    
    [cell setCompletionModel:self.completionModels[indexPath.row]];
    
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // hide the completions table view and insert the selected completion
    [self _hideCompletionsTableViewAndSelectCompletionModel:self.completionModels[indexPath.row]];
}
#pragma mark Properties
@dynamic delegate;
// the internal delegate tracks the external delegate that is set on the receiver
- (void)setDelegate:(id<KSOTokenTextViewDelegate>)delegate {
    [self.internalDelegate setDelegate:delegate];
    
    [super setDelegate:self.internalDelegate];
}
#pragma mark *** Public Methods ***
- (BOOL)tokenizeTextAndGetTokenRange:(NSRangePointer)tokenRange; {
    return [self _tokenizeTextInRange:self.selectedRange tokenRange:tokenRange];
}
#pragma mark Properties
@dynamic representedObjects;
- (NSArray *)representedObjects {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id<KSOTokenTextAttachment> value, NSRange range, BOOL *stop) {
        if (value) {
            [retval addObject:value.representedObject];
        }
    }];
    
    return retval;
}
- (void)setRepresentedObjects:(NSArray *)representedObjects {
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
    
    for (id<KSOTokenRepresentedObject> representedObject in representedObjects) {
        NSString *text = representedObject.tokenRepresentedObjectDisplayName;
        
        [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[self _textAttachmentWithRepresentedObject:representedObject text:text]]];
    }
    
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:temp];
    
    if (self.selectedRange.length == 0) {
        [self setSelectedRange:NSMakeRange(self.text.length, 0)];
    }
}
- (void)setTokenizingCharacterSet:(NSCharacterSet *)tokenizingCharacterSet {
    _tokenizingCharacterSet = [tokenizingCharacterSet copy] ?: [self.class _defaultTokenizingCharacterSet];
}
- (void)setTokenTextAttachmentClass:(Class<KSOTokenTextAttachment>)tokenTextAttachmentClass {
    _tokenTextAttachmentClass = tokenTextAttachmentClass ?: [self.class _defaultTokenTextAttachmentClass];
}
- (void)setCompletionDelay:(NSTimeInterval)completionDelay {
    _completionDelay = completionDelay < 0.0 ? [self.class _defaultCompletionDelay] : completionDelay;
}
- (void)setCompletionTableViewCellClass:(Class<KSOTokenCompletionTableViewCell>)completionTableViewCellClass {
    _completionTableViewCellClass = completionTableViewCellClass ?: [self.class _defaultCompletionTableViewCellClass];
}
#pragma mark *** Private Methods ***
- (void)_KSOTokenTextViewInit; {
    _completionOperationQueue = [[NSOperationQueue alloc] init];
    [_completionOperationQueue setMaxConcurrentOperationCount:1];
    [_completionOperationQueue setQualityOfService:NSQualityOfServiceUserInitiated];
    
    _tokenizingCharacterSet = [self.class _defaultTokenizingCharacterSet];
    _tokenTextAttachmentClass = [self.class _defaultTokenTextAttachmentClass];
    _completionDelay = [self.class _defaultCompletionDelay];
    _completionTableViewCellClass = [self.class _defaultCompletionTableViewCellClass];
    
    [self setTextColor:[self.class _defaultTextColor]];
    [self setTypingAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
    [self setInputAccessoryView:[[KDINextPreviousInputAccessoryView alloc] initWithFrame:CGRectZero responder:self]];
    [(KDINextPreviousInputAccessoryView *)self.inputAccessoryView setItemOptions:KDINextPreviousInputAccessoryViewItemOptionsDone];
    [self.textStorage setDelegate:self];
    
    _internalDelegate = [[KSOTokenTextViewInternalDelegate alloc] init];
    [self setDelegate:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
    
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    kstWeakify(self);
    [tapGestureRecognizer KDI_addBlock:^(__kindof UIGestureRecognizer * _Nonnull gestureRecognizer) {
        kstStrongify(self);
        if (self.text.length == 0) {
            return;
        }
        
        CGPoint location = [tapGestureRecognizer locationInView:self];
        
        // adjust the location by the text container insets
        location.x -= self.textContainerInset.left;
        location.y -= self.textContainerInset.top;
        
        // ask the layout manager for character index corresponding to the tapped location
        NSInteger index = [self.layoutManager characterIndexForPoint:location inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
        
        // if the index is within our text
        if (index >= self.text.length) {
            return;
        }
        
        // get the effective range for the token at index
        NSRange range;
        id value = [self.textStorage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        
        // if there is a token
        if (value == nil) {
            return;
        }
        
        // if our selection is zero length or a different token is selected, select the entire range of the token
        if (self.selectedRange.length == 0) {
            [self setSelectedRange:range];
        }
        // if the user tapped on a token that was already selected, move the caret immediately after the token
        else if (NSEqualRanges(range, self.selectedRange)) {
            [self setSelectedRange:NSMakeRange(NSMaxRange(range), 0)];
        }
        // otherwise select the different token
        else {
            [self setSelectedRange:range];
        }
        
        if (!self.isFirstResponder) {
            [self becomeFirstResponder];
        }
    }];
    
    [self addGestureRecognizer:tapGestureRecognizer];
    
    _gestureRecognizerDelegate = [[KSOTokenTextViewGestureRecognizerDelegate alloc] initWithGestureRecognizers:@[tapGestureRecognizer] textView:self];
}
#pragma mark -
- (BOOL)_tokenizeTextInRange:(NSRange)range tokenRange:(NSRangePointer)outTokenRange; {
    NSRange tokenRange = [self _tokenRangeForRange:range];
    
    if (tokenRange.length > 0) {
        // trim surrounding whitespace to prevent something like " a@b.com" being shown as a token
        NSString *tokenText = [[self.text substringWithRange:tokenRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // initially the represented object is the token text itself
        id representedObject = tokenText;
        
        // if the delegate implements tokenTextView:representedObjectForEditingText: use its return value for the represented object
        if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectForEditingText:)]) {
            representedObject = [self.delegate tokenTextView:self representedObjectForEditingText:tokenText];
        }
        
        // initial array of represented objects to insert
        NSArray *representedObjects = @[representedObject];
        // index to insert the objects at
        NSInteger index = [self _indexOfTokenTextAttachmentInRange:range textAttachment:NULL];
        
        // if the delegate responds to tokenTextView:shouldAddRepresentedObjects:atIndex use its return value for the represented objects to insert
        if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)]) {
            representedObjects = [self.delegate tokenTextView:self shouldAddRepresentedObjects:representedObjects atIndex:index];
        }
        
        // if there are represented objects to insert, continue
        if (representedObjects.count > 0) {
            NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
            
            // loop through each represented object and ask the delegate for the display text for each one
            for (id<KSOTokenRepresentedObject> representedObject in representedObjects) {
                NSString *displayText = representedObject.tokenRepresentedObjectDisplayName;
                
                [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[self _textAttachmentWithRepresentedObject:representedObject text:displayText]]];
            }
            
            // replace all characters in token range with the text attachments
            [self.textStorage replaceCharactersInRange:tokenRange withAttributedString:temp];
            
            [self setSelectedRange:NSMakeRange(tokenRange.location + 1, 0)];
            
            // hide the completion table view if it was visible
            [self _hideCompletionsTableViewAndSelectCompletionModel:nil];
            
            if ([self.delegate respondsToSelector:@selector(tokenTextView:didAddRepresentedObjects:atIndex:)]) {
                [self.delegate tokenTextView:self didAddRepresentedObjects:representedObjects atIndex:index];
            }
            
            return YES;
        }
        
        if (outTokenRange != NULL) {
            *outTokenRange = tokenRange;
        }
    }
    return NO;
}
- (NSRange)_tokenRangeForRange:(NSRange)range; {
    NSRange searchRange = NSMakeRange(0, range.location);
    // take the inverted set of our tokenizing set
    NSMutableCharacterSet *characterSet = [self.tokenizingCharacterSet.invertedSet mutableCopy];
    // remove the NSAttachmentCharacter from our inverted character set, we don't want to match against tokens
    [characterSet removeCharactersInString:[NSString stringWithFormat:@"%C",(unichar)NSAttachmentCharacter]];
    
    NSRange foundRange = [self.text rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch range:searchRange];
    NSRange retval = foundRange;
    
    // first search backwards until we hit either a token or end of text
    while (foundRange.length > 0) {
        retval = NSUnionRange(retval, foundRange);
        
        searchRange = NSMakeRange(0, foundRange.location);
        foundRange = [self.text rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch range:searchRange];
    }
    
    // if we found something searching backwards, use a scanner to scan all characters from our character set starting at retval.location and moving forwards
    if (retval.location != NSNotFound) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:self.text];
        
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:retval.location];
        
        NSString *string;
        if ([scanner scanCharactersFromSet:characterSet intoString:&string]) {
            retval = NSMakeRange(retval.location, string.length);
        }
    }
    
    // if the receiver has no text, leaving the NSNotFound will throw an exception when trying to replace with a completion
    if (retval.location == NSNotFound) {
        retval.location = 0;
    }
    
    return retval;
}
- (NSUInteger)_indexOfTokenTextAttachmentInRange:(NSRange)range textAttachment:(id<KSOTokenTextAttachment> *)textAttachment; {
    // if we don't have any text, the attachment is nil, otherwise search for an attachment clamped to the passed in range.location and the end of our text - 1
    id<KSOTokenTextAttachment> attachment = self.text.length == 0 ? nil : [self.attributedText attribute:NSAttachmentAttributeName atIndex:MIN(range.location, self.attributedText.length - 1) effectiveRange:NULL];
    NSArray *representedObjects = self.representedObjects;
    NSUInteger retval = [representedObjects indexOfObject:attachment.representedObject];
    
    if (retval == NSNotFound) {
        retval = representedObjects.count;
    }
    
    if (textAttachment) {
        *textAttachment = attachment;
    }
    
    return retval;
}
- (NSArray *)_copyTokenTextAttachmentsInRange:(NSRange)range; {
    NSMutableArray *representedObjects = [[NSMutableArray alloc] init];
    NSMutableIndexSet *rangeAsIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // enumerate text attachments in the range to be deleted and add their represented object to the array
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id<KSOTokenTextAttachment> value, NSRange range, BOOL *stop) {
        if (value) {
            [representedObjects addObject:value.representedObject];
            
            // remove the range of the attachment from the entire selected range
            [rangeAsIndexSet removeIndexesInRange:range];
        }
    }];
    
    // if there is any plain text left selected, count will be > 0, create represented objects for left over text
    if (rangeAsIndexSet.count > 0) {
        [rangeAsIndexSet enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
            if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectForEditingText:)]) {
                [representedObjects addObject:[self.delegate tokenTextView:self representedObjectForEditingText:[self.textStorage.string substringWithRange:range]]];
            }
        }];
    }
    
    if (representedObjects.count > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        BOOL retval = NO;
        
        if ([self.delegate respondsToSelector:@selector(tokenTextView:writeRepresentedObjects:pasteboard:)]) {
            retval = [self.delegate tokenTextView:self writeRepresentedObjects:representedObjects pasteboard:pasteboard];
        }
        
        if (!retval) {
            NSMutableArray *strings = [[NSMutableArray alloc] init];
            
            for (id<KSOTokenRepresentedObject> representedObject in representedObjects) {
                [strings addObject:representedObject.tokenRepresentedObjectDisplayName];
            }
            
            [pasteboard setStrings:strings];
        }
    }
    
    return representedObjects;
}
- (NSTextAttachment<KSOTokenTextAttachment> *)_textAttachmentWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text; {
    NSTextAttachment<KSOTokenTextAttachment> *retval = [[(id)self.tokenTextAttachmentClass alloc] initWithRepresentedObject:representedObject text:text tokenTextView:self];
    
    if ([retval respondsToSelector:@selector(setFont:)]) {
        [retval setFont:self.font];
    }
    
    return retval;
}
#pragma mark -
- (void)_showCompletionsTableView; {
    if ([self.delegate respondsToSelector:@selector(tokenTextViewShouldShowCompletionsTableView:)] &&
        ![self.delegate tokenTextViewShouldShowCompletionsTableView:self]) {
        return;
    }
    
    // if the completion range is zero length, hide the completions table view
    if ([self _tokenRangeForRange:self.selectedRange].length == 0) {
        [self _hideCompletionsTableViewAndSelectCompletionModel:nil];
        return;
    }
    
    // if our completion table view doesn't exist, create it and ask the delegate to display it
    if (self.tableView == nil) {
        [self setTableView:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain]];
        
        CGFloat estimatedRowHeight = 44.0;
        
        if ([self.completionTableViewCellClass respondsToSelector:@selector(estimatedRowHeight)]) {
            estimatedRowHeight = [self.completionTableViewCellClass estimatedRowHeight];
        }
        
        [self.tableView setEstimatedRowHeight:estimatedRowHeight];
        [self.tableView setRowHeight:UITableViewAutomaticDimension];
        [self.tableView registerClass:self.completionTableViewCellClass forCellReuseIdentifier:NSStringFromClass(self.completionTableViewCellClass)];
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(tokenTextView:showCompletionsTableView:)]) {
        [self.delegate tokenTextView:self showCompletionsTableView:self.tableView];
    }
    
    // if the delegate responds to either of the completion returning methods, continue
    if ([self.delegate respondsToSelector:@selector(tokenTextView:completionModelsForSubstring:indexOfRepresentedObject:completion:)]) {
        NSInteger index = [self _indexOfTokenTextAttachmentInRange:self.selectedRange textAttachment:NULL];
        NSRange range = [self _tokenRangeForRange:self.selectedRange];
        NSString *substring = [self.text substringWithRange:range];
        
        kstWeakify(self);
        [self.completionOperationQueue cancelAllOperations];
        [self.completionOperationQueue addOperation:[[KSOTokenCompletionOperation alloc] initWithTokenTextView:self substring:substring index:index completion:^(NSArray<id<KSOTokenCompletionModel>> * _Nullable completionModels) {
            kstStrongify(self);
            [self setCompletionModels:completionModels];
        }]];
    }
    else if ([self.delegate respondsToSelector:@selector(tokenTextView:completionModelsForSubstring:indexOfRepresentedObject:)]) {
        
        NSInteger index = [self _indexOfTokenTextAttachmentInRange:self.selectedRange textAttachment:NULL];
        NSRange range = [self _tokenRangeForRange:self.selectedRange];
        NSString *substring = [self.text substringWithRange:range];
        
        [self setCompletionModels:[self.delegate tokenTextView:self completionModelsForSubstring:substring indexOfRepresentedObject:index]];
    }
}
- (void)_hideCompletionsTableViewAndSelectCompletionModel:(id<KSOTokenCompletionModel>)completionModel; {
    // if the delegate responds, ask it to hide the completions table view
    if ([self.delegate respondsToSelector:@selector(tokenTextView:hideCompletionsTableView:)]) {
        // if we were given a completion to insert, do it
        if (completionModel != nil) {
            NSArray *representedObjects;
            
            if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectsForCompletionModel:)]) {
                representedObjects = [self.delegate tokenTextView:self representedObjectsForCompletionModel:completionModel];
            }
            else if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectForEditingText:)]) {
                representedObjects = @[[self.delegate tokenTextView:self representedObjectForEditingText:[completionModel tokenCompletionModelTitle]]];
            }
            else {
                representedObjects = @[[completionModel tokenCompletionModelTitle]];
            }
            
            NSInteger index = [self _indexOfTokenTextAttachmentInRange:self.selectedRange textAttachment:NULL];
            
            // if the delegate responds to tokenTextView:shouldAddRepresentedObjects:atIndex use its return value for the represented objects to insert
            if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)]) {
                representedObjects = [self.delegate tokenTextView:self shouldAddRepresentedObjects:representedObjects atIndex:index];
            }
            
            if (representedObjects.count > 0) {
                NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor}];
                
                for (id<KSOTokenRepresentedObject> representedObject in representedObjects) {
                    NSString *displayText = representedObject.tokenRepresentedObjectDisplayName;
                    
                    [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[self _textAttachmentWithRepresentedObject:representedObject text:displayText]]];
                }
                
                if (![self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)] ||
                    ([self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)] &&
                     [self.delegate tokenTextView:self shouldAddRepresentedObjects:representedObjects atIndex:index])) {
                    
                        [self.textStorage replaceCharactersInRange:[self _tokenRangeForRange:self.selectedRange] withAttributedString:temp];
                        
                        if ([self.delegate respondsToSelector:@selector(tokenTextView:didAddRepresentedObjects:atIndex:)]) {
                            [self.delegate tokenTextView:self didAddRepresentedObjects:representedObjects atIndex:index];
                        }
                }
            }
        }
        
        [self.delegate tokenTextView:self hideCompletionsTableView:self.tableView];
        
        [self setCompletionModels:nil];
    }
}
#pragma mark -
+ (NSCharacterSet *)_defaultTokenizingCharacterSet; {
    NSMutableCharacterSet *retval = [[NSCharacterSet newlineCharacterSet] mutableCopy];
    
    [retval addCharactersInString:@","];
    
    return [retval copy];
}
+ (Class<KSOTokenTextAttachment>)_defaultTokenTextAttachmentClass; {
    return KSOTokenDefaultTextAttachment.class;
}
+ (NSTimeInterval)_defaultCompletionDelay; {
    return 0.0;
}
+ (Class<KSOTokenCompletionTableViewCell>)_defaultCompletionTableViewCellClass; {
    return KSOTokenDefaultCompletionTableViewCell.class;
}
+ (UIColor *)_defaultTextColor; {
    return UIColor.blackColor;
}
#pragma mark Properties
- (void)setSelectedTextAttachmentRanges:(NSIndexSet *)selectedTextAttachmentRanges {
    // force a display of the old selected token ranges
    [_selectedTextAttachmentRanges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.layoutManager invalidateDisplayForCharacterRange:range];
    }];
    
    _selectedTextAttachmentRanges = [selectedTextAttachmentRanges copy];
    
    // force a display of the new selected token ranges
    [_selectedTextAttachmentRanges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.layoutManager invalidateDisplayForCharacterRange:range];
    }];
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    if (_tableView == nil) {
        [self setCompletionModels:nil];
    }
}
- (void)setCompletionModels:(NSArray<id<KSOTokenCompletionModel>> *)completionModels {
    _completionModels = completionModels;
    
    if (_completionModels.count == 0 &&
        self.tableView.window != nil) {
        
        [self.tableView setHidden:YES];
    }
    
    [self.tableView reloadData];
    
    if (_completionModels.count > 0 &&
        self.tableView.window != nil) {
        
        [self.tableView setHidden:NO];
    }
}

@end
