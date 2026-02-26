#!/bin/bash

# 打包脚本：生成符合HACS要求的ZIP文件并可选推送到GitHub

echo "开始打包 China Southern Power Grid Statistics 组件..."

# 切换到项目根目录
cd "$(dirname "$0")" || {
    echo "错误：无法切换到项目根目录"
    exit 1
}

# 切换到组件代码目录
cd "custom_components/china_southern_power_grid_stat" || {
    echo "错误：无法切换到组件目录"
    exit 1
}

# 生成ZIP文件，保存到项目根目录
zip -r "../../china_southern_power_grid_stat.zip" * || {
    echo "错误：生成ZIP文件失败"
    exit 1
}

# 回到项目根目录
cd ../..

# 验证生成结果
if [ -f "china_southern_power_grid_stat.zip" ]; then
    echo "✅ 打包成功！"
    echo "生成的文件：$(pwd)/china_southern_power_grid_stat.zip"
    echo "文件大小：$(du -h china_southern_power_grid_stat.zip | cut -f1)"
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
    git commit -m "Update component files" || {
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

echo "\n打包完成。该ZIP文件可用于："
echo "1. HACS手动安装"
echo "2. 作为组件发布包"
echo "3. 本地测试部署"
