#!/bin/bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
output_dir=${1:-"$project_dir/dist"}

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
    printf 'Run this build in an arm64 shell on an Apple Silicon Mac.\n' >&2
    exit 1
fi

if ! java_home=${JAVA_HOME:-$(/usr/libexec/java_home -F -v 11 -a arm64 2>/dev/null)} ||
    [[ ! -x "$java_home/bin/jlink" || ! -r "$java_home/release" ]]; then
    printf 'Install the arm64 Temurin 11 JDK or set JAVA_HOME to its Contents/Home directory.\n' >&2
    exit 1
fi

java_version=$(awk -F '"' '/^JAVA_RUNTIME_VERSION=/ { print $2; exit }' "$java_home/release")
if [[ "$java_version" != 11.* ]] ||
    ! grep -q '^IMPLEMENTOR_VERSION="Temurin-' "$java_home/release" ||
    ! grep -q '^OS_ARCH="aarch64"$' "$java_home/release" ||
    ! grep -q '^OS_NAME="Darwin"$' "$java_home/release"; then
    printf 'Set JAVA_HOME to an arm64 Temurin 11 JDK for macOS.\n' >&2
    exit 1
fi

version=$(plutil -extract CFBundleShortVersionString raw -o - "$project_dir/packaging/Info.plist")
archive_name="Logisim-$version-macos-arm64.zip"
mkdir -p -- "$output_dir"
output_dir=$(cd -- "$output_dir" && pwd -P)
output_app="$output_dir/Logisim.app"
output_zip="$output_dir/$archive_name"

if [[ -e "$output_app" || -L "$output_app" || -e "$output_zip" || -L "$output_zip" ]]; then
    printf 'The output directory already contains a Logisim build. Choose a new output directory.\n' >&2
    exit 1
fi

build_dir=$(mktemp -d "$output_dir/.build.XXXXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT
app="$build_dir/Logisim.app"
contents="$app/Contents"
resources="$contents/Resources"
runtime="$contents/Runtime"
classes="$build_dir/classes"
original_jar="$project_dir/vendor/logisim.jar"

mkdir -p "$contents/MacOS" "$resources/Java" "$classes"
cp -X "$project_dir/packaging/Info.plist" "$project_dir/packaging/PkgInfo" "$contents/"
cp -X "$project_dir/packaging/LogisimApp.icns" "$project_dir/packaging/LogisimDoc.icns" "$resources/"
cp -X "$original_jar" "$resources/Java/logisim.jar"

"$java_home/bin/javac" --release 11 -cp "$original_jar" \
    -d "$classes" "$project_dir/src/MacLauncher.java"
"$java_home/bin/jar" --create --file "$resources/Java/mac-launcher.jar" \
    --manifest "$project_dir/packaging/Manifest.mf" \
    -C "$classes" . -C "$project_dir/src" MacLauncher.java
"$java_home/bin/jlink" \
    --add-modules java.se,jdk.accessibility,jdk.charsets,jdk.localedata,jdk.unsupported,jdk.zipfs \
    --compress=2 --no-header-files --no-man-pages --output "$runtime"

xcrun clang -arch arm64 -mmacosx-version-min=11.0 -Wall -Wextra -Werror -O2 \
    -I"$java_home/include" -I"$java_home/include/darwin" \
    "-DJAVA_VERSION=\"$java_version\"" \
    -L"$runtime/lib/jli" -Wl,-rpath,@executable_path/../Runtime/lib/jli \
    -o "$contents/MacOS/Logisim" "$project_dir/src/launch.c" -ljli

codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
ditto -c -k --sequesterRsrc --keepParent "$app" "$build_dir/$archive_name"

mv -- "$app" "$output_app"
mv -- "$build_dir/$archive_name" "$output_zip"
printf 'Built %s\nPackaged %s\n' "$output_app" "$output_zip"
