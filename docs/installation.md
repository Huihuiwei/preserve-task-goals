# 新手安装教程

[返回首页](../README.md)

## 先理解三个概念

- **仓库**：GitHub 上存放这个技能文件的地方。
- **安装**：把技能文件放进当前 Codex 能发现的技能目录。
- **调用**：在任务中让 Codex 读取并使用这套工作流程。

仅把仓库下载到“下载”文件夹，不一定能被 Codex 自动发现。也不需要为了使用这个纯文本技能另外配置模型 API Key、显卡或 Python 环境；你只需要已经可以正常使用的 Codex。

## 已有本地文件：离线安装到所有项目可用的位置

Windows 用户可在本仓库文件夹中打开 PowerShell，执行：

```powershell
& .\scripts\install-local.ps1 -AddGlobalInstructions
```

脚本沿用本机内置安装器的目录约定：设置了 `CODEX_HOME` 时使用其 `skills` 子目录，否则使用 `%USERPROFILE%\.codex\skills\preserve-task-goals`。这属于当前 Windows 用户的个人安装，可在该用户的不同项目中使用，不是所有系统账户或 WSL 环境的共用安装。

`-AddGlobalInstructions` 会先备份已有全局 `AGENTS.md`，再追加本技能的使用规则；明确允许调用这个 Skill，保留其他规则、项目约束与权限边界。不想追加全局规则时省略该参数。它不逐个改写项目文件，也不修改其他技能设置。

该脚本不需要联网或管理员权限，但当前会话必须允许写入目标用户目录。遇到权限限制时使用正常的授权流程，或由你在本机 PowerShell 中手动运行；不要修改沙箱设置或关闭保护。脚本不修改 PowerShell 的执行策略。

已有安装若内容相同可重复执行；若同名文件不同，脚本停止并要求先比较，不覆盖本地修改。输出中的 `DiscoveryVerified=false` 表示文件已核对，但仍需开启新 Codex 会话确认技能发现，不能把复制成功说成客户端已经加载。

## 方法一：直接让 Codex 安装（推荐）

打开 Codex 对话，粘贴：

```text
请使用 $skill-installer 从 https://github.com/Huihuiwei/preserve-task-goals 安装 preserve-task-goals。
技能入口位于仓库根目录 SKILL.md：仓库内路径为 .，安装名称为 preserve-task-goals。
请检查内容后安装到当前版本支持的个人技能目录，并保留已有同名技能的本地修改。
如果当前安装器需要命令参数，应使用 --path . --name preserve-task-goals。
完成后报告实际安装位置，并说明如何确认技能已被发现。
```

这是发给 Codex 的自然语言指令，**不要把整段贴进 PowerShell 或终端执行**。

如果 Codex 提示没有 `skill-installer`，可以让它按下面的方法手动安装。若需要访问网络或写入个人目录，按当前环境的正常授权流程处理；权限不足时，不要通过关闭保护或修改沙箱来安装。

## 方法二：用 Git 安装到个人目录

这种方式适合希望在多个项目中使用同一技能的人。先在终端运行 `git --version` 确认 Git 已安装；未安装时也可直接跳到方法三。

以下路径采用 Codex 官方文档列出的个人技能目录 `.agents/skills`。如果你的内置安装器使用 `$CODEX_HOME/skills` 或 `~/.codex/skills`，以它实际支持的目录为准，不要在多个目录重复安装同名技能。

### Windows

打开 PowerShell，复制以下三行：

```powershell
$skillParent = Join-Path $env:USERPROFILE '.agents\skills'
New-Item -ItemType Directory -Path $skillParent -Force | Out-Null
git clone https://github.com/Huihuiwei/preserve-task-goals.git (Join-Path $skillParent 'preserve-task-goals')
```

通常会安装到：

```text
C:\Users\你的用户名\.agents\skills\preserve-task-goals\SKILL.md
```

### macOS / Linux

打开终端，执行：

```bash
mkdir -p "$HOME/.agents/skills"
git clone https://github.com/Huihuiwei/preserve-task-goals.git "$HOME/.agents/skills/preserve-task-goals"
```

通常会安装到：

```text
~/.agents/skills/preserve-task-goals/SKILL.md
```

如果提示目标目录已存在，先查看里面的内容；不要直接删除或覆盖。已有 Git 安装可以按后面的更新步骤处理。

## 方法三：下载 ZIP，不用 Git

1. 打开 [GitHub 仓库](https://github.com/Huihuiwei/preserve-task-goals)。
2. 点击绿色 **Code** 按钮，再选 **Download ZIP**。
3. 解压下载文件。解压后的文件夹通常叫 `preserve-task-goals-main`。
4. 将它重命名为 `preserve-task-goals`。
5. 把这个完整文件夹放入个人技能目录，或下节的项目技能目录。

确认 `SKILL.md` 就在 `preserve-task-goals` 内的第一层。不要多套一层同名文件夹，也不要只复制 `SKILL.md` 而丢掉 `references` 等配套文件。

Windows 可以在资源管理器地址栏输入 `%USERPROFILE%\.agents\skills`。macOS 可以用 Finder 的“前往文件夹”输入 `~/.agents/skills`。目录不存在时可自行创建。

## 只在一个项目中使用

将技能放到该项目的 `.agents/skills/preserve-task-goals` 中，并从该项目内使用 Codex。

在项目根目录打开终端后，可执行：

```bash
git clone https://github.com/Huihuiwei/preserve-task-goals.git .agents/skills/preserve-task-goals
```

或者用方法三解压后放到同一位置。项目级安装与个人级安装任选其一，通常不必重复安装。

如果要把技能随自己的项目一起提交，使用解压后的普通文件夹最容易理解；直接克隆会产生嵌套 Git 仓库，不要在不理解子模块的情况下把它当普通文件夹提交。

## 如何确认安装成功

1. 确认实际目录中存在 `SKILL.md`、`agents/openai.yaml` 和 `references`。
2. 在 Codex CLI 或 IDE 中输入 `$`，查找 `preserve-task-goals`；支持技能列表的客户端也可以打开技能列表。
3. 发送下面的提示词：

```text
请使用 $preserve-task-goals。先说明你是否能读取该技能及其参考文件，
再用它核对当前任务的目标和进度。找不到时请直接说明，不要假装已加载。
```

部分客户端会自动刷新；若没有出现，尝试开启新会话或重启 Codex，再检查安装位置。**文件复制成功、技能被发现、具体任务正确完成是三个不同状态。**

## 更新

最简单的方式是让 Codex 检查更新：

```text
请更新已安装的 preserve-task-goals，先确认实际安装目录和安装方式。
比较上游变化并保留我的本地修改，不要直接覆盖。
更新后检查技能结构，并报告更新了哪些内容。
```

如果使用 Git 安装，且没有本地修改：

Windows PowerShell：

```powershell
$skillDir = Join-Path $env:USERPROFILE '.agents\skills\preserve-task-goals'
git -C $skillDir status --short
git -C $skillDir pull --ff-only
```

macOS / Linux：

```bash
git -C "$HOME/.agents/skills/preserve-task-goals" status --short
git -C "$HOME/.agents/skills/preserve-task-goals" pull --ff-only
```

如果第一条命令显示本地修改，先保存并比较修改，再决定如何更新。若存在分叉或冲突，不使用强制覆盖来解决。若安装在其他目录，用实际路径替换示例。

ZIP 或安装器下载的副本不一定含 Git 信息。可以重新下载到另一个临时目录，比较后替换；不对非 Git 目录运行 `git pull`。

## 移除

先确认实际安装路径，再把 `preserve-task-goals` 文件夹移出技能目录，或放进回收站。如果曾经手动合并 `AGENTS.md` 片段，移除技能不会自动删除该片段；可自行决定是否保留。

移除后如果技能列表未刷新，开启新会话或重启 Codex。不要删除整个 `.agents`、`.codex` 或 `skills` 目录。

## 常见问题

| 问题 | 处理方法 |
| --- | --- |
| `git` 不是可识别的命令 | 使用 ZIP 安装，或从 Git 官方来源安装 Git |
| GitHub 无法连接 | 检查正常网络访问，稍后重试；无法下载时不算安装完成 |
| 目标目录已经存在 | 比较现有内容，不覆盖本地修改；按实际安装方式更新 |
| 文件下载了但技能没出现 | 检查技能目录、文件层级及 `SKILL.md` 文件名，刷新会话 |
| `.agents` 和 `.codex` 应该选哪个 | 优先让当前版本的安装器判断；手动安装按当前官方文档选择，避免重复副本 |
| Windows 与 WSL 中只有一边能用 | Windows 与 WSL 的用户目录不同，应在实际运行 Codex 的环境中安装 |
| 安装后没有自动调用 | 显式写 `$preserve-task-goals`；自动选择不是每轮必然触发 |
| 能不能用于普通 ChatGPT 网页聊天 | 不能靠本机文件夹安装就假定网页聊天已加载，需使用该客户端支持的技能或插件机制 |
| 能不能保证代理不再犯错 | 不能。技能提供工作流程，仍需具体实现和验证证据 |

## 官方说明

安装路径、触发方式可能随客户端更新。当前说明参考 [OpenAI 的技能文档](https://developers.openai.com/codex/skills) 及本机内置 `skill-installer` 的帮助；以你正在使用的客户端和安装器为准。
