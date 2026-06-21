# 项目架构
该文档用于说明项目的架构与目录结构，以便组织代码。

## 目录结构
注：目录按照相关性组织，而非按文件类型分类。

```
Zero-Based-Isekai-Tower-Defense/
├── py_tools/                                 # Python 工具目录
│   ├── bin/                                  # 二进制工具目录
│   ├── input/                                # 输入资源目录
│   ├── lib/                                  # Python 库代码目录
│   ├── output/                               # 输出目录
│   └── generate_atlas.py                     # 图集生成脚本
├── src/                                      # 游戏源代码目录
│   ├── .godot/                               # Godot 编辑器配置目录（自动生成）
│   ├── .godot-devtool/                       # godot-devtool 插件配置目录
│   ├── .vscode/                              # VS Code 配置目录
│   ├── addons/                               # 插件目录
│   │   ├── godot_devtool/                    # 开发工具插件目录
│   │   └── mask_check/                       # 掩码勾选框插件目录
│   ├── assets/                               # 资源文件目录
│   │   ├── atlas/                            # 图集目录
│   │   │   ├── animated_atlas/               # 动画图集目录
│   │   │   ├── atlas_texture/                # 图集纹理资源目录
│   │   │   ├── image_atlas/                  # 图像图集目录
│   │   │   └── sprite_frames/                # 精灵帧资源目录
│   │   ├── audios/                           # 音频目录
│   │   ├── dpi_textures/                     # DPI 图像纹理资源目录
│   │   ├── fonts/                            # 字体目录
│   │   ├── lang/                             # 语言目录
│   │   └── shaders/                          # 着色器目录
│   ├── autoloads/                            # 自动加载目录
│   │   └── managers/                         # 管理器目录
│   │       ├── audio_manager.gd              # 音频管理器
│   │       ├── canvas_manager.gd             # 画布管理器
│   │       ├── entity_manager.gd             # 实体管理器
│   │       ├── game_manager.gd               # 游戏管理器
│   │       ├── global_manager.gd             # 全局管理器
│   │       ├── grid_manager.gd               # 网格管理器
│   │       ├── input_manager.gd              # 输入管理器
│   │       ├── level_manager.gd              # 关卡管理器
│   │       ├── pathway_manager.gd            # 路径管理器
│   │       ├── search_manager.gd             # 搜索管理器
│   │       ├── select_manager.gd             # 选择管理器
│   │       ├── setting_manager.gd            # 设置管理器
│   │       ├── system_manager.gd             # 系统管理器
│   │       ├── time_manager.gd               # 时间管理器
│   │       └── wave_manager.gd               # 波次管理器
│   ├── classes/                              # 类目录
│   │   ├── behaviors/                        # 行为类目录
│   │   │   ├── barrack_behavior.gd           # 兵营行为
│   │   │   ├── behavior.gd                   # 行为基类
│   │   │   ├── dodge_behavior.gd             # 闪避行为
│   │   │   ├── melee_behavior.gd             # 近战行为
│   │   │   ├── nav_path_behavior.gd          # 导航路径行为
│   │   │   ├── rally_behavior.gd             # 集结行为
│   │   │   ├── skill_behavior.gd             # 技能行为
│   │   │   └── spawner_behavior.gd           # 生成器行为
│   │   ├── bullet_trajectories/              # 子弹轨迹类目录
│   │   │   ├── bullet_trajectory.gd          # 子弹轨迹基类
│   │   │   ├── instant_bullet_trajectory.gd  # 瞬移轨迹
│   │   │   ├── linear_bullet_trajectory.gd   # 直线轨迹
│   │   │   ├── parabola_bullet_trajectory.gd # 抛物线轨迹
│   │   │   └── track_bullet_trajectory.gd    # 追踪轨迹
│   │   ├── components/                       # 组件类目录
│   │   │   ├── aura_component.gd             # 光环组件
│   │   │   ├── barrack_component.gd          # 兵营组件
│   │   │   ├── bullet_component.gd           # 子弹组件
│   │   │   ├── component.gd                  # 组件基类
│   │   │   ├── dodge_component.gd            # 闪避组件
│   │   │   ├── experience_component.gd       # 经验组件
│   │   │   ├── fx_component.gd               # 特效组件
│   │   │   ├── health_component.gd           # 生命组件
│   │   │   ├── melee_component.gd            # 近战组件
│   │   │   ├── modifier_component.gd         # 修饰器组件
│   │   │   ├── nav_path_component.gd         # 导航路径组件
│   │   │   ├── rally_component.gd            # 集结组件
│   │   │   ├── skill_component.gd            # 技能组件
│   │   │   ├── spawner_component.gd          # 生成器组件
│   │   │   ├── sprite_component.gd           # 精灵组件
│   │   │   ├── tower_component.gd            # 防御塔组件
│   │   │   └── ui_component.gd               # UI组件
│   │   ├── influences/                       # 影响资源类目录
│   │   │   ├── damage_influence.gd           # 伤害影响资源
│   │   │   ├── heal_influence.gd             # 治疗影响资源
│   │   │   └── influence.gd                  # 影响资源基类
│   │   ├── skills/                           # 技能类目录
│   │   │   ├── skill.gd                      # 技能基类
│   │   │   ├── area_skill.gd                 # 范围技能
│   │   │   ├── melee_skill.gd                # 近战技能
│   │   │   ├── ranged_skill.gd               # 远程技能
│   │   │   ├── multiple_ranged_skill.gd      # 多次远程技能
│   │   │   └── spawn_skill.gd                # 生成技能
│   │   ├── static_classes/                   # 静态类目录（常量、工具函数）
│   │   │   ├── constants.gd                  # 常量定义
│   │   │   ├── log.gd                        # 日志工具
│   │   │   └── utils.gd                      # 工具函数
│   │   ├── systems/                          # 系统类目录
│   │   │   ├── aura_system.gd                # 光环系统
│   │   │   ├── behavior_system.gd            # 行为系统
│   │   │   ├── bullet_system.gd              # 子弹系统
│   │   │   ├── damage_system.gd              # 伤害系统
│   │   │   ├── entity_system.gd              # 实体系统
│   │   │   ├── fx_system.gd                  # 特效系统
│   │   │   ├── grouping_system.gd            # 分组系统
│   │   │   ├── health_system.gd              # 血量系统
│   │   │   ├── level_system.gd               # 等级系统
│   │   │   ├── modifier_system.gd            # 修饰器系统
│   │   │   ├── sprite_system.gd              # 精灵系统
│   │   │   ├── system.gd                     # 系统基类
│   │   │   ├── time_system.gd                # 时间系统
│   │   │   └── tower_system.gd               # 防御塔系统
│   │   ├── animation_data.gd                 # 动画数据
│   │   ├── animation_group.gd                # 动画组
│   │   ├── audio_group.gd                    # 音频组
│   │   ├── damage.gd                         # 伤害数据
│   │   ├── damage_number.gd                  # 伤害数字
│   │   ├── entity.gd                         # 实体基类
│   │   ├── camera.gd                         # 相机类
│   │   ├── entity_group.gd                   # 实体组
│   │   ├── entity_group_2d.gd                # 2D实体组
│   │   ├── interact_policy.gd                # 交互策略
│   │   ├── offset_group.gd                   # 偏移组
│   │   ├── property_modifier.gd              # 属性修饰器
│   │   ├── same_process_resource.gd          # 同进程资源
│   │   ├── searcher.gd                         # 搜索资源
│   │   ├── sprite_group.gd                   # 精灵组
│   │   └── sync_animations_data.gd           # 同步动画数据
│   ├── controls/                             # 控件目录
│   │   ├── track_editor/                     # 轨道编辑器控件
│   │   │   ├── left_track_tool_bar/          # 左侧工具栏
│   │   │   ├── mouse_tool_bar/               # 鼠标工具栏
│   │   │   ├── right_track_tool_bar/         # 右侧工具栏
│   │   │   ├── add_track_button.gd           # 添加轨道按钮
│   │   │   ├── h_scroll_bar.gd               # 水平滚动条
│   │   │   ├── remove_track_button.gd        # 移除轨道按钮
│   │   │   ├── ruler_panel_container.gd      # 标尺面板容器
│   │   │   ├── tick.gd                       # 刻度
│   │   │   ├── track.gd                      # 轨道
│   │   │   ├── track_editor.gd               # 轨道编辑器
│   │   │   ├── track_item.gd                 # 轨道项
│   │   │   └── v_scroll_bar.gd               # 垂直滚动条
│   │   ├── adaptive_scroll_container.gd      # 自适应滚动容器
│   │   ├── option_button_label.gd            # 选项按钮标签
│   │   ├── spin_box_button.gd                # 数值框按钮
│   │   └── spin_box_label.gd                 # 数值框标签
│   ├── entities/                             # 实体目录
│   │   ├── enemies/                          # 敌人目录
│   │   └── towers/                           # 防御塔目录
│   ├── game/                                 # 游戏目录
│   │   ├── game_ui/                          # 游戏界面
│   │   ├── levels/                           # 关卡目录
│   │   │   └── level.gd                      # 关卡基类
│   │   ├── debug_menu/                       # 调试菜单
│   │   ├── range_info/                       # 范围信息
│   │   ├── select_menu/                      # 选择菜单
│   │   ├── wave_flag/                        # 波次旗帜
│   │   ├── wave/                             # 波次相关类目录
│   │   │   ├── sub_wave.gd                   # 子波次类
│   │   │   ├── wave.gd                       # 波次类
│   │   │   ├── wave_group.gd                 # 波次组类
│   │   │   └── wave_spawn.gd                 # 波次生成类
│   │   ├── pathway/                          # 路径目录
│   │   │   ├── pathway.gd                    # 路径
│   │   │   ├── pathway_container.gd          # 路径容器
│   │   │   ├── pathway_node.gd               # 路径节点
│   │   │   └── subpathway.gd                 # 子路径
│   │   ├── gird.gd                           # 网格
│   │   ├── system_container.gd               # 系统容器
│   │   ├── system_container.tscn             # 系统容器场景
│   │   └── world.gd                          # 世界类
│   ├── docs/                                 # 文档目录
│   │   ├── CODE_SPEC.md                      # 代码规范文档
│   │   ├── COMMITS_SPEC.md                   # 提交规范文档
│   │   ├── GIT_USAGE.md                      # Git 使用说明文档
│   │   ├── PROCESS.md                        # 项目流程文档
│   │   └── PROJECT_STRUCTURE.md              # 项目架构文档
│   ├── main/                                 # 主界面
│   │   └── wave_editor/                      # 波次编辑器
│   │       ├── load_button.gd                # 加载按钮
│   │       ├── load_file_dialog.gd           # 加载文件对话框
│   │       ├── mouse_tool_bar.gd             # 鼠标工具栏
│   │       ├── save_button.gd                # 保存按钮
│   │       ├── save_file_dialog.gd           # 保存文件对话框
│   │       ├── spawn_data_v_box_container.gd # 生成数据容器
│   │       ├── spawn_track_editor.gd         # 生成轨道编辑器
│   │       ├── sub_wave_track_editor.gd      # 子波次轨道编辑器
│   │       ├── wave_editor.gd                # 波次编辑器主脚本
│   │       └── wave_track_editor.gd          # 波次轨道编辑器
│   ├── map/                                  # 地图界面
│   ├── tools/                                # 构建/辅助工具脚本目录
│   │   └── sprite_frames_datas/              # 精灵帧数据目录
│   └── theme.tres                            # 主题资源
├── .gitattributes                            # Git 属性配置
├── .gitignore                                # Git 忽略配置
├── LICENSE                                   # 许可证文件
├── README.md                                 # 项目说明文档
└── export_presets.cfg                        # 导出预设配置
```

## 架构
项目使用 ECS（实体-组件-系统）架构，将数据与逻辑分离到组件与系统中：
- **实体（Entity）**: 游戏对象的抽象表示，通过 `entity.gd` 定义。
- **组件（Component）**: 数据容器，存储实体的属性（如位置、血量、技能等）。
- **系统（System）**: 处理逻辑，遍历实体并对具有特定组件的实体执行操作。

## 代码层级
```
核心层（core）- 基础类型、常量、工具函数。
    ↓
管理器层（managers）- 全局管理类，协调各系统。
    ↓
实体层（entities）- 实体定义。
    ↓
组件层（components）- 数据定义，无业务逻辑。
    ↓
系统层（systems）- 业务逻辑处理。
```

## 实体生命周期
1. **创建实体**: 遍历并调用所有系统的 `_on_insert` 回调。
2. **更新实体**: 每帧遍历并调用所有系统的 `_on_update` 回调。
3. **移除实体**: 遍历并调用所有系统的 `_on_remove` 回调。

## 关键目录说明
| 目录 | 说明 |
|------|------|
| `autoloads/managers/` | 全局管理器，通过 Godot 自动加载机制在游戏启动时初始化 |
| `classes/components/` | ECS 组件定义，仅包含数据，不包含逻辑 |
| `classes/systems/` | ECS 系统定义，包含游戏逻辑，通过系统管理器调度 |
| `classes/behaviors/` | 行为模式定义，控制实体的动作行为 |
| `classes/skills/` | 技能系统，定义各种技能的效果和释放逻辑 |
| `assets/` | 游戏资源文件，包括音频、图集等 |
| `tools/` | 开发工具脚本，用于资源生成和维护 |
| `py_tools/` | Python 辅助工具，用于图集生成等预处理任务 |