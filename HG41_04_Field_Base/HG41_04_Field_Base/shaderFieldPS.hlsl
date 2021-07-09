

#include "shaderNoise.hlsl"

Texture2D		g_Texture : register(t0);
SamplerState	g_SamplerState : register(s0);


// 定数バッファ
cbuffer ConstatntBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;

    float4 CameraPosition;
}

struct LIGHT {
	float4 Direction;
	float4 Diffuse;
	float4 Ambient;
};

cbuffer LightBuffer:register(b1) {
	LIGHT Light;
}

//=============================================================================
// ピクセルシェーダ
//=============================================================================
void main( in  float4 inPosition		: SV_POSITION,
            in float4 inWorldPosition   : POSITION0,
			in  float4 inNormal			: NORMAL0,
			in  float4 inDiffuse		: COLOR0,
			in  float2 inTexCoord		: TEXCOORD0,

			out float4 outDiffuse		: SV_Target )
{
    
//	outDiffuse = g_Texture.Sample(g_SamplerState, inTexCoord);
//地形の高さごとに描画されるテクスチャを変更する	
	float soil = fbm2(inTexCoord*0.1, 16);

	if (soil < 0.15)//一定の高さ以下ならあらかじめ用意されていたテクスチャ
		outDiffuse = g_Texture.Sample(g_SamplerState, inTexCoord);
	else {//一定以上であればプロシージャルテクスチャを張り付ける
		outDiffuse.rgb = (fbm2(inTexCoord*0.1, 16)*0.5+0.5)*float3(0.7, 0.9, 0.4)*random2(inTexCoord)*2.0;
		outDiffuse.a = 1.0;
	}
	float3 difx = fbm3(float3(0.001,0.0,0.0),10);

	
	float dx = sin((inTexCoord.x - 0.001)*0.3)*4.0 -
		sin((inTexCoord.x - 0.001)*0.3)*4.0;

	dx = fbm2((inTexCoord + float2(0.001, 0.0))*0.05,10)*10.0
		- fbm2((inTexCoord - float2(0.001, 0.0))*0.05,10)*10.0;
	
	dx = dispMap(inTexCoord + float2(0.001, 0.0))
		- dispMap(inTexCoord - float2(0.001, 0.0));

	float dz = 0.0;

	dz= fbm2((inTexCoord + float2(0.0, 0.001))*0.05,10)*10.0
		- fbm2((inTexCoord - float2(0.0, 0.001))*0.05,10)*10.0;

	dz = dispMap(inTexCoord + float2(0.0, 0.001))
		- dispMap(inTexCoord - float2(0.0, 0.001));
	float2 rand = fbm2(inTexCoord*0.5,10)+0.5;
	if (inWorldPosition.y+rand.y> 0.5) {
		outDiffuse.rgb = (1.0, 1.0, 1.0);
	}

	float3 normal = float3(-dx, 0.001,-dz);
	normal = normalize(normal);

	float3 lightDir = Light.Direction.xyz;
	lightDir = normalize(lightDir);

	float light = saturate(0.5 - dot(normal,lightDir)*0.5);
	outDiffuse.rgb *= light;


	/*float MaxHeight = 10.0;
	float MinHeight = 0.0;
	float alpha = clamp((inWorldPosition.y - MinHeight) / (MaxHeight - MinHeight), 0.0, 1.0);
	outDiffuse.rgb = outDiffuse.rgb*alpha*float3(0.3, 0.3, 0.3)*(1.0 - alpha);水中を暗く描画するため。一定の高さ以下であれば暗く描画。
*/
	float fog = distance(CameraPosition.xyz, inWorldPosition.xyz)*0.03;
	fog = saturate(fog);//大気散乱を起こす

	outDiffuse.rgb = outDiffuse.rgb*(1.0 - fog)+float3(0.6, 0.8, 1.0)*fog* light*0.1;


}
