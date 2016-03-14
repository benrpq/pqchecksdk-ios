/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PQCheckRecordSelfieViewController.h"
#import "PQCheckFaceShape.h"
#import "PQCheckDigestLabel.h"
#import "SDAVAssetExportSession.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"

static const Float64 kMaximumRecordingDurationInSeconds = 15.0;
static const int32_t kVideoFramePerSecond = 10;
static const int32_t kVideoWidth = 480;
static const int32_t kVideoHeight = 360;
static const int32_t kAverageVideoBitRate = 480000;
static const int32_t kAverageAudioBitRate = 32000;
static const int32_t kAudioSamplingRate = 22050;
static const int32_t kAudioNumberOfChannels = 1;
static const int32_t kMinimumFreeDiskSpaceLimit = 1048576;
static const CGFloat kDigestLabelVerticalOffset = 40.0f;
static const NSTimeInterval kDotAnimationInterval = 0.85f;
static const NSTimeInterval kDotAnimationDelayInterval = 1.0f;
static const NSTimeInterval kPaceRate = 0.85f;
static const NSTimeInterval kDelayBeforeDigestDismissal = 1.0f;
static const NSTimeInterval kMinimumAcceptableRecordingDuration = 2.0f;
static NSString* const kDefaultMovieOutputName = @"output.mp4";

@interface PQCheckRecordSelfieViewController () <AVCaptureFileOutputRecordingDelegate, PQCheckDigestLabelDelegate>
{
    BOOL _isRecording;
    AVCaptureDevice *_camera;
    AVCaptureDevice *_microphone;
    AVCaptureSession *_captureSession;
    AVCaptureDeviceInput *_cameraInput;
    AVCaptureDeviceInput *_microphoneInput;
    AVCaptureMovieFileOutput *_movieFileOutput;
    PQCheckDigestLabel *_digestLabel;
    PQCheckFaceShape *_faceShape;
    UIButton *_startStopButton;
    UIView *_dot[3];
    UIView *_customOverlayView;
    NSTimeInterval _startHoldTime, _endHoldTime;
    PQCheckSelfieMode _mode;
}
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation PQCheckRecordSelfieViewController

- (id)initWithPQCheckSelfieMode:(PQCheckSelfieMode)mode transcript:(NSString *)transcript
{
    self = [super init];
    if (self)
    {
        _transcript = transcript;
        _customOverlayView = nil;
        _mode = mode;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _isRecording = NO;
    
    [self registerNotificationListeners];
    
    NSError *error = nil;
    if ([self configureCaptureDevice:&error])
    {
        error = nil;
        if ([self configureCaptureSession:&error])
        {
            [self configureOutputProperties];
            [self configureCaptureQuality];
        }
    }
    
    assert(_captureSession != nil);
    [self configurePreviewLayer];
    [self configureFaceShape];
    [self configureDigestLabel];
    if (self.pacingEnabled == NO)
    {
        [self configureStartStopButton];
    }
    
    [_captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self unregisterNotificationListeners];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self attemptSelfie];
}

- (PQCheckSelfieMode)currentSelfieMode
{
    return _mode;
}

- (void)attemptSelfie
{
    if (self.pacingEnabled)
    {
        [self startRecordingAnimationCompletion:^{
            [self startRecording];
            [_digestLabel showAnimatedWithDelayInterval:kPaceRate];
        }];
    }
}

- (void)setTranscript:(NSString *)transcript
{
    _transcript = transcript;
    
    [self configureDigestLabel];
}

- (void)setCustomOverlayView:(UIView *)overlayView
{
    _customOverlayView = overlayView;
}

- (void)enableSolidOverlayWithColor:(UIColor *)color opacity:(CGFloat)opacity
{
    if (_customOverlayView == nil)
    {
        [_faceShape removeFromSuperview];
        _faceShape.solidBackground = YES;
        _faceShape.outerFillColor = color;
        _faceShape.outerFillOpacity = opacity;
        [self.view insertSubview:_faceShape belowSubview:_digestLabel];
    }
}

- (void)enableTransparentOverlayWithLineColor:(UIColor *)color
{
    if (_customOverlayView == nil)
    {
        [_faceShape removeFromSuperview];
        _faceShape.solidBackground = NO;
        _faceShape.lineColor = color;
        [self.view insertSubview:_faceShape belowSubview:_digestLabel];
    }
}

- (IBAction)recordButtonToggled:(id)sender
{
    [_digestLabel show];
}

- (void)                   captureOutput:(AVCaptureFileOutput *)captureOutput
     didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                         fromConnections:(NSArray *)connections
                                   error:(NSError *)error
{
    BOOL recordingWasSuccessful = YES;
    if ([error code] != noErr)
    {
        // A problem has occurred, check whether or not recording was successful
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            recordingWasSuccessful = [value boolValue];
        }
    }
    
    if (recordingWasSuccessful)
    {
        // Export the movie it to document directory
        NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                              inDomains:NSUserDomainMask] lastObject];
        NSURL *targetURL = [documentDirectoryURL URLByAppendingPathComponent:kDefaultMovieOutputName isDirectory:NO];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[targetURL path]])
        {
            [[NSFileManager defaultManager] removeItemAtURL:targetURL error:nil];
        }

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
        SDAVAssetExportSession *encoder = [[SDAVAssetExportSession alloc] initWithAsset:asset];
        encoder.outputFileType = AVFileTypeMPEG4;
        encoder.outputURL = targetURL;
        encoder.videoSettings = @{
                                  AVVideoCodecKey: AVVideoCodecH264,
                                  AVVideoWidthKey: @(kVideoWidth),
                                  AVVideoHeightKey: @(kVideoHeight),
                                  AVVideoCompressionPropertiesKey: @{
                                          AVVideoAverageBitRateKey: @(kAverageVideoBitRate),
                                          AVVideoProfileLevelKey: AVVideoProfileLevelH264Main41
                                          },
                                  };
        encoder.audioSettings = @{
                                  AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                  AVNumberOfChannelsKey: @(kAudioNumberOfChannels),
                                  AVSampleRateKey: @(kAudioSamplingRate),
                                  AVEncoderBitRateKey: @(kAverageAudioBitRate),
                                  };
        [encoder exportAsynchronouslyWithCompletionHandler:^{
            if (encoder.status == AVAssetExportSessionStatusCompleted)
            {
                NSLog(@"Recording is successful, the movie is saved at %@", targetURL);
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[targetURL path] error:nil];
                NSLog(@"File-size: %@ bytes", [fileAttributes objectForKey:NSFileSize]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate selfieViewController:self didFinishWithMediaURL:targetURL];
                });
            }
            else if (encoder.status == AVAssetExportSessionStatusCancelled)
            {
                NSLog(@"Export is cancelled");
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The export of recorded media was cancelled", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:400 userInfo:userInfo];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate selfieViewController:self didFailWithError:error];
                });
            }
            else
            {
                NSLog(@"Export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);

                NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:encoder.error.code userInfo:encoder.error.userInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate selfieViewController:self didFailWithError:error];
                });
            }
        }];
    }
    else
    {
        NSLog(@"Recording is not successful, error: %@", [error localizedDescription]);

        NSError *sdkError = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:error.code userInfo:error.userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate selfieViewController:self didFailWithError:sdkError];
        });
    }
}

- (void)configureDigestLabel
{
    assert(self.transcript != nil && self.transcript.length > 0);
    
    _digestLabel = [[PQCheckDigestLabel alloc] initWithDigest:self.transcript];
    _digestLabel.labelColor = [UIColor colorWithRed:13.0f/255.0f green:185.0f/255.0f blue:78.0f/255.0f alpha:1.0f];
    [self.view insertSubview:_digestLabel aboveSubview:_faceShape];
    _digestLabel.center = self.view.center;
    CGRect frame = _digestLabel.frame;
    frame.origin.y = kDigestLabelVerticalOffset;
    _digestLabel.frame = frame;
    _digestLabel.delegate = self;
}

- (void)configureFaceShape
{
    if (_customOverlayView == nil)
    {
        // The frame of _faceShape will be overwritten by its default value
        _faceShape = [[PQCheckFaceShape alloc] initWithFrame:CGRectZero];
        _faceShape.outerFillColor = [UIColor whiteColor];
        _faceShape.outerFillOpacity = 0.95f;
        [self.view addSubview:_faceShape];
    }
    else
    {
        [self.view addSubview:_customOverlayView];
    }
        
}

- (void)configureStartStopButton
{
    CGSize viewSize = self.view.frame.size;
    CGFloat buttonDimension = 0.1*viewSize.height;
    
    CGRect frame = CGRectMake(0.0, 0.0, buttonDimension, buttonDimension);
    UIImage *normalImage = [UIImage circularImageWithRadius:0.5*buttonDimension
                                                  fillColor:[UIColor redColor]
                                                borderColor:[UIColor redColor]
                                             andBorderWidth:0.0f];
    UIImage *highlightedImage = [UIImage circularImageWithRadius:0.5*buttonDimension
                                                       fillColor:[[UIColor redColor] darkerColor]
                                                     borderColor:[[UIColor redColor] darkerColor]
                                                  andBorderWidth:0.0f];
    _startStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startStopButton setImage:normalImage forState:UIControlStateNormal];
    [_startStopButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [_startStopButton setFrame:frame];
    [self.view addSubview:_startStopButton];
    
    // Configure the location of the button
    [_startStopButton setCenter:self.view.center];
    frame = _startStopButton.frame;
    frame.origin.y = self.view.frame.size.height - (1.5*buttonDimension);
    _startStopButton.frame = frame;
    
    // Add shadow to this button
    _startStopButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _startStopButton.layer.shadowOpacity = 0.5f;
    
    // Link actions to this button
    [_startStopButton addTarget:self
                         action:@selector(recordButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    [_startStopButton addTarget:self
                         action:@selector(recordButtonTouchUp:)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)startRecordingAnimationCompletion:(void (^)(void))completionBlock
{
    CGSize viewSize = self.view.frame.size;
    CGFloat buttonDimension = 0.1*viewSize.height;
    CGRect frame = CGRectMake(0.0, 0.0, buttonDimension, buttonDimension);
    UIColor *greenColour = [UIColor colorWithRed:13.0f/255.0f green:185.0f/255.0f blue:78.0f/255.0f alpha:1.0f];
    
    _dot[0] = [[UIView alloc] initWithFrame:frame];
    _dot[0].backgroundColor = greenColour;
    _dot[0].layer.cornerRadius = 0.5*buttonDimension;
    _dot[0].layer.opacity = 0.0f;
    [self.view addSubview:_dot[0]];
    
    _dot[1] = [[UIView alloc] initWithFrame:frame];
    _dot[1].backgroundColor = greenColour;
    _dot[1].layer.cornerRadius = 0.5*buttonDimension;
    _dot[1].layer.opacity = 0.0f;
    [self.view addSubview:_dot[1]];

    _dot[2] = [[UIView alloc] initWithFrame:frame];
    _dot[2].backgroundColor = greenColour;
    _dot[2].layer.cornerRadius = 0.5*buttonDimension;
    _dot[2].layer.opacity = 0.0f;
    [self.view addSubview:_dot[2]];

    // Configure the location of the dots
    [_dot[1] setCenter:self.view.center];
    frame = _dot[1].frame;
    frame.origin.y = self.view.frame.size.height - (1.5*buttonDimension);
    _dot[1].frame = frame;
    
    frame = _dot[0].frame;
    frame.origin.y = _dot[1].frame.origin.y;
    frame.origin.x = _dot[1].frame.origin.x - (1.5*buttonDimension);
    _dot[0].frame = frame;
    
    frame = _dot[2].frame;
    frame.origin.y = _dot[1].frame.origin.y;
    frame.origin.x = _dot[1].frame.origin.x + (1.5*buttonDimension);
    _dot[2].frame = frame;
    
    [UIView animateWithDuration:kDotAnimationInterval delay:kDotAnimationDelayInterval options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _dot[0].layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kDotAnimationInterval delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _dot[1].layer.opacity = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kDotAnimationInterval delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _dot[2].layer.opacity = 1.0f;
            } completion:^(BOOL finished) {
                completionBlock();
                
                [_dot[0] removeFromSuperview];
                [_dot[1] removeFromSuperview];
                [_dot[2] removeFromSuperview];
            }];
        }];
    }];
}

- (BOOL)configureCaptureDevice:(NSError **)error
{
    // Initialise our capture devices
    _camera = nil;
    _microphone = nil;
    
    // We are only interested on the front camera
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (AVCaptureDevicePositionFront == [device position])
        {
            _camera = device; // We've got our device
        }
    }
    
    if (_camera == nil)
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }
    
    // Set the frame-rate of the camera
    *error = nil;
    BOOL frameRateSupported = NO;
    CMTime frameDuration = CMTimeMake(1, kVideoFramePerSecond);
    NSArray *supportedFrameRateRanges = [_camera.activeFormat videoSupportedFrameRateRanges];
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration))
        {
            frameRateSupported = YES;
        }
    }
    if (frameRateSupported && [_camera lockForConfiguration:error])
    {
        [_camera setActiveVideoMaxFrameDuration:frameDuration];
        [_camera setActiveVideoMinFrameDuration:frameDuration];
        [_camera unlockForConfiguration];
    }
    
    // Now it's time for microphone
    _microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (_microphone == nil)
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }
    
    return YES;
}

- (BOOL)configureCaptureSession:(NSError **)error
{
    _captureSession = [[AVCaptureSession alloc] init];

    // Ensure we have got our camera device
    assert(nil != _camera);
    assert(nil != _captureSession);
    
    // Initialise the camera input
    _cameraInput = nil;
    _microphoneInput = nil;
    
    // Request the camera input
    *error = nil;
    _cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_camera error:error];
    if (*error != nil)
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }

    // Attach the camera input to capture session
    if ([_captureSession canAddInput:_cameraInput])
    {
        [_captureSession addInput:_cameraInput];
    }
    else
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }
    
    // Request the microphone input
    *error = nil;
    _microphoneInput = [AVCaptureDeviceInput deviceInputWithDevice:_microphone error:error];
    if (*error != nil)
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }
    
    // Attach the microphone input to capture session
    if ([_captureSession canAddInput:_microphoneInput])
    {
        [_captureSession addInput:_microphoneInput];
    }
    else
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }

    // Add movie output file
    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    CMTime maxDuration = CMTimeMakeWithSeconds(kMaximumRecordingDurationInSeconds, kVideoFramePerSecond);
    _movieFileOutput.maxRecordedDuration = maxDuration;
    _movieFileOutput.minFreeDiskSpaceLimit = kMinimumFreeDiskSpaceLimit;
    
    if ([_captureSession canAddOutput:_movieFileOutput])
    {
        [_captureSession addOutput:_movieFileOutput];
    }
    else
    {
        // FIXME: return an appropriate NSError here
        return NO;
    }
    
    return YES;
}

- (void)configureOutputProperties
{
    AVCaptureConnection *captureConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([captureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [captureConnection setVideoOrientation:orientation];
    }
}

- (void)configureCaptureQuality
{
    assert(_captureSession != nil);
    
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
    {
        [_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    }
}

- (void)configurePreviewLayer
{
    assert(_captureSession != nil);
    
    // Add video preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect layerRect = self.view.layer.bounds;
    self.previewLayer.bounds = layerRect;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
    [self.view.layer addSublayer:self.previewLayer];
}

- (BOOL)startRecording
{
    _isRecording = YES;
    
    // Create a temporary URL to record to
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:kDefaultMovieOutputName];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:outputPath isDirectory:NO];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
    {
        NSError *error = nil;
        if ([[NSFileManager defaultManager] removeItemAtPath:outputPath error:&error] == NO)
        {
            return NO;
        }
    }
    [_movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    
    return YES;
}

- (void)stopRecording
{
    _isRecording = NO;
    [_movieFileOutput stopRecording];
}

- (void)recordButtonTouchDown:(id)sender
{
    if (self.isPacingEnabled == NO)
    {
        // Press-and-hold, this indicates the beginning of a hold action
        _startHoldTime = [[NSDate date] timeIntervalSince1970];

        [_digestLabel show];
        
        [self startRecording];
    }
}

- (void)recordButtonTouchUp:(id)sender
{
    if (self.isPacingEnabled == NO)
    {
        // Press-and-hold, this indicates the ending of a hold action
        _endHoldTime = [[NSDate date] timeIntervalSince1970];
        
        [self stopRecording];
        
        [_digestLabel dismiss];
        
        CGFloat delta = _endHoldTime - _startHoldTime;
        if (delta < kMinimumAcceptableRecordingDuration)
        {
            // The recording is way too short, we should ignore the video
        }
    }
}

#pragma mark - Notification handlers and listeners

- (void)registerNotificationListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationLifeCycleNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)unregisterNotificationListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)handleApplicationLifeCycleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification])
    {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - PQCheckDigestLabel delegate

- (void)PQCheckDigestLabel:(PQCheckDigestLabel *)digestLabel didFinishAnimationWithSuccess:(BOOL)success
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayBeforeDigestDismissal * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [_digestLabel dismiss];
    });
    [self stopRecording];
}

@end
