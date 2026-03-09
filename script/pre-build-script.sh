# Set up cargo path for Xcode
export PATH="$HOME/.cargo/bin:$PATH"

# Move to the root of our monorepo
cd "${PROJECT_DIR}/.."

echo "Building Rust Core Engine..."
cargo build

echo "Generating UniFFI Swift Bindings..."
mkdir -p "${PROJECT_DIR}/FocusApp/Generated"
cargo run --bin uniffi-bindgen -- generate --library target/debug/libfocus_core.dylib --language swift --out-dir "${PROJECT_DIR}/FocusApp/Generated"
