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
#import <MBProgressHUD/MBProgressHUD.h>
#import "PQCheckRecordSelfieViewController.h"
#import "PQCheckFaceShape.h"
#import "PQCheckDigestLabel.h"
#import "PQCheckSettings.h"
#import "SDAVAssetExportSession.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "NSString+Utils.h"

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
static const CGFloat kInstructionLabelVerticalOffset = 40.0f;
static const CGFloat kDelayBeforeStartRecording = 1.0f;
static const NSTimeInterval kPaceRate = 0.85f;
static const NSTimeInterval kDelayBeforeDigestDismissal = 1.0f;
static const NSTimeInterval kMinimumAcceptableRecordingDuration = 1.0f;
static const NSTimeInterval kDelayBetweenReattempt = 1.0f;
static const int32_t kDefaultFaceLockedThreshold = 64;
static const int32_t kDefaultFaceLockedAngleTolerance = 15;
static NSString* const kDefaultBannerBackgroundColourHexString = @"#0db94e";
static NSString* const kDefaultMovieOutputName = @"output.mp4";

@interface PQCheckRecordSelfieViewController () <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, PQCheckDigestLabelDelegate>
{
    BOOL _isRecording;
    AVCaptureDevice *_camera;
    AVCaptureDevice *_microphone;
    AVCaptureSession *_captureSession;
    AVCaptureDeviceInput *_cameraInput;
    AVCaptureDeviceInput *_microphoneInput;
    AVCaptureMovieFileOutput *_movieFileOutput;
    AVCaptureVideoDataOutput *_videoDataOutput;
    dispatch_queue_t _videoDataOutputQueue;
    CIDetector *_faceDetector;
    UILabel *_instructionLabel;
    UIColor *_bannerBackgroundColor;
    PQCheckDigestLabel *_digestLabel;
    PQCheckFaceShape *_faceShape;
    UIButton *_startStopButton;
    NSUInteger _faceLockCounter;
    BOOL _faceLocked;
    UIColor *_faceShapeColor;
    UIView *_customOverlayView;
    UIView *_howToView;
    NSTimeInterval _startHoldTime, _endHoldTime;
    PQCheckSelfieMode _mode;
    NSInteger _faceLockedThreshold;
    NSInteger _faceLockedAngleTolerance;
}
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation PQCheckRecordSelfieViewController

- (id)initWithPQCheckSelfieMode:(PQCheckSelfieMode)mode transcript:(NSString *)transcript
{
    NSLog(@"++++++++++ %s", __PRETTY_FUNCTION__);
    self = [super init];
    if (self)
    {
        _transcript = transcript;
        _customOverlayView = nil;
        _mode = mode;
        _faceLockedThreshold = [PQCheckSettings PQCheckFaceLockThreshold];
        if (_faceLockedThreshold <= 0)
        {
            _faceLockedThreshold = kDefaultFaceLockedThreshold;
        }

        _faceLockedAngleTolerance = [PQCheckSettings PQCheckFaceLockAngleTolerance];
        if (_faceLockedAngleTolerance <= 0)
        {
            _faceLockedAngleTolerance = kDefaultFaceLockedAngleTolerance;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _isRecording = NO;
    
    [self registerNotificationListeners];
    
    _faceLockCounter = 0;
    _faceDetector = nil;
    _faceShapeColor = [UIColor whiteColor];
    
    NSString *hexString = [PQCheckSettings PQCheckBannerBackgroundColourHexString];
    if ([NSString isStringNilEmptyOrNewLine:hexString])
    {
        hexString = kDefaultBannerBackgroundColourHexString;
    }
    _bannerBackgroundColor = [UIColor colorFromHexString:hexString];

    [self setUpAVCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"++++++++++ %s", __PRETTY_FUNCTION__);
    
    [self tearDownAVCapture];
    
    [self unregisterNotificationListeners];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.pacingEnabled)
    {
        if (self.shouldShowInstructions)
        {
            [self showInstructionScreen];
        }
        else
        {
            [self faceSearchAndStartRecording];
        }
    }
}

- (PQCheckSelfieMode)currentSelfieMode
{
    return _mode;
}

- (void)reattemptSelfie
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;

    if (self.pacingEnabled)
    {
        [_captureSession removeOutput:_movieFileOutput];
        [_videoDataOutput setSampleBufferDelegate:nil queue:_videoDataOutputQueue];
        _videoDataOutputQueue = nil;
        _videoDataOutput = nil;
        _faceDetector = nil;
        _faceLocked = NO;
        _faceLockCounter = 0;
    }
    
    __unsafe_unretained PQCheckRecordSelfieViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayBetweenReattempt * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [hud hide:YES];
        
        if (weakSelf.pacingEnabled)
        {
            [weakSelf faceSearchAndStartRecording];
        }
        else
        {
            [_startStopButton setEnabled:YES];
            [_startStopButton setHidden:NO];
        }
    });
}

- (void)setTranscript:(NSString *)transcript
{
    _transcript = transcript;
    
    [self configureDigestLabel];
}

- (void)setBannerBackgroundColor:(UIColor *)color
{
    _bannerBackgroundColor = color;
    
    if (_instructionLabel)
    {
        _instructionLabel.backgroundColor = color;
    }
    
    if (_digestLabel)
    {
        _digestLabel.backgroundColor = color;
    }
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
        _faceShapeColor = color;
        [self.view insertSubview:_faceShape belowSubview:_digestLabel];
    }
}

- (IBAction)recordButtonToggled:(id)sender
{
    [_digestLabel show];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

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
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[outputFileURL path]] == NO)
    {
        recordingWasSuccessful = NO;
        if (error == nil)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The recorded media is not found, perhaps it's too short", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
            error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:404 userInfo:userInfo];
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
        __unsafe_unretained PQCheckRecordSelfieViewController *weakSelf = self;
        [encoder exportAsynchronouslyWithCompletionHandler:^{
            if (encoder.status == AVAssetExportSessionStatusCompleted)
            {
                NSLog(@"Recording is successful, the movie is saved at %@", targetURL);
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[targetURL path] error:nil];
                NSLog(@"File-size: %@ bytes", [fileAttributes objectForKey:NSFileSize]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate selfieViewController:self didFinishWithMediaURL:targetURL];
                });
            }
            else if (encoder.status == AVAssetExportSessionStatusCancelled)
            {
                NSLog(@"Export is cancelled");
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The export of recorded media was cancelled", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:400 userInfo:userInfo];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate selfieViewController:weakSelf didFailWithError:error];
                });
            }
            else
            {
                NSLog(@"Export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);

                NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:encoder.error.code userInfo:encoder.error.userInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate selfieViewController:weakSelf didFailWithError:error];
                });
            }
        }];
    }
    else
    {
        NSLog(@"Recording is not successful, error: %@", [error localizedDescription]);

        __unsafe_unretained PQCheckRecordSelfieViewController *weakSelf = self;
        NSError *sdkError = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:error.code userInfo:error.userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate selfieViewController:weakSelf didFailWithError:sdkError];
        });
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)    captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection
{
    // Get the image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments)
    {
        CFRelease(attachments);
    }
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSDictionary *imageOptions = @{CIDetectorImageOrientation: [self exifOrientation:orientation]};
    
    NSArray *features = [_faceDetector featuresInImage:ciImage options:imageOptions];
    
    __unsafe_unretained PQCheckRecordSelfieViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_faceLocked == NO)
        {
            _instructionLabel.hidden = NO;
            
            // Conditions:
            // 1. One facial feature only
            // 2. 0.0 face angle
            // 3. Has mouth
            // 4. Has left and right eyes
            if (features != nil && [features count] == 1)
            {
                for (CIFaceFeature *faceFeature in features)
                {
                    NSInteger angle = (NSInteger)fabsf(faceFeature.faceAngle);
                    if (angle <= _faceLockedAngleTolerance && faceFeature.hasMouthPosition &&
                        faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition)
                    {
                        _faceLockCounter++;
                    }
                    else
                    {
                        _faceLockCounter = 0;
                    }
                }
                
                if (_faceLockCounter < _faceLockedThreshold/3)
                {
                    _instructionLabel.text = NSLocalizedString(@"Align your face", @"Align your face");
                }
                else if (_faceLockCounter < _faceLockedThreshold)
                {
                    _instructionLabel.text = NSLocalizedString(@"Great, hold still", @"Great, hold still");
                }
                else
                {
                    _instructionLabel.text = NSLocalizedString(@"Read out the number!", @"Reaad out the number!");
                }
                [_instructionLabel setNeedsDisplay];
                
                if (_faceLockCounter > _faceLockedThreshold)
                {
                    _faceLocked = YES;

                    [_faceShape setLineColor:_faceShapeColor];
                    
                    // Start recording
                    [_captureSession removeOutput:_videoDataOutput];
                    if ([_captureSession canAddOutput:_movieFileOutput])
                    {
                        [_captureSession addOutput:_movieFileOutput];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayBeforeStartRecording * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            _instructionLabel.text = @"";
                            _instructionLabel.hidden = YES;
                            
                            [weakSelf startRecording];
                            [_digestLabel showAnimatedWithDelayInterval:kPaceRate];
                        });
                    }
                    
                    [_videoDataOutput setSampleBufferDelegate:nil queue:_videoDataOutputQueue];
                    _videoDataOutputQueue = nil;
                    _videoDataOutput = nil;
                    _faceDetector = nil;
                }
            }
            else
            {
                // Reset the counter, we need to get at least 64 samples
                _faceLockCounter = 0;
                _instructionLabel.hidden = NO;
                _instructionLabel.text = NSLocalizedString(@"Align your face", @"Align your face");
                [_instructionLabel setNeedsDisplay];
            }
        }
        
        if (_faceLocked == NO)
        {
            UIColor *color = [UIColor colorWithRed:((CGFloat)_faceLockedThreshold - _faceLockCounter)/(CGFloat)_faceLockedThreshold green:_faceLockCounter/(CGFloat)_faceLockedThreshold blue:0.0f alpha:1.0f];
            [_faceShape setLineColor:color];
        }
    });
}

#pragma mark - Private methods

- (void)configureDigestLabel
{
    assert(self.transcript != nil && self.transcript.length > 0);
    
    _digestLabel = [[PQCheckDigestLabel alloc] initWithDigest:self.transcript];
    _digestLabel.labelColor = [UIColor whiteColor];
    _digestLabel.backgroundColor = _bannerBackgroundColor;
    [self.view insertSubview:_digestLabel aboveSubview:_faceShape];
    _digestLabel.center = self.view.center;
    CGRect frame = _digestLabel.frame;
    frame.origin.y = kDigestLabelVerticalOffset;
    _digestLabel.frame = frame;
    _digestLabel.delegate = self;
}

- (void)configureInstructionLabel
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width * 0.8, 40.0f);
    _instructionLabel = [[UILabel alloc] initWithFrame:frame];
    _instructionLabel.textColor = [UIColor whiteColor];
    _instructionLabel.backgroundColor = _bannerBackgroundColor;
    _instructionLabel.font = [UIFont fontWithName:@"Avenir-Book" size:24.0f];
    _instructionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_instructionLabel];
    _instructionLabel.center = self.view.center;
    frame = _instructionLabel.frame;
    frame.origin.y = kInstructionLabelVerticalOffset;
    _instructionLabel.frame = frame;
    _instructionLabel.text = @"";
    _instructionLabel.hidden = YES;
}

- (void)configureFaceShape
{
    if (_customOverlayView == nil)
    {
        // The frame of _faceShape will be overwritten by its default value
        _faceShape = [[PQCheckFaceShape alloc] initWithFrame:CGRectZero];
        _faceShape.outerFillColor = _faceShapeColor;
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

- (void)showInstructionScreen
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    _howToView = [[UIView alloc] initWithFrame:rect];
    _howToView.backgroundColor = _bannerBackgroundColor;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *leftImage = [UIImage imageNamed:@"how_to_left" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:leftImage];
    leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat imageWidth = (size.width - 40.0f)/2.0f;
    CGSize imageSize = CGSizeMake(imageWidth, imageWidth*(435.0f/294.0f));
    leftImageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    [_howToView addSubview:leftImageView];
    leftImageView.center = _howToView.center;
    CGRect frame = leftImageView.frame;
    frame.origin.x = 10.0f;
    frame.origin.y -= (64.0f + 10.0f)/2.0f;
    leftImageView.frame = frame;
    
    UIImage *rightImage = [UIImage imageNamed:@"how_to_right" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:rightImage];
    rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    rightImageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    [_howToView addSubview:rightImageView];
    rightImageView.center = _howToView.center;
    frame = rightImageView.frame;
    frame.origin.x = size.width - imageSize.width - 10.0f;
    frame.origin.y -= (64.0f + 10.0f)/2.0f;
    rightImageView.frame = frame;
    
    frame = CGRectMake(leftImageView.frame.origin.x,
                       leftImageView.frame.origin.y + imageSize.height + 10.0f,
                       imageSize.width,
                       64.0f);
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:frame];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.font = [UIFont fontWithName:@"Avenir-Book" size:24.0f];
    leftLabel.adjustsFontSizeToFitWidth = YES;
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.numberOfLines = -1;
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.text = NSLocalizedString(@"Align your face within the dotted line", @"Align your face within the dotted line");
    [_howToView addSubview:leftLabel];

    frame = CGRectMake(rightImageView.frame.origin.x,
                       rightImageView.frame.origin.y + imageSize.height + 10.0f,
                       imageSize.width,
                       64.0f);
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:frame];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.font = [UIFont fontWithName:@"Avenir-Book" size:24.0f];
    rightLabel.adjustsFontSizeToFitWidth = YES;
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.numberOfLines = -1;
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.text = NSLocalizedString(@"Read out each number as it is shown", @"Read out each number as it is shown");
    [_howToView addSubview:rightLabel];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"arrow_down" inBundle:bundle compatibleWithTraitCollection:nil];
    [dismissButton setImage:image forState:UIControlStateNormal];
    [dismissButton setFrame:CGRectMake(size.width - 60, size.height - 60, 40.0f, 40.0f)];
    [dismissButton addTarget:self action:@selector(dismissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_howToView addSubview:dismissButton];
    
    frame = _howToView.frame;
    frame.origin.y = size.height;
    _howToView.frame = frame;
    [self.view addSubview:_howToView];
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect viewFrame = _howToView.frame;
        viewFrame.origin.y = 0.0f;
        _howToView.frame = viewFrame;
    } completion:nil];
}

- (void)faceSearchAndStartRecording
{
    if (self.pacingEnabled)
    {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        _faceLockCounter = 0;
        
        [_captureSession removeOutput:_movieFileOutput];
        [self configureVideoDataOutput];
    }
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

- (void)configureVideoDataOutput
{
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // BGRA works better with CoreGraphics and OpenGL
    NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCMPixelFormat_32BGRA]};
    [_videoDataOutput setVideoSettings:rgbOutputSettings];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Discard frames if the data output queue is blocked
    
    // Create a serial dispatch queue to process the video frames in an orderly/serial fashion
    _videoDataOutputQueue = dispatch_queue_create("com.post-quantum.pqcheck.video_data_output.queue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    
    if ([_captureSession canAddOutput:_videoDataOutput])
    {
        [_captureSession addOutput:_videoDataOutput];
    }
    
    [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
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
        [_startStopButton setEnabled:NO];
        [_startStopButton setHidden:YES];
        
        // Press-and-hold, this indicates the ending of a hold action
        _endHoldTime = [[NSDate date] timeIntervalSince1970];
        
        [self stopRecording];
        
        [_digestLabel dismiss];
        
        CGFloat delta = _endHoldTime - _startHoldTime;
        if (delta < kMinimumAcceptableRecordingDuration)
        {
            // The recording is way too short, we should ignore the video
            NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:kDefaultMovieOutputName];
            NSURL *url = [[NSURL alloc] initFileURLWithPath:outputPath isDirectory:NO];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
    }
}

- (void)dismissButtonTapped:(id)sender
{
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGRect viewFrame = _howToView.frame;
        viewFrame.origin.y = size.height;
        _howToView.frame = viewFrame;
    } completion:^(BOOL finished) {
        [_howToView removeFromSuperview];
        
        if (self.pacingEnabled)
        {
            [self faceSearchAndStartRecording];
        }
    }];
}

- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
    int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}

- (void)setUpAVCapture
{
    NSError *error = nil;
    if ([self configureCaptureDevice:&error])
    {
        error = nil;
        if ([self configureCaptureSession:&error])
        {
            [self configureOutputProperties];
            [self configureCaptureQuality];
            
            [_captureSession startRunning];
        }
    }
    
    assert(_captureSession != nil);
    [self configurePreviewLayer];
    [self configureFaceShape];
    [self configureDigestLabel];
    [self configureInstructionLabel];
    if (self.pacingEnabled == NO)
    {
        [self configureStartStopButton];
    }
}

- (void)tearDownAVCapture
{
    [_videoDataOutput setSampleBufferDelegate:nil queue:_videoDataOutputQueue];
    _videoDataOutputQueue = nil;
    _videoDataOutput = nil;
    _faceDetector = nil;
    
    _faceLocked = NO;
    _faceLockCounter = 0;
    
    _camera = nil;
    _microphone = nil;
    _captureSession = nil;
    _cameraInput = nil;
    _microphoneInput = nil;
    _movieFileOutput = nil;
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
        _digestLabel.delegate = nil;
        _digestLabel = nil;
    });
    [self stopRecording];
}

@end
