# 项目架构
该文档用于说明项目的架构与目录结构，以便组织代码。

## 目录
```
src/
├── .build/                 # 编译输出（自动生成，不提交 Git）目录
├── addons/                 # 插件目录
├── assets/                 # 资源文件目录
│   ├── animated_atlas/     # 动画图集目录
│   ├── audios/             # 音频目录
│   ├── fonts/              # 字体目录
│   ├── image_atlas/        # 图像图集目录
│   └── shaders/            # 着色器目录
├── autoloads/              # 自动加载目录
│   └── managers/           # 管理器目录
├── classes/                # 类目录
│   ├── components          # 组件类目录
│   │   └── subcomponents/  # 子组件目录
│   ├── resources/          # 资源类目录
│   ├── systems/            # 系统类目录
│   │   └── behaviors/      # 行为类目录
│   └── entity.gd           # 实体类
├── datas/                  # 数据目录
├── docs/                   # 文档目录
├── resources/              # 资源目录
│   ├── atlas_textures/     # 图集纹理资源目录
│   ├── select_menu/        # 选择菜单资源目录
│   └── sprite_frames/      # 精灵帧资源目录
├── scenes/                 # 场景目录
│   ├── entities/           # 实体场景目录
│   ├── levels/             # 关卡场景目录
│   └── ui/                 # UI 场景目录
├── tools/                  # 构建/辅助工具脚本目录
```

## 架构
项目使用 ECS 实体-组件-系统架构，将数据与逻辑分离到组件与系统中。

## 代码层级
核心层（core）
↓
管理器层（managers）
↓
组件层（components）
↓
系统层（systems）

## 流程

### 实体生命周期
1. 创建实体，遍历并调用所有系统的 `_on_insert` 回调。
2. 开始更新实体，每帧遍历并调用所有系统的 `_on_update` 回调。
3. 实体被移除，遍历并调用所有系统的 `_on_remove` 回调。

### 创建实体流程：
1. 在 `scenes/entities` 目录创建一个场景，场景根节点为 `Entity` 实体节点。
2. 为场景挂载各种组件：
	- 如：`RangedComponent` 远程攻击组件，可以使实体向其他实体发射子弹。
	- 一些组件可能有子组件：如 `RangedComponent` 有 `RangedAttack` 单次远程攻击子组件。
3. 修改组件的属性为想要的属性：
	- 如：`RangedAttack` 的攻击范围、攻击速度等。
4. 可以扩展 `Entity` 的脚本来在一些回调中进行一些操作：
	- 如：`_on_update` 回调，每帧会被调用。
5. 运行 tools/update_json_datas 更新场景字典 entity_scenes

> **注意**：为了可复用性不应该依赖扩展脚本来为实体增加逻辑，而是将逻辑抽象为组件的属性，除非该逻辑不会被复用或过于特例化。

### 创建组件流程：
1. 在 `classes/components` 中创建一个 `.gd` 脚本：
	- 脚本名为蛇形命名法，如：`health_component`。
2. 使用 `class_name` 声明组件类名：
	- 类名为帕斯卡命名法，如：`HealthComponent`。
3. 为组件声明属性：
	- 如：`max_hp` 最大血量、`hp` 当前血量。
	- 请为属性增加文档注释以便在编辑器查看。
4. 在 `classes/systems` 中创建一个 `.gd` 脚本并续承 `System` 类：
	- 命名方法同上。
5. 使用 `class_name` 声明系统类名：
	- 命名方法同上。
6. 通过一些回调函数对拥有特定组件的实体进行操作：
	- 如：`_on_insert` 回调，会在实体被插入时调用。
7. 最后将此系统节点增加到需要的场景的 `SystemController` 节点。

