# 代码规范

该文档用于说明与规范代码的编写。

---

## 1. 编写风格

本项目遵循官方的 GDScript 编写风格指南：
> [GDScript 编写风格指南](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html)

### 1.1 文档注释编写风格

Godot 文档注释使用 BBCode 语法编写，具体语法参考：
> [GDScript 文档注释](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_documentation_comments.html)

1. **引用任何代码必须使用链接语法**
    - 引用任何类、方法、属性、信号时都必须使用链接语法，不能直接写在文档注释中。
2. **所有代码必须使用代码块包裹**
    - 所有代码都必须使用 [code] 内联代码块或 [codeblock] 多行代码块包裹，不能直接写在文档注释中。

示例：
```gdscript
## 向量加法，将两个 [Vector2] 相加。[br][br]
## [b]提示[/b]: 这是一个用于演示的方法，实际使用时请使用运算符 [operator Vector2.operator +]。[br][br]
## 使用示例：
## [codeblock]
## var v1 = Vector2(1, 2)
## var v2 = Vector2(3, 4)
## print(vector_add(v1, v2))     # Vector2(4, 6)
## [/codeblock]
func vector_add(a: Vector2, b: Vector2) -> Vector2:
    return a + b

## 伤害信号，用于通知实体被伤害。
signal damage_taken(value: float)

## 对一个 [Entity] 实体造成伤害，并发射伤害信号 [signal damage_taken]。
func take_damage(entity: Entity, value: float) -> void:
    entity.health -= value
    damage_taken.emit(value)
```

---

### 1.2 方法文档注释编写风格
方法的文档注释编写风格如下（* 表示可选项）：

```gdscript
## 方法描述[br][br]
## *[param 参数名]: 参数描述[br][br]
## *-> 返回值描述[br][br]
## *[b]提示[/b]: 提示信息
func 方法名(参数名: 参数类型) -> 返回值类型: pass
```

1. **方法描述**：方法的功能描述，用于解释方法的作用。
2. ***参数信息**：方法的参数信息，用于说明方法的参数，每个参数用换行隔开。如果参数名已经语义清晰可以省略参数描述。
3. ***返回值描述**：方法的返回值描述，用于说明方法的输出。如果返回值类型已经语义清晰可以省略返回值描述。
4. ***提示信息**：方法的提示信息，用于说明方法的使用注意事项。提示之前必须有空行隔开。

示例：
```gdscript
## 绘制椭圆。[br][br]
## [param position]: 局部空间位置。[br]
## [param width]: 轮廓宽度。只在 [param filled] 为 [code]false[/code] 时生效。[br]
## -> 错误信息，成功返回 [code]"ok"[/code]，失败返回错误信息字符串。[br][br]
## [b]提示[/b]: 这是一个用于演示的方法，实际绘制椭圆请使用 [method CanvasItem.draw_ellipse]。
func draw_ellipse(
        position: Vector2, 
        major: float, 
        minor: float, 
        color: Color, 
        filled: bool = true, 
        width: float = -1.0
    ) -> String:
        ...
```

---

## 2. 节点通信规范

### 2.1 核心规则

1. **命令用方法，通知用信号**
    | 场景 | 使用方式 | 示例 |
    |------|----------|------|
    | A 想让 B 做一个动作 | 调用方法 | `player.take_damage(50)` |
    | B 的状态改变了，通知关心者 | 发射信号 | `health_changed.emit(new_hp)` |

2. **信号的拥有者必须是信号的发射者**
    - 外部发射别人的信号，如： `player.damage_taken.emit(50)` → 应改为 `player.take_damage(50)`

3. **禁止直接通过节点路径访问兄弟节点**
    - 直接访问兄弟节点，如： `$"../UI/HealthBar".value = hp` → 应改为发射信号，让 UI 自行连接并响应

---

### 2.2 通信方式选择

按优先级从高到低：

1. **编辑器装配（推荐）**
   - 通过 `@export` 声明依赖，在编辑器中拖拽连接。脚本解耦，零硬编码路径。

2. **父节点协调**
   - 父节点在 `_ready()` 中连接子节点信号。逻辑集中，但父节点不宜过重。

3. **全局事件总线**
   - 仅用于跨场景的全局事件（如玩家死亡、任务完成）。禁止局部 UI 交互走全局单例。

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