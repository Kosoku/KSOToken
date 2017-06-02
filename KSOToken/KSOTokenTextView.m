//
//  KSOTokenTextView.m
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

#import "KSOTokenTextView.h"

@interface KSOTokenTextViewInternalDelegate : NSObject <KSOTokenTextViewDelegate>
@property (weak,nonatomic) id<KSOTokenTextViewDelegate> delegate;
@end

@implementation KSOTokenTextViewInternalDelegate

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return nil;
}

@end

@interface KSOTokenTextView ()
@property (strong,nonatomic) KSOTokenTextViewInternalDelegate *internalDelegate;

- (void)_KSOTokenTextViewInit;
@end

@implementation KSOTokenTextView

@dynamic delegate;
// the internal delegate tracks the external delegate that is set on the receiver
- (void)setDelegate:(id<KSOTokenTextViewDelegate>)delegate {
    [self.internalDelegate setDelegate:delegate];
    
    [super setDelegate:self.internalDelegate];
}

- (void)_KSOTokenTextViewInit; {
    _internalDelegate = [[KSOTokenTextViewInternalDelegate alloc] init];
    [self setDelegate:nil];
}

@end
