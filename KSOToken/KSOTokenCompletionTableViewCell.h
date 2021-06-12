//
//  KSOTokenCompletionTableViewCell.h
//  KSOToken
//
//  Created by William Towe on 6/5/17.
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

#import <Foundation/Foundation.h>
#import <KSOToken/KSOTokenCompletionModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for the UITableViewCell used to display objects conforming to KSOTokenCompletionModel.
 */
@protocol KSOTokenCompletionTableViewCell <NSObject>
@required
/**
 Set and get the completion model being displayed by the receiver.
 
 @see KSOTokenCompletionModel
 */
@property (strong,nonatomic) id<KSOTokenCompletionModel> completionModel;

@optional
/**
 Return the estimated row height of the receiver. If this property is implemented its value is set as the estimatedRowHeight of the completion table view.
 */
@property (class,readonly,nonatomic) CGFloat estimatedRowHeight;
@end

NS_ASSUME_NONNULL_END
