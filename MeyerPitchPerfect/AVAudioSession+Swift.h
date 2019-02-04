//
//  AVAudioSession+Swift.h
//  MeyerPitchPerfect
//
//  Created by Meyer, Gustavo on 2/3/19.
//  Copyright © 2019 Meyer. All rights reserved.
//

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioSession (Swift)

- (BOOL)swift_setCategory:(AVAudioSessionCategory)category error:(NSError **)outError NS_SWIFT_NAME(setCategory(_:));
- (BOOL)swift_setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError NS_SWIFT_NAME(setCategory(_:options:));

@end

NS_ASSUME_NONNULL_END
