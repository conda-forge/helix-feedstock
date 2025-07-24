@echo on

:: Set Cargo build profile
:: LTO=thin is already the default, and fat just takes too much memory
set CARGO_PROFILE_RELEASE_STRIP=symbols

:: Check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml

set "HELIX_LIBEXEC=%LIBRARY_PREFIX%/libexec/helix"
set "HELIX_DEFAULT_RUNTIME=%LIBRARY_PREFIX%/libexec/helix/runtime"

:: Build package
cargo install --profile opt --locked --no-track --root "%HELIX_LIBEXEC%" --path helix-term

:: remove extra build files
rmdir /s /q runtime\grammars\sources
del /q runtime\grammars\*.dSYM 2>nul
rmdir /s /q runtime\grammars\*.dSYM 2>nul

:: Copy runtime files
robocopy "runtime" "%HELIX_DEFAULT_RUNTIME%" /S