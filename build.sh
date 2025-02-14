#!/bin/zsh

# https://www.jianshu.com/p/3f43370437d2
# http://liumh.com/2015/11/25/ios-auto-archive-ipa/

################################################################################


# ./build.sh debug  任何以 d 开头的参数, 打测试环境的包
# ./build.sh        没参数, 打正环境的包

# 给测试的包一定是 Release, 包里面的代码是经过编译器优化的
# 然后是区分环境, 根据 DBG 宏来选择连哪个服务器

# DEBUG 宏表示程序员 cmd+r
# DBG 宏表示连接测试服

################################################################################

echo 'preparing parameters...'

PROJECT_NAME="TmallApp.xcworkspace"
SCHEME_NAME="TmallApp"
OUTPUT_PATH="`pwd`/build"

DERIVED_PATH="$OUTPUT_PATH/derived"
ARCHIVE_PATH="$OUTPUT_PATH/$SCHEME_NAME-`date +'%Y-%m-%d_%H%M%S'`.xcarchive"
EXPORT_PATH="$OUTPUT_PATH/export"
EXPORT_OPTIONS_PATH="$OUTPUT_PATH/export-options.plist"

if [[ $1 == d* ]]; then
CONDITIONS='${inherited} DBG'
else
CONDITIONS='${inherited}'
fi


echo 'preparing...'
rm -rf $OUTPUT_PATH
mkdir $OUTPUT_PATH


echo 'archiving...'
xcodebuild archive \
  -workspace $PROJECT_NAME -scheme $SCHEME_NAME -configuration Release -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath $DERIVED_PATH \
  -archivePath $ARCHIVE_PATH \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS="${CONDITIONS}"
if [[ $? -ne 0 ]]; then
  printf '\7'
  exit 1
fi


echo 'exporting...'
cat > $EXPORT_OPTIONS_PATH << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>compileBitcode</key>
  <true/>
  <key>destination</key>
  <string>export</string>
  <key>method</key>
  <string>development</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>signingCertificate</key>
  <string>Apple Development: Kevin Wu (S49737847Q)</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>com.hi.tmallapp</key>
    <string>8e53e8d9-8ef5-44df-aca5-61eeb38dd4d2</string>
  </dict>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
EOL

xcodebuild -exportArchive \
  -archivePath $ARCHIVE_PATH \
  -exportPath $EXPORT_PATH \
  -exportOptionsPlist $EXPORT_OPTIONS_PATH
if [[ $? -ne 0 ]]; then
  printf '\7'
  exit 2
fi


printf '\7'
printf '\n\n\n    >>> DONE <<<\n\n\n'
