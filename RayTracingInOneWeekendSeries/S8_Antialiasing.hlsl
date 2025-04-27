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
	bool front_face;
};

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

// Final ray color
float3 ray_color(ray_t ray)
{
	interval_t interval;
	interval.min = 0;
	interval.max = infinity;
	hit_record_t rec;
	if (hit_world(ray, interval, rec))
	{
        return 0.5 * (rec.normal + float3(1,1,1));
	}

	float3 unitdir = normalize(ray.dir);
	float a = 0.5f * (unitdir.y + 1.0f);
	//return float3(a, 0, 0);
	return  (1.0f - a) * float3(1.0f, 1.0f, 1.0f) + a * float3(0.5f, 0.7f, 1.0f);
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

	Output[px] = float4(color * Camera[0].pixelSampleScale, 1.0f);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
