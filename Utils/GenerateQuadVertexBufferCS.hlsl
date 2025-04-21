// GenerateQuadVertexBuffer technique, shader GenerateQuadVertexBuffer_CS
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	int vertexID = int(DTid.x);
    float2 position = float2(-1.0f, -1.0f);
    float2 uv = float2(0.0f, 0.0f);
	switch(vertexID % 6)
	{
		// first triangle, couter clock wise
		case 0: position = float2(-1.0f, -1.0f); uv = float2(0.0f, 0.0f); break;
		case 1: position = float2(1.0f, -1.0f); uv = float2(1.0f, 0.0f);  break;
		case 2: position = float2(-1.0f, 1.0f); uv = float2(0.0f, 1.0f);  break;

		// second triangle, clock wise
		case 3: position = float2(-1.0f, 1.0f); uv = float2(0.0f, 1.0f);  break;
		case 4: position = float2(1.0f, 1.0f); uv = float2(1.0f, 1.0f);  break;
		case 5: position = float2(1.0f, -1.0f); uv = float2(1.0f, 0.0f);  break;
	}
	
	InOutVertexBuffer[vertexID].Position = position;
	InOutVertexBuffer[vertexID].UV = uv;
}
