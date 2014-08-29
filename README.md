STTwitter-Sample
================

STTwitter を使った Sample

[CocoaPods](http://cocoapods.org/) を導入してご利用下さい。

```
$ sudo gem install cocoapods
$ pod install
```

HRConsumer.h で以下の2行に対し、Twitter から取得したアプリケーション毎の CONSUMER_KEY と CONSUMER_SECRET を設定する必要があります。

```
static NSString *const CONSUMER_KEY = @"";
static NSString *const CONSUMER_SECRET = @"";
```