//
//  ViewController.m
//  SFSpeechRecognizerSample
//
//  Created by satoshi.marumoto on 2019/12/05.
//  Copyright © 2019 satoshi.marumoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //locale
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"]];
    //delegate
    speechRecognizer.delegate = self;
    self.label.text = @"音声認識アプリへようこそ。";
    self.label.textAlignment = UITextAlignmentCenter;
    [self.button setTitle:@"音声認識スタート" forState: UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    //authorization
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"認証されました。");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"音声認識へのアクセスが拒否されています。");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"音声認識はまだ許可されていません。");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"この端末で音声認識はできません。");
                break;
            default:
                break;
        }
    }];
}

- (void)startRecording {
    
    // Initialize the AVAudioEngine
    audioEngine = [[AVAudioEngine alloc] init];
    
    // Make sure there's not a recognition task already running
    if (recognitionTask) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    recognitionRequest.shouldReportPartialResults = YES;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the microphone after pressing the button should be being logged
            // in the console.
            NSLog(@"RESULT:%@",result.bestTranscription.formattedString);
            self.label.text = result.bestTranscription.formattedString;
            isFinal = !result.isFinal;
        }
        if (error) {
            [self->audioEngine stop];
            [inputNode removeTapOnBus:0];
            self->recognitionRequest = nil;
            self->recognitionTask = nil;
            
            self.button.enabled = YES;
            [self.button setTitle:@"音声認識スタート" forState: UIControlStateNormal];
            
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self->recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // Starts the audio engine, i.e. it starts listening.
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    self.label.text = @"何か喋ってください。";
    NSLog(@"Say Something, I'm listening");
}

- (IBAction)buttonTapped:(id)sender {
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
        self.button.enabled = NO;
        [self.button setTitle:@"停止中" forState: UIControlStateDisabled];
    } else {
        [self startRecording];
        [self.button setTitle:@"音声認識を中止" forState: UIControlStateNormal];
    }
}

#pragma mark - SFSpeechRecognizerDelegate Delegate Methods

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Availability:%d",available);
    if (available) {
        self.button.enabled = YES;
        [self.button setTitle:@"音声認識スタート" forState: UIControlStateNormal];
    }
}


@end
