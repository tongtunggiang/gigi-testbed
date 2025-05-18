// Unnamed technique, shader LightingPassVS
/*$(ShaderResources)*/

struct VSInput
{
	float3 position   : POSITION;
	float2 uv         : TEXCOORD0;
};

struct VSOutput // AKA PSInput
{
	float4 position   : SV_POSITION;
	float2 uv         : TEXCOORD0;
};

VSOutput vsmain(VSInput input)
{
	VSOutput ret = (VSOutput)0;
	ret.position = float4(input.position, 1.0f);
	ret.uv = input.uv;
	return ret;
}
