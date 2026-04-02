// Unnamed technique, shader SImpleImageCS
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	int2 imageSize = /*$(Variable:ImageSize)*/;
	int imageWidth = imageSize.x;
	int imageHeight = imageSize.y;

	uint2 px = DTid.xy;

	float r = float(px.x) / (imageWidth - 1);
	float g = float(px.y) / (imageHeight - 1);
	float b = 0.0f;

	Output[px] = float4(r, g, b, 1.0f);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
