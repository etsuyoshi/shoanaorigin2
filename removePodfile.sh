#!/bin/sh
# 派生ファイルを削除する
rm -rf ~/Library/Developer/Xcode/DerivedData/

rm Podfile.lock
rm -rf Pods
rm -rf *.xcworkspace

#podfile更新する
pod install
open *.xcworkspace
