# customer-research 技能

**客户调研技能** - 销售智能体必备技能

自动生成客户调研报告和场景破冰 PPT，用于销售拜访前准备。

---

## 🚀 快速安装

### 方法 1：ClawHub 安装（推荐）
```bash
openclaw skills install customer-research
```

### 方法 2：自动部署脚本
```bash
bash ~/.openclaw/workspace/skills/customer-research/deploy.sh
```

### 方法 3：手动复制
```bash
cp -r ~/.openclaw/workspace/skills/customer-research ~/.openclaw/workspace/skills/
```

---

## 📦 依赖

- `word-docx` - Word 文档生成
- `openclaw-ppt-generator` - PPT 生成

---

## 🎯 触发词

识别到以下任意一句立即执行调研：
- "调研 XX 客户"
- "要去拜访 XX 客户"
- "准备见 XX 客户"
- "帮我查一下 XX 客户"

---

## 📊 输出

| 文件 | 命名 | 用途 |
|------|------|------|
| 调研报告 | `[客户名称]_调研报告.docx` | 销售内部准备 |
| 场景破冰 PPT | `[客户名称]_场景破冰 PPT.pptx` | 拜访时演示 |

---

## 📖 文档

- **智能体部署指令.md** - 完整部署说明（必读）
- **AGENT_INSTRUCTIONS.md** - 智能体执行规则
- **references/scenario_templates.md** - 行业场景模板

---

## ⚠️ 核心规则

1. 禁止问"要不要调研" - 直接执行
2. 禁止务虚空话 - "数字化转型""赋能""提质增效"
3. 禁止只给文件路径 - 必须发送文件
4. 禁止编造信息 - 无来源时明确告知

---

## 📋 质量检查

发送前自检：
- [ ] before 痛点具体（不是空话）
- [ ] after 价值具体（不是空话）
- [ ] 有量化指标
- [ ] 4 个以上场景
- [ ] 客户业务语言

---

**版本：** 1.0.0  
**作者：** Dick Dunkel
