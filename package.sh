#!/bin/bash

# 打包脚本：生成符合HACS要求的ZIP文件

echo "开始打包 China Southern Power Grid Statistics 组件..."

# 切换到组件代码目录
cd "$(dirname "$0")/custom_components/china_southern_power_grid_stat" || {
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

echo "\n打包完成。该ZIP文件可用于："
echo "1. HACS手动安装"
echo "2. 作为组件发布包"
echo "3. 本地测试部署"
