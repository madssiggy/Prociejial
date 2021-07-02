

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
	//outDiffuse.rgb = float3(0.1, 0.2, 1.0);
	////線形補間を応用したフォグ
	//float fog = distance(CameraPosition.xyz, inWorldPosition.xyz)*0.03;
	//fog = saturate(fog);
	//outDiffuse.rgb = outDiffuse.rgb*(1.0 - fog) + float3(0.8, 0.9, 1.0)*fog;
	//
	float2 offset;
	offset.x = fbm2(inTexCoord*0.3, 16, Parameter.x*0.1);
	offset.y = fbm2(inTexCoord*0.7, 16, Parameter.x*0.1);
	outDiffuse.a= fbm2(inTexCoord+offset, 16,Parameter*0.1)*0.5 + 0.5;
	outDiffuse.a = gain(0.9, outDiffuse.a);
	//outDiffuse.a = 1.0 - fbm3(inWorldPosition.xyz, 10)*0.5;
    
    
}
