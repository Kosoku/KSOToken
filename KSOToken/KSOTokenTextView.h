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

NS_ASSUME_NONNULL_BEGIN

@protocol KSOTokenTextViewDelegate;

@interface KSOTokenTextView : KDITextView

@property (weak,nonatomic,nullable) id<KSOTokenTextViewDelegate,UITextViewDelegate> delegate;

/**
 Set and get the represented objects of the receiver.
 
 These can either be NSString objects or custom model objects. If custom model objects are provided, the delegate should implement `tokenTextView:representedObjectForEditingText:` and `tokenTextView:displayTextForRepresentedObject:`.
 */
@property (copy,nonatomic,nullable) NSArray *representedObjects;

/**
 Set and get the character set used to delimit tokens.
 
 The default is [NSCharacterSet characterSetWithCharactersInString:@","].
 */
@property (copy,nonatomic,null_resettable) NSCharacterSet *tokenizingCharacterSet;
/**
 Set and get the completion delay of the receiver.
 
 The default is 0.0.
 */
@property (assign,nonatomic) NSTimeInterval completionDelay;

@end

@protocol KSOTokenTextViewDelegate <UITextViewDelegate>
@optional

@end

NS_ASSUME_NONNULL_END
