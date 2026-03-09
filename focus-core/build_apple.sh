#!/bin/bash
set -e

echo "🚀 Building Focus Core for Apple Platforms..."

# 1. Ensure Rust targets are installed
echo "📦 Installing Rust macOS targets..."
rustup target add aarch64-apple-darwin x86_64-apple-darwin

# 2. Compile for macOS targets
echo "🔨 Compiling Rust core..."
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin

# 3. Create Universal macOS binary
echo "🧬 Creating Universal macOS Binary..."
mkdir -p ../target/universal-macos/release
lipo -create -output ../target/universal-macos/release/libfocus_core.a \
    ../target/aarch64-apple-darwin/release/libfocus_core.a \
    ../target/x86_64-apple-darwin/release/libfocus_core.a

# 4. Generate Swift Bindings
echo "📝 Generating Swift bindings..."
mkdir -p generated_swift
cargo run --bin uniffi-bindgen -- generate --library ../target/aarch64-apple-darwin/release/libfocus_core.dylib --language swift --out-dir generated_swift

# 5. Prepare Headers for XCFramework (Best Practice: isolate headers from swift)
echo "📂 Isolating headers for XCFramework..."
rm -rf headers_for_xcframework
mkdir -p headers_for_xcframework
cp generated_swift/*.h headers_for_xcframework/
cp generated_swift/*.modulemap headers_for_xcframework/module.modulemap

# 6. Package as XCFramework inside the SPM Package folder
echo "📦 Assembling XCFramework into FocusCore package..."
rm -rf ../FocusCore/FocusCore.xcframework
xcodebuild -create-xcframework \
    -library ../target/universal-macos/release/libfocus_core.a -headers headers_for_xcframework \
    -output ../FocusCore/FocusCore.xcframework

# 7. Copy the Swift interface to the Package Sources
echo "🚚 Updating SPM Swift Source..."
mkdir -p ../FocusCore/Sources/FocusCore
cp generated_swift/focus_core.swift ../FocusCore/Sources/FocusCore/

echo "✅ Success! SPM Package FocusCore is up to date."
