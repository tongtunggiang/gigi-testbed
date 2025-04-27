// Final render technique, shader S14_InitializeSpheres
/*$(ShaderResources)*/

// Random
// From Gigi's RNG example:
// https://github.com/electronicarts/gigi-techniques/tree/main/Users/awolfe/RngExample

// Computed using nested PCG, with implementation based on https://jcgt.org/published/0009/03/02/supplementary.pdf
#define PRIME32_6 747796405u
#define PRIME32_7 2891336453u
#define PRIME32_8 277803737u

/*
uint wang_hash(inout uint seed)
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}
*/

uint HashPCG(inout uint val)
{
    uint state = val * PRIME32_6 + PRIME32_7;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * PRIME32_8;
    val = state;
    return (word >> 22u) ^ word;
}

uint HashInit(uint3 seed)
{
    return uint(seed.x * uint(1973) + seed.y * uint(9277) + seed.z * uint(26699)) | uint(1);
}

float RandomFloat01(inout uint state)
{
    return float(HashPCG(state)) / 4294967296.0;
}

static const float c_pi = 3.14159265359f;
static const float c_twopi = 2.0f * c_pi;

float3 RandomUnitVector(inout uint state)
{
    float z = RandomFloat01(state) * 2.0f - 1.0f;
    float a = RandomFloat01(state) * c_twopi;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return float3(x, y, z);
}
// #include "PCG.hlsli"

static uint rngState;

float random()
{
	return RandomFloat01(rngState);
}

float random(float min, float max)
{
	return min + (max - min)*random();
}

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
