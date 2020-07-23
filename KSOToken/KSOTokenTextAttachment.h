//
//  KSOTokenTextAttachment.h
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

#import <Foundation/Foundation.h>
#import <KSOToken/KSOTokenRepresentedObject.h>

NS_ASSUME_NONNULL_BEGIN

@class KSOTokenTextView;

/**
 Protocol describing NSTextAttachment instances that represent model objects conforming to KSOTokenRepresentedObject in the text view.
 */
@protocol KSOTokenTextAttachment <NSObject>
@required
/**
 Get the BBTokenTextView that owns the receiver.
 */
@property (readonly,weak,nonatomic) KSOTokenTextView *tokenTextView;
/**
 Get the represented object represented by the receiver.
 
 @see KSOTokenRepresentedObject
 */
@property (readonly,strong,nonatomic) id<KSOTokenRepresentedObject> representedObject;

/**
 Designated initializer.
 
 @param representedObject The object represented by the receiver
 @param text The text drawn by the receiver
 @param tokenTextView The token text view that owns the receiver
 @return An initialized instance of the receiver
 */
- (instancetype)initWithRepresentedObject:(id<KSOTokenRepresentedObject>)representedObject text:(NSString *)text tokenTextView:(KSOTokenTextView *)tokenTextView;

@optional
/**
 Set and get whether the owning text view has user interaction enabled.
 */
@property (assign,nonatomic,getter=isEnabled) BOOL enabled;

/**
 Set and get the font used to draw the text attachment. Implement this if you want your text attachment to respond to dynamic type changes.
 */
@property (strong,nonatomic,nullable) UIFont *font;
/**
 Set and get the tint color used when drawing the attachment. How the tint color is used is up to the implementation. Whenever the tint color of the owning KSOTokenTextView changes, this property will be set on all text attachments if it is implemented.
 */
@property (strong,nonatomic,nullable) UIColor *tintColor;
@end

NS_ASSUME_NONNULL_END
