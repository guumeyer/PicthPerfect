//
//  AVAudioSession+Swift.m
//  MeyerPitchPerfect
//
//  Created by Meyer, Gustavo on 2/3/19.
//  Copyright © 2019 Meyer. All rights reserved.
//

#import "AVAudioSession+Swift.h"

@implementation AVAudioSession (Swift)

- (BOOL)swift_setCategory:(AVAudioSessionCategory)category error:(NSError **)outError {
    return [self setCategory:category error:outError];
}
- (BOOL)swift_setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    return [self setCategory:category withOptions:options error:outError];
}

@end
