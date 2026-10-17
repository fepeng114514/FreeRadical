# 代码规范

该文档用于说明与规范代码的编写。

***

## 1. 代码编写风格

本项目遵循官方的 GDScript 代码编写风格：

> [GDScript 编写风格指南](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html)

### 1.1 布尔值变量命名规范

布尔值变量命名时需要增加前缀，以表示其语义：

| 前缀/后缀          | 语义        | 适用场景    | 示例                                    |
| :------------- | :-------- | :------ | :------------------------------------ |
| **`is_`**      | "是否是..."  | 状态/属性判断 | `is_enabled`, `is_visible`, `is_dead` |
| **`has_`**     | "是否有..."  | 拥有/包含关系 | `has_target`, `has_ammo`              |
| **`can_`**     | "能否..."   | 能力/权限   | `can_attack`, `can_jump`              |
| **`need_`**     | "需要..."   | 需求/依赖    | `need_ammo`, `need_target`  |
| **`should_`**  | "是否应该..." | 建议/决策   | `should_update`, `should_flee`        |
| **`_enabled`** | "启用状态"    | 功能开关    | `attack_enabled`                      |

### 1.2 显式声明变量类型

在定义变量时禁止使用默认变体类型，应显式声明变量类型。

示例：

```gdscript
var entities: Array[Entity] = []
for entity: Entity in entities:
    entity.health -= 10
```

---

## 2. 文档注释编写规范

Godot 文档注释使用 BBCode 语法编写，具体语法参考：

> [GDScript 文档注释](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_documentation_comments.html)

### 2.1 引用任何代码必须使用链接语法

引用任何类、方法、属性、信号时都必须使用链接语法，不能直接写在文档注释中。

示例：

```gdscript
## 绘制椭圆。[br][br]
## [b]提示[/b]: 这是一个用于演示的方法，实际绘制椭圆请使用 [method CanvasItem.draw_ellipse]。
func draw_ellipse(position: Vector2, width: float, filled: bool = true) -> void:
    pass
```

### 2.2 所有代码必须使用代码块包裹

所有代码都必须使用 \[code] 内联代码块或 \[codeblock] 多行代码块包裹，不能直接写在文档注释中。

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
```

### 2.3 方法文档注释编写规范

方法的文档注释编写风格如下（\* 表示可选项）：

```gdscript
## 方法描述[br][br]
## *[param 参数名]: 参数描述[br][br]
## *-> 返回值描述[br][br]
## *[b]提示[/b]: 提示信息
func 方法名(参数名: 参数类型) -> 返回值类型: pass
```

1. **方法描述**：方法的功能描述，用于解释方法的作用。
2. \***参数信息**：方法的参数信息，用于说明方法的参数，每个参数用换行隔开。如果参数名已经语义清晰可以省略参数描述。
3. \***返回值描述**：方法的返回值描述，用于说明方法的输出。如果返回值类型已经语义清晰可以省略返回值描述。
4. \***提示信息**：方法的提示信息，用于说明方法的使用注意事项。提示之前必须有空行隔开。

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

