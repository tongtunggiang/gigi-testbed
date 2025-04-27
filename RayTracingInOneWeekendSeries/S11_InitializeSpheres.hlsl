//  technique, shader S10_InitializeSpheres
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	// world.add(make_shared<sphere>(point3( 0.0, -100.5, -1.0), 100.0, material_ground));
    Spheres[0].center = float3(0,-100.5,-1);
    Spheres[0].radius = 100;
	Spheres[0].materialIndex = 0;
	
	// world.add(make_shared<sphere>(point3( 0.0,    0.0, -1.2),   0.5, material_center));
    Spheres[1].center = float3(0, 0, -1.2);
    Spheres[1].radius = 0.5f;
	Spheres[1].materialIndex = 1;
	
	// world.add(make_shared<sphere>(point3(-1.0,    0.0, -1.0),   0.5, material_left));
    Spheres[2].center = float3(-1.0,    0.0, -1.0);
    Spheres[2].radius = 0.5f;
	Spheres[2].materialIndex = 2;

	// world.add(make_shared<sphere>(point3(-1.0,    0.0, -1.0),   0.4, material_bubble));
    Spheres[3].center = float3(-1.0,    0.0, -1.0);
    Spheres[3].radius = 0.4f;
	Spheres[3].materialIndex = 3;

	// world.add(make_shared<sphere>(point3( 1.0,    0.0, -1.0),   0.5, material_right));
    Spheres[4].center = float3(1.0,    0.0, -1.0);
    Spheres[4].radius = 0.5f;
	Spheres[4].materialIndex = 4;
}

/*
Shader Resources:
	Buffer Spheres (as UAV)
*/
