//
//  KSOTokenCompletionOperation.h
//  KSOToken
//
//  Created by William Towe on 10/22/17.
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
#import "KSOTokenCompletionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class KSOTokenTextView;

@interface KSOTokenCompletionOperation : NSOperation

- (instancetype)initWithTokenTextView:(KSOTokenTextView *)tokenTextView substring:(NSString *)substring index:(NSUInteger)index completion:(void(^)(NSArray<id<KSOTokenCompletionModel> > * _Nullable completionModels))completion;

@end

NS_ASSUME_NONNULL_END
