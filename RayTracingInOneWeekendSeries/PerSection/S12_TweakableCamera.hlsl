// Rays, a Simple Camera, and Background technique, shader S4_RaySimpleCameraBackground
/*$(ShaderResources)*/

// Constants
static const float infinity = 3.402823466e+38f;

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
float3 sample_square()
{
	return float3(random() - 0.5, random() - 0.5, 0);
}
float3 random_vector()
{
	return float3(random(), random(), random());
}
float3 random_vector(float min, float max)
{
	return float3(random(min, max), random(min, max), random(min, max));
}
float3 random_unit_vector()
{
	return RandomUnitVector(rngState);
}
float3 random_on_hemisphere(float3 normal)
{
	float3 on_unit_sphere = random_unit_vector();
	if (dot(on_unit_sphere, normal) > 0)
		return on_unit_sphere;
	else
		return -on_unit_sphere;
}

// Interval
struct interval_t
{
	float min, max;
};
float interval_size(const interval_t interval)
{
	return interval.max - interval.min;
}
bool interval_contains(const interval_t interval, float x)
{
	return interval.min <= x && x <= interval.max;
}
bool interval_surrounds(const interval_t interval, float x)
{
	return interval.min < x && x < interval.max;
}
float interval_clamp(const interval_t interval, float x)
{
	if (x < interval.min) return interval.min;
	if (x > interval.max) return interval.max;
	return x;
}
static const interval_t empty_interval = { +infinity, -infinity };
static const interval_t universe_interval = { -infinity, +infinity };

// Helper
bool near_zero(float3 vec)
{
	const float s = 1e-8;
	return abs(vec.x) < s && abs(vec.y) < s && abs(vec.z) < s;
}

struct ray_t
{
	float3 origin;
	float3 dir;
};

// Ray
float3 ray_at(ray_t ray, float t)
{
	return ray.origin + ray.dir * t;
};

// Hittables
struct hit_record_t
{
	float3 p;
	float3 normal;
	float t;
	int materialIndex;
	bool front_face;
};

// Schlick's reflectance
float reflectance(float cos, float refractionIndex)
{
	float r0 = (1.0f - refractionIndex) / (1.0f + refractionIndex);
	r0 = r0 * r0;
	return r0 + (1.0f - r0) * pow((1.0f - cos), 5);
}

// Material
bool scatter(Struct_Material material, const ray_t ray, const hit_record_t rec, inout float3 attenuation, inout ray_t scattered)
{
	switch (material.type)
	{
		case MaterialType::Metal:
		{
			float3 reflected =  reflect(ray.dir, rec.normal);
			reflected = normalize(reflected) + (material.fuzz * random_unit_vector());
			scattered.origin = rec.p;
			scattered.dir = reflected;
			attenuation = material.color;
			return dot(scattered.dir, rec.normal) > 0;
		}
		case MaterialType::Dielectric:
		{
			attenuation = float3(1, 1, 1);
			float ri = rec.front_face ? (1.0f / material.refractionIndex) : material.refractionIndex;

			float3 unitDirection = normalize(ray.dir);
			float cosTheta = min(dot(-unitDirection, rec.normal), 1.0f);
			float sinTheta = sqrt(1.0f - cosTheta*cosTheta);
			bool cannotRefract = ri * sinTheta > 1.0f;
			float3 direction = (cannotRefract || reflectance(cosTheta, ri) > random()) ? 
				reflect(unitDirection, rec.normal) :
				refract(unitDirection, rec.normal, ri);

			scattered.origin = rec.p;
			scattered.dir = direction;

			return true;
		}
		case MaterialType::Lambertian:
		default: // pass through
		{
			float3 scatterDirection = rec.normal + random_unit_vector();
			if (near_zero(scatterDirection))
			{
				scatterDirection = rec.normal;
			}
			scattered.origin = rec.p;
			scattered.dir = scatterDirection;
			attenuation = material.color;
			return true;
		}
	}

	return false;
}

bool hit_sphere(const Struct_Sphere sphere, const ray_t ray, interval_t interval, inout hit_record_t rec)
{
	const float3 center = sphere.center;
	const float radius = sphere.radius;

    float3 oc = center - ray.origin;
    float a = dot(ray.dir, ray.dir);
	float h = dot(ray.dir, oc); // half of b
    float c = dot(oc, oc) - radius * radius;
    float discriminant = h*h - a*c;

	if (discriminant < 0)
	{
		return false;
	}

	float sqrtd = sqrt(discriminant);

	// Find the nearest root that lies in the acceptable range.
	float root = (h - sqrtd) / a;
	if (!interval_surrounds(interval, root)) {
		root = (h + sqrtd) / a;
		if (!interval_surrounds(interval, root))
		{
			return false;
		}
	}
	
	rec.t = root;
	rec.p = ray_at(ray, rec.t);
	rec.normal = (rec.p - center) / radius;

	float3 outward_normal = (rec.p - center) / radius;
	rec.front_face = dot(ray.dir, outward_normal) < 0;
	rec.normal = rec.front_face ? outward_normal : -outward_normal;

	rec.materialIndex = sphere.materialIndex;

	return true;
}

bool hit_world(const ray_t ray, interval_t interval, inout hit_record_t rec)
{
	hit_record_t temp_rec;
	bool hit_anything = false;
	float closest_so_far = interval.max;
	for (int i = 0; i < /*$(Variable:NumSpheres)*/; ++i)
	{
		interval_t temp_interval;
		temp_interval.min = interval.min;
		temp_interval.max = closest_so_far;
		if (hit_sphere(Spheres[i], ray, temp_interval, temp_rec))
		{
			hit_anything = true;
			closest_so_far = temp_rec.t;
			rec = temp_rec;
		}
	}
	return hit_anything;
}

// Maximum number of child rays being casted back to the world
#define MAX_DEPTH 10

// Final ray color
float3 ray_color(ray_t ray)
{
	// HLSL does not allow recursive functions, so use loops instead
	float3 colors[MAX_DEPTH];

	ray_t currentRay = ray;
	int depth = MAX_DEPTH-1;
	for (; depth >= 0; --depth)
	{
		interval_t interval;
		interval.min = 0.0001;
		interval.max = infinity;
		hit_record_t rec;
		if (!hit_world(ray, interval, rec))
		{
			float3 unitdir = normalize(ray.dir);
			float a = 0.5f * (unitdir.y + 1.0f);
			float3 skyColor = (1.0f - a) * float3(1.0f, 1.0f, 1.0f) + a * float3(0.5f, 0.7f, 1.0f);
			colors[depth] = skyColor;
			break;
		}

		ray_t scattered;
		float3 attenuation;
		if (!scatter(Materials[rec.materialIndex], ray, rec, attenuation, scattered))
		{
			colors[depth] = float3(0,0,0);
			break;
		}

		colors[depth] = attenuation;
		ray = scattered;
	}

	// Backtrack the stack results to get the final color
	if (depth < MAX_DEPTH - 1)
	{
		for (; depth < MAX_DEPTH - 1; ++depth)
		{
			colors[depth+1] *= colors[depth];
		}
	}

	return colors[depth];
}

ray_t get_ray(int2 px)
{
	float3 pixel00_loc = Camera[0].pixel00_loc;
	float3 pixelDelta_u = Camera[0].pixelDelta_u;
	float3 pixelDelta_v = Camera[0].pixelDelta_v;
	float3 cameraCenter = Camera[0].cameraCenter;
	
	float3 offset = sample_square();
	float3 pixelSample = pixel00_loc + 
		((px.x + offset.x) * pixelDelta_u) +
		((px.y + offset.y) * pixelDelta_v);

	float3 rayOrigin = cameraCenter;
    if (/*$(Variable:CameraDefocusAngle)*/ > 0)
    {
        float angle = random(radians(-180), radians(180));
        float3 unit = float3(sin(angle), cos(angle), 0);
        float length = random();

        float3 randomInUnitDisk = unit / length;
    
        rayOrigin += randomInUnitDisk.x * Camera[0].defocusDiskU + randomInUnitDisk.y * Camera[0].defocusDiskV;
    }
	float3 rayDirection = pixelSample - rayOrigin;
	
	ray_t ray;
	ray.origin = rayOrigin;
	ray.dir = rayDirection;
	return ray;
}

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	uint2 px = DTid.xy;

    uint3 rngSeed = uint3(px, /*$(Variable:iFrame)*/);
	rngState = HashInit(rngSeed);

	float3 color = float3(0,0,0);
	for (int sample = 0; sample < Camera[0].numSamplesPerPixel; sample++) {
		ray_t r = get_ray(px);
		color += ray_color(r);
	}

	color *= Camera[0].pixelSampleScale;
	if (/*$(Variable:UseGammaCorrection)*/)
	{
		color.x = color.x > 0 ? sqrt(color.x) : 0;
		color.y = color.y > 0 ? sqrt(color.y) : 0;
		color.z = color.z > 0 ? sqrt(color.z) : 0;
	}
	Output[px] = float4(color, 1.0f);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
