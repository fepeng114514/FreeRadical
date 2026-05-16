# 项目架构分析文档

> 生成时间：2026-05-15
> 项目名称：从零开始的异世界塔防（Zero-Based Isekai Tower Defense）
> 引擎：Godot 4.6（Forward Plus 渲染模式）
> 语言：GDScript

---

## 一、项目概述

本项目是一款 **2D 塔防游戏**，使用 **Godot 4.6** 引擎开发，采用 **ECS（Entity-Component-System）** 架构模式，将游戏对象的数据与逻辑解耦。游戏主题为"异世界"题材的塔防玩法，包含敌人波次进攻、防御塔建造与升级、英雄单位、状态效果/光环等核心机制。

### 核心特性

- 基于 ECS 架构，实体（Entity）承载组件（Component），系统（System）处理逻辑
- 行为树（Behavior Tree）驱动的实体 AI 系统
- 子弹轨迹系统（直线/抛物线/追踪/瞬移）
- 波次生成系统（Wave System）控制敌人出现节奏
- 路径系统（Pathway System）支持多路径、子路径导航
- 空间索引网格（Space Index Grid）优化索敌性能
- 完整的伤害系统（含物理/魔法/炮击/真实/毒/秒杀等多种伤害类型）

---

## 二、项目目录结构

```
src/
├── addons/                        # Godot 编辑器插件
│   └── mask_check/                # 遮罩检查工具插件
│
├── assets/                        # 资源文件
│   ├── animated_atlas/            # 动画图集（用于 SpriteFrames）
│   ├── image_atlas/               # 图像图集（用于 AtlasTexture）
│   ├── audios/                    # 音频文件（.ogg）
│   ├── fonts/                     # 字体文件
│   └── shaders/                   # 着色器文件
│
├── autoloads/                     # 自动加载（全局单例）
│   ├── I18n.gd                    # 国际化
│   ├── signals.gd                 # 全局信号库
│   └── managers/                  # 管理器集合
│       ├── audio_manager.gd       # 音频播放管理
│       ├── canvas_manager.gd      # 画布坐标转换
│       ├── editor_manager.gd      # 编辑器工具
│       ├── entity_manager.gd      # 实体管理（核心）
│       ├── game_manager.gd        # 游戏数据（金币/生命）
│       ├── global_manager.gd      # 全局配置（窗口/世界大小）
│       ├── grid_manager.gd        # 网格数据
│       ├── input_manager.gd       # 鼠标输入
│       ├── level_manager.gd       # 关卡切换
│       ├── pathway_manager.gd     # 路径数据（核心）
│       ├── select_manager.gd      # 实体选择交互
│       ├── setting_manager.gd     # 设置管理
│       ├── system_manager.gd      # 系统主循环（核心）
│       ├── time_manager.gd        # 时间/帧率管理
│       └── wave_manager.gd        # 波次控制
│
├── classes/                       # 全局类/工具
│   ├── constants.gd               # 常量枚举（C 类）
│   ├── log.gd                     # 日志系统（Log 类）
│   └── utils.gd                   # 工具函数库（U 类）
│
├── conf.gd                        # 游戏配置（Conf 类）
├── project.godot                  # Godot 项目配置文件
│
├── datas/                         # 数据目录（当前为空）
│
├── docs/                          # 文档目录
│   ├── ARCHITECTURE_ANALYSIS.md   # 🔵 本文档
│   ├── CODE_SPEC.md               # 代码规范
│   ├── COMMITS_SPEC.md            # 提交规范（约定式提交）
│   ├── PROCESS.md                 # 开发流程说明
│   ├── PROJECT_STRUCTURE.md       # 项目结构概览
│   └── TODO.md                    # 待办事项
│
├── ecs/                           # ECS 核心
│   ├── damage.gd                  # 伤害数据类
│   ├── entity.gd                  # 实体基类（核心）
│   ├── entity_group.gd            # 实体组（Node）
│   ├── entity_group_2d.gd         # 实体组（Node2D）
│   │
│   ├── components/                # 组件集合
│   │   ├── aura_component.gd      # 光环组件
│   │   ├── barrack_component.gd   # 兵营组件
│   │   ├── bullet_component.gd    # 子弹组件
│   │   ├── dodge_component.gd     # 闪避组件（待实现）
│   │   ├── fx_component.gd        # 特效组件
│   │   ├── health_component.gd    # 血量组件
│   │   ├── level_component.gd     # 等级组件
│   │   ├── melee_component.gd     # 近战组件
│   │   ├── modifier_component.gd  # 状态效果组件
│   │   ├── nav_path_component.gd  # 导航路径组件
│   │   ├── property_modifier.gd   # 属性修改器
│   │   ├── rally_component.gd     # 集结点组件
│   │   ├── skill_component.gd     # 技能组件
│   │   ├── spawner_component.gd   # 生成器组件
│   │   ├── sprite_component.gd    # 精灵组件
│   │   ├── sprite_group.gd        # 精灵组
│   │   ├── tower_component.gd     # 防御塔组件
│   │   ├── ui_component.gd        # UI交互组件
│   │   │
│   │   └── subcomponents/         # 技能子组件
│   │       ├── skill_area.gd      # 范围技能
│   │       ├── skill_base.gd      # 技能基类
│   │       ├── skill_melee.gd     # 近战技能
│   │       ├── skill_ranged.gd    # 远程技能
│   │       ├── skill_ranged_multiple.gd  # 多重远程技能
│   │       └── skill_spawn.gd     # 召唤技能
│   │
│   └── systems/                   # 系统集合
│       ├── system.gd              # 系统基类
│       ├── aura_system.gd         # 光环系统
│       ├── behavior_system.gd     # 行为树系统
│       ├── bullet_system.gd       # 子弹系统
│       ├── damage_system.gd       # 伤害结算系统
│       ├── entity_system.gd       # 实体生命周期系统
│       ├── fx_system.gd           # 特效系统
│       ├── grouping_system.gd     # 实体分组系统
│       ├── health_system.gd       # 血量系统
│       ├── level_system.gd        # 等级系统
│       ├── modifier_system.gd     # 状态效果系统
│       ├── sprite_system.gd       # 精灵动画系统
│       ├── time_system.gd         # 时间更新系统
│       ├── tower_system.gd        # 防御塔系统
│       │
│       └── behaviors/             # 行为树节点
│           ├── behavior.gd        # 行为基类
│           ├── barrack_behavior.gd     # 兵营行为
│           ├── melee_behavior.gd       # 近战行为
│           ├── nav_path_behavior.gd    # 路径行走行为
│           ├── rally_behavior.gd       # 集结点行为
│           ├── skill_behavior.gd       # 技能释放行为
│           └── spawner_behavior.gd     # 生成器行为
│
├── resources/                     # 资源文件
│   ├── atlas_textures/            # 图集纹理
│   ├── classes/                   # 自定义资源类
│   │   ├── animation_data.gd      # 动画数据资源
│   │   ├── animation_group.gd     # 动画组资源
│   │   ├── audio_group.gd         # 音频组资源
│   │   ├── death_data.gd          # 死亡数据资源
│   │   ├── offset_group.gd        # 偏移组资源
│   │   ├── pathway_node.gd        # 路径节点资源
│   │   ├── sync_animations_data.gd # 同步动画资源
│   │   ├── trajectories/          # 子弹轨迹资源
│   │   │   ├── bullet_trajectory.gd       # 轨迹基类
│   │   │   ├── trajectory_instant.gd      # 瞬移轨迹
│   │   │   ├── trajectory_linear.gd       # 直线轨迹
│   │   │   ├── trajectory_parabola.gd     # 抛物线轨迹
│   │   │   └── trajectory_tracking.gd     # 追踪轨迹
│   │   └── wave/                  # 波次资源
│   │       ├── wave.gd            # 波次数据
│   │       ├── wave_group.gd      # 波次集合
│   │       ├── wave_spawn.gd      # 生成条目
│   │       └── wave_spawn_group.gd # 生成批次
│   ├── default_bus_layout.tres    # 音频总线布局
│   ├── grid_tileset.tres          # 网格图块集
│   ├── sprite_frames/             # 精灵帧资源
│   └── theme.tres                 # 主题样式
│
├── scenes/                        # 场景文件
│   ├── entities/                  # 实体场景
│   │   ├── bullet.tscn            # 子弹场景
│   │   ├── cursor.tscn            # 鼠标光标
│   │   ├── explosion_air.tscn     # 空中爆炸特效
│   │   ├── wave_spawner.tscn      # 波次生成器
│   │   ├── entity_scene_paths.json # 实体场景路径索引
│   │   │
│   │   ├── enemies/               # 敌人实体
│   │   │   ├── enemy.tscn         # 通用敌人
│   │   │   ├── enemy_goblin.tscn  # 哥布林敌人
│   │   │   └── enemy_orc.tscn     # 兽人敌人
│   │   │
│   │   └── towers/                # 防御塔实体
│   │       ├── tower.tscn                    # 通用防御塔
│   │       ├── tower_archer*.tscn             # 弓箭手塔（3级）
│   │       ├── tower_artillery*.tscn          # 炮塔（3级）
│   │       ├── tower_barrack*.tscn            # 兵营（3级）
│   │       ├── tower_mage*.tscn               # 法师塔（3级）
│   │       ├── tower_build*.tscn              # 建造预览
│   │       ├── tower_holder*.tscn             # 塔位
│   │       ├── tower_preview*.tscn            # 放置预览
│   │       └── bullet_*.tscn                  # 各塔子弹
│   │
│   ├── levels/                    # 关卡场景
│   │   ├── level.tscn             # 关卡模板
│   │   ├── level_1.tscn           # 第1关
│   │   ├── level_systems.tscn     # 关卡系统节点
│   │   ├── systems.tscn           # 系统配置场景
│   │   ├── camera.gd              # 摄像机
│   │   ├── grid.gd                # 网格绘制
│   │   ├── level.gd               # 关卡逻辑
│   │   ├── pathway.gd             # 路径绘制
│   │   ├── pathways.gd            # 路径集合
│   │   ├── subpathway.gd          # 子路径
│   │   ├── systems.gd             # 系统列表加载
│   │   ├── world.gd               # 世界节点（实体父级）
│   │   └── world.gd               # 世界节点
│   │
│   └── ui/                        # UI 场景
│       ├── game_ui/               # 游戏内 UI
│       │   ├── bottom_bar.tscn    # 底部操作栏
│       │   ├── top_bar.tscn       # 顶部信息栏
│       │   ├── top_controls.tscn  # 顶部控制按钮
│       │   ├── player_resources.tscn  # 玩家资源显示
│       │   ├── skills.tscn        # 技能面板
│       │   ├── speed_button.tscn  # 倍速按钮
│       │   ├── game_ui_layer.tscn # UI 分层
│       │   ├── entity_info_bar.tscn   # 实体信息栏
│       │   ├── game_ui_text.tscn  # UI 文字
│       │   ├── info_circle_controller/    # 信息圈控制器
│       │   ├── select_menu_controller/    # 选择菜单控制器
│       │   └── wave_flag/                 # 波次标记
│       ├── main/                  # 主菜单
│       │   ├── main.tscn          # 主菜单场景
│       │   ├── main.gd            # 主菜单逻辑
│       │   ├── play_button.gd     # 开始按钮
│       │   ├── quit_button.gd     # 退出按钮
│       │   ├── setting_button.gd  # 设置按钮
│       │   └── exit_dialog.tscn   # 退出确认弹窗
│       └── map/                   # 大地图
│           └── map.tscn           # 地图选择场景
│
└── tools/                         # 开发工具
    ├── generate_texture.gd        # 纹理/SpriteFrames生成
    ├── update_audio_paths.gd      # 音频路径索引更新
    ├── update_entity_scene_paths.gd # 实体场景路径索引更新
    ├── sprite_frames_datas/       # SpriteFrames 数据
    └── wave_editor/               # 波次编辑器
        └── wave_editor.tscn       # 波次编辑场景
```

---

## 三、核心架构：ECS（Entity-Component-System）

项目采用高度模块化的 ECS 架构，将游戏对象拆分为三个层次。

### 3.1 实体（Entity）

**文件：** `ecs/entity.gd` → `class_name Entity`

实体是游戏中所有具有行为和属性的对象的基类，如：敌人、友军、防御塔、子弹、状态效果等。每个实体：

- 继承自 `Node2D`，拥有 2D 空间位置
- 挂载多个 `Component` 节点作为子节点，以获取不同的能力
- 拥有**唯一 ID**（`id`），由 `EntityManager` 分配
- 存储实体标识（`flags`，位运算），如 `ENEMY`、`BOSS`、`FRIENDLY`、`TOWER`、`FLYING` 等
- 拥有**状态位**（`state`，位运算），如 `IDLE`、`MELEE`、`RANGED`、`DEATH` 等
- 提供丰富的**生命周期回调**：`_on_insert`、`_on_remove`、`_on_update`、`_on_damage`、`_on_death`、`_on_kill` 等
- 支持**白名单/黑名单**机制控制交互目标

### 3.2 组件（Component）

**位置：** `ecs/components/`

组件是实体的"能力模块"，以子节点形式挂载到实体上。每个组件定义数据和配置，不包含业务逻辑。

| 组件 | 类名 | 功能描述 |
|------|------|----------|
| 血量组件 | `HealthComponent` | 管理实体的 HP、护甲、反伤、免疫伤害类型、死亡数据 |
| 技能组件 | `SkillComponent` | 持有多个技能子组件，驱动技能释放 |
| 子弹组件 | `BulletComponent` | 子弹飞行数据（起点/终点/轨迹/搜索模式） |
| 近战组件 | `MeleeComponent` | 近战拦截、阻挡列表、攻击数据 |
| 导航路径组件 | `NavPathComponent` | 路径行走状态、当前路径索引、反转/循环 |
| 集结点组件 | `RallyComponent` | 集结点位置、移动状态 |
| 状态效果组件 | `ModifierComponent` | 状态效果数据、周期触发 |
| 光环组件 | `AuraComponent` | 光环范围、影响类型、周期触发 |
| 兵营组件 | `BarrackComponent` | 士兵生成、集结点、士兵管理 |
| 防御塔组件 | `TowerComponent` | 塔类型、升级/出售、建造者管理 |
| 精灵组件 | `SpriteComponent` | 精灵显示、动画管理 |
| 精灵组 | `SpriteGroup` | 多精灵组合管理 |
| 生成器组件 | `SpawnerComponent` | 实体召唤数据 |
| 特效组件 | `FXComponent` | 特效播放后自动移除 |
| UI 组件 | `UIComponent` | 选择交互、信息栏显示 |
| 等级组件 | `LevelComponent` | 实体等级、经验 |
| 属性修改器 | `PropertyModifier` | 属性数值临时修改 |
| 闪避组件 | `DodgeComponent` | （待实现）闪避能力 |

**技能子组件（`ecs/components/subcomponents/`）：**

| 子组件 | 类名 | 功能 |
|--------|------|------|
| 技能基类 | `Skill` | 冷却、组冷却、搜索模式、伤害数据 |
| 远程技能 | `SkillRanged` | 发射子弹攻击 |
| 多重远程技能 | `SkillRangedMultiple` | 发射多发子弹 |
| 近战技能 | `SkillMelee` | 近战范围攻击 |
| 范围技能 | `SkillArea` | 范围效果 |
| 召唤技能 | `SkillSpawn` | 召唤其他实体 |

### 3.3 系统（System）

**位置：** `ecs/systems/`，继承自 `System` 基类

系统是纯逻辑模块，每帧遍历具备特定组件的实体并执行操作。

| 系统 | 类名 | 功能描述 |
|------|------|----------|
| 实体系统 | `EntitySystem` | 实体生命周期管理（插入/移除/更新）、跟踪来源、持续时间 |
| 伤害系统 | `DamageSystem` | 伤害队列处理、护甲减伤计算、反伤、死亡判定 |
| 血量系统 | `HealthSystem` | 血量更新、死亡处理 |
| 子弹系统 | `BulletSystem` | 子弹飞行、命中/未命中处理 |
| 防御塔系统 | `TowerSystem` | 塔升级/出售、建造者管理 |
| 行为系统 | `BehaviorSystem` | 驱动行为树 |
| 光环系统 | `AuraSystem` | 光环周期性效果 |
| 状态效果系统 | `ModifierSystem` | 状态效果周期性效果 |
| 特效系统 | `FXSystem` | 特效生命周期管理 |
| 精灵系统 | `SpriteSystem` | 精灵动画更新、朝向 |
| 分组系统 | `GroupingSystem` | 实体类型分组维护 |
| 时间系统 | `TimeSystem` | 更新时间戳 |
| 等级系统 | `LevelSystem` | 等级相关逻辑 |

### 3.4 行为树（Behavior Tree）

**位置：** `ecs/systems/behaviors/`

行为系统使用类似行为树的机制驱动实体 AI，每个行为类像树节点一样执行逻辑。

**系统驱动：** `BehaviorSystem` 按顺序遍历行为列表，每个行为返回 `true` 表示阻断后续行为（类似于行为树的"优先级"）。

| 行为 | 类名 | 功能 |
|------|------|------|
| 行为基类 | `Behavior` | 定义 `_on_insert`/`_on_remove`/`_on_update`/`_on_skip` |
| 路径行走行为 | `NavPathBehavior` | 实体沿导航路径移动 |
| 集结点行为 | `RallyBehavior` | 实体向集结点移动 |
| 近战行为 | `MeleeBehavior` | 近战拦截与攻击 |
| 技能行为 | `SkillBehavior` | 技能释放循环 |
| 兵营行为 | `BarrackBehavior` | 士兵生成管理 |
| 生成器行为 | `SpawnerBehavior` | 实体召唤逻辑 |

**行为执行顺序（优先级）：**
1. `NavPathBehavior` — 路径行走
2. `RallyBehavior` — 前往集结点
3. `MeleeBehavior` — 近战拦截
4. `SkillBehavior` — 释放技能
5. `BarrackBehavior` — 兵营管理
6. `SpawnerBehavior` — 召唤实体

---

## 四、管理器系统（Autoloads / Managers）

项目通过 Godot 的"自动加载"功能注册了多个全局单例管理器。

### 管理器层次与职责

```
管理器分层示意图：

表现层
  ├── AudioManager     音频播放（音乐/音效）
  ├── CanvasManager    画布坐标转换
  └── InputManager     鼠标输入

数据层
  ├── GameManager      游戏数据（金币/生命）
  ├── GlobalManager    全局配置（窗口/世界大小）
  ├── SettingManager   设置管理
  └── I18n             国际化

核心管理层
  ├── EntityManager    实体创建/索引/空间搜索
  ├── PathwayManager   路径数据/节点查询
  ├── GridManager      网格数据
  ├── TimeManager      时间戳/帧率/协程等待
  ├── WaveManager      波次控制

交互层
  ├── SelectManager    实体选择/集结点设置
  └── LevelManager     关卡切换

系统层
  └── SystemManager    系统主循环/队列管理
```

### 核心管理器详解

#### SystemManager（系统管理器）
- 维护 `system_list`（系统数组）
- 通过 `_physics_process` 驱动所有系统的 `_on_update`
- 维护 `insert_queue`、`remove_queue`、`damage_queue` 三个队列
- 使用 `call_deferred` 在帧末安全处理插入和移除
- 提供 `call_systems` 方法遍历所有系统调用指定函数

#### EntityManager（实体管理器）
- 维护实体场景字典（从 `entity_scene_paths.json` 加载）
- 分配实体唯一 ID
- 维护**类型组**（enemies/friendlys/units/towers/modifiers/auras）
- 维护**组件组**（按组件类型索引实体）
- 实现**空间索引网格**（Space Index Grid，100px/格）优化索敌
- 提供丰富的索敌接口（按距离/血量/路程/赏金/随机等搜索模式）

#### PathwayManager（路径管理器）
- 管理所有路径（Pathway）、子路径（Subpathway）、路径节点（PathwayNode）
- 路径数据结构：Pathway → Subpathway[] → PathwayNode[]
- 支持 5 条子路径、256 个路径节点、20px 子路径间距
- 提供随机路径/子路径获取、路径比例计算等

#### TimeManager（时间管理器）
- 追踪 `tick_ts`（时间戳）和 `tick`（帧计数）
- 提供 `is_ready_time` 判断冷却/等待是否完成
- 提供 `y_wait` 协程等待函数（支持中断回调）

---

## 五、数据流与主循环

### 5.1 游戏主循环

```
每一帧（_physics_process）：
│
├─ 1. SystemManager 遍历所有 System 调用 _on_update(delta)
│   ├─ TimeSystem → 更新时间戳
│   ├─ EntitySystem → 更新实体生命周期
│   ├─ BehaviorSystem → 驱动行为树
│   ├─ BulletSystem → 子弹飞行
│   ├─ DamageSystem → 伤害结算
│   ├─ HealthSystem → 血量/死亡
│   ├─ TowerSystem → 塔升级/出售
│   ├─ AuraSystem → 光环效果
│   ├─ ModifierSystem → 状态效果
│   ├─ SpriteSystem → 动画更新
│   ├─ FXSystem → 特效管理
│   ├─ GroupingSystem → 分组维护
│   └─ LevelSystem → 等级逻辑
│
└─ 2. 帧末（call_deferred）
    ├─ _process_insert_queue → 插入新实体
    └─ _process_remove_queue → 移除实体
```

### 5.2 实体生命周期

```
创建（EntityManager.create_entity）
  │
  ├─ 分配 ID、设置名称
  │
  ├─ 插入队列（Entity.insert_entity）
  │   └─ SystemManager._process_insert_queue
  │       ├─ 添加到 entity_list
  │       ├─ 遍历所有 System._on_insert
  │       │   └─ 任一返回 false → 移除实体
  │       └─ 设置 visible = true
  │
  ├─ 每帧更新（System._on_update）
  │   ├─ 排除 DEATH/WAITING 实体
  │   ├─ 检查持续时间
  │   ├─ 处理来源追踪（track_source）
  │   ├─ 首次更新：播放生成动画/音效
  │   └─ 调用 Entity._on_update
  │
  └─ 移除（Entity.remove_entity）
      └─ SystemManager._process_remove_queue
          ├─ 遍历所有 System._on_remove
          │   └─ 任一返回 false → 保留实体
          └─ e.free()
```

### 5.3 伤害流程

```
1. 技能/子弹创建 Damage 对象
   → damage.insert_damage() → 加入 SystemMgr.damage_queue

2. DamageSystem._on_update 处理伤害队列：
   ├─ 验证目标/来源/血量组件
   ├─ 检查伤害免疫
   ├─ 计算实际伤害（护甲减伤）
   ├─ 处理反伤（spiked）
   ├─ 应用伤害（health_c.hp -= actual_damage）
   └─ 调用 Entity._on_damage 回调
       └─ hp ≤ 0 → 标记死亡（DeathData）
```

---

## 六、波次系统（Wave System）

### 6.1 数据结构（资源类）

```
WaveGroup（波次集合）
  └─ wave_list: Array[Wave]
       └─ Wave（波次）
            ├─ interval: float（波次间隔）
            └─ spawn_group_list: Array[WaveSpawnGroup]
                 └─ WaveSpawnGroup（生成批次）
                      ├─ pathway_idx: int（路径索引）
                      ├─ delay: float（批次延迟）
                      └─ spawn_list: Array[WaveSpawn]
                           └─ WaveSpawn（生成条目）
                                ├─ entity: String（敌人场景名）
                                ├─ count: int（数量）
                                ├─ interval: float（敌人间隔）
                                ├─ subpathway_idx: int（子路径）
                                ├─ reversed: bool（反方向）
                                └─ loop: bool（循环）
```

### 6.2 波次生成流程

```
WaveSpawner（波次生成器实体）
  │
  ├─ 播放波次前奏音效
  ├─ 等待 first_release_wave 信号
  │
  └─ 遍历 wave_list：
      ├─ 开始波次计时（WaveMgr.start_wave_timer）
      ├─ 可被 is_release_wave 跳过等待
      ├─ 播放波次音效
      │
      └─ 并发启动所有 WaveSpawnGroup（_spawn_group_spawner）
          └─ 对每个 WaveSpawn：
              ├─ 等待 delay
              ├─ 循环 count 次：
              │   ├─ EntityMgr.create_entity(entity)
              │   ├─ 设置 NavPathComponent（路径/子路径/起点）
              │   └─ 等待 interval
              └─ 等待 next_interval
      │
      └─ 所有批次完成后继续下一波
```

---

## 七、子弹与轨迹系统

### 7.1 子弹轨迹架构

```
BulletTrajectory（资源基类）
  ├─ _init_trajectory(bullet_c, entity, target)  — 初始化
  ├─ _update_trajectory(e, bullet_c, target, flying_time, delta) — 每帧更新
  ├─ _get_predict_time() — 预判时间
  ├─ _should_miss(bullet_c, flying_time) — 是否未命中
  └─ _has_arrived(e, bullet_c, flying_time) — 是否到达
```

### 7.2 轨迹类型

| 轨迹 | 类名 | 行为 |
|------|------|------|
| 直线 | `TrajectoryLinear` | 从 A 点直线飞向 B 点 |
| 抛物线 | `TrajectoryParabola` | 带重力加速度的弧线飞行 |
| 追踪 | `TrajectoryTracking` | 持续追踪目标实时更新方向 |
| 瞬移 | `TrajectoryInstant` | 瞬间到达目标位置 |

### 7.3 子弹生命周期（BulletSystem）

```
BulletSystem._on_update:
  ├─ 获取所有子弹实体（BulletComponent）
  │
  └─ 对每颗子弹：
      ├─ 目标无效？→ 损坏处理（_on_bullet_miss）
      ├─ 更新目标位置（如果可追踪）
      ├─ 调用轨迹 _update_trajectory
      ├─ 预制时间 > 0？→ 预制目标位置
      ├─ 检查 _should_miss？→ 未命中回调
      ├─ 检查 _has_arrived？→ 命中回调（_on_bullet_hit）
      │   └─ 创建 Damage，移除子弹实体
      └─ 继续飞行
```

---

## 八、防御塔系统

防御塔是游戏的核心交互对象，具有完整的升级链：

```
塔位（TowerHolder）
  │
  ├─ 建造：弓箭手塔 / 炮塔 / 兵营 / 法师塔
  │
  └─ 升级链（每级 3 个等级）：
      ├─ TowerArcher Lv1 → Lv2 → Lv3
      ├─ TowerArtillery Lv1 → Lv2 → Lv3
      ├─ TowerBarrack Lv1 → Lv2 → Lv3
      └─ TowerMage Lv1 → Lv2 → Lv3
```

**防御塔组件（`TowerComponent`）** 管理：
- `tower_type`：塔类型（BUILD 建造中 / TOWER_HOLDER 空塔位 / TOWER 已建成）
- `upgrade_to`：升级目标场景名（触发升级时创建新塔）
- `is_sell`：出售标记
- `total_price`：累计投入价格（用于出售计算）
- `tower_holder`：塔位外观样式

**兵营组件（`BarrackComponent`）** 额外管理：
- 士兵生成与统一管理（`soldier_group`）
- 集结点设置（`rally_center_position`）
- 士兵最大数量限制

---

## 九、常数与枚举体系

项目在 `classes/constants.gd`（类名 `C`）中定义了完整的枚举体系，采用**位运算枚举**支持组合：

| 枚举 | 用途 | 示例值 |
|------|------|--------|
| `DamageType` | 伤害类型 | PHYSICAL, MAGICAL, EXPLOSION, TRUE, DISINTEGRATE, POISON |
| `DamageFlag` | 伤害标识 | NOT_KILL, KILL_REMOVE, NO_DODGE, NO_SPIKED |
| `Flag` | 实体标识 | ENEMY, BOSS, FRIENDLY, HERO, TOWER, MODIFIER, AURA, FLYING |
| `ModType` | 状态效果类型 | POISON, LAVA, BLEED, FREEZE, STUN |
| `AuraType` | 光环类型 | BUFF, DEBUFF |
| `SearchMode` | 搜索模式 | 按距离/血量/路程/伤害/ID/赏金/随机 × 目标类型 |
| `State` | 实体状态 | IDLE, MELEE, RANGED, BLOCK, RALLY, DEATH 等 |
| `InfoBarType` | 信息栏类型 | NONE, UNIT, TOWER, TEXT |

---

## 十、UI 系统

### 10.1 主菜单

- 场景位置：`scenes/ui/main/`
- 包含：开始游戏、设置、退出按钮
- 每个按钮独立脚本（`play_button.gd` 等）

### 10.2 游戏内 UI

- 场景位置：`scenes/ui/game_ui/`
- **顶部栏**（`top_bar.tscn`）：显示波次、金币、生命等信息
- **底部栏**（`bottom_bar.tscn`）：防御塔建造/操作
- **玩家资源**（`player_resources.tscn`）：资源数值显示
- **实体信息栏**（`entity_info_bar.tscn`）：选中实体信息展示
- **技能面板**（`skills.tscn`）：英雄技能展示
- **倍速按钮**（`speed_button.tscn`）：游戏速度控制
- **选择菜单控制器**（`select_menu_controller/`）：防御塔升级/出售菜单
- **信息圈控制器**（`info_circle_controller/`）：实体状态信息圈

### 10.3 大地图

- 场景位置：`scenes/ui/map/`
- 用于关卡选择（待完善）

---

## 十一、工具脚本

| 工具 | 功能 |
|------|------|
| `tools/generate_texture.gd` | 根据精灵帧数据生成 AtlasTexture 和 SpriteFrames |
| `tools/update_audio_paths.gd` | 扫描 assets/audios 更新音频路径索引 JSON |
| `tools/update_entity_scene_paths.gd` | 扫描实体场景目录更新场景路径索引 JSON |
| `tools/wave_editor/wave_editor.tscn` | 可视化波次编辑器场景 |

---

## 十二、开发流程总结

### 创建新实体
1. 在 `scenes/entities/` 创建场景，根节点为 `Entity`
2. 挂载所需组件（如 `SkillComponent`、`NavPathComponent` 等）
3. 配置组件属性
4. 可选：扩展 Entity 脚本实现特殊回调
5. 运行 `update_entity_scene_paths` 更新索引

### 创建新组件
1. 在 `ecs/components/` 创建脚本，声明 `class_name`
2. 定义属性（为属性增加文档注释）
3. 在 `ecs/systems/` 创建对应的 System
4. 将系统节点添加到 `level_systems.tscn`

### 创建新行为
1. 在 `ecs/systems/behaviors/` 创建脚本，继承 `Behavior`
2. 实现 `_on_update` 等回调
3. 添加到 `behavior_system.gd` 的行为执行列表

---

## 十三、项目状态评估

### 已完成的功能
- ✅ ECS 核心架构（实体/组件/系统）
- ✅ 行为树 AI 系统
- ✅ 四种子弹轨迹（直线/抛物线/追踪/瞬移）
- ✅ 波次生成系统
- ✅ 路径导航系统
- ✅ 空间索引网格索敌
- ✅ 多类型伤害系统（含护甲/反伤/免疫）
- ✅ 状态效果与光环系统
- ✅ 防御塔建造/升级/出售
- ✅ 兵营系统（士兵生成/集结点）
- ✅ 四类防御塔各 3 级（弓箭手/炮塔/兵营/法师）
- ✅ 三种敌人（通用/哥布林/兽人）
- ✅ 音频管理（音乐/音效）
- ✅ 实体选择交互
- ✅ 编辑器工具链
- ✅ 国际化框架

### 待完善的功能
- ⬜ 闪避组件（`DodgeComponent`）
- ⬜ 升级组件
- ⬜ 网格管理器功能完善
- ⬜ 关卡管理器存档功能
- ⬜ 大地图关卡选择
- ⬜ 子弹伤害数据外部化

---

## 十四、技术债务与建议

1. **抽象层优化**：`Entity` 类目前直接包含较多逻辑，可考虑进一步拆分
2. **资源管理**：实体场景路径使用 JSON 文件索引，后续量大时可考虑自动注册机制
3. **性能优化**：空间索引网格已实现，但大量实体时的分组维护可进一步优化
4. **数据驱动**：技能/敌人属性可考虑采用数据表（如 CSV/JSON）驱动
5. **测试覆盖**：当前无单元测试框架，关键逻辑（伤害计算、索敌）建议添加测试
6. **类型安全**：已使用 `Array[Entity]`、`Array[System]` 等泛型类型，但部分旧代码仍需加强
