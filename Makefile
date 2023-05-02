BUILD_TYPE=Release
VERSION=1.4.0
COREML=true

ifeq ($(COREML),false)
    COREML_COMMAND := -DWHISPER_COREML=0
	RUNTIME_OUTPUT_PATH := runtimes/
	APPLE_OUTPUT_PATH := Whisper.net.Runtime/
else
    COREML_COMMAND := -DWHISPER_COREML=1
	RUNTIME_OUTPUT_PATH := runtimes/coreml-
	APPLE_OUTPUT_PATH := Whisper.net.Runtime/coreml-
endif

nuget:
	mkdir -p nupkgs
	nuget pack Whisper.net.Runtime.nuspec -Version $(VERSION) -OutputDirectory ./nupkgs
	dotnet pack Whisper.net/Whisper.net.csproj -p:Version=$(VERSION) -o ./nupkgs -c $(BUILD_TYPE)

clean:
	rm -rf nupkgs
	rm -rf build
	rm -rf runtimes

android: android_x86 android_x64 android_arm64-v8a

apple: clean macos ios ios_64 maccatalyst_x64 maccatalyst_arm64 ios_simulator_x64 ios_simulator_arm64 tvos_simulator_x64 tvos_simulator_arm64 tvos lipo

linux: linux_x64 linux_arm64 linux_arm

linux_x64:
	rm -rf build/linux-x64
	cmake -S . -B build/linux-x64
	cmake --build build/linux-x64 --config $(BUILD_TYPE)
	cp build/linux-x64/whisper.cpp/libwhisper.so ./Whisper.net.Runtime/runtimes/linux-x64/whisper.so

linux_arm64:
	rm -rf build/linux-arm64
	cmake -S . -B build/linux-arm64
	cmake --build build/linux-arm64 --config $(BUILD_TYPE)
	cp build/linux-arm64/whisper.cpp/libwhisper.so ./Whisper.net.Runtime/runtimes/linux-arm64/whisper.so

linux_arm:
	rm -rf build/linux-arm
	cmake -S . -B build/linux-arm
	cmake --build build/linux-arm --config $(BUILD_TYPE)
	cp build/linux-arm/whisper.cpp/libwhisper.so ./Whisper.net.Runtime/runtimes/linux-arm/whisper.so

macos:
	rm -rf build/macos
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=MAC_UNIVERSAL -S . -B build/macos
	cmake --build build/macos
	mkdir -p $(RUNTIME_OUTPUT_PATH)macos
	cp build/macos/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)macos/libwhisper.dylib

ios:
	rm -rf build/ios
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=OS -S . -B build/ios
	cmake --build build/ios
	mkdir -p $(RUNTIME_OUTPUT_PATH)ios
	cp build/ios/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)ios/libwhisper.dylib

ios_64:
	rm -rf build/ios_64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=OS64 -S . -B build/ios_64
	cmake --build build/ios_64
	mkdir -p $(RUNTIME_OUTPUT_PATH)ios_64
	cp build/ios_64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)ios_64/libwhisper.dylib

maccatalyst_x64:
	rm -rf build/maccatalyst_x64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=MAC_CATALYST -S . -B build/maccatalyst_x64
	cmake --build build/maccatalyst_x64
	mkdir -p $(RUNTIME_OUTPUT_PATH)maccatalyst_x64
	cp build/maccatalyst_x64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)maccatalyst_x64/libwhisper.dylib

maccatalyst_arm64:
	rm -rf build/maccatalyst_arm64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=MAC_CATALYST_ARM64 -S . -B build/maccatalyst_arm64
	cmake --build build/maccatalyst_arm64
	mkdir -p $(RUNTIME_OUTPUT_PATH)maccatalyst_arm64
	cp build/maccatalyst_arm64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)maccatalyst_arm64/libwhisper.dylib

ios_simulator_x64:
	rm -rf build/ios_simulator_x64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=SIMULATOR64 -S . -B build/ios_simulator_x64
	cmake --build build/ios_simulator_x64
	mkdir -p $(RUNTIME_OUTPUT_PATH)ios_simulator_x64
	cp build/ios_simulator_x64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)ios_simulator_x64/libwhisper.dylib

ios_simulator_arm64:
	rm -rf build/ios_simulator_arm64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=SIMULATORARM64 -S . -B build/ios_simulator_arm64
	cmake --build build/ios_simulator_arm64
	mkdir -p $(RUNTIME_OUTPUT_PATH)ios_simulator_arm64
	cp build/ios_simulator_arm64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)ios_simulator_arm64/libwhisper.dylib

tvos_simulator_x64:
	rm -rf build/tvos_simulator_x64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=SIMULATOR_TVOS -S . -B build/tvos_simulator_x64
	cmake --build build/tvos_simulator_x64
	mkdir -p $(RUNTIME_OUTPUT_PATH)tvos_simulator_x64
	cp build/tvos_simulator_x64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)tvos_simulator_x64/libwhisper.dylib

tvos_simulator_arm64:
	rm -rf build/tvos_simulator_arm64
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=SIMULATOR_TVOSARM64 -S . -B build/tvos_simulator_arm64
	cmake --build build/tvos_simulator_arm64
	mkdir -p $(RUNTIME_OUTPUT_PATH)tvos_simulator_arm64
	cp build/tvos_simulator_arm64/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)tvos_simulator_arm64/libwhisper.dylib

tvos:
	rm -rf build/tvos
	cmake $(COREML_COMMAND) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=TVOS -S . -B build/tvos
	cmake --build build/tvos
	mkdir -p $(RUNTIME_OUTPUT_PATH)tvos
	cp build/tvos/whisper.cpp/libwhisper.dylib $(RUNTIME_OUTPUT_PATH)tvos/libwhisper.dylib

lipo:
	mkdir -p $(APPLE_OUTPUT_PATH)tvos-simulator
	lipo -create $(RUNTIME_OUTPUT_PATH)tvos_simulator_arm64/libwhisper.dylib -create $(RUNTIME_OUTPUT_PATH)tvos_simulator_x64/libwhisper.dylib -output $(APPLE_OUTPUT_PATH)tvos-simulator/libwhisper.dylib
	mkdir -p $(APPLE_OUTPUT_PATH)ios-simulator
	lipo -create $(RUNTIME_OUTPUT_PATH)ios_simulator_arm64/libwhisper.dylib -create $(RUNTIME_OUTPUT_PATH)ios_simulator_x64/libwhisper.dylib -output $(APPLE_OUTPUT_PATH)ios-simulator/libwhisper.dylib
	mkdir -p $(APPLE_OUTPUT_PATH)ios-device
	cp $(RUNTIME_OUTPUT_PATH)ios/libwhisper.dylib $(APPLE_OUTPUT_PATH)ios-device/libwhisper.dylib
	mkdir -p $(APPLE_OUTPUT_PATH)maccatalyst
	lipo -create $(RUNTIME_OUTPUT_PATH)maccatalyst_x64/libwhisper.dylib -create $(RUNTIME_OUTPUT_PATH)maccatalyst_arm64/libwhisper.dylib -output $(APPLE_OUTPUT_PATH)maccatalyst/libwhisper.dylib
	mkdir -p $(APPLE_OUTPUT_PATH)tvos-device
	cp $(RUNTIME_OUTPUT_PATH)tvos/libwhisper.dylib $(APPLE_OUTPUT_PATH)tvos-device/libwhisper.dylib
	mkdir -p $(APPLE_OUTPUT_PATH)macos
	cp $(RUNTIME_OUTPUT_PATH)macos/libwhisper.dylib $(APPLE_OUTPUT_PATH)macos/libwhisper.dylib

android_arm64-v8a:
	rm -rf build/android-arm64-v8a
	cmake -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_SYSTEM_NAME=Android -DCMAKE_ANDROID_API=21 -DCMAKE_ANDROID_NDK=/Users/sandrohanea/Library/Developer/Xamarin/android-sdk-macosx/ndk-bundle -S . -B build/android-arm64-v8a
	cmake --build build/android-arm64-v8a
	mkdir -p Whisper.net.Runtime/android-arm64-v8a
	cp build/android-arm64-v8a/whisper.cpp/libwhisper.so Whisper.net.Runtime/android-arm64-v8a/libwhisper.so

android_x86:
	rm -rf build/android-x86
	cmake -DCMAKE_ANDROID_ARCH_ABI=x86 -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_SYSTEM_NAME=Android -DCMAKE_ANDROID_API=21 -DCMAKE_ANDROID_NDK=/Users/sandrohanea/Library/Developer/Xamarin/android-sdk-macosx/ndk-bundle -S . -B build/android-x86
	cmake --build build/android-x86
	mkdir -p Whisper.net.Runtime/android-x86
	cp build/android-x86/whisper.cpp/libwhisper.so Whisper.net.Runtime/android-x86/libwhisper.so

android_x64:
	rm -rf build/android-x86_64
	cmake -DCMAKE_ANDROID_ARCH_ABI=x86_64 -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_SYSTEM_NAME=Android -DCMAKE_ANDROID_API=21 -DCMAKE_ANDROID_NDK=/Users/sandrohanea/Library/Developer/Xamarin/android-sdk-macosx/ndk-bundle -S . -B build/android-x86_64
	cmake --build build/android-x86_64
	mkdir -p Whisper.net.Runtime/android-x86_64
	cp build/android-x86_64/whisper.cpp/libwhisper.so Whisper.net.Runtime/android-x86_64/libwhisper.so

xcframework:
	mkdir -p output/lib
	xcrun xcodebuild -create-xcframework -library Whisper.net.Runtime/ios-device/libwhisper.dylib -library Whisper.net.Runtime/ios-simulator/libwhisper.dylib -library Whisper.net.Runtime/tvos-device/libwhisper.dylib -library Whisper.net.Runtime/tvos-simulator/libwhisper.dylib -library Whisper.net.Runtime/macos/libwhisper.dylib -library Whisper.net.Runtime/maccatalyst/libwhisper.dylib -output output/lib/whisper.xcframework