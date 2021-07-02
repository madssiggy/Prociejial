float random2(in float2 vec) {
	return frac(sin(dot(vec.xy, float2(12.998, 78.223)))*4378.545);
	//fracは少数をなくせる
}//	2D疑似乱数

float2 random22(in float2 vec) {
	vec = float2(dot(vec, float2(127.1, 311.7)), dot(vec, float2(269.5, 183.3)));
	//vec = frac(vec,*372.12);
	return frac(sin(vec)*(4378.545));
}

float voronoi2(in float2 vec) {
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);
	float2 position = (0, 0);
	float value = 1.0;
	for (int y = -1;y <= 1;y++)
	{
		for (int x = -1;x <= 1;x++)
		{
			float2 offset = float2(x, y);

			position = random22(ivec + offset);

			float dist = distance(position + offset, fvec);

			value = min(value, dist);
		}

	}
	return value;
}

float valueNoise2(in float2 vec) {
	//整数部小数部の分離
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);
	//四角の格子と捉えると、a=左上、b=右上,c=左下、d=右下
	float a = random2(ivec + float2(0.0, 0.0));
	float b = random2(ivec + float2(1.0, 0.0));
	float c = random2(ivec + float2(0.0, 1.0));
	float d = random2(ivec + float2(1.0, 1.0));
	//エルミート補間。
	fvec = smoothstep(0.0, 1.25, fvec);
	//lerpは線形補間の関数。xの割合に基づいてa,b||c,dの線形補間を行っている。
	return lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);
	//a,bの補間とcdの補間同士を補間。

}

float perlinNoise2(in float2 vec) {
	//整数部小数部の分離
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);
	//四角の格子と捉えると、a=左上、b=右上,c=左下、d=右下
	float a = dot(random22(ivec + float2(0.0, 0.0))*2.0 - 1.0, fvec - float2(0.0, 0.0));
	float b = dot(random22(ivec + float2(1.0, 0.0))*2.0 - 1.0, fvec - float2(1.0, 0.0));
	float c = dot(random22(ivec + float2(0.0, 1.0))*2.0 - 1.0, fvec - float2(0.0, 1.0));
	float d = dot(random22(ivec + float2(1.0, 1.0))*2.0 - 1.0, fvec - float2(1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);
	return lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);


}
float FractalNoise(in float2 vec) {
	float2 ivec = floor(vec);//整数部
	float2 fvec = frac(vec);//小数部
	float a = dot(random22(ivec + float2(0.0, 0.0))*2.0 - 1.0, fvec - float2(0.0, 0.0));
	float b = dot(random22(ivec + float2(1.0, 0.0))*2.0 - 1.0, fvec - float2(1.0, 0.0));
	float c = dot(random22(ivec + float2(0.0, 1.0))*2.0 - 1.0, fvec - float2(0.0, 1.0));
	float d = dot(random22(ivec + float2(1.0, 1.0))*2.0 - 1.0, fvec - float2(1.0, 1.0));

	for (float i = 2.0;i < 4.0;i += 1.0) {
		//整数部小数部の分離

		//四角の格子と捉えると、a=左上、b=右上,c=左下、d=右下
		a += dot(random22(ivec + float2(0.0, 0.0))*2.0*i - 1.0, fvec - float2(0.0, 0.0));
		b += dot(random22(ivec + float2(1.0, 0.0))*2.0*i - 1.0, fvec - float2(1.0, 0.0));
		c += dot(random22(ivec + float2(0.0, 1.0))*2.0*i - 1.0, fvec - float2(0.0, 1.0));
		d += dot(random22(ivec + float2(1.0, 1.0))*2.0*i - 1.0, fvec - float2(1.0, 1.0));

		fvec = smoothstep(0.0, 1.0, fvec);
	}
	return lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);

}
float voronoi(in float2 vec) {

}

float fbm22(in float2 vec, int octave) {
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0;i < octave;i++) {
		value += amplitude * abs(perlinNoise2(vec));
		vec *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}//
float fbm2(in float2 vec, int octave, float offset = 0.0) {
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0;i < octave;i++) {
		value += amplitude * perlinNoise2(vec+offset);//floatのみをfloat2が入るところに代入するとその数値をxyとしたfloat2に変換されて加算される。
		vec *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}//非整数ブラウン運動。フラクタルパーリンノイズ

float dispMap(in float2 inTexCoord) {
	//float minHeight = -5.0;
	//if (inTexCoord.x <= 5.0 || inTexCoord.x >= 45.0||
	//	inTexCoord.y <= 5.0|| inTexCoord.y >= 45.0) {
	//	return minHeight;
	//}
	//else if (inTexCoord.x <= 7.0 || inTexCoord.x >= 38.0 ||
	//	inTexCoord.y <= 7.0 || inTexCoord.y >= 38.0) {
	//	return fbm2(inTexCoord*0.05, 10)*10.0+minHeight;
	//}
	//else if (inTexCoord.x <= 10.0 || inTexCoord.x >= 40.0 ||
	//	inTexCoord.y <= 10.0 || inTexCoord.y >= 40.0) {
	//	return fbm2(inTexCoord*0.05, 10)*10.0;
	//}
	return fbm2(inTexCoord*0.05, 10)*10.0;
 }
 /*フラクタルブラウンモーション
非整数ブラウン運動
フラクタルノイズ
オクターブノイズ
*/
float gammacorrect(float gamma, float x) {
	return pow(x, 1.0 / gamma);
}

float bias(float b, float x) {
	return pow(x, log(b) / log(0.5));
}
float gain(float g, float x) {
	if (x < 0.5) {
		return bias(1.0 - g, 2.0*x) / 2.0;
	}
	else {
		return 1.0 - bias(1.0 - g, 2.0 - 2.0*x) / 2.0;
	}
}
float random3(in float3 vec) {
	return frac(sin(dot(vec.xyz, float3(12.9898, 78.233, 47.2311)))*4358.54);

}
//3Dホワイトノイズ
float3 random33(in float3 vec) {
	vec = float3(dot(vec, float3(127.1, 311.7, 245.4)),
		dot(vec, float3(269.5, 183.3, 131.2)),
		dot(vec, float3(522.3, 243.1, 532.4)));
	return frac(sin(vec)*4358.54);
}

float valueNoise3(in float3 vec) {
	float3 ivec = floor(vec);
	float3 fvec = frac(vec);

	float a = random3(ivec + float3(0.0, 0.0, 0.0));
	float b = random3(ivec + float3(1.0, 0.0, 0.0));
	float c = random3(ivec + float3(0.0, 1.0, 0.0));
	float d = random3(ivec + float3(1.0, 1.0, 0.0));

	float e = random3(ivec + float3(0.0, 0.0, 1.0));
	float f = random3(ivec + float3(1.0, 0.0, 1.0));
	float g = random3(ivec + float3(0.0, 1.0, 1.0));
	float h = random3(ivec + float3(1.0, 1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);

	float v1 = lerp(a, b, fvec.x);
	float v2 = lerp(c, d, fvec.x);
	float v3 = lerp(v1, v2, fvec.y);

	float v4 = lerp(e, f, fvec.x);
	float v5 = lerp(g, h, fvec.x);
	float v6 = lerp(v4, v5, fvec.y);

	float v7 = lerp(v3, v6, fvec.z);
	return v7;
}

float perlinNoise3(in float3 vec) {
	//整数部小数部の分離
	float3 ivec = floor(vec);
	float3 fvec = frac(vec);
	//四角の格子と捉えると、a=左上、b=右上,c=左下、d=右下
	float a = dot(random33(ivec + float3(0.0, 0.0, 0.0))*2.0 - 1.0, fvec - float3(0.0, 0.0, 0.0));
	float b = dot(random33(ivec + float3(1.0, 0.0, 0.0))*2.0 - 1.0, fvec - float3(1.0, 0.0, 0.0));
	float c = dot(random33(ivec + float3(0.0, 1.0, 0.0))*2.0 - 1.0, fvec - float3(0.0, 1.0, 0.0));
	float d = dot(random33(ivec + float3(1.0, 1.0, 0.0))*2.0 - 1.0, fvec - float3(1.0, 1.0, 0.0));

	float e = dot(random33(ivec + float3(0.0, 0.0, 1.0))*2.0 - 1.0, fvec - float3(0.0, 0.0, 1.0));
	float f = dot(random33(ivec + float3(1.0, 0.0, 1.0))*2.0 - 1.0, fvec - float3(1.0, 0.0, 1.0));
	float g = dot(random33(ivec + float3(0.0, 1.0, 1.0))*2.0 - 1.0, fvec - float3(0.0, 1.0, 1.0));
	float h = dot(random33(ivec + float3(1.0, 1.0, 1.0))*2.0 - 1.0, fvec - float3(1.0, 1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);
	float v1 = lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);
	float v2 = lerp(lerp(e, f, fvec.x), lerp(g, h, fvec.x), fvec.y);
	float v3 = lerp(v1, v2, fvec.z);

	return v3;
}

float fbm3(in float3 vec, int octave) {
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0;i < octave;i++) {
		value += amplitude * perlinNoise3(vec);
		vec *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}//非整数ブラウン運動。フラクタルパーリンノ