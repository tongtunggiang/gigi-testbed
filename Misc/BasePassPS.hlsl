// Unnamed technique, shader ModelViewerPS
/*$(ShaderResources)*/

struct PSInput // AKA VSOutput
{
	float4 Position   : SV_POSITION;
	float4 Color      : TEXCOORD0;
	float3 Normal     : NORMAL;
	float3 WorldPos   : POSITION;
};

struct PSOutput
{
	float4 PositionTarget : SV_Target0;
	float4 NormalTarget : SV_Target1;
	float4 AlbedoTarget : SV_Target2;
	float MaterialID : SV_Target3;
};

PSOutput psmain(PSInput input)
{
	PSOutput ret = (PSOutput)0;
	ret.PositionTarget = float4(input.WorldPos, 1.0);
	ret.NormalTarget = float4(input.Normal, 1.0f);
	ret.AlbedoTarget = input.Color;
	ret.MaterialID = /*$(Variable:Material_Index)*/;
	return ret;
}
