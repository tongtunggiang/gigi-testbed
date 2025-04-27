// Metal technique, shader S10_InitializeMaterials
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	// auto material_ground = make_shared<lambertian>(color(0.8, 0.8, 0.0));
	Materials[0].type = MaterialType::Lambertian;
	Materials[0].color = float3(0.8f, 0.8f, 0.0);
	// auto material_center = make_shared<lambertian>(color(0.1, 0.2, 0.5));
	Materials[1].type = MaterialType::Lambertian;
	Materials[1].color = float3(0.1f, 0.2f, 0.5f);
	// auto material_left   = make_shared<dielectric>(1.50);
	Materials[2].type = MaterialType::Dielectric;
	Materials[2].refractionIndex = 1.5f;
	// auto material_bubble = make_shared<dielectric>(1.00 / 1.50);
	Materials[3].type = MaterialType::Dielectric;
	Materials[3].refractionIndex = 1.0f / 1.5f;
	// auto material_right  = make_shared<metal>(color(0.8, 0.6, 0.2));
	Materials[4].type = MaterialType::Metal;
	Materials[4].color = float3(0.8f, 0.6f, 0.2f);
	Materials[4].fuzz = 1.0f;
}

/*
Shader Resources:
	Buffer Materials (as UAV)
*/
