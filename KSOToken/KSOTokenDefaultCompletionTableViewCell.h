//
//  KSOTokenDefaultCompletionTableViewCell.h
//  KSOToken
//
//  Created by William Towe on 6/5/17.
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
#import <KSOToken/KSOTokenCompletionTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOTokenDefaultCompletionTableViewCell is a UITableViewCell subclass that is used by default to display model objects conforming to KSOTokenCompletionModel in the completions table view. You can provide a custom class conforming to KSOTokenCompletionTableViewCell. The default appearance uses a UILabel with the titleTextColor as the text color and highlightBackgroundColor as the background color when drawing matching ranges.
 */
@interface KSOTokenDefaultCompletionTableViewCell : UITableViewCell <KSOTokenCompletionTableViewCell>

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
