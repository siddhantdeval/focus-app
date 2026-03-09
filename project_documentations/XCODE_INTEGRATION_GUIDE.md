# Xcode & Rust Bridge Setup Guide

This document captures the definitive **Best Practice** for connecting our compiled Rust backend (`focus-core`) with our SwiftUI macOS frontend (`FocusApp`) using UniFFI inside Xcode 16+. 

This approach uses infrastructure-as-code (`.xcconfig`) and automated build scripts to avoid manual hacking of search paths, ensuring that a simple `Cmd + B` always provides fresh bindings.

---

## 1. Project Initialization

1. Open Xcode and create a new **macOS App**.
2. Name it `FocusApp`.
3. Choose **SwiftUI** for Interface and **Swift** for Language.
4. Set Testing System and Storage to **None**.
5. Save it in the monorepo root (`/focus-macapp/FocusApp`).
6. *Note: Uncheck "Create Git repository on my Mac" so it does not conflict with our root repository.*

---

## 2. Infrastructure as Code (`.xcconfig`)

We use a `.xcconfig` file to provide Xcode with search paths for the bridging header and libraries, and to disable Apple's restrictive User Script Sandboxing (which otherwise blocks Rust from writing generated files).

1. Ensure `FocusApp.xcconfig` exists at `/FocusApp/FocusApp/FocusApp.xcconfig`.
2. Right-click the `FocusApp` folder in the Xcode navigator.
3. Select **Add Files to "FocusApp"...** and select `FocusApp.xcconfig`.
4. Click the top-level **FocusApp** project in the navigator.
5. In the middle pane, select the **Project** (not the Target) named `FocusApp`.
6. Go to the **Info** tab.
7. Under **Configurations**, expand both `Debug` and `Release`. 
8. Change the dropdown next to `FocusApp` from `None` to `FocusApp` (this applies our config).

---

## 3. The Automated "Run Script"

Instead of manually running `cargo` in the terminal, we inject a script so Xcode compiles the Rust core *before* compiling the Swift UI.

1. Click the **FocusApp Target** in the middle pane.
2. Go to the **Build Phases** tab.
3. Click the **`+`** button (top left of the Build Phases pane) and select **New Run Script Phase**.
4. **CRITICAL:** Click and drag this new "Run Script" row upwards so it sits **ABOVE** the "Compile Sources" phase.
5. Expand the "Run Script" row and paste the following bash script:

```bash
# Set up cargo path for Xcode
export PATH="$HOME/.cargo/bin:$PATH"

# Move to the root of our monorepo
cd "${PROJECT_DIR}/.."

echo "Building Rust Core Engine..."
cargo build

echo "Generating UniFFI Swift Bindings..."
mkdir -p "${PROJECT_DIR}/FocusApp/Generated"
cargo run --bin uniffi-bindgen -- generate --library target/debug/libfocus_core.dylib --language swift --out-dir "${PROJECT_DIR}/FocusApp/Generated"
```

---

## 4. Run the Build & Link Generated Files

1. Press **`Cmd + B`** in Xcode. 
    *   *Note: This will successfully build Rust and generate the files, but it will fail the Swift compilation because we haven't linked the output yet.*
2. Once the script runs, a `Generated` folder will appear on disk.
3. Right-click the `FocusApp` folder in the Xcode navigator.
4. Select **Add Files to "FocusApp"...**
5. Navigate to `/FocusApp/FocusApp/Generated` and select the folder.
6. **CRITICAL:** Ensure **Copy items if needed** is UNCHECKED. (We want references, not copies). Click Add.

---

## 5. Link the Binary

Finally, we must explicitly package the compiled Rust machine code (`libfocus_core.dylib`) into the macOS app.

1. Go back to the **Build Phases** tab.
2. Expand the **Link Binary With Libraries** phase.
3. Click the **`+`** button, then **Add Other...** -> **Add Files...**
4. Navigate up to `/focus-macapp/target/debug/`
5. Select `libfocus_core.dylib` and click Open.

---

## 🚀 Final Verification

Hit **`Cmd + Shift + K`** to perform a deep clean, and then hit **`Cmd + B`** to build.

Your Rust bridge is now fully integrated. Changing Rust code and hitting Run in Xcode will perfectly synchronize both ends of your application seamlessly!

---

## 🛠️ Next Steps: Phase 2 Migration Plan

The current "Run Script" approach is optimized for **Phase 1: Prototyping**. While effective for local development, it has limitations with Xcode's security sandbox and multi-platform distribution.

In **Phase 2**, we will migrate to the **Industry Standard Production Architecture**:

1.  **XCFrameworks:** We will pre-compile the Rust library into a `.xcframework`. This allows us to bundle all architectures (macOS, iOS Simulator, iOS Device) into a single binary.
2.  **Swift Package Manager (SPM):** We will wrap the Rust library and the generated Swift code into a local Swift Package. 
3.  **Benefits:**
    *   **Zero Sandbox Issues:** No bash scripts running during the build phase.
    *   **Improved Build Speed:** Xcode only recompiles the UI; Rust is only rebuilt when necessary.
    *   **Clean Dependency Management:** One single import in Xcode for all your Rust logic.
