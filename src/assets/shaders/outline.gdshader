shader_type canvas_item;

// 可调节参数：描边厚度和颜色
uniform float line_thickness : hint_range(0, 20) = 1.0;
uniform vec4 outline_color : source_color = vec4(1.0);

void fragment() {
	// 1. 获取当前像素原本的颜色
	vec4 original_color = texture(TEXTURE, UV);
	
	// 2. 计算在 UV 空间中偏移多少个单位，才能达到指定的像素厚度
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;

	// 3. 检测边缘：采样当前像素周围 8 个方向的透明度 (Alpha)
	// 如果周围有非透明像素，说明当前像素位于边缘外侧
	float outline = 0.0;
	outline += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;   // 左
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;   // 右
	outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;   // 上
	outline += texture(TEXTURE, UV + vec2(0.0,  size.y)).a;   // 下
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;   // 左上
	outline += texture(TEXTURE, UV + vec2(-size.x,  size.y)).a;   // 左下
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;   // 右上
	outline += texture(TEXTURE, UV + vec2(size.x,  size.y)).a;   // 右下
	
	// 把结果限制在 0 到 1 之间
	outline = min(outline, 1.0);

	// 4. 混合颜色
	// 关键逻辑：如果当前像素是透明 (original_color.a = 0) 但周围有非透明像素 (outline > 0)，
	// 则用描边颜色；否则显示原本的颜色。
	COLOR = mix(original_color, outline_color, outline - original_color.a);
}