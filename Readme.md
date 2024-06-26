WinSize 5.0
===

WinSize 是一个用来快速将程序窗口定位到预设位置和大小的工具。5.0 版本并不能单纯的看作是 4.0 的升级，5.0 是完全重构优化后的更自由化的版本。侧重一套容易记忆的快捷键启动所有动作，减少鼠标操作，并可被第三方程序调用。

> 如果可以省略，那么尽量省略。这可能并不怎么新手友好，但值得给它点时间，去习惯一下。

在 @思忆 和 @不隔山 两位朋友的督促、建议、测试下，5.0 采用了更底层的窗口尺寸计算方法，使效果更佳符合预期，感谢~如果没有你们，我大概永远也不会想要研究这种东西。

## 程序获取

你可以在此处获得本程序：https://afdian.net/item/d8fea58cb99c11eebcb75254001e7c00

WinSize 是绿色版程序，仅在 Win11 x64 位系统下测试通过。

## 关于价格

我不喜欢背刺老用户，所以没有特殊情况是不会再有降价和折扣了，放心买，随时都是最好的价格。

## 程序文件

- WinSize.exe: 主程序，启动后常驻托盘
- WinSize-Cli.exe: 命令行程序，供第三方程序调用，仅提供窗口重定位功能

## 关于升级

如果用着没问题，也不用追着升级，也没有检测更新，更没有更新提醒。

**一个小小的约定**：如果版本号第二位变化，说明修复了一些影响比较大 bug，建议更新；如果版本号最后一位变化，可能是添加功能什么的，就影响不大。

## 文档目录

- [使用方法](./使用方法.md)
- [入门引导](./入门引导.md)（老鸟可略过）
- [配置文件](./配置文件.md)
- [布局字符串](./布局字符串.md)
- [第三方调用](./第三方调用.md)
- 功能说明
  - [窗口布局功能](./窗口布局功能.md)
  - [快速窗口布局](./快速窗口布局.md)
  - [大写锁定提示](./大写锁定提示.md)
  - [时间显示](./时间显示.md)
  - [窗口置顶](./窗口置顶.md)
  - [排除窗口](./排除窗口.md)
- [常见问题](./常见问题.md)

## 路线图

- [x] 提取核心功能
- [x] 第三方调用核心功能 100%
- [x] 配置文件读写 100%
- [x] 快捷键调用核心功能 100%
- [x] 托盘菜单
- [x] 用户窗口排除规则