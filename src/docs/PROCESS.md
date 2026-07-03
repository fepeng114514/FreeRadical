# 流程
此文档用于规范项目开发流程，包括创建实体、组件、系统等。

## 创建实体流程
1. 首先在 `src/scenes/entities` 目录创建一个场景，场景根节点为 `Entity` 实体节点。
2. 为场景挂载各种组件：
   - 如：`SkillComponent` 远程攻击组件，可以使实体向其他实体发射子弹。
   - 一些组件可能有子组件：如 `SkillComponent` 有 `RangedSkill` 单次远程攻击子组件。
3. 修改组件的属性为想要的属性：
   - 如：`RangedSkill` 的攻击范围、攻击速度等。
4. 可以扩展 `Entity` 的脚本来在一些回调中进行一些操作：
   - 如：`_on_update` 回调，每帧会被调用。
5. 最后运行 `tools/update_entity_scene_paths` 更新场景字典 `scenes/entities/entity_scene_paths.json`。

> **注意**：为了可复用性不应该依赖扩展脚本来为实体增加逻辑，而是将逻辑抽象为组件的属性，除非该逻辑不会被复用或过于特例化。

## 创建组件流程
1. 首先在 `src/classes/components` 中创建一个 `.gd` 脚本：
   - 命名格式为 `组件名_component`，如：`health_component`。
2. 使用 `class_name` 声明组件类名：
   - 命名格式为 `组件名Component`，如：`HealthComponent`。
3. 为组件声明属性：
   - 如：`max_hp` 最大血量、`hp` 当前血量。
   - 请为属性增加文档注释以便在编辑器查看。
4. 在 `src/classes/systems` 中创建一个 `.gd` 脚本并继承 `System` 类：
   - 命名格式为 `系统名System`，如：`HealthSystem`。
5. 使用 `class_name` 声明系统类名：
   - 命名格式为 `系统名System`，如：`HealthSystem`。
6. 通过一些回调函数对拥有特定组件的实体进行操作：
   - 如：`_on_insert` 回调，会在实体被插入时调用。
7. 最后将此系统节点增加到需要的场景的 `SystemController` 节点。

## 导入图集流程
1. 首先将图像文件放到 `py_tools/generate_atlas/input/图集名称/图像类型` 中。
   - 图像类型为 `atlas_texture` 或 `sprite_frames`。
2. 使用 `py_tools/generate_atlas` 脚本生成图集：
   - 输出格式为 dds bc7。
3. 将图集放入 `src/assets/atlas` 中。
4. 在 `src/tools/generate_texture/sprite_frames_datas/动画类型.json` 中输入动画数据。
   - 动画数据格式见下方。
5. 最后在编辑器运行 `src/tools/generate_texture/generate_texture.gd` 脚本生成 SpriteFrames 与 AtlasTexture。

### 动画文件格式
```json
"动画资源名": {           # 生成的 SpriteFrames 资源名
   "layer_count": 0,    # 多层动画层数，默认为 0，会创建 n 个 SpriteFrames
   "animations": {      # 动画列表
	  "动画名": {        # SpriteFrames 中的动画名
		 "from": 1,     # 起始帧索引
		 "to": 10,	   # 结束帧索引
		 "fps": 30,	   # 帧率，默认为 30
		 "loop": true   # 是否循环，默认为 true
	  }
   }
}
```

- 动画名应由方向和动作两部分组成，使用下划线分隔，格式为 "动作_方向"。
- 无方向的动画可以省略方向部分。
- 方向部分可以是 `AnimationGroup` 资源属性: `"up"`、`"down"`、`"left_right"` 等。
- 动作部分可以是任意描述动画的字符串，如 `"idle"`、`"walk"`、`"melee"`、`"death"` 等。

#### 示例
- `"idle_up"` 表示向上的待机动画。
- `"walk_left_right"` 表示左右的行走动画。
- `"melee"` 表示无方向的近战技能动画。

## 创建关卡流程

### 第一步：创建关卡
1. 首先在 `src/game/levels` 目录创建一个继承自 `src/game/levels/level.tscn` 场景。
2. 在 `Background` 节点中添加背景图片。
3. 在 `Gird` 节点中绘制地形网格。
4. 在 `PathwayContainer` 节点中添加 `Pathway` 路径节点。
   - 子路径会自动根据 `Pathway` 生成。
5. 在 `WaveFlagContainer` 节点中添加 `WaveFlag` 波次旗帜节点。
   - 每个 `WaveFlag` 需要绑定一个 `Pathway` 路径节点，来显示波次到来时间与释放波次。
   - 为了便于管理，请让每个波次旗帜与 `Pathway` 路径节点一一对应，例如：波次旗帜 1 对应路径节点 1，波次旗帜 2 对应路径节点 2，以此类推。
6. 在 `World` 节点中添加 `WaveSpawner` 波次生成器节点。
   - 为 `WaveSpawner` 波次生成器节点添加 `wave_group` 波次组资源，并保存在 `src/game/levels/波次组资源名.tscn` 中，用于波次编辑器加载。
   - 波次组资源名格式为 `level_关卡索引_wave`，例如：第一关的波次组资源名为 `level_1_wave`。
7. 最后在 `World` 节点中添加塔位等实体。
   - 塔位需要设置 `default_rally_center_local_pos`  默认集结点。

### 第二步：添加入口
1. 在 `src/map/map.tscn` 的 `FlagController` 节点中添加 `Flag` 关卡旗帜节点。
   - 旗帜节点需要指定 `level_scene_path` 关卡场景路径，来进入该关卡。

### 第三步：编辑出怪
1. 首先在主页的左上角点击 `波次编辑器` 按钮。
2. 在波次编辑器中编辑出怪。
3. 最后保存波次。
