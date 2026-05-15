#!/bin/bash
# customer-research 技能自动部署脚本
# 兼容：Hermes Agent, OpenClaw, 或其他支持技能的 agent framework
# 安全版本：无 rm -rf，路径验证，环境检测

set -e

echo "🚀 开始部署 customer-research 技能..."
echo ""

# ---------------------------------------------------------------------------
# 环境检测
# ---------------------------------------------------------------------------

detect_agent_framework() {
    if command -v hermes &> /dev/null || [ -n "$HERMES_HOME" ]; then
        echo "hermes"
    elif command -v openclaw &> /dev/null || [ -n "$OPENCLAW_HOME" ]; then
        echo "openclaw"
    else
        echo "unknown"
    fi
}

AGENT_FRAMEWORK=$(detect_agent_framework)
echo "📋 检测到 Agent Framework: $AGENT_FRAMEWORK"

# 根据环境设置路径
if [ "$AGENT_FRAMEWORK" = "hermes" ]; then
    SKILLS_DIR="${HERMES_HOME:-$HOME/.hermes}/skills"
    WORKSPACE_DIR="${HERMES_HOME:-$HOME/.hermes}"
    INSTALL_CMD="hermes skills install"
elif [ "$AGENT_FRAMEWORK" = "openclaw" ]; then
    SKILLS_DIR="${OPENCLAW_HOME:-$HOME/.openclaw/workspace}/skills"
    WORKSPACE_DIR="${OPENCLAW_HOME:-$HOME/.openclaw/workspace}"
    INSTALL_CMD="openclaw skills install"
else
    SKILLS_DIR="$(pwd)/skills"
    WORKSPACE_DIR="$(pwd)"
    INSTALL_CMD=""
    echo "⚠️  未识别到 Hermes 或 OpenClaw，使用当前目录"
fi

# ---------------------------------------------------------------------------
# 1. 检查 ClawHub 登录状态
# ---------------------------------------------------------------------------

echo "📋 步骤 1/4: 检查 ClawHub 登录状态..."
if command -v clawhub &> /dev/null; then
    if ! clawhub whoami 2>&1 | grep -q "✔"; then
        echo "❌ 未登录 ClawHub，请先执行：clawhub login"
        exit 1
    fi
    echo "✅ ClawHub 已登录"
else
    echo "⚠️  clawhub CLI 未安装，跳过登录检查"
fi
echo ""

# ---------------------------------------------------------------------------
# 2. 安装技能（安全版本）
# ---------------------------------------------------------------------------

echo "📋 步骤 2/4: 安装 customer-research 技能..."
TARGET_DIR="$SKILLS_DIR/customer-research"

if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  检测到已安装的技能"
    echo "    目标目录：$TARGET_DIR"
    echo ""
    echo "选项："
    echo "  [1] 覆盖安装（备份旧版本）"
    echo "  [2] 跳过安装"
    echo "  [3] 取消部署"
    echo ""
    read -r -p "请选择 [1-3]: " response
    
    case "$response" in
        1)
            # 安全备份：移动到备份目录，不用 rm -rf
            BACKUP_DIR="$SKILLS_DIR/.backup/customer-research-$(date +%Y%m%d%H%M%S)"
            mkdir -p "$(dirname "$BACKUP_DIR")"
            mv "$TARGET_DIR" "$BACKUP_DIR"
            echo "✅ 旧版本已备份到：$BACKUP_DIR"
            ;;
        2)
            echo "⏭️  跳过安装"
            ;;
        3)
            echo "❌ 部署取消"
            exit 1
            ;;
        *)
            echo "❌ 无效选择，部署取消"
            exit 1
            ;;
    esac
fi

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 复制技能文件（从当前脚本所在目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
    # 使用 cp -n 保留已存在的文件，避免覆盖
    cp -rn "$SCRIPT_DIR"/* "$TARGET_DIR/" 2>/dev/null || {
        # 如果 cp -n 失败，使用普通 cp
        cp -r "$SCRIPT_DIR"/* "$TARGET_DIR/"
    }
    echo "✅ 技能文件已复制到：$TARGET_DIR"
else
    echo "ℹ️  技能已在目标目录，跳过复制"
fi
echo ""

# ---------------------------------------------------------------------------
# 3. 检查依赖
# ---------------------------------------------------------------------------

echo "📋 步骤 3/4: 检查依赖技能..."
MISSING_DEPS=()

if [ ! -d "$SKILLS_DIR/word-docx" ]; then
    MISSING_DEPS+=("word-docx")
fi

if [ ! -d "$SKILLS_DIR/openclaw-ppt-generator" ]; then
    MISSING_DEPS+=("openclaw-ppt-generator")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  缺少依赖技能：${MISSING_DEPS[*]}"
    if [ -n "$INSTALL_CMD" ]; then
        echo ""
        echo "建议安装命令："
        for dep in "${MISSING_DEPS[@]}"; do
            echo "  $INSTALL_CMD $dep"
        done
        echo ""
        read -r -p "是否现在安装？[y/N]: " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            for dep in "${MISSING_DEPS[@]}"; do
                $INSTALL_CMD "$dep" || echo "⚠️  安装 $dep 失败，请手动安装"
            done
        fi
    else
        echo "请手动安装依赖技能"
    fi
else
    echo "✅ 依赖技能已安装"
fi
echo ""

# ---------------------------------------------------------------------------
# 4. 更新 SOUL.md（仅 OpenClaw 需要）
# ---------------------------------------------------------------------------

if [ "$AGENT_FRAMEWORK" = "openclaw" ]; then
    echo "📋 步骤 4/4: 检查 SOUL.md..."
    SOUL_FILE="$WORKSPACE_DIR/SOUL.md"
    APPEND_FILE="$TARGET_DIR/SOUL_APPEND.md"

    if [ ! -f "$SOUL_FILE" ]; then
        read -r -p "未找到 SOUL.md，是否创建？[y/N]: " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "# SOUL.md" > "$SOUL_FILE"
            echo "✅ SOUL.md 已创建"
        else
            echo "ℹ️  跳过 SOUL.md 创建"
        fi
    fi

    if [ -f "$APPEND_FILE" ]; then
        if grep -q "新客户拜访铁律" "$SOUL_FILE" 2>/dev/null; then
            echo "ℹ️  SOUL.md 已包含相关内容，跳过更新"
        else
            cat "$APPEND_FILE" >> "$SOUL_FILE"
            echo "✅ SOUL.md 已更新"
        fi
    else
        echo "ℹ️  SOUL_APPEND.md 不存在，跳过"
    fi
else
    echo "📋 步骤 4/4: 跳过 SOUL.md 更新（Hermes 不需要）"
fi
echo ""

# ---------------------------------------------------------------------------
# 5. 验证部署
# ---------------------------------------------------------------------------

echo "📋 验证部署..."
echo ""

PASS=0
FAIL=0

# 检查技能文件
if [ -f "$TARGET_DIR/SKILL.md" ]; then
    echo "✅ 技能文件：已安装"
    ((PASS++))
else
    echo "❌ 技能文件：缺失"
    ((FAIL++))
fi

# 检查 SOUL.md（仅 OpenClaw）
if [ "$AGENT_FRAMEWORK" = "openclaw" ]; then
    if [ -f "$SOUL_FILE" ] && grep -q "新客户拜访铁律" "$SOUL_FILE" 2>/dev/null; then
        echo "✅ SOUL.md：已更新"
        ((PASS++))
    else
        echo "ℹ️  SOUL.md：未更新（可选）"
        ((PASS++))
    fi
else
    echo "ℹ️  SOUL.md：跳过（Hermes）"
    ((PASS++))
fi

# 检查脚本
if [ -f "$TARGET_DIR/scripts/research.py" ]; then
    echo "✅ 调研脚本：已安装"
    ((PASS++))
else
    echo "❌ 调研脚本：缺失"
    ((FAIL++))
fi

# 检查依赖
for dep in "word-docx" "openclaw-ppt-generator"; do
    if [ -d "$SKILLS_DIR/$dep" ]; then
        echo "✅ 依赖 $dep：已安装"
        ((PASS++))
    else
        echo "⚠️  依赖 $dep：未安装（可选）"
        ((PASS++))
    fi
done

echo ""
echo "================================"
echo "部署完成：$PASS 通过，$FAIL 失败"
echo "================================"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "⚠️  部分检查未通过，请手动修复后重试"
    exit 1
fi

echo ""
echo "📌 使用说明："
echo "   触发词：'调研 XX 客户' / '要去拜访 XX 客户' / '准备见 XX 客户'"
echo "   输出：Word 调研报告 + 场景破冰 PPT"
echo "   规则：禁止空话，必须 before/after 对比 + 量化指标"
echo ""
echo "📖 详细文档：$TARGET_DIR/智能体部署指令.md"
echo ""
