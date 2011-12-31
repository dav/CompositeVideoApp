//
//  AVManager.h
//  CompositeVideoApp
//
//  Created by dav on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
  BOOL isRecording;
}

@property (nonatomic, retain) UIView* previewView;
@property (nonatomic, retain) AVCaptureSession* captureSession;
@property (nonatomic, retain) AVCaptureDevice* captureDevice;
@property (nonatomic, retain) AVAssetWriter* assetWriter;
@property (nonatomic, retain) AVAssetWriterInput* assetWriterInput;
@property (nonatomic) CMTime recordStartTime;

- (id) initWithViewForPreview:(UIImageView*)aView;
- (void) toggleRecording;

@end
