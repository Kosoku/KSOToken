//
//  KSOTokenDefaultTextAttachment.h
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

#import <UIKit/UIKit.h>
#import <KSOToken/KSOTokenTextAttachment.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOTokenDefaultTextAttachment is an NSTextAttachment subclass that is used to represent model objects conforming to KSOTokenRepresentedObject. You can provide a custom class that conforms to KSOTokenTextAttachment or subclass KSOTokenDefaultTextAttachment and modify its appearance using the public properties.
 */
@interface KSOTokenDefaultTextAttachment : NSTextAttachment <KSOTokenTextAttachment>

/**
 Set and get the font used to draw tokens.
 
 The default is self.tokenTextView.typingFont.
 */
@property (strong,nonatomic,null_resettable) UIFont *tokenFont;
/**
 Set and get the text color used to draw tokens.
 
 The default is self.tokenTextView.tintColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenTextColor;
/**
 Set and get the background color used to draw tokens.
 
 The default is [UIColor clearColor].
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenBackgroundColor;
/**
 Set and get the text color used to draw highlighted tokens.
 
 The default is [UIColor whiteColor].
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenHighlightedTextColor;
/**
 Set and get the background color used to draw highlighted tokens.
 
 The default is self.tokenTextView.tintColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenHighlightedBackgroundColor;
/**
 Set and get the corner radius used to draw tokens.
 
 The default is 3.0.
 */
@property (assign,nonatomic) CGFloat tokenCornerRadius;

@end

NS_ASSUME_NONNULL_END
