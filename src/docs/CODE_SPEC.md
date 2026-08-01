# 代码规范

该文档用于说明与规范代码的编写。

---

## 1. 编写风格

本项目遵循官方的 GDScript 编写风格指南：
> [GDScript 编写风格指南](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

## 2. 节点通信规范

### 2.1 核心规则

1. 命令用方法，通知用信号
    | 场景 | 使用方式 | 示例 |
    |------|----------|------|
    | A 想让 B 做一个动作 | 调用方法 | `player.take_damage(50)` |
    | B 的状态改变了，通知关心者 | 发射信号 | `health_changed.emit(new_hp)` |

2. 信号的拥有者必须是信号的发射者
    - 外部发射别人的信号，如： `player.damage_taken.emit(50)` → 应改为 `player.take_damage(50)`

3. 禁止直接通过硬编码路径访问兄弟节点并修改其属性
    - 直接访问兄弟节点，如： `$"../UI/HealthBar".value = hp` → 应改为发射信号，让 UI 自行连接并响应

---

### 2.2 通信方式选择

按优先级从高到低：

1. **编辑器装配（推荐）**
   通过 `@export` 声明依赖，在编辑器中拖拽连接。脚本解耦，零硬编码路径。

2. **父节点协调**
   父节点在 `_ready()` 中连接子节点信号。逻辑集中，但父节点不宜过重。

3. **全局事件总线**
   仅用于跨场景的全局事件（如玩家死亡、任务完成）。禁止局部 UI 交互走全局单例。

---

### 1.3 标准模板

#### 被调用方（提供 API）

```gdscript
# player.gd
class_name Player
extends CharacterBody2D

signal health_changed(new_hp: int)
signal died

var hp: int = 100

func take_damage(amount: int) -> void:
    hp -= amount
    health_changed.emit(hp)
    
    if hp <= 0:
        died.emit()
```

#### 调用方（发起命令）

```gdscript
# enemy.gd

@export var target: Player     # 编辑器拖入

func attack() -> void:
    target.take_damage(50)     # 调用方法，不是发射信号
```

#### 观察方（响应信号）

```gdscript
# health_bar.gd

@export var player: Player     # 编辑器拖入

func _ready() -> void:
    player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_hp: int) -> void:
    value = new_hp
```

---

### 2.3 禁止事项

| 禁止写法 | 原因 | 正确替代 |
|----------|------|----------|
| `$"../UI/Bar".value = x` | 依赖节点路径，脆且耦合 | 发射信号，Bar 自行连接 |
| `other_node.signal.emit()` | 外部发射他人信号 | 调用对方的公共方法 |
| `signal.emit()` 用作命令 | 信号语义是通知，不是请求 | 提供方法让外界调用 |
| `get_node("../../X").method()` | 硬编码路径 | `@export var x: Node` |
| 局部 UI 交互走全局单例 | 全局污染，调试困难 | 编辑器装配或父节点协调 |