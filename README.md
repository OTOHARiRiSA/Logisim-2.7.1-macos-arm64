# Logisim 2.7.1 (macOS arm64)

這是我個人重新打包的 Logisim 2.7.1，主要是為了讓它在搭載了 Apple Silicon 的 Mac 上能正常執行。應用程式內建 Eclipse Temurin 11 執行環境，下載後即可使用，無需另外安裝 Java。

A personal repack of Carl Burch’s Logisim 2.7.1 for Apple Silicon Macs. It bundles an Eclipse Temurin 11 runtime, so no separate Java installation is required.

## 下載與安裝 / Download and install

[下載 Logisim 2.7.1 / Release downloads](https://github.com/OTOHARiRiSA/Logisim-2.7.1-macos-arm64/releases/tag/2.7.1)

DMG 和 ZIP 內含相同的 `Logisim.app`，選擇其中一種即可。

Both downloads contain the same `Logisim.app`. Choose either format.

| 格式 / Format | 安裝方式 / Installation |
| --- | --- |
| DMG | 開啟磁碟映像，將 `Logisim.app` 拖到「應用程式」。<br>Open the disk image and drag `Logisim.app` to Applications. |
| ZIP | 解壓縮後，將 `Logisim.app` 移到「應用程式」。<br>Extract the archive and move `Logisim.app` to Applications. |

### 首次開啟 / First launch

此版本使用 ad hoc 簽名，尚未經 Apple 公證。若 Gatekeeper 攔截且你確認來源可信，先嘗試開啟一次，再到「系統設定 → 隱私權與安全性」為 Logisim 選擇「強制打開」。 [Apple 支援](https://support.apple.com/zh-tw/102445)

This release is ad hoc signed and has not been notarized. If Gatekeeper blocks it and you trust the download, try opening it once, then choose **Open Anyway** for Logisim in **System Settings → Privacy & Security**. [Apple Support](https://support.apple.com/en-us/102445)

## 這是如何做的？ / How was this built?

此專案使用原版 Logisim 2.7.1 的 JAR 與資源，搭配 arm64 原生啟動器。建置時使用 Temurin 11 JDK，並以 `jlink` 產生應用程式內的 Java 執行環境。

The build uses the original Logisim 2.7.1 JAR and resources with a native arm64 launcher. It creates the bundled Java runtime with `jlink` from the Temurin 11 JDK.

在 Apple Silicon Mac 上安裝 Xcode Command Line Tools 和 **Eclipse Temurin 11 JDK（macOS aarch64）** 後執行下列指令。

Run these commands on an Apple Silicon Mac with the Xcode Command Line Tools and **Eclipse Temurin 11 JDK (macOS aarch64)** installed. [Temurin macOS installer guide](https://adoptium.net/en-GB/installation/macOS)

```sh
git clone https://github.com/OTOHARiRiSA/Logisim-2.7.1-macos-arm64.git
cd Logisim-2.7.1-macos-arm64
./build.sh
```

腳本會透過 macOS 尋找 JDK 11。若使用自行解壓縮的 JDK，或同時安裝了多個版本，可設定 `JAVA_HOME` 指向 Temurin 11 的 `Contents/Home`。

The script looks for JDK 11 through macOS. Set `JAVA_HOME` to Temurin 11's `Contents/Home` to select it explicitly.

建置結果為 `dist/Logisim.app` 和 `dist/Logisim-2.7.1-macos-arm64.zip`。如需保留先前的建置結果，可以指定另一個輸出目錄，例如 `./build.sh /tmp/logisim-build`。

The build produces `dist/Logisim.app` and `dist/Logisim-2.7.1-macos-arm64.zip`. Pass a new output directory, such as `./build.sh /tmp/logisim-build`, to keep an earlier build.

## 授權 / License

- **Logisim 2.7.1** 由 Carl Burch 開發，原始碼和授權條款收錄於 `vendor/logisim.jar`。 The original JAR includes the Logisim source and GPL terms. [Logisim](https://cburch.com/logisim/)
- **Eclipse Temurin (OpenJDK)** 使用 GPL v2 with Classpath Exception。GitHub Release 2.7.1 內建 Temurin 11.0.33+10，對應原始碼為 `OpenJDK11U-jdk-sources_11.0.33_10.tar.gz`。 The source for the bundled Temurin runtime is available in the upstream release. [Temurin 11.0.33+10](https://github.com/adoptium/temurin11-binaries/releases/tag/jdk-11.0.33%2B10)
- 本重新打包專案以 GPL v2.0 發布。 This repackaging project is released under GPL v2.0. [LICENSE](LICENSE)
