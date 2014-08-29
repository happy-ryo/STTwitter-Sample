//
// Created by happy_ryo on 2014/08/30.
//
#import "HRAuthViewController.h"
#import "HRConsumer.h"
#import "STTwitterAPI.h"


@implementation HRAuthViewController {
    STTwitterAPI *_twitter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                             consumerSecret:CONSUMER_SECRET];
}

// Login ボタンが押されると実行される
- (IBAction)tapCloseButton {
    __weak HRAuthViewController *weakSelf = self;

    [_twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                successBlock:^(NSString *oAuthToken,
                                                                        NSString *oAuthTokenSecret,
                                                                        NSString *userID,
                                                                        NSString *screenName) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            } errorBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf failAlert];
                });
            }];

        }                                    errorBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf failAlert];
            });
        }];
    }                           errorBlock:^(NSError *error) {
        if (error.code == 401) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf failAlert];
            });
        }
    }];
}

- (void)failAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sample" message:@"Twitter と iOS の連携設定、またはこのアプリケーションへの許可設定を行って下さい" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end