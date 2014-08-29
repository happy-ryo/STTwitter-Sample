//
//  HRViewController.m
//  STTwitter-Sample
//
//  Created by happy_ryo on 2014/08/30.
//

#import "HRViewController.h"
#import "STTwitterAPI.h"
#import "HRConsumer.h"

@interface HRViewController ()
@property(nonatomic, strong) STTwitterAPI *twitter;
@property(nonatomic, strong) UITextView *commentTextView;
@end

@implementation HRViewController {
    IBOutlet UITextView *_commentTextView;
    STTwitterAPI *_twitter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 画面サイズを取得
    CGRect mainScreenRect = [[UIScreen mainScreen] bounds];

    // Tweet する為のボタンを作成
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // サイズ指定
    tweetButton.frame = CGRectMake(0, 0, mainScreenRect.size.width, 40);
    // 表示される文字列を指定
    [tweetButton setTitle:@"Tweet" forState:UIControlStateNormal];
    // 表示される文字列の文字色を指定
    [tweetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 背景色を指定
    tweetButton.backgroundColor = [UIColor blackColor];
    // ボタンが押された時のイベントを指定
    // TouchUpInside 時に tweet メソッドが実行される
    [tweetButton addTarget:self action:@selector(tweet) forControlEvents:UIControlEventTouchUpInside];

    // キーボードの上に表示する物（ボタン）を設定する
    _commentTextView.inputAccessoryView = tweetButton;
    // 認証前に投稿内容を編集できないように
    _commentTextView.editable = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // HRConsumer.h の中の CONSUMER_KEY と CONSUMER_SECRET を設定して下さい
    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                 consumerKey:CONSUMER_KEY
                                              consumerSecret:CONSUMER_SECRET];

    // Blocks での循環参照を回避するため弱参照の変数を用意する
    __weak HRViewController *weakSelf = self;
    // Reverse Authentication を開始する
    [_twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        // iOS に登録されている、最初のアカウント情報を取得する
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        // 取得したアカウント情報の利用許可を得る
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            // 利用許可を得たアカウントで設定した CONSUMER_KEY のアプリケーションの認証を行い、oauth token を取得する
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                successBlock:^(NSString *oAuthToken,
                                                                        NSString *oAuthTokenSecret,
                                                                        NSString *userID,
                                                                        NSString *screenName) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // ナビゲーションバーにユーザー名を表示する
                    weakSelf.navigationItem.title = screenName;
                    // _twitter を oauthToken と oauthTokenSecret が設定された物に差し替える
                    weakSelf.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                                     consumerSecret:CONSUMER_SECRET
                                                                         oauthToken:oAuthToken
                                                                   oauthTokenSecret:oAuthTokenSecret];
                    // 投稿内容の編集を許可する
                    weakSelf.commentTextView.editable = YES;
                    // 投稿内容を入力するコンポーネントにフォーカスをあてる
                    [weakSelf.commentTextView becomeFirstResponder];
                });
            } errorBlock:^(NSError *error) {
                // ユーザーがTwitterの利用を承認していない場合は、承認用の画面へ遷移する
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf performSegueWithIdentifier:@"oauth" sender:nil];
                    });
                }
            }];

        }                                    errorBlock:^(NSError *error) {
            // ユーザーがTwitterの利用を承認していない場合は、承認用の画面へ遷移する
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf performSegueWithIdentifier:@"oauth" sender:nil];
                });
            }
        }];
    }                           errorBlock:^(NSError *error) {
        // ユーザーがTwitterの利用を承認していない場合は、承認用の画面へ遷移する
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performSegueWithIdentifier:@"oauth" sender:nil];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tweet {
    __weak HRViewController *weakSelf = self;
    // Twitter へステータスのアップデートを行う（不要なオプションには nil を）
    [_twitter postStatusUpdate:_commentTextView.text
             inReplyToStatusID:nil
                      mediaIDs:nil
                      latitude:nil
                     longitude:nil
                       placeID:nil
            displayCoordinates:nil
                      trimUser:nil
                  successBlock:^(NSDictionary *status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 投稿に成功したので入力内容をクリアする
            _commentTextView.text = @"";
            [weakSelf alert:@"投稿に成功しました"];
        });
    }
                    errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf alert:@"投稿に失敗しました"];
        });
    }];
}

- (void)alert:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sample" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
