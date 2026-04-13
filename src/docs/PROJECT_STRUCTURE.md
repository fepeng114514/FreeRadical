# PROJECT_STRUCTURE
该文档用于说明目录的作用，以便组织代码。

## src 根目录
```
src/
├── .build/                 # 编译输出（自动生成，不提交 Git）
├── addons/                 # 插件
├── assets/                 # 资源文件
│   ├── animated_atlas/     # 动画图集 
│   ├── audios/             # 音频 
│   ├── fonts/              # 字体 
│   ├── image_atlas/        # 图像图集 
│   └── shaders/            # 着色器
├── autoloads/              # 自动加载
│   └── managers/           # 管理器
├── classes/                # 类
│   ├── components          # 组件类
│   │   └── subcomponents/  # 子组件
│   ├── resources           # 资源类
│   └── systems             # 系统类
│       └── behaviors/      # 行为类
├── datas/                  # 数据
├── docs/                   # 文档
├── resources/              # 资源
│   ├── atlas_textures/     # 图集纹理资源
│   ├── select_menu/        # 选择菜单资源
│   └── sprite_frames/      # 精灵帧资源
├── scenes/                 # 场景
│   ├── entities/           # 实体场景
│   ├── levels/             # 关卡场景
│   └── ui/                 # UI 场景
├── tools/                  # 构建/辅助工具脚本
```
