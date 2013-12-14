AKWebRenderer
=============

AKWebRenderer is an experimental iOS library which allows you to render web pages into snapshot views. This repository hosts an example project **TwitterClient** to demonstrate how it works.

Install
-------

Requires iOS SDK 7.0 or above to build.
Requires iOS 7.0 or above to run.

Usage
-----

AKMediaCache.h
AKMediaCache.m
AKWebRenderWorker.h
AKWebRenderWorker.m
AKWebRenderRequest.h
AKWebRenderRequest.m

About implementations
---------------------
There are several topics about workaround implementations. You can find many questionable codes in this library because of them, so I'm going to write down details and reasons as far as possible.

Determine when UIWebView truly finished loading:
http://stackoverflow.com/questions/10996028/uiwebview-when-did-a-page-really-finish-loading
http://stackoverflow.com/questions/5809212/how-do-i-tell-when-a-uiwebview-is-done-rendering-not-loading

Why using `- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets` instead of `- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` :

`- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` can create snapshot views much faster compared to `- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets`, but the view returned from `- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` is *dynamic*, which means its contains are updated when the source UIWebView contents are changed.

How to copy snapshot views from UIWebView:
http://ero.movie.coocan.jp/iPhone/AboutCameraApp.pdf

Views returned from `- (UIView *)resizableSnapshotViewFromRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates withCapInsets:(UIEdgeInsets)capInsets` are private subclass of `_UIReplicantView`, and they have a child view which inherits from a private class `_UIReplicantContentView`. `layer` property of `_UIReplicantContentView` object has a subview of `CASlotProxy` as its backing store (`layer.contents` property). As a result, we can't simply call `[layer renderInContext:]` to create a `CGImageRef` instance from layer. That's why I had to workaround this by creating a copy of view which shares `CASlotProxy` backing store with the original snapshot view.

Another problem here is there is no way to render UIWebView into CGContext in other than main thread. Doing so causes lock error and there are no workarounds for this problem as far as I can find.

TODO
----

- Multiple AKWebRenderWorker for better performance
- Caches rendered snapshots to disk
- Support for iOS 6 (Possibly negative because of how this library is implemented)

License
-------
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
