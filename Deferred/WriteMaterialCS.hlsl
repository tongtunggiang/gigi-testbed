// Unnamed technique, shader WriteMaterialCS
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
	g_Materials[/*$(Variable:Material_Index)*/].DiffuseAlbedo = /*$(Variable:Material_DiffuseAlbedo)*/;
	g_Materials[/*$(Variable:Material_Index)*/].FresnelR0     = /*$(Variable:Material_FresnelR0)*/;
	g_Materials[/*$(Variable:Material_Index)*/].Shininess     = /*$(Variable:Material_Shininess)*/;
}

/*
Shader Resources:
	Buffer g_Materials (as UAV)
*/
