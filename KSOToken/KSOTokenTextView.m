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

@interface KSOTokenTextViewInternalDelegate : NSObject <KSOTokenTextViewDelegate>
@property (weak,nonatomic) id<KSOTokenTextViewDelegate> delegate;
@end

@implementation KSOTokenTextViewInternalDelegate

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return nil;
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

@interface KSOTokenTextView () <UITextViewDelegate,NSTextStorageDelegate>
@property (strong,nonatomic) KSOTokenTextViewInternalDelegate *internalDelegate;

@property (copy,nonatomic) NSIndexSet *selectedTextAttachmentRanges;

- (void)_KSOTokenTextViewInit;
- (NSRange)_tokenRangeForRange:(NSRange)range;
- (NSUInteger)_indexOfTokenTextAttachmentInRange:(NSRange)range textAttachment:(id<KSOTokenTextAttachment> *)textAttachment;
+ (NSCharacterSet *)_defaultTokenizingCharacterSet;
+ (NSString *)_defaultTokenTextAttachmentClassName;
+ (NSTimeInterval)_defaultCompletionDelay;
+ (UIFont *)_defaultTypingFont;
+ (UIColor *)_defaultTypingTextColor;
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
#pragma mark NSTextStorageDelegate
- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    // fix up our attributes so that everything, including the attachments, use our desired font and text color
    [textStorage addAttributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor} range:editedRange];
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:self.tokenizingCharacterSet].length > 0) {
        
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
                NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor}];
                
                // loop through each represented object and ask the delegate for the display text for each one
                for (id obj in representedObjects) {
                    NSString *displayText = [obj description];
                    
                    if ([self.delegate respondsToSelector:@selector(tokenTextView:displayTextForRepresentedObject:)]) {
                        displayText = [self.delegate tokenTextView:self displayTextForRepresentedObject:obj];
                    }
                    
                    [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[[NSClassFromString(self.tokenTextAttachmentClassName) alloc] initWithRepresentedObject:obj text:displayText tokenTextView:self]]];
                }
                
                // replace all characters in token range with the text attachments
                [self.textStorage replaceCharactersInRange:tokenRange withAttributedString:temp];
                
                [self setSelectedRange:NSMakeRange(tokenRange.location + 1, 0)];
                
                // hide the completion table view if it was visible
//                [self _hideCompletionsTableViewAndSelectCompletion:nil];
                
                if ([self.delegate respondsToSelector:@selector(tokenTextView:didAddRepresentedObjects:atIndex:)]) {
                    [self.delegate tokenTextView:self didAddRepresentedObjects:representedObjects atIndex:index];
                }
            }
        }
        return NO;
    }
    // delete
    else if (text.length == 0) {
        if (self.text.length > 0) {
            NSMutableArray *representedObjects = [[NSMutableArray alloc] init];
            
            // enumerate text attachments in the range to be deleted and add their represented object to the array
            [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(KSOTokenDefaultTextAttachment *value, NSRange range, BOOL *stop) {
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
    
}
#pragma mark Properties
@dynamic delegate;
// the internal delegate tracks the external delegate that is set on the receiver
- (void)setDelegate:(id<KSOTokenTextViewDelegate>)delegate {
    [self.internalDelegate setDelegate:delegate];
    
    [super setDelegate:self.internalDelegate];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
- (void)setTokenizingCharacterSet:(NSCharacterSet *)tokenizingCharacterSet {
    _tokenizingCharacterSet = [tokenizingCharacterSet copy] ?: [self.class _defaultTokenizingCharacterSet];
}
- (void)setTokenTextAttachmentClassName:(NSString *)tokenTextAttachmentClassName {
    _tokenTextAttachmentClassName = tokenTextAttachmentClassName ?: [self.class _defaultTokenTextAttachmentClassName];
}
- (void)setCompletionDelay:(NSTimeInterval)completionDelay {
    _completionDelay = completionDelay < 0.0 ? [self.class _defaultCompletionDelay] : completionDelay;
}
- (void)setTypingFont:(UIFont *)typingFont {
    _typingFont = typingFont ?: [self.class _defaultTypingFont];
}
- (void)setTypingTextColor:(UIColor *)typingTextColor {
    _typingTextColor = typingTextColor ?: [self.class _defaultTypingTextColor];
}
#pragma mark *** Private Methods ***
- (void)_KSOTokenTextViewInit; {
    _tokenizingCharacterSet = [self.class _defaultTokenizingCharacterSet];
    _tokenTextAttachmentClassName = [self.class _defaultTokenTextAttachmentClassName];
    _completionDelay = [self.class _defaultCompletionDelay];
    _typingFont = [self.class _defaultTypingFont];
    _typingTextColor = [self.class _defaultTypingTextColor];
    
    [self setContentInset:UIEdgeInsetsZero];
    [self setTypingAttributes:@{NSFontAttributeName: _typingFont, NSForegroundColorAttributeName: _typingTextColor}];
    [self setTextContainerInset:UIEdgeInsetsZero];
    [self.textContainer setLineFragmentPadding:0];
    [self.textStorage setDelegate:self];
    
    _internalDelegate = [[KSOTokenTextViewInternalDelegate alloc] init];
    [self setDelegate:nil];
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
    KSOTokenDefaultTextAttachment *attachment = self.text.length == 0 ? nil : [self.attributedText attribute:NSAttachmentAttributeName atIndex:MIN(range.location, self.attributedText.length - 1) effectiveRange:NULL];
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

+ (NSCharacterSet *)_defaultTokenizingCharacterSet; {
    NSMutableCharacterSet *retval = [[NSCharacterSet newlineCharacterSet] mutableCopy];
    
    [retval addCharactersInString:@","];
    
    return [retval copy];
}
+ (NSString *)_defaultTokenTextAttachmentClassName {
    return NSStringFromClass([KSOTokenDefaultTextAttachment class]);
}
+ (NSTimeInterval)_defaultCompletionDelay; {
    return 0.0;
}
+ (UIFont *)_defaultTypingFont; {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIColor *)_defaultTypingTextColor; {
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

@end
