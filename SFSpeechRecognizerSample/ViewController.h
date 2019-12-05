//
//  ViewController.h
//  SFSpeechRecognizerSample
//
//  Created by satoshi.marumoto on 2019/12/05.
//  Copyright © 2019 satoshi.marumoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Speech/Speech.h>

@interface ViewController : UIViewController <SFSpeechRecognizerDelegate> {
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
}

@end

