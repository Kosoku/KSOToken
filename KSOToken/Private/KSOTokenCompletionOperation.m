//
//  KSOTokenCompletionOperation.m
//  KSOToken
//
//  Created by William Towe on 10/22/17.
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

#import "KSOTokenCompletionOperation.h"
#import "KSOTokenTextView.h"

#import <Stanley/Stanley.h>

@interface KSOTokenCompletionOperation ()
@property (weak,nonatomic) KSOTokenTextView *tokenTextView;
@property (copy,nonatomic) NSString *substring;
@property (assign,nonatomic) NSUInteger index;
@property (copy,nonatomic) void(^completion)(NSArray<id<KSOTokenCompletionModel> > *);

@property (assign,nonatomic,getter=isExecuting) BOOL executing;
@property (assign,nonatomic,getter=isFinished) BOOL finished;
@end

@implementation KSOTokenCompletionOperation

- (void)start {
    if (self.isCancelled) {
        [self setExecuting:NO];
        [self setFinished:YES];
        return;
    }
    
    if (!NSThread.isMainThread) {
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self main];
}
- (void)main {
    if (self.isCancelled) {
        [self setExecuting:NO];
        [self setFinished:YES];
    }
    
    [self setExecuting:YES];
    
    kstWeakify(self);
    [self.tokenTextView.delegate tokenTextView:self.tokenTextView completionModelsForSubstring:self.substring indexOfRepresentedObject:self.index completion:^(NSArray<id<KSOTokenCompletionModel>> * _Nullable completionModels) {
        kstStrongify(self);
        if (!self.isCancelled) {
            KSTDispatchMainAsync(^{
                self.completion(completionModels);
            });
        }
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (instancetype)initWithTokenTextView:(KSOTokenTextView *)tokenTextView substring:(NSString *)substring index:(NSUInteger)index completion:(void (^)(NSArray<id<KSOTokenCompletionModel>> *))completion {
    if (!(self = [super init]))
        return nil;
 
    _tokenTextView = tokenTextView;
    _substring = [substring copy];
    _index = index;
    _completion = [completion copy];
    
    return self;
}

@synthesize executing=_executing;
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@kstKeypath(self,isExecuting)];
    
    _executing = executing;
    
    [self didChangeValueForKey:@kstKeypath(self,isExecuting)];
}

@synthesize finished=_finished;
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@kstKeypath(self,isFinished)];
    
    _finished = finished;
    
    [self didChangeValueForKey:@kstKeypath(self,isFinished)];
}

@end
