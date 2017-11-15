//
//  CDViOSScanner.m
//  Dealr, Inc.
//

#import <AVFoundation/AVFoundation.h>
#import "CDViOSScanner.h"

@class UIViewController;

@interface CDViOSScanner () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UILabel *_label1;
    UILabel *_label2;
    UIButton *_cancelButton;
    UIButton *_torchButton;
    //UINavigationBar *_navcon;
    //UILabel *_navtitle;
    
    
    UIView *_highlightView;
    
}

@end

@implementation CDViOSScanner

/*-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (CDViOSScanner*)[super initWithWebView:theWebView];
    return self;
}*/

- (void) cordovaGetBC:(CDVInvokedUrlCommand *)command
{
    
    NSError *error = nil;

    int scannerOpeningWidth = 125;
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.webView.superview addSubview:_highlightView];
    
    _label1 = [[UILabel alloc] init];
    _label1.frame = CGRectMake(0, 0, self.webView.superview.bounds.size.width/2-scannerOpeningWidth/2, self.webView.superview.bounds.size.height);
    _label1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self.webView.superview addSubview:_label1];
    
    _label2 = [[UILabel alloc] init];
    _label2.frame = CGRectMake(self.webView.superview.bounds.size.width/2+scannerOpeningWidth/2, 0, self.webView.superview.bounds.size.width/2-scannerOpeningWidth/2, self.webView.superview.bounds.size.height);
    _label2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self.webView.superview addSubview:_label2];
    
    
    
   // UIButton *_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton = [[UIButton alloc] init];
[_cancelButton addTarget:self
               action:@selector(closeView:)
     forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(0, self.webView.superview.bounds.size.height-100, self.webView.superview.bounds.size.width/2-scannerOpeningWidth/2, 40.0);
    _cancelButton.transform=CGAffineTransformMakeRotation(M_PI / 2);

    [self.webView.superview addSubview:_cancelButton];
    
    _torchButton = [[UIButton alloc] init];
    [_torchButton addTarget:self
                      action:@selector(toggleFlashlight:)
            forControlEvents:UIControlEventTouchUpInside];
    [_torchButton setTitle:@"Light" forState:UIControlStateNormal];
    _torchButton.frame = CGRectMake(self.webView.superview.bounds.size.width/2+scannerOpeningWidth/2, self.webView.superview.bounds.size.height-100, self.webView.superview.bounds.size.width/2-scannerOpeningWidth/2, 40.0);
    _torchButton.transform=CGAffineTransformMakeRotation(M_PI / 2);
    
    [self.webView.superview addSubview:_torchButton];
    
    
    

    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;

    
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                      AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeDataMatrixCode]];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.webView.superview.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    [self.webView.superview.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.webView.superview bringSubviewToFront:_label1];
    [self.webView.superview bringSubviewToFront:_label2];
    [self.webView.superview bringSubviewToFront:_highlightView];

    [self.webView.superview bringSubviewToFront:_cancelButton];
    [self.webView.superview bringSubviewToFront:_torchButton];
    
 // [self.webView.superview bringSubviewToFront:_navcon];
    
    _callback = command.callbackId;
    
    _barCodeTypes = command.arguments;
    
}
/*
@IBAction func didTouchFlashButton(sender: AnyObject) {
    let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    // check if the device has torch
    if avDevice.hasTorch {
        // lock your device for configuration
        avDevice.lockForConfiguration(nil)
        // check if your torchMode is on or off. If on turns it off otherwise turns it on
        if avDevice.torchActive {
            avDevice.torchMode = AVCaptureTorchMode.Off
        } else {
            // sets the torch intensity to 100%
            avDevice.setTorchModeOnWithLevel(1.0, error: nil)
        }
        // unlock your device
        avDevice.unlockForConfiguration()
    }
}*/

- (void) toggleFlashlight:(id)sender
{
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (device.torchMode == AVCaptureTorchModeOff)
            {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES;
            }
            else
            {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                // torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    } }

- (void) closeView :(id)sender{
    
    [_prevLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:NO];
    
    [_label1 performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    [_label2 performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    [_highlightView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    [_cancelButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    [_torchButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];

    
    //[_navtitle performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    //[_navcon performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    [_session stopRunning];
    
    [_session removeOutput:_output];
    
    [_session removeInput:_input];
    
    _output = nil;
    
    _input = nil;
    
    _device = nil;
    
    _session = nil;
    
    _barCodeResults = @[@"",@"",@"0"];
    
    CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: _barCodeResults];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callback];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                             AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeDataMatrixCode];
    
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                
                highlightViewRect = barCodeObject.bounds;
                _highlightView.frame = highlightViewRect;
                
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                _barCodeResults = @[[(AVMetadataMachineReadableCodeObject *)metadata stringValue],metadata.type,@"1"];
                    break;
            }
        }
        if (detectionString != nil)
        {
            [_prevLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:NO];
            
            [_label1 performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            [_label2 performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            [_highlightView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];

            [_cancelButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            [_torchButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];

            //[_navtitle performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            //[_navcon performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            
            [_session stopRunning];
            
            [_session removeOutput:_output];
            
            [_session removeInput:_input];
            
            _output = nil;
            
            _input = nil;
            
            _device = nil;
            
            _session = nil;
            
            CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray : _barCodeResults];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_callback];
            
            break;
            
        }
        else
            _label1.text = @"Scanning";
    }

    
}
@end
