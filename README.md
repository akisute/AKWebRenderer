# AKWebRenderer

AKWebRenderer is an experimental iOS library which allows you to render web pages into snapshot views. This repository hosts an example project **TwitterClient** to demonstrate how it works.

## Install

Requires iOS SDK 7.0 or above to build.
Requires iOS 7.0 or above to run.

**WARNING:** This library does not work in iOS 9 or later. See later sections for more details.

## Usage

Just include following files to your project:

- AKMediaCache.h
- AKMediaCache.m
- AKWebRenderWorker.h
- AKWebRenderWorker.m
- AKWebRenderRequest.h
- AKWebRenderRequest.m
- 
## About example project

The example project `TwitterClient` renders timeline tweets of the first Twitter account available through `Social.framework`. You need to add a Twitter account from `Settings -> Twitter` to run this example. After adding an account, you'll see 3 different kinds of tweets in UICollectionView, which are:

- Plain text tweets, when no links or media are embedded.
- Link URL tweets, when only links are embedded.
- Image tweets, when images are embedded.

In this example project, image tweets are rendered asynchronously using `AKMediaCache` and underlying `AKWebRenderWorker` and `AKWebRenderRequest`. You can see image tweets are asynchronously rendered into cells.

## About implementations

There are several topics about implementations of workarounds. You can find many questionable codes in this library because of them, so I'm going to write down details and reasons as far as possible.

### Determine when UIWebView truly finished loading

http://stackoverflow.com/questions/10996028/uiwebview-when-did-a-page-really-finish-loading
http://stackoverflow.com/questions/5809212/how-do-i-tell-when-a-uiwebview-is-done-rendering-not-loading

### How to create snapshots

`- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` can create snapshot views much faster compared to `- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect...`, but the view returned from `- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` is *dynamic*, which means its contains are updated when the source UIWebView contents are changed. In short, you can't copy the snapshot view. This means you have to create a different instance of UIWebView each time you need to return snapshots and keep them allocated until these snapshots are no longer allocated, which makes no sence.

Another way you might want to try to make a copy of snapshot is to render snapshot into UIImage(or CGImage) by using `CALayer.render(in ctx: CGContext)`. Another problem here is there is no way to render UIWebView into CGContext in other than main thread. Rendering layer in non-main thread causes lock error and there are no workarounds for this problem as far as I can find. This is why I somehow have to find out the workaround below.

### How to copy snapshot views from UIWebView

http://ero.movie.coocan.jp/iPhone/AboutCameraApp.pdf

Views returned from `- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect...` are instances of private subclass named `_UIReplicantView`, and they have a child view which inherits from a private class `_UIReplicantContentView`. `layer` property of `_UIReplicantContentView` is an instance of `CALayer` which `contents` property (or "backing store", so to speak) holds an instance of `CASlotProxy`. Here's a view hierarchy tree:

```
(lldb) expr cachedView = [someView resizableSnapshotViewFromRect:rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero]
<_UIReplicantView: 0x13c773e90; frame = (0 0; 144 144); layer = <_UIReplicantLayer: 0x13c75fbb0>>

(lldb) po [cachedView recursiveDescription]
<_UIReplicantView: 0x13c773e90; frame = (0 0; 144 144); layer = <_UIReplicantLayer: 0x13c75fbb0>>
   | <_UIReplicantContentView: 0x13d922410; frame = (0 0; 144 144); layer = <_UIReplicantLayer: 0x13d921ab0>>

(lldb) po (_UIReplicantLayer)0x13d921ab0
<_UIReplicantLayer:0x13d921ab0; position = CGPoint (72 72); bounds = CGRect (0 0; 144 144); delegate = <_UIReplicantContentView: 0x13d922410; frame = (0 0; 144 144); layer = <_UIReplicantLayer: 0x13d921ab0>>; contents = <CASlotProxy: 0x13c70a800>; opaque = YES; allowsGroupOpacity = YES; rasterizationScale = 2; contentsScale = 2>
```

`CASlotProxy` is seemed to be an subclass of `NSProxy`. If it were an subclass of `NSData` or `UIImage` or anything like that we can simply render it into `CGContext` using Core Graphics functions, but it isn't. That's why I had to workaround this by creating a copy of view which shares `CASlotProxy` backing store with the original snapshot view. However, this workaround is no longer working in iOS 9 or later (confirmed on device, iOS 9.3.4/iPhone 6s).

## TODO

- Multiple AKWebRenderWorker for better performance
- Caches rendered snapshots to disk
- Support for iOS 6 (Possibly negative because of how this library is implemented)

## License

http://opensource.org/licenses/MIT

    The MIT License (MIT)
    
    Copyright (c) 2013 Masashi Ono.
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
