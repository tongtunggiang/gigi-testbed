// Unnamed technique, shader ModelViewerVS
/*$(ShaderResources)*/

struct VSInput
{
	float3 Position   : POSITION;
	uint   VertexID   : SV_VertexID;
	uint   InstanceId : SV_InstanceID;
	float3 Color      : COLOR;
	float3 Normal     : NORMAL;
	float4 Tangent    : TANGENT;
	float2 UV         : TEXCOORD0;
	int MaterialID    : TEXCOORD1;
	int ShapeID       : TEXCOORD2;

	// Extra info from instance buffer
	float3 offset : TEXCOORD3;
	float scale : TEXCOORD4;
};

struct VSOutput // AKA PSInput
{
	float4 Position   : SV_POSITION;
	float4 Color      : TEXCOORD0;
	float3 Normal     : NORMAL;
	float3 WorldPos   : POSITION;
};

VSOutput vsmain(VSInput input)
{
	float4 outPos = mul(float4(input.Position * input.scale + input.offset, 1.0f), /*$(Variable:ViewProjMtx)*/);

	VSOutput ret = (VSOutput)0;	
	ret.Position = outPos;
	ret.WorldPos = input.Position;
	ret.Normal = normalize(input.Normal);
	ret.Color = float4(input.Color, 1.0f);
	return ret;
}
