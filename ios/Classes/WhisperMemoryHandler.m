//
// WhisperMemoryHandler.m
//
// Created by Claude Code for whisper_flutter_coreml
//

#import "WhisperMemoryHandler.h"
#import "whisper.cpp/coreml/whisper-encoder.h"
#import <UIKit/UIKit.h>

@interface WhisperMemoryHandler ()
@property (nonatomic, strong) FlutterMethodChannel* channel;
@end

@implementation WhisperMemoryHandler

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"whisper_flutter_coreml/memory"
              binaryMessenger:[registrar messenger]];
    WhisperMemoryHandler* instance = [[WhisperMemoryHandler alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    // Setup memory warning observer
    [[NSNotificationCenter defaultCenter] 
        addObserver:instance
        selector:@selector(handleMemoryWarning:)
        name:UIApplicationDidReceiveMemoryWarningNotification 
        object:nil];
    
    NSLog(@"[Whisper Memory] Handler registered and memory warning observer setup");
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"checkMemoryAvailable" isEqualToString:call.method]) {
        [self checkMemoryAvailable:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)checkMemoryAvailable:(FlutterResult)result {
    // Use our CoreML memory functions to check availability
    size_t availableMemory = whisper_coreml_get_available_memory();
    
    // Consider memory available if we have at least 200MB free
    // (Conservative threshold for iPhone 11 and similar devices)
    const size_t MINIMUM_MEMORY_THRESHOLD = 200 * 1024 * 1024; // 200 MB
    
    BOOL hasMemory = (availableMemory >= MINIMUM_MEMORY_THRESHOLD);
    
    NSLog(@"[Whisper Memory] Memory check: %.2f MB available, threshold: %.2f MB -> %@",
          availableMemory / (1024.0 * 1024.0),
          MINIMUM_MEMORY_THRESHOLD / (1024.0 * 1024.0),
          hasMemory ? @"SUFFICIENT" : @"INSUFFICIENT");
    
    result(@(hasMemory));
}

- (void)handleMemoryWarning:(NSNotification *)notification {
    NSLog(@"[Whisper Memory] iOS memory warning received - notifying Flutter");
    
    // Trigger CoreML memory cleanup
    whisper_coreml_handle_memory_pressure();
    
    // Notify Flutter about the memory warning
    [self.channel invokeMethod:@"memoryWarning" arguments:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end