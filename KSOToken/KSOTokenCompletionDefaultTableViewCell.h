//
//  KSOTokenCompletionDefaultTableViewCell.h
//  KSOToken
//
//  Created by William Towe on 6/5/17.
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
#import <KSOToken/KSOTokenCompletionTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOTokenCompletionDefaultTableViewCell is a UITableViewCell subclass that is used by default to display model objects conforming to KSOTokenCompletionModel in the completions table view. You can provide a custom class conforming to KSOTokenCompletionTableViewCell. The default appearance uses a UILabel with the titleTextColor as the text color and highlightBackgroundColor as the background color when drawing matching ranges.
 */
@interface KSOTokenCompletionDefaultTableViewCell : UITableViewCell <KSOTokenCompletionTableViewCell>

/**
 Return the estimated row height of the receiver. This will be set as the estimatedRowHeight of the completion table view.
 
 The default is 44.0.
 */
@property (class,readonly,nonatomic) CGFloat estimatedRowHeight;

/**
 Set and get the title font.
 
 The default is [UIFont systemFontOfSize:17.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *titleFont;
/**
 Set and get the title text color.
 
 The default is UIColor.blackColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *titleTextColor;
/**
 Set and get the highlight background color, which is used to draw the matching range if the represented completion model implements the optional methods.
 
 The default is UIColor.yellowColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *highlightBackgroundColor;

@end

NS_ASSUME_NONNULL_END
