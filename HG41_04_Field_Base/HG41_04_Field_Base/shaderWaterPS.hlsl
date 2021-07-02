

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
    float4 Parameter;

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

    outDiffuse = 1.0;

	float2 windWay;
	windWay = float2(1.0, 1.0);//凪。
	windWay.x = -1.3;
	windWay.y = 3.4;
	float waveHeight = 0.05;
	int test = 6;
	test = 20;
	float dx = sin((inTexCoord.x - 0.001)*0.3)*4.0 -
		sin((inTexCoord.x - 0.001)*0.3)*4.0;

	dx = fbm2((inTexCoord + float2(0.001, 0.0))*waveHeight, test, Parameter.x*windWay.x)
		- fbm2((inTexCoord - float2(0.001, 0.0))*waveHeight, test, Parameter.x*windWay.x);


	float dz = 0.0;
	//Param.xを乗算するとスプライトの流れが速くなる。
	//float2に掛かっている数字を大きくするとより細かい波にできる
	dz = fbm2((inTexCoord + float2(0.0, 0.001))*waveHeight, test, Parameter.x*windWay.y)
		- fbm2((inTexCoord - float2(0.0, 0.001))*waveHeight, test, Parameter.x*windWay.y);



	float3 normal = float3(-dx, 0.001, -dz);//yの数字を大きくすると凹凸が大きくなる。
	normal = normalize(normal);

	float3 lightDir = float3(1.0, -1.0, 1.0);
	lightDir = normalize(lightDir);

	float3 eyev = inWorldPosition.xyz - CameraPosition.xyz;
	eyev = normalize(eyev);
/*	//フォン
	float3 ref = reflect(lightDir, normal);

	float spec = saturate(-dot(ref, eyev));
	spec = pow(spec, 20);
	outDiffuse.rgb = spec * 1.0;*/
	//フレネルの式

	float fresnel = saturate(1.0 + dot(eyev, normal));
	fresnel = 0.05 + (1.0 - 0.05)*pow(fresnel, 5);

	outDiffuse.rgb = float3(0.0, 0.1, 0.1)*(1.0 - fresnel)
		+ float3(0.55, 0.65, 1.0)*fresnel;
	outDiffuse.a = 0.75;
	//float depth = distance(CameraPosition.xyz, inWorldPosition.xyz)*0.03;
	//depth= saturate(depth);
	//outDiffuse.a = abs(depth-1.0);

}
