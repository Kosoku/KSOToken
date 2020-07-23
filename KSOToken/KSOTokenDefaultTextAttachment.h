//
//  KSOTokenDefaultTextAttachment.h
//  KSOToken
//
//  Created by William Towe on 6/2/17.
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

#import <UIKit/UIKit.h>
#import <KSOToken/KSOTokenTextAttachment.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOTokenDefaultTextAttachment is an NSTextAttachment subclass that is used to represent model objects conforming to KSOTokenRepresentedObject. You can provide a custom class that conforms to KSOTokenTextAttachment or subclass KSOTokenDefaultTextAttachment and modify its appearance using the public properties. The default values match the appearance of native iOS apps that use similar controls (e.g. Mail).
 */
@interface KSOTokenDefaultTextAttachment : NSTextAttachment <KSOTokenTextAttachment>

/**
 Set and get whether the receiver updates its appearance when the tint color of the owning text view changes. You can set this to NO in a custom subclass if you do not want the tint color to be taken into account when drawing.
 
 The default is YES.
 */
@property (assign,nonatomic) BOOL respondsToTintColorChanges;
/**
 Set and get the font used to draw tokens.
 
 The default is self.tokenTextView.font.
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
 Set and get the text color to use when disabled.
 
 The default is self.tokenTextView.textColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenDisabledTextColor;
/**
 Set and get the color used to draw the background when disabled.
 
 The default is UIColor.clearColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *tokenDisabledBackgroundColor;
/**
 Set and get the corner radius used to draw tokens.
 
 The default is 0.0.
 */
@property (assign,nonatomic) CGFloat tokenCornerRadius;

@end

NS_ASSUME_NONNULL_END
