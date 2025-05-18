// GenerateQuadVertexBuffer technique, shader GenerateQuadVertexBuffer_CS
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	// first triangle, couter clock wise
	InOutVertexBuffer[0].Position = float3(-1.0f, -1.0f, 1.0f); InOutVertexBuffer[0].UV = float2(0.0f, 0.0f);
	InOutVertexBuffer[1].Position = float3( 1.0f, -1.0f, 1.0f); InOutVertexBuffer[1].UV = float2(1.0f, 0.0f);
	InOutVertexBuffer[2].Position = float3(-1.0f,  1.0f, 1.0f); InOutVertexBuffer[2].UV = float2(0.0f, 1.0f);

	// second triangle, clock wise
	InOutVertexBuffer[3].Position = float3(-1.0f,  1.0f, 1.0f); InOutVertexBuffer[3].UV = float2(0.0f, 1.0f);
	InOutVertexBuffer[4].Position = float3( 1.0f,  1.0f, 1.0f); InOutVertexBuffer[4].UV = float2(1.0f, 1.0f);
	InOutVertexBuffer[5].Position = float3( 1.0f, -1.0f, 1.0f); InOutVertexBuffer[5].UV = float2(1.0f, 0.0f);
}
