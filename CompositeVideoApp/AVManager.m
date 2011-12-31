//
//  AVManager.m
//  CompositeVideoApp
//
//  Created by dav on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AVManager.h"

@interface AVManager ()
- (NSURL*) tempFileURL;
@end

@implementation AVManager

@synthesize captureDevice;
@synthesize captureSession;
@synthesize previewView;
@synthesize assetWriter;
@synthesize assetWriterInput;
@synthesize recordStartTime;

/*
 Before I post the code some setup: This is all in a class that manages the AV stuff. 
 I have a button on screen start/stop recording. When this is touched the toggleRecording method is called.
 http://forums.macrumors.com/showthread.php?t=1038514
 */
- (id) initWithViewForPreview:(UIImageView*)aView {
  self = [super init];
  if (self) {
    self.previewView = aView;
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (input) {
      [self.captureSession addInput:input];
    } else {
      NSLog(@"Error creating video input device");
    }
    
    AVCaptureVideoDataOutput *outputData = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [outputData setSampleBufferDelegate:self queue:dispatch_queue_create("renderqueue",NULL)];
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSString* key = (NSString*) kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [outputData setVideoSettings:videoSettings];
    [self.captureSession addOutput:outputData];
    
    isRecording = NO;
    self.recordStartTime = kCMTimeZero;
  }
  return self;
}

// The above has some issues, but works. This is the action for the button to start/stop recording:
- (void) toggleRecording {
  if (isRecording) {
    NSLog(@"Stopping recording");
    [self.assetWriterInput markAsFinished];
    [self.assetWriter endSessionAtSourceTime:self.recordStartTime];
    [self.assetWriter finishWriting];
    NSLog(@"Export done");
  } else {
    NSLog(@"Starting to record");
    
    NSURL *outputPath = [self tempFileURL];
    if (![outputPath isFileURL]) {
      NSLog(@"Not file URL");
    }
    
    NSError *error = nil;
    NSLog(@"Setting output path: %@", outputPath);
    self.assetWriter = [AVAssetWriter assetWriterWithURL:outputPath fileType:AVFileTypeQuickTimeMovie  error:&error];
    if (error != nil) {
      NSLog(@"Creation of assetWriter resulting in a non-nil error");
      NSLog(@" Error: %@", [error localizedDescription]);
      NSLog(@"Reason: %@", [error localizedFailureReason]); 
    }
    
    NSMutableDictionary *outputSettingsDict = [[NSMutableDictionary alloc] init];
    [outputSettingsDict setValue:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [outputSettingsDict setValue:[NSNumber numberWithInt:1280] forKey:AVVideoWidthKey];
    [outputSettingsDict setValue:[NSNumber numberWithInt:720] forKey:AVVideoHeightKey];
    self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettingsDict];
    [outputSettingsDict release];
    
    if (self.assetWriterInput == nil) {
      NSLog(@"assetWriterInput is nil");
    }
    
    self.assetWriterInput.expectsMediaDataInRealTime = YES; // If you uncomment this you get an exception saying it's not implemented yet (this may well not be true anymore: this was written on a very early 4.1 beta
    [self.assetWriter addInput:self.assetWriterInput];

    // START
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:self.recordStartTime];
  }
  
  isRecording = !isRecording;
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate 

// Finally we have a callback that we can use to get each frame as it becomes available
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  NSLog(@"captureOutput");
  if (!CMSampleBufferDataIsReady(sampleBuffer)) {
    NSLog(@"sampleBuffer data is not ready");
  }
  
  CMTime timeNow = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  
  // Lock the image buffer
  CVPixelBufferLockBaseAddress(imageBuffer,0); 
  
  // Get information about the image
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer); 
  
  // Create a CGImageRef from the CVImageBufferRef
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
  
  // Temp: draw a black rect: replace the next 2 lines with the correct compositing that you want.
  CGContextSetFillColorWithColor(newContext, [[UIColor blackColor] CGColor]);
  CGContextFillRect(newContext, CGRectMake(0, 0, 400, 400));
  
  // We unlock the  image buffer
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  // We release some components
  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);
  
  if (isRecording) {
    if (![self.assetWriterInput isReadyForMoreMediaData]) {
      NSLog(@"Not ready for data :(");
    }
    NSLog(@"Trying to append");
    if (![self.assetWriterInput appendSampleBuffer:sampleBuffer]) {
      NSLog(@"Failed to append pixel buffer");
    } else {
      NSLog(@"Append worked");
    }
  }
  
  recordStartTime = timeNow;
}

#pragma mark -

- (NSURL*) tempFileURL {
  NSString *theTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CompositeVideoApp.tmp"];
  char thePathBuffer[strlen([theTemplate UTF8String]) + 1];
  strncpy(thePathBuffer, [theTemplate UTF8String], strlen([theTemplate UTF8String]));
  mkstemps(thePathBuffer, 4);
  NSString *thePath = [NSString stringWithUTF8String:thePathBuffer];
  return [NSURL fileURLWithPath:thePath];  
}

@end
