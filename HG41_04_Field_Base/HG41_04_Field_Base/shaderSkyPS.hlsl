

#include "shaderNoise.hlsl"

Texture2D		g_Texture : register(t0);
SamplerState	g_SamplerState : register(s0);

// �萔�o�b�t�@
cbuffer ConstatntBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;

    float4 CameraPosition;
    float4 Parameter;

}

//���C�g�o�b�t�@
struct LIGHT {
	float4 Direction;
	float4 Diffuse;
	float4 Ambient;
};

cbuffer LightBuffer:register(b1) {
	LIGHT Light;
}

//=============================================================================
// �s�N�Z���V�F�[�_
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
	////���`��Ԃ����p�����t�H�O
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

	float3 diffuse = 0.0;
	outDiffuse.rgb = diffuse;
	outDiffuse.a = 1.0;

	
//�U������------------------------------------
	float3 eye = inWorldPosition - CameraPosition;
	eye = normalize(eye);

	//��C�����B������C�ɐN�����钷���ƂȂ��Ă���
	float dist = distance(inWorldPosition*0.8, CameraPosition);

	//�~�[�U��

	float m;
	m = saturate(-dot(Light.Direction.xyz, eye));
	m = pow(m, 50);

	diffuse += m * 0.08;//���z�̗֊s


	//���C���[�U��
	float3 vy = float3(0.0, 1.0, 0.0);
	float atm = saturate(1.0 - dot(-Light.Direction.xyz, vy));//;//���C�g�����̑�C�B���z�̕�����C�������Ă��ƂɂȂ��Ă���.

	float3 rcolor = 1.0 - float3(0.5, 0.8, 1.0)*atm*1.0;//���C���[�U�������B

	float ld = 0.5 - dot(Light.Direction.xyz, eye)*0.5;//���C���[�U��.�U�����₷���F�̐��l�������Ă���
	diffuse += rcolor * dist*ld*float3(0.6, 0.8, 1.0)*0.008;


	outDiffuse.rgb = diffuse;

	outDiffuse.a = 1.0;

}
