# Focus: Local Environment Setup Guide

This guide outlines the mandatory steps required to set up your local development environment for building and running the Focus application (Shared Rust Core + Native UIs).

---

## 🏗️ 1. Native SDKs (Mac/iOS) - ACTION REQUIRED

To build the macOS and iOS applications, you **must** have the full version of Xcode installed. The Command Line Tools alone are insufficient for app bundling and SwiftUI development.

1.  **Check for Xcode**: 
    Open your terminal and run:
    ```bash
    ls -d /Applications/Xcode*
    ```
2.  **Install via App Store**: 
    If not found, download [Xcode from the Mac App Store](https://apps.apple.com/us/app/xcode/id480193682).
3.  **Active Developer Directory**:
    Once installed, ensure your system is pointing to the full Xcode app (not just command line tools):
    ```bash
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    ```
4.  **Accept License**:
    ```bash
    sudo xcodebuild -license accept
    ```

---

## 🦀 2. Rust Toolchain (Automated) - NO ACTION REQUIRED

I have added a `rust-toolchain.toml` file to the project root. This file "pins" the Rust version and all necessary cross-compilation targets natively to this project. 

The next time you run `cargo build` or any other cargo command inside this folder, **rustup** will automatically detect the file and ask to install any missing targets or the correct compiler version for you.

---

## 🛠️ 3. UniFFI Binding Generation

We use a **local-only** UniFFI toolchain. You do **not** need to install anything globally. 

To generate Swift bindings for the native macOS/iOS app, use the following workflow from the root of the project:

```bash
# 1. Compile the Rust library
cd focus-core
cargo build

# 2. Generate the Swift code (The "Bridge")
mkdir -p out/apple
# We use the uniffi-bindgen CLI to extract the Swift and C-header files from the compiled dynamic library.
cargo run --bin uniffi-bindgen -- generate --library ../target/debug/libfocus_core.dylib --language swift --out-dir out/apple
```

---

## 📱 4. Building the macOS Skeleton App

Once Xcode is set up and the bindings are generated:

1.  Open Xcode.
2.  File → New → Project → macOS → App.
3.  Name it `FocusApp`.
4.  We will then link the `focus-core` static library and the generated Swift files. (I will provide the specific code and project configuration steps once you confirm Xcode is ready).

---

## 🪟 5. Windows Setup (Phase 1.5)

To build the Windows version on your Mac, we will eventually set up **GitHub Actions**. However, if you wish to verify Windows builds locally:
1.  Install [xwin](https://github.com/Jake-Shadle/xwin) via `cargo install xwin`.
2.  Run `xwin --accept-license splat --output ./win-sdk`.
3.  *Note: Full Windows UI development requires a Windows machine or a VM with Visual Studio.*

---

## 🏁 Verification Checklist
Before moving to UI implementation, ensure you can run:

- [ ] `xcodebuild -version` returns a valid Xcode version (e.g., Xcode 15+).
- [ ] `cargo test` passes inside `focus-core`.
- [ ] `rustup target list --installed` shows all targets from Step 2.

**Once you have completed the Xcode installation and `xcode-select` command, let me know to proceed with the bridge implementation!**
