#pragma once


class CSky : public CGameObject
{
private:

	ID3D11Buffer*	m_VertexBuffer = NULL;
	ID3D11Buffer*	m_IndexBuffer = NULL;
	CTexture*		m_Texture = NULL;

	CShader*		m_Shader;

	float			m_Time;


	static const int SKY_X = 32;
	static const int SKY_Z = 32;

	VERTEX_3D m_Vertex[SKY_X * SKY_Z];

	float			m_LightRotation;

public:
	void Init();
	void Uninit();
	void Update();
	void Draw();

	float GetLightRotation() { return m_LightRotation; }

LIGHT GetLight(){
	LIGHT light;
	light.Direction = XMFLOAT4(0.0f, -cosf(m_LightRotation), sinf(m_LightRotation), 0.0f);
	light.Diffuse = COLOR(0.9f, 0.9f, 0.9f, 1.0f);
	light.Ambient = COLOR(0.1f, 0.1f, 0.1f, 1.0f);
	return light;
}
};