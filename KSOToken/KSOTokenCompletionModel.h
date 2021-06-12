//
//  KSOTokenCompletionModel.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for objects that will be displayed in the completions table view.
 */
@protocol KSOTokenCompletionModel <NSObject>
@required
/**
 Return the title of the completion.
 */
- (NSString *)tokenCompletionModelTitle;
@optional
/**
 Return the matching range of the completion.
 */
- (NSRange)tokenCompletionModelRange;
/**
 Return the matching ranges of the completion. If implemented, this is preferred over tokenCompletionModelRange.
 */
- (NSIndexSet *)tokenCompletionModelIndexes;
@end

/**
 Add support for the KSOTokenCompletionModel protocol to NSString.
 */
@interface NSString (KSOTokenCompletionModelExtensions) <KSOTokenCompletionModel>
@end

/**
 Add support for the KSOTokenCompletionModel protocol to NSURL.
 */
@interface NSURL (KSOTokenCompletionModelExtensions) <KSOTokenCompletionModel>
@end

NS_ASSUME_NONNULL_END
