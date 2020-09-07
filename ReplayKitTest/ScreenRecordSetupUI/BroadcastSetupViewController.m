//
//  BroadcastSetupViewController.m
//  ScreenRecordSetupUI
//
//  Created by yfm on 2020/9/7.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = UIColor.redColor;
        
    [self userDidFinishSetup];
    
    UIButton *stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 50)];
    stopBtn.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
    [stopBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
}

- (void)btnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    NSDictionary *setupInfo = @{ @"broadcastName" : @"example" };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
