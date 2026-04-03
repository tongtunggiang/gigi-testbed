// Final render technique, shader S14_InitializeSpheres
/*$(ShaderResources)*/

#include "Random.hsh"

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint3 rngSeed = uint3(0,0,0);
	rngState = HashInit(rngSeed);

	int objectIdx = 0;

	// auto ground_material = make_shared<lambertian>(color(0.5, 0.5, 0.5));
	// world.add(make_shared<sphere>(point3(0,-1000,0), 1000, ground_material));
	Materials[objectIdx].type = MaterialType::Lambertian;
	Materials[objectIdx].color = float3(0.5f, 0.5f, 0.5f);
	Spheres[objectIdx].center = float3(0, -1000, 0);
	Spheres[objectIdx].radius = 1000;
	Spheres[objectIdx].materialIndex = objectIdx;
	++objectIdx;

    // auto material1 = make_shared<dielectric>(1.5);
    // world.add(make_shared<sphere>(point3(0, 1, 0), 1.0, material1));
	Materials[objectIdx].type = MaterialType::Dielectric;
	Materials[objectIdx].refractionIndex = 1.5f;
	Spheres[objectIdx].center = float3(0, 1, 0);
	Spheres[objectIdx].radius = 1;
	Spheres[objectIdx].materialIndex = objectIdx;
	++objectIdx;

    // auto material2 = make_shared<lambertian>(color(0.4, 0.2, 0.1));
    // world.add(make_shared<sphere>(point3(-4, 1, 0), 1.0, material2));
	Materials[objectIdx].type = MaterialType::Lambertian;
	Materials[objectIdx].color = float3(0.4f, 0.2f, 0.1f);
	Spheres[objectIdx].center = float3(-4, 1, 0);
	Spheres[objectIdx].radius = 1;
	Spheres[objectIdx].materialIndex = objectIdx;
	++objectIdx;

    // auto material3 = make_shared<metal>(color(0.7, 0.6, 0.5), 0.0);
    // world.add(make_shared<sphere>(point3(4, 1, 0), 1.0, material3));
	Materials[objectIdx].type = MaterialType::Metal;
	Materials[objectIdx].color = float3(0.7f, 0.6f, 0.5f);
	Materials[objectIdx].fuzz = 0.0f;
	Spheres[objectIdx].center = float3(4, 1, 0);
	Spheres[objectIdx].radius = 1;
	Spheres[objectIdx].materialIndex = objectIdx;
	++objectIdx;

	// other random small spheres
	int remainingSpheres = /*$(Variable:NumSpheres)*/ - 4;
	if (remainingSpheres > 0)
	{
		int grid = int(ceil(sqrt(float(remainingSpheres))));
		int halfGrid = grid / 2;
		for (; objectIdx < /*$(Variable:NumSpheres)*/; ++objectIdx)
		{
			int x = objectIdx / grid - halfGrid;
			int y = objectIdx % grid - halfGrid;

			float mat = random(0, 1);
			float3 center = float3(x + 0.9f*random(), 0.2f, y + 0.9f*random());
			if (length(center - float3(4, 0.2, 0)) > 0.9f)
			{
				if (mat < 0.8f)
				{
					Materials[objectIdx].type = MaterialType::Lambertian;
					Materials[objectIdx].color = float3(random(), random(), random());
				}
				else if (mat < 0.95f)
				{
					Materials[objectIdx].type = MaterialType::Metal;
					Materials[objectIdx].color = float3(random(0.5f, 1), random(0.5f, 1), random(0.5f, 1));
					Materials[objectIdx].fuzz = random(0, 0.5f);
				}
				else
				{
					Materials[objectIdx].type = MaterialType::Dielectric;
					Materials[objectIdx].refractionIndex = 1.5f;
				}

				Spheres[objectIdx].center = center;
				Spheres[objectIdx].radius = 0.2;
				Spheres[objectIdx].materialIndex = objectIdx;
			}
		}
	}
}

/*
Shader Resources:
	Buffer Materials (as UAV)
	Buffer Spheres (as UAV)
*/
