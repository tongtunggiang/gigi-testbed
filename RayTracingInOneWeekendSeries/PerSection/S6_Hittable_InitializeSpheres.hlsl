// Rays, a Simple Camera, and Background technique, shader S6_Hittable_InitializeSpheres
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
    Spheres[0].center = float3(0, 0, -1);
    Spheres[0].radius = 0.5f;
    Spheres[1].center = float3(0,-100.5,-1);
    Spheres[1].radius = 100;
}

/*
Shader Resources:
	Buffer Spheres (as UAV)
*/
