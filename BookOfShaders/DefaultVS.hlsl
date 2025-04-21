// Book of shaders 05 - shaping functions technique, shader DefaultVS
/*$(ShaderResources)*/

struct VSInput
{
	float2 position   : POSITION;
	float2 uv         : TEXCOORD;
};

struct VSOutput // AKA PSInput
{
	float4 position   : SV_POSITION;
	float2 uv		  : TEXCOORD;
};

VSOutput MainVS(VSInput input)
{
	VSOutput ret = (VSOutput)0;
	ret.position = float4(input.position.xy, 0.0f, 1.0f);
	ret.uv = input.uv;
	return ret;
}
