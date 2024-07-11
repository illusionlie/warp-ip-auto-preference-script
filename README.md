# WARP IP Auto-preference
WARP IP Auto-preference (以下简称WIPAP) 是一个用于优选Cloudflare WARP IP的脚本
修改自<https://gitlab.com/Misaka-blog/warp-script/-/blob/main/files/warp-yxip/warp-yxip.bat>的脚本

---

## 功能

 * 自动优选并设置warp-cli
 * WARP IPv4 Endpoint IP 优选 (自动排除不可用的IP)
 * WARP IPv4 Endpoint IP 持续优选 (循环执行)

---

## 如何使用

直接下载源码中的`WIPAP.bat`, 新建一个空文件夹, 放入, 双击运行即可

---

## 提醒

代码写的很难看, 并且不一定能保证完美运行
暂时没把IPv6也写进去, 很快就写进去
