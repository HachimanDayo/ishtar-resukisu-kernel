# ishtar ReSukiSU + SUSFS 内核

为 Xiaomi 13 Ultra（ishtar）+ AviumUI 16.2.1 编译集成 [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) 与 [SUSFS](https://gitlab.com/simonpunk/susfs4ksu) 的 GKI 内核。

| 组件 | 来源 |
|---|---|
| 内核源码 | AOSP `kernel/common` `deprecated/android13-5.15-2025-05` @ `39bd6e622fc6`（5.15.180，KMI `android13-5.15` gen 8） |
| Root | ReSukiSU（默认 `main`），hook 模式：SuSFS Inline Hook（`CONFIG_KSU_SUSFS`） |
| SUSFS | susfs4ksu `gki-android13-5.15`，补丁 `50_add_susfs_in_gki-android13-5.15.patch` |
| 打包 | AnyKernel3 刷机包 + 替换内核后的 AviumUI 原厂 `boot.img`（`stock/boot.img.xz`） |

## 编译

GitHub → Actions → **Build ReSukiSU + SUSFS GKI kernel (ishtar)** → Run workflow。

可选输入：ReSukiSU 的 ref、SUSFS 的 ref、`uname -r` 后缀（默认 `-android13-8-g39bd6e622fc6`）。

编译完成后在运行页面的 Artifacts 下载，内含：

- `AnyKernel3-*.zip`：在 ReSukiSU / SukiSU 管理器的“安装”或第三方 Recovery 中刷入
- `boot-*.img`：fastboot 直接刷写
- `SHA256SUMS`

## 刷机

先临时启动验证（不写入分区，重启即恢复）：

```
fastboot boot boot-xxx.img
```

确认触屏、Wi-Fi、蜂窝网络、相机、指纹正常，管理器识别到 ReSukiSU 且 SUSFS 显示已启用后，再正式刷入：

```
fastboot flash boot boot-xxx.img
```

或在已 root 的系统中用管理器刷入 `AnyKernel3-*.zip`（刷入当前槽位）。

## 回退

刷回 AviumUI 原厂内核：

```
fastboot flash boot AviumUI\img\boot.img
```

仓库内的 `stock/boot.img.xz` 解压后与该文件相同（SHA256 见 `stock/boot.img.sha256`）。

## 用户态

SUSFS 的用户态工具 / 模块（`ksu_susfs`、`ksu_module_susfs`）需另外安装，版本应与内核中的 SUSFS 版本（Actions 日志 “Integrate SUSFS” 步骤中打印的 `SUSFS_VERSION`）一致。
