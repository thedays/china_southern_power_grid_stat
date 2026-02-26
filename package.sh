#!/bin/bash

# 打包脚本：生成符合HACS要求的ZIP文件，自动更新版本号并可选推送到GitHub

echo "开始打包 China Southern Power Grid Statistics 组件..."

# 切换到项目根目录
cd "$(dirname "$0")" || {
    echo "错误：无法切换到项目根目录"
    exit 1
}

# 读取当前版本号
MANIFEST_FILE="custom_components/china_southern_power_grid_stat/manifest.json"
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "错误：找不到manifest.json文件"
    exit 1
fi

CURRENT_VERSION=$(grep "version" "$MANIFEST_FILE" | cut -d '"' -f 4)
echo "当前版本号：$CURRENT_VERSION"

# 自动增加版本号（格式：x.y.z -> x.y.z+1）
IFS="." read -r major minor patch <<< "$CURRENT_VERSION"
NEW_PATCH=$((patch + 1))
NEW_VERSION="$major.$minor.$NEW_PATCH"
echo "新版本号：$NEW_VERSION"

# 更新manifest.json中的版本号
sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/g" "$MANIFEST_FILE" || {
    echo "错误：更新版本号失败"
    exit 1
}
echo "✅ 版本号已更新到 $NEW_VERSION"

# 定义ZIP文件路径（基于项目根目录）
RELEASE_ZIP="china_southern_power_grid_stat-v$NEW_VERSION.zip"
general_zip="china_southern_power_grid_stat.zip"

# 切换到组件代码目录
cd "custom_components/china_southern_power_grid_stat" || {
    echo "错误：无法切换到组件目录"
    exit 1
}

# 生成release版本的ZIP文件
zip -r "../../$RELEASE_ZIP" * || {
    echo "错误：生成ZIP文件失败"
    exit 1
}

# 同时生成通用版本（无版本号后缀）
cp "../../$RELEASE_ZIP" "../../$general_zip" || {
    echo "警告：复制通用版本ZIP文件失败"
}

# 回到项目根目录
cd ../..

# 验证生成结果
if [ -f "$RELEASE_ZIP" ]; then
    echo "✅ 打包成功！"
    echo "Release版本：$(pwd)/$RELEASE_ZIP"
    echo "通用版本：$(pwd)/$general_zip"
    echo "文件大小：$(du -h "$RELEASE_ZIP" | cut -f1)"
else
    echo "❌ 打包失败：未生成ZIP文件"
    exit 1
fi

# 检查是否需要推送到GitHub
echo "\n是否将更改推送到GitHub？"
echo "1. 是"
echo "2. 否"
read -p "请选择 (1/2): " push_choice

if [ "$push_choice" = "1" ]; then
    echo "\n开始推送到GitHub..."
    
    # 检查git状态
    git status
    
    # 只添加脚本和代码文件，排除ZIP文件
    git add package.sh custom_components/ || {
        echo "错误：添加文件到git失败"
        exit 1
    }
    
    # 提交更改
    git commit -m "Bump version to $NEW_VERSION" || {
        echo "错误：git提交失败"
        exit 1
    }
    
    # 推送到GitHub
    git push origin master || {
        echo "错误：推送到GitHub失败"
        exit 1
    }
    
    echo "✅ 推送到GitHub成功！"
else
    echo "跳过推送到GitHub步骤。"
fi

echo "\n打包完成。生成的文件可用于："
echo "1. HACS手动安装"
echo "2. GitHub Release发布"
echo "3. 本地测试部署"
