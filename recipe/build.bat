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
if errorlevel 1 exit 1

:: Move binary
if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%
rename "%HELIX_LIBEXEC%/bin/hx" "%LIBRARY_BIN%/hx"
rmdir /s /q "%HELIX_LIBEXEC%/bin%" 2>nul

:: remove extra build files
rmdir /s /q runtime\grammars\sources
del /q runtime\grammars\*.dSYM 2>nul
rmdir /s /q runtime\grammars\*.dSYM 2>nul

:: Copy runtime files
robocopy "runtime" "%HELIX_DEFAULT_RUNTIME%" /S
if %ERRORLEVEL% GEQ 8 exit 1