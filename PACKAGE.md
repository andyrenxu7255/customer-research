# customer-research 技能包 - 完整分发说明

**版本：** 1.0  
**发布日期：** 2026 年 5 月 6 日  
**作者：** Dick Dunkel 销售智能体

---

## 📦 包内容

```
customer-research/
├── SKILL.md                      # 技能主配置（必读）
├── README.md                     # 安装和使用说明
├── AGENT_INSTRUCTIONS.md         # 智能体执行规则
├── 给销售智能体的使用说明.md      # 中文使用说明
├── PACKAGE.md                    # 本文件
├── install.sh                    # 安装脚本
├── customer-research.zip         # 打包文件
├── scripts/
│   ├── research.py               # 调研脚本
│   ├── create_word.py            # Word 报告生成
│   ├── create_ppt.py             # PPT 生成（旧版）
│   └── create_scenario_ppt.py    # PPT 生成（场景版）
└── references/
    └── scenario_templates.md     # 行业场景模板库
```

---

## 🚀 快速安装（给其他智能体）

### 方法 1：复制文件夹
```bash
cp -r /root/.openclaw/workspace/skills/customer-research ~/.openclaw/workspace/skills/
```

### 方法 2：使用 zip 包
```bash
unzip /root/.openclaw/workspace/skills/customer-research/customer-research.zip -d ~/.openclaw/workspace/skills/
```

### 方法 3：运行安装脚本
```bash
bash /root/.openclaw/workspace/skills/customer-research/install.sh
```

---

## ✅ 依赖检查

安装后确认以下技能已存在：
```bash
ls ~/.openclaw/workspace/skills/ | grep -E "word-docx|openclaw-ppt-generator"
```

如缺失，请先安装：
```bash
openclaw skills install word-docx
openclaw skills install openclaw-ppt-generator
```

---

## 📖 阅读顺序（给其他智能体）

1. **首先阅读：** `给销售智能体的使用说明.md` - 了解核心规则
2. **然后阅读：** `AGENT_INSTRUCTIONS.md` - 了解执行细节
3. **参考使用：** `references/scenario_templates.md` - 行业场景模板

---

## 🎯 核心规则（必须遵守）

### 铁律
**新客户拜访前必须执行调研，无例外。**

### 触发词
- "要去拜访 XX 客户"
- "准备见 XX 客户"
- "调研 XX 客户"
- "帮我查一下 XX 客户"

### 输出
| 文件 | 命名 | 用途 |
|------|------|------|
| 调研报告 | `[客户名称]_调研报告.docx` | 销售内部准备 |
| 场景破冰 PPT | `[客户名称]_场景破冰 PPT.pptx` | 拜访时演示 |

### PPT 标准
- ✅ 4 个以上具体业务场景
- ✅ before/after 对比（细节描述）
- ✅ 量化指标（时间/金额/百分比）
- ❌ 禁止"数字化转型""赋能"等空话

---

## 📊 行业场景库

内置 4 个行业场景模板：

| 行业 | 场景数量 | 场景示例 |
|------|----------|----------|
| 医疗 | 4 个 | 院长看板、护士排班、患者随访、库存耗材 |
| 制造 | 4 个 | 生产排程、质量追溯、设备管理、成本核算 |
| 零售 | 3 个 | 库存管理、会员运营、门店督导 |
| 教育 | 2 个 | 招生管理、教学质量 |

新增行业场景请编辑 `references/scenario_templates.md`

---

## 🔧 使用示例

### 输入
```
销售：要去拜访美中宜和
```

### 智能体执行流程
```
1. 识别客户名称：美中宜和
2. 执行 4 轮搜索：
   - AI 相关领导发言
   - AI 相关招标记录
   - 数据相关内容
   - 基本情况与最新动态
3. 生成 Word 报告
4. 生成场景破冰 PPT（before/after 对比）
5. 发送文件到企业微信
6. 记录到 memory/customers/美中宜和.md
7. 询问销售下一步行动
```

### 输出
```
📊 美中宜和调研报告已生成，请查收。
📊 美中宜和场景破冰 PPT 已生成，请查收。

销售，调研完成。下一步：
1. 预约拜访信息科负责人
2. 准备拜访问题清单
3. 还是有其他安排？
```

---

## ⚠️ 常见错误

### 错误 1：只给文件路径
```
❌ 错误："文件在 /root/.openclaw/workspace/xxx.docx"
✅ 正确：使用 openclaw message send --media 发送
```

### 错误 2：PPT 内容空泛
```
❌ 错误："提升效率""数字化转型"
✅ 正确："每月 5 号等报表，汇总要 3 天"→"每天早上 8 点自动推送日报"
```

### 错误 3：编造信息
```
❌ 错误："这个项目预算 100 万"（无来源）
✅ 正确："公开渠道未检索到预算信息，需拜访确认"
```

---

## 📋 质量检查清单

发送文件前自检：
- [ ] 每个场景都有具体的 before 痛点描述
- [ ] 每个场景都有具体的 after 价值描述
- [ ] 每个场景都有量化指标
- [ ] 场景数量 4 个以上
- [ ] 语言是客户业务语言，不是厂商术语
- [ ] 文件已通过企业微信发送
- [ ] 客户记忆已创建/更新

---

## 📞 技术支持

**技能位置：** `/root/.openclaw/workspace/skills/customer-research/`

**问题反馈：** 联系技能作者（Dick Dunkel 销售智能体）

**文档位置：**
- 安装说明：`README.md`
- 执行规则：`AGENT_INSTRUCTIONS.md`
- 场景模板：`references/scenario_templates.md`

---

## 📌 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-05-06 | 初始版本，支持 before/after 场景对比 |

---

**最后提醒：**

**我们是销售智能体，不是聊天机器人。**

**每个动作都要指向签约和交付。**

**—— Dick Dunkel**
