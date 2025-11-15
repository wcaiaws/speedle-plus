# DailyJournal iOS 基础框架

一个使用 SwiftUI 与 MVVM 架构构建的日常记录 App 骨架，包含列表、筛选、搜索、详情和编辑等基础模块，方便在此基础上继续扩展功能（如同步、提醒、Widget 等）。

## 功能概览

- 以 `JournalEntry` 为中心的数据模型，支持标题、正文、标签与心情（Mood）。
- `JournalViewModel` 负责状态管理、搜索、筛选与持久化逻辑。
- SwiftUI 界面包括：
  - `JournalListView`：展示、筛选和删除记录。
  - `EntryEditorView`：表单式编辑器，可新增或修改记录。
  - `JournalDetailView`：展示完整内容并支持跳转编辑。
  - `MoodSelector`、`EntryCard` 等可复用组件。
- `FileJournalStorage` 默认将数据序列化为 JSON 文件；`seed.json` 用作首次启动的示例数据。

## 目录结构

```
ios/DailyJournal
├── DailyJournalApp.swift        // App 入口
├── Models
│   ├── JournalEntry.swift
│   └── Mood.swift
├── ViewModels
│   └── JournalViewModel.swift
├── Services
│   └── JournalStorage.swift
├── Views
│   ├── JournalListView.swift
│   ├── JournalDetailView.swift
│   ├── EntryEditorView.swift
│   └── Components
│       ├── EntryCard.swift
│       └── MoodSelector.swift
└── Resources
    └── MockData
        └── seed.json
```

## 如何集成到 Xcode

1. 在 Xcode 中创建一个 **App** 模板（SwiftUI + Swift + iOS 16+）。
2. 将 `ios/DailyJournal` 下的 Swift 文件拖入项目，确保勾选 “Copy items if needed” 并添加到主 Target。
3. 将 `Resources/MockData/seed.json` 加入资源目录，并在 Target 的 **Build Phases → Copy Bundle Resources** 中确认已包含。
4. 如果需要自定义主题色，请在 `Assets.xcassets` 中添加 `Mood*.colorset` 与 README 中的色值一致，或直接修改 `Mood` 中的 `accentColorName`。
5. 运行 `DailyJournalApp` 目标，即可看到示例数据与基础交互。

## 下一步可以做什么

- **持久化**：接入 Core Data、CloudKit 或第三方同步方案。
- **安全性**：为敏感内容增加生物识别解锁。
- **提醒与组件**：添加本地通知、锁屏/桌面小组件。
- **多媒体**：在记录中插入照片或语音备忘。
- **多语言**：在 `Localizable.strings` 中补充文案，支持中英文切换。

欢迎根据自身需求继续扩展。若需要进一步的模块（如 API 同步、富文本编辑等），可以在此框架上迭代。祝开发顺利！
