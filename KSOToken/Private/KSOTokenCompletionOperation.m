//
//  KSOTokenCompletionOperation.m
//  KSOToken
//
//  Created by William Towe on 10/22/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
