---
name: winsize
description: 看清并调整 Windows 上的窗口布局。当用户说"把窗口摆到左边""把 A 和 B 并排""还原刚才的布局""帮我看看现在开了哪些窗口""把浏览器放右半屏"时使用。只在本机生效，依赖正在运行的 WinSize。
---

# WinSize：窗口布局

## 0. 这个 skill 能做什么

| 你想做的事 | 可以直接这样说 | 对应命令 |
| --- | --- | --- |
| 看现在开了哪些窗口 | "现在都开了什么窗口" / "Chrome 在哪块屏" | `windows` |
| 把一个窗口摆到某个位置 | "把 Chrome 放左半屏" / "记事本铺满右边屏幕" | `apply` |
| 一次摆好几个窗口 | "浏览器在左、编辑器在右、终端铺满下半个屏" | `batch` |
| 存一套常用布局 | "把这个尺寸存成 LeftHalf" | `save-layout` |
| 看都有哪些方案 | "都有哪些布局方案" | `layouts` |
| 撤销刚才的摆放 | "撤销" / "放回去" | `restore` |
| 改完配置让它生效 | "配置我改好了，重载一下" | `reload` |
| 置顶 / 取消置顶 | "把 Chrome 置顶" / "取消置顶" | `action --name=pin --hwnd=… --param=on` |
| 排除 / 取消排除某个窗口 | "以后别动这个窗口" / "恢复它" | `action --name=exclude --hwnd=… --param=on` |
| 重启或退出程序 | "重启一下 WinSize" / "把 WinSize 关了吧" | `action --name=reboot` / `action --name=quit`（都要 `--commit`） |
| 看程序现在支持哪些动作 | "你能让 WinSize 做什么" | `actions` |

**现在做不到**（程序里有，但还没有接口）：

| 能力 | 目前只能靠用户 |
| --- | --- |
| 绑定窗口 / 唤回 | 按 `1`~`9`、`0` |
| 辅助线、悬停激活 | 按 `G` / `T` |
| 隐藏标题栏、右上角置顶 | `LAlt + 右键` 点窗口顶部 |
| 改配置项（字号、开关、排除表…） | 打开设置页 |
| 截图 / 看窗口内容 | —— |

**不做**：截图、识别窗口内容、改系统设置、改用户配置、管理进程。

**一句话**：它让 AI 变成一个"会摆窗口的助手"，不是一个"会看屏幕的助手"。

### 指挥示例

**能直接干**（目标具体、窗口可指认）：

| 用户说 | 怎么处理 |
| --- | --- |
| "把 Chrome 放左半屏" | `windows --exe=chrome` → `apply --hwnd=… --layout=FullLeft` |
| "记事本铺满右屏" | 同上，换 `--layout=FullRight` |
| "浏览器在左、编辑器在右" | `batch` 两条，一次提交 |
| "把终端压到下面三分之一" | `apply --rect="0|66sh|100sw|34sh"` |

**必须反问**（含糊、没指认窗口、没有可执行的目标）：

| 用户说 | 为什么不能直接做 | 反问什么 |
| --- | --- | --- |
| "帮我整理一下桌面" | 不知道摆哪几个窗口、目标是什么 | "要摆哪几个窗口？想怎么分？" |
| "把窗口弄整齐" | "整齐"不是可执行的位置 | "左右各半，还是指定比例？" |
| "让它们别挡着" | 谁挡谁、往哪挪都不明确 | "哪几个窗口挡住了？想挪到哪边？" |

反问模板：**"要摆哪几个窗口？想怎么分（左右各半 / 上下 / 指定比例）？"**

**动手前要先说清的边界**：

- 只能摆可见、非最小化的普通窗口；管理员权限窗口可能"完全没动"（`verdict=blocked`），这不是失败重试能解决的。
- 默认只预演。看到 `verdict` 正常再加 `--commit`，别一上来就落地。
- 一次最多 50 条；更多要分批。
- `hwnd=0` 表示"当前前台窗口"，用户说"这个窗口"时通常就是它。

---

## 1. 开工：三步检查，一步都不能跳

最常见的失败不是"命令写错"，而是**没确认前提就开始编命令**。先做完这三步。

### 第 1 步：确认 Node.js 可用

```bash
node -v
```

- 输出 `v18.x` 或更高 → 继续。
- 低于 18 或"不是内部命令" → **停**，告诉用户："这个功能需要 Node.js 18 以上，你的环境里没有（或版本太低）。"
  然后用第 11 节的 HTTP 兜底方案，或直接说明无法执行。

### 第 2 步：确认 WinSize 正在运行、并找到它的安装目录

WinSize 运行后会在**程序目录**生成 `runtime.json`（里面有端口和 token）。

**优先做法：直接问用户**——"WinSize 装在哪个目录？" 这比猜快得多，也不会猜错。

用户不方便回答时，可以按顺序试这几个位置：

- `%LOCALAPPDATA%\Programs\WinSize`
- `C:\Program Files\WinSize`
- 用户桌面 / 下载里解压出来的文件夹
- 已在别处打开的终端窗口的工作目录

**怎么确认目录对不对**：该目录下应同时有 `WinSize.exe`、`Config.ini`、`runtime.json`、`cli\`。

`runtime.json` 不存在 = 程序没运行（或那个目录不可写）。**不要自己去找端口**，也不要让用户去开
设置页——服务是随程序启动就在监听的。

### 第 3 步：跑一次 status

```bash
node "<WinSize目录>\cli\winsize.mjs" status
```

- 输出里有 `"app": "WinSize"` 和版本号 → 可用，继续。
- 退出码 `2` / 提示"找不到 runtime.json" → 回第 2 步：目录不对，或程序没开。
- 其他报错 → 把原文给用户看，别自己修。

> **路径必须加引号**：`C:\Program Files\...` 这种带空格的路径，不加引号会被拆成两个参数。
> 下文一律用 `<CLI>` 代指这个完整路径，例如
> `<CLI>` = `"C:\Program Files\WinSize\cli\winsize.mjs"`。

---

## 2. 命令总表

全部命令都是 `node <CLI> <命令> [参数]`。

| 命令 | 作用 | 会动窗口吗 |
| --- | --- | --- |
| `status` | 服务和版本是否可用 | 否 |
| `windows` | 列出窗口 | 否 |
| `layouts` | 列出已存的布局方案 | 否 |
| `apply` | 摆**一个**窗口（**默认只预演**） | 加 `--commit` 才会 |
| `batch` | 摆**多个**窗口，一次调用 | 加 `--commit` 才会 |
| `restore` | 撤销上一次 `apply` | 是 |
| `reload` | 让主程序重读 `Config.ini` | 否 |
| `save-layout` | 存一个布局方案 | 否 |
| `del-layout` | 删一个布局方案 | 否 |
| `actions` | 列出程序支持的动作（自省） | 否 |
| `action` | 执行一个动作，如置顶 / 排除 / 重启（**默认只预演**） | 加 `--commit` 才会 |

---

## 3. 命令详解

### 3.1 `windows` —— 先查后动

```bash
node <CLI> windows                      # 全部可见窗口
node <CLI> windows --exe=chrome         # 按进程名筛（子串、不分大小写）
node <CLI> windows --title=记事本        # 按标题筛（子串）
node <CLI> windows --pid=1234           # 按进程号
node <CLI> windows --hwnd=131072        # 单个窗口
node <CLI> windows --all                # 连不可见的窗口一起列
```

**返回的是数组**，不是单个对象。一个程序可能有多个窗口（比如 Chrome 开了好几个），
**不要只取第一个**，要按标题挑出用户真正指的那个。

标题是中文时**直接写中文**，不需要转义——参数由脚本自己处理，别手写 `\u4e2d` 之类的东西。

### 3.2 `apply` —— 摆窗口

```bash
# 预演：只告诉你"将会摆到哪"，窗口不动
node <CLI> apply --hwnd=131072 --layout=LeftTop

# 真的执行
node <CLI> apply --hwnd=131072 --layout=LeftTop --commit

# 用布局串而不是名字
node <CLI> apply --hwnd=131072 --rect="0|0|50sw|100sh" --commit
```

- `--hwnd` 必填，从 `windows` 拿。**不要猜句柄**，猜出来的数字多半是别的窗口。
- `--layout` 与 `--rect` 二选一。`--layout` 的名字必须来自 `layouts` 的返回。
- 不带 `--commit` 就是预演——**窗口不会动**。没把握时先预演。

**批量摆多个窗口**用 `batch`，一次调用搞定（少一半出错机会）：

```bash
node <CLI> batch --op="hwnd=131072,target=layout:LeftTop" --op="hwnd=262144,target=layout:RightTop" --commit
```

每个 `--op` 是 `hwnd=<句柄>,target=<目标>`，`target` 写法与 `apply` 的 `--layout` / `--rect` 一致
（`layout:名字` 或 `rect:布局串`）。**不加 `--commit` 就是整体预演**，窗口一个都不动。

> 批量时**要么全做、要么一个都不动**：只要有一条属于"参数错 / 窗口不存在 / 窗口不能动 /
> 布局名不存在 / 超过 50 条"，整批拒绝，错误里会指出是第几条（`ops[n]`）。
>
> **不要用重复 `--hwnd` 来表达批量**（`--hwnd=1 --hwnd=2` 这种）。参数解析里同名参数会互相覆盖，
> 结果是**静默只动最后一个窗口**，看着像成功——这是 6.0.1 之前的真实 bug。

### 3.3 `layouts` / `save-layout` / `del-layout`

```bash
node <CLI> layouts
node <CLI> save-layout --name=LeftHalf --spec="0|0|50sw|100sh"
node <CLI> del-layout --name=LeftHalf
```

- `--name` 就是之后 `--layout=` 用的名字，建议英文单词拼接（`LeftHalf`、`TopRight`）。
- 被 `[Keys]` 引用的方案删不掉，会报错——这是保护，别绕过。

### 3.4 `restore` / `reload`

```bash
node <CLI> restore --token=<undo>    # undo 来自 apply 的返回
node <CLI> reload                    # 用户手改了 Config.ini 之后必须跑
```

- **撤销只有 1 步**，而且重启 WinSize 后失效。需要长期可回退时，先 `save-layout` 再动。
- `reload` 只让程序重读配置，不改文件。

### 3.5 `actions` / `action` —— 置顶、排除、重启

`actions` 是**自省**：程序现在认哪些动作、要不要窗口、参数能填什么、给不给外部调。

```bash
node <CLI> actions
```

`action` 执行其中一个动作，**默认只预演**，加 `--commit` 才真做：

```bash
# 置顶（on / off / toggle，不写 param 就是 toggle）
node <CLI> action --name=pin --hwnd=131072 --param=on
node <CLI> action --name=pin --hwnd=131072 --param=on --commit

# 排除 / 恢复
node <CLI> action --name=exclude --hwnd=131072 --param=on --commit

# 重启 / 退出：必须先预演看一眼，再加 --commit
node <CLI> action --name=reboot              # 预演：会换 token、会断连接
node <CLI> action --name=reboot --commit
```

要点：

- **`on` / `off` / `toggle` 的区别很重要**：热键是"切换"，你对同一个窗口连说两次"置顶"
  就变回原样了。要一个确定的结果，就写 `--param=on` 或 `--param=off`。
- **重启 / 退出后 token 和端口都会变**（退出还会删掉 `runtime.json`），
  所以后续调用要重新读 `runtime.json`；`--commit` 之前务必先预演并把后果告诉用户。
- 有专用接口的动作（`layout` / `applyrect` / `reload`）**不在这里做**，会回 `not-exposed`
  并告诉你该走哪；`help` / `settings` / `version` 一律不给外部调（会抢用户屏幕或卡住程序）。
- 排除是"整条规则"级的：规则只有 `进程|类` 两段，**不能只排除同一个程序里的某一个窗口**。
  被拒时照 `error.format` 说的做，别自己拼规则。

### 3.5.1 窗口切换（`wswitch` / `wswitchRev`）

`action` 里还有两个"切窗口"的动作，和置顶、排除同一个入口，但**不需要 hwnd，也不需要 commit**：

```bash
node tools/winsize.mjs action --name=wswitch     # 切到下一个窗口（立即生效）
node tools/winsize.mjs action --name=wswitchRev  # 反向切回上一个
```

它们标着 `instant`，响应里 `committed:true`、没有 `preview`。默认只切"同程序 + 同窗口类"的窗口，
切换方式为「轮转」；用户自己按的是 `Alt+反引号` 与 `Shift+Alt+反引号`。想改行为用 `Config.ini` 的 `[Plugins.WindowSwitch]`，或者让用户去设置页「插件 → 窗口切换」改，别自己拼键值；插件被停用时这两个动作会一起消失。

### 3.6 `exclusions` —— 查看和增删排除规则

排除表决定"哪些窗口不参与布局、不能摆"。**整节覆盖 `Config.ini` 的 `[Exclusions]` 很容易写坏**
（内置规则和顺序会一起变），所以增删单条走这个接口：

```bash
# 看现有规则：每条现在命中几个窗口，内置规则单独列
node <CLI> exclusions

# 加一条（默认只预演，返回会命中的窗口，让你先确认范围）
node <CLI> exclude --rule="C:\Program Files\Google\Chrome\Application\chrome.exe|Chrome_WidgetWin_1"
node <CLI> exclude --hwnd=131072          # 也可以给窗口，规则按"进程路径|窗口类"推导

# 确认无误再落地
node <CLI> exclude --hwnd=131072 --commit

# 删一条
node <CLI> unexclude --rule="C:\x\a.exe|SomeClass"
node <CLI> unexclude --rule="C:\x\a.exe|SomeClass" --commit
```

要点：

- 规则只有 `进程|类` 两段。只写进程段表示"这个进程的所有窗口"；带上类名才是"只有这一类"。
  多写一段会被拒（`bad-rule`）。
- **同一个程序开了多个同类窗口时，这条规则会一起排掉**。先看预演返回的 `hits` 里的标题，
  那不是用户想要的范围就问，别自己拼更长的规则——拼不出来，规则只到类这一级。
- 加规则是幂等的（已在表里返回 `changed:0`）；删不存在的规则回 `not-found`，
  `options` 里带现有规则。
- 写进配置后**立刻生效**，不需要再发 `reload`。

---

## 4. 布局串语法

```
x|y|宽|高[|显示器]
```

| 段 | 含义 |
| --- | --- |
| `x` `y` | 左上角坐标，相对**目标显示器的工作区**（不含任务栏） |
| `宽` `高` | 尺寸 |
| 第 5 段 | 显示器号；省略或 `0` = **跟随鼠标当前所在那块屏** |

> 坐标原点默认是**目标显示器的工作区**；一旦表达式里出现 `vw` / `vh`，原点自动改成**虚拟屏左上角**（只有 `0|0|100vw|100vh` 才是"横跨所有屏"）。

> ⚠️ **多显示器时永远把第 5 段写上。** 省略它等于"听天由命"——鼠标在哪块屏就摆到哪块，
> 而鼠标位置你控制不了。实测踩过：想摆到主屏右半，结果因为鼠标在小屏，窗口落到了小屏上，
> 还和别的窗口叠在一起（坐标变成了负数）。这类错误**不会报错**，`verdict` 依然是 `ok`。

每段可以写数字，也可以写表达式：

| 记号 | 含义 |
| --- | --- |
| `sw` / `sh` | 工作区宽 / 高（screen width / height） |
| `vw` / `vh` | 整片虚拟屏宽 / 高（跨所有显示器） |
| `ww` / `wh` | 窗口自身当前宽 / 高 |

支持加减，例如 `100sw-1920`（右半屏再往左挪 1920）。

**常用例子**：

| 想要 | 布局串 |
| --- | --- |
| 左半屏 | `0\|0\|50sw\|100sh` |
| 右半屏 | `50sw\|0\|50sw\|100sh` |
| 左上四分之一 | `0\|0\|50sw\|50sh` |
| 居中 60% | `20sw\|20sh\|60sw\|60sh` |
| 铺满整块屏 | `0\|0\|100sw\|100sh` |
| 横跨所有显示器 | `0\|0\|100vw\|100vh` |
| 放到第 2 块屏的左半 | `0\|0\|50sw\|100sh\|2` |

**手写容易错**（少一段、单位写成 `%`、用了中文逗号）——`apply` 会报 `bad-layout` 并给出正确格式，
照 `format` 字段改就行，别自己瞎试。

---

## 5. 窗口对象长什么样

```json
{
  "hwnd": 131072,
  "pid": 28096,
  "exe": "chrome.exe",
  "class": "Chrome_WidgetWin_1",
  "title": "文档 - Chrome",
  "rect":        { "x": 0, "y": 0, "w": 2560, "h": 1440 },
  "visibleRect": { "x": 8, "y": 0, "w": 2544, "h": 1400 },
  "monitor": 2,
  "state": "normal",
  "visible": 1,
  "excluded": 0,
  "operable": 1,
  "exePath": "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  "topmost": 0,
  "excludedRules": []
}
```

| 字段 | 怎么用 |
| --- | --- |
| `hwnd` | 句柄，`apply` 用它 |
| `rect` | **窗外框**（含不可见边框） |
| `visibleRect` | **肉眼看到的边界**。判断"摆好没有"用这个，不是 `rect` |
| `monitor` | 在哪块屏（从 1 开始） |
| `state` | `normal` / `maximized` / `minimized` / `hidden`（不可见或被 DWM 隐身） |
| `operable` | `0` = **不能动**：在用户排除表里、工具窗、系统窗、或 WinSize 自己的窗口 |
| `excluded` | `1` = 在用户的排除表里（用来向用户解释原因） |
| `exePath` | 完整路径。**排除规则里写的是这个**，不是 `exe` |
| `topmost` | `1` = 已置顶。`pin` 是切换语义，动手前先看它 |
| `excludedRules` | 命中的**用户**规则；空数组 = 没被排除。要解释"为什么不能动"就用它 |

`rect` 与 `visibleRect` 差的是窗口阴影，通常 16×8 像素。**不要把这个差当成"没摆好"**。

---

## 6. 摆完看 `verdict`：不等于 `ok` 不是 bug

`apply` 的每条结果都带 `verdict`。**重试同样的目标通常没用**，照下表处理。

| verdict | 含义 | 该怎么办 |
| --- | --- | --- |
| `ok` | 到位（偏差 ≤ 2px） | 完成 |
| `rounded` | 差 3~7px（系统取整 / 边框） | 当成功，不用管 |
| `clamped` | 位置对了但尺寸不符（被窗口顶住） | 撞到最小 / 最大尺寸限制。**换更大的目标**，或告诉用户"这个窗口最小就这么大" |
| `blocked` | **完全没动** | 多半是管理员权限窗口（UIPI）。换目标也不行，如实告诉用户 |
| `maximized` | 窗口正处在最大化 | 已按最大化处理；要精确摆放需用户先还原窗口 |
| `partial` | 动了，尺寸基本对，只差位置 | 系统限制。把实际值报给用户，别假装成功 |
| `preview` | **预演**：没执行，所以没有 `actual`/`deviation` | 正常。确认目标后再加 `--commit` |

**`clamped` 与 `blocked` 的区别是"窗口有没有动"**：动了一半 = 被尺寸约束（换更大的目标能成），
一动没动 = 被拒绝（换目标也没用）。**别把两者都说成"权限问题"**。

另外：UWP 应用、部分游戏、部分自绘边框的程序无法精确摆放，这是系统限制，不是你写错了。

> **报告结果时用 `actual` 而不是 `target`。** 不要对用户说"已经摆好了"而你只看的是目标值。

---

## 7. 出错时怎么读

失败时 `error` **永远是一个对象**（不是字符串），形态固定：

```json
{
  "ok": false,
  "error": {
    "code": "bad-layout",
    "message": "ops[2] 的布局名「LeftTp」不存在",
    "format": "布局名必须是 [Layout] 里已有的名字，或改用 rect:<布局串>",
    "options": ["LeftTop", "RightTop", "Center", "FullTop"],
    "example": "target=layout:LeftTop"
  }
}
```

- `message` 说清"出了什么错"，带 `ops[n]`（第几条）和实际值。**它只陈述事实**，
  不会猜"你是不是想写 xxx"。
- `format` = 该用什么格式；`options` = 这里能选哪些；`example` = 能直接抄的写法。
- 后三个字段**没有就省略**，不要当成一定存在。

| code | 含义 | 怎么办 |
| --- | --- | --- |
| `bad-request` | 参数缺了 / 形状不对 | 照 `format` 改 |
| `no-window` | 句柄已失效（窗口关了） | 重新 `windows` 取 |
| `not-operable` | 这个窗口不能动 | **别重试**；换窗口，或告诉用户原因 |
| `bad-layout` | 布局名不存在 / 布局串写错 | 看 `options`（现有名字）与 `format`（语法） |
| `too-many` | 一次超过 50 条 | 拆成两批 |
| `wrong-method` | HTTP 方法用错 | 看 `format` 里写的正确方法 |
| `not-found` | 路径不存在 | 检查拼写；可用路径写在 `format` 里 |
| `not-exposed` | 这个动作不开放给外部调用 | **别换名字重试**；照 `options` 走专用接口，或让用户自己按 |
| `unknown-action` | 没有这个动作名 | 跑一次 `actions` 看现有名字，`options` 也列了全部 |
| `needs-hwnd` | 这个动作要指定窗口 | 先 `windows` 拿 `hwnd` 再调 |
| `action-failed` | 动作执行时出错（窗口刚好关了等） | 重新查窗口再试一次；仍失败就如实报错 |
| `forbidden` | token 或 Origin 不对 | 确认读的是**当前**的 `runtime.json`（程序重启后 token 会变） |
| `write-failed` / `registry-failed` | 写配置 / 改注册表失败 | 环境问题（只读目录、被安全软件拦），报给用户 |

---

## 8. 最常见的四个翻车点

| 现象 | 原因 | 正确做法 |
| --- | --- | --- |
| `找不到 runtime.json` | 没在程序目录下跑，或程序没开 | 用绝对路径调 `<WinSize目录>\cli\winsize.mjs`，脚本会自己找上一级的 `runtime.json` |
| 参数被拆成两半 | 路径带空格没加引号 | `node "C:\Program Files\WinSize\cli\winsize.mjs" status` |
| 中文标题匹配不到 | 自己手写了转义 / 编码 | **直接写中文**，交给脚本处理 |
| 布局串报 `bad-layout` | 少一段、用了 `%`、中文逗号 | 照返回的 `format` / `example` 改 |
| 窗口跑到了**另一块屏** | 布局串没写显示器号，跟随了鼠标位置 | 补第 5 段，如 `0\|0\|50sw\|100sh\|2` |
| 批量只动了**一个**窗口 | 用了重复 `--hwnd`（同名参数互相覆盖） | 改用 `batch --op=... --op=...` |

**不要自己拼 curl 调这些接口**——中文标题、`|`、引号都容易翻车，脚本已经处理好了。

---

## 9. 三条硬规则

1. **先查后动**：`apply` 之前必须先 `windows` 拿到真实 `hwnd`，不要猜、不要从对话里抄一个数字。
2. **批量优先**：一次要摆多个窗口时用一次调用，不要一个个来。
3. **没把握先预演**：不带 `--commit` 时窗口不会动，只告诉你"将会摆到哪"。
   方案已存、目标明确时可以直接 `--commit`，不必多跑一趟。

### 建议的执行顺序

```
status → windows（找 hwnd）→ layouts（看有没有现成方案）
       → apply 预演 → 向用户确认 → apply --commit → 读 verdict 报告结果
```

用户说得很明确（"把 Chrome 放左半屏"）时，可以省掉"向用户确认"，直接 commit，
但**仍然要先查 hwnd**。

---

## 10. 绝对不要做的事

1. **不要把 `runtime.json` 里的 token 贴到任何公开地方**（聊天记录、issue、日志）。
   它等于本机接口的钥匙。
2. **不要改用户的配置项**（字体、开关、排除表、托盘…）。`/api/config` 系列是设置页专用的。例外一，布局方案可以用 `save-layout` / `del-layout`；例外二，排除表可以用 `/api/exclusions`（CLI 的 `exclude` / `unexclude`）增删单条规则，见 §3.6。这两类都是这个 skill 的正常用途，其它配置项仍然不要动。
3. **不要循环重试**同一个失败操作。`blocked` / `not-operable` 重试一百次也是同样的结果。
4. **不要假装成功**。`verdict` 不是 `ok` 就如实说，把 `actual` 报给用户。
5. **不要在用户没要求时乱动窗口**。这个 skill 是"用户让你摆才摆"，不是"看到窗口就想整理"。
6. **不要一次 apply 超过 50 条**，会被拒绝（`too-many`）。
7. **`reboot` / `quit` 必须先预演、先问用户**。它们会断连接、换 token，退出还会删 `runtime.json`。
   用户没说要重启或退出，就不要调——这不是"顺手清理一下"的操作。

---

## 11. 兜底：没有 Node 时直接发 HTTP

用户环境里没有 Node 18+，但程序在跑，可以直连 HTTP。先读 `runtime.json` 拿 `port` 和 `token`，
然后（Windows PowerShell）：

```powershell
$rt = Get-Content "C:\WinSize\runtime.json" -Raw | ConvertFrom-Json
$h = @{ "X-WinSize-Token" = $rt.token }
Invoke-RestMethod "http://127.0.0.1:$($rt.port)/api/windows" -Headers $h
```

常用路径：

| 路径 | 方法 | 作用 |
| --- | --- | --- |
| `/api/env` | GET | 服务与版本信息 |
| `/api/windows` | GET | 列窗口（`?exe=` `?title=` `?hwnd=` `?all=1`） |
| `/api/layouts` | GET / POST / DELETE | 布局方案的增删查 |
| `/api/apply` | POST | 摆窗口（form: `hwnd` `target` `commit`） |
| `/api/restore` | POST | 撤销（form: `token`） |
| `/api/reload` | POST | 重读配置 |
| `/api/actions` | GET | 动作自省（哪些能调、要不要窗口、参数可选值） |
| `/api/action` | POST | 执行动作（form: `name` `hwnd` `param` `commit`，默认预演） |
| `/api/exclusions` | GET / POST / DELETE | 排除表：列表带命中数，增删单条（默认预演） |

`target` 有两种写法：`layout:LeftTop` 或 `rect:0|0|50sw|100sh`。
`action` 的 `param` 对置顶/排除是 `on` / `off` / `toggle`；`commit=1` 才落地。
**中文标题走 GET 的 `?title=` 时要做 URL 编码**，这是兜底方案最容易错的地方——能装 Node 就用脚本。

---

## 12. 边界

- **只本机**：服务只监听 `127.0.0.1`，别人连不上。
- **撤销只有 1 步**，重启程序后失效。需要长期可回退时，先 `save-layout` 再动。
- **不能跨用户提权**：管理员权限的窗口（任务管理器、部分安装程序）摆不动，这是 Windows 的 UIPI 限制。
- 这个 skill 依赖 **WinSize 本体**；没有程序、只有这个 skill，什么也做不了。
