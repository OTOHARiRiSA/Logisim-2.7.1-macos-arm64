# Logisim 2.7.1 (macOS-arm64)

這是我個人重新打包的 Logisim 2.7.1，主要是為了讓它在搭載了 Apple Silicon 的 Mac 上能正常執行。
*A personal repack of Logisim 2.7.1, mainly to ensure it runs natively on Macs with Apple Silicon.*

# 這是如何做的？ / How was this built?
- 使用原版 Logisim 2.7.1 的 `.jar` 與資源文件
  *Used the original Logisim 2.7.1 `jar` and resource files.*
- 嵌入了 **Eclipse Temurin 11 (ARM64)** JRE 重新打包。
  *Repackaged with and embedded **Eclipse Temurin 11 (ARM64)** Java Runtime Environment.*

# 注意

因為没有 Apple 開發者簽名，首次打開時可能會被 macOS GateKeeper 攔截。
 *Because this app is not signed with an Apple Developer certificate, it may be blocked by macOS Gatekeeper on first launch.*

**如何解決 / How to bypass:**

打開你的终端輸入 / Open your terminal to paste following command
```bash
  sudo xattr -rd com.apple.quarantine /path/to/app
```
  (请把命令里的 "/path/to/app" 换成 Logisim 的實際路径！！！)
  (Replace "/path/to/app" with actual path to your logisim application!!!）


## License
1. **Logisim 2.7.1**: Developed by Carl Burch, licensed under **GNU GPL v2.0** [Logisim Official Websiste](https://cburch.com/logisim/)
2. **Eclipse Temurin (OpenJDK)**: Licensed under **GNU GPL v2.0 with Classpath Exception**

This Repack project is also released under the **GPL v2.0** license
