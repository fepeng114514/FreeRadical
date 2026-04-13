# PROJECT_STRUCTURE
该文档用于说明项目的架构与目录结构，以便组织代码。

## 目录
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

## 结构
项目使用 ECS 实体-组件-系统架构，将数据与逻辑分离到组件与系统中。

**创建实体流程**：
1. 在 `scenes/entities` 目录创建一个场景，场景根节点为 `Entity` 实体节点。
2. 为场景挂载各种组件：
	- 如 `RangedComponent` 远程攻击组件，可以使实体向其他实体发射子弹。
	- 一些组件可能有子组件：如 `RangedComponent` 有 `RangedAttack` 单次远程攻击子组件。
3. 修改组件的属性为想要的属性：
	- 如 `RangedAttack` 的攻击范围、攻击速度等。
4. 可以扩展 `Entity` 的脚本来在一些回调中进行一些操作
	- 如 `_on_update` 回调，每帧会被调用。

> **注意**：不应该依赖扩展脚本来为实体增加逻辑，除非该逻辑不会被复用，否则请将逻辑抽象为组件的属性，便于复用。

**创建组件流程**
