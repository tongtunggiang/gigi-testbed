// Rays, a Simple Camera, and Background technique, shader S4_RaySimpleCameraBackground
/*$(ShaderResources)*/

// Constants
static const float infinity = 3.402823466e+38f;

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
	bool hit;
	bool front_face;
};

hit_record_t hit_sphere(const Struct_Sphere sphere, const ray_t ray, interval_t interval)
{
	hit_record_t rec;

	const float3 center = sphere.center;
	const float radius = sphere.radius;

    float3 oc = center - ray.origin;
    float a = dot(ray.dir, ray.dir);
	float h = dot(ray.dir, oc); // half of b
    float c = dot(oc, oc) - radius * radius;
    float discriminant = h*h - a*c;

	if (discriminant < 0)
	{
		rec.hit = false;
		return rec;
	}

	float sqrtd = sqrt(discriminant);

	// Find the nearest root that lies in the acceptable range.
	float root = (h - sqrtd) / a;
	if (!interval_surrounds(interval, root)) {
		root = (h + sqrtd) / a;
		if (!interval_surrounds(interval, root))
		{
			rec.hit = false;
			return rec;
		}
	}
	
	rec.hit = true;
	rec.t = root;
	rec.p = ray_at(ray, rec.t);
	rec.normal = (rec.p - center) / radius;

	float3 outward_normal = (rec.p - center) / radius;
	rec.front_face = dot(ray.dir, outward_normal) < 0;
	rec.normal = rec.front_face ? outward_normal : -outward_normal;

	return rec;
}

hit_record_t hit_world(const ray_t ray, interval_t interval)
{
	bool hit_anything = false;
	float closest_so_far = interval.max;
	hit_record_t final_record;
	final_record.hit = false;
	for (int i = 0; i < /*$(Variable:NumSpheres)*/; ++i)
	{
		interval_t temp_interval;
		temp_interval.min = interval.min;
		temp_interval.max = closest_so_far;
		hit_record_t temp_rec = hit_sphere(Spheres[i], ray, temp_interval);
		if (temp_rec.hit)
		{
			hit_anything = true;
			closest_so_far = temp_rec.t;
			final_record = temp_rec;
		}
	}
	return final_record;
}

// Final ray color
float3 ray_color(ray_t ray)
{
	interval_t interval;
	interval.min = 0;
	interval.max = infinity;
	hit_record_t rec = hit_world(ray, interval);
	if (rec.hit)
	{
        return 0.5 * (rec.normal + float3(1,1,1));
	}

	float3 unitdir = normalize(ray.dir);
	float a = 0.5f * (unitdir.y + 1.0f);
	//return float3(a, 0, 0);
	return  (1.0f - a) * float3(1.0f, 1.0f, 1.0f) + a * float3(0.5f, 0.7f, 1.0f);
}

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
	uint2 px = DTid.xy;

	float3 pixel00_loc = Camera[0].pixel00_loc;
	float3 pixelDelta_u = Camera[0].pixelDelta_u;
	float3 pixelDelta_v = Camera[0].pixelDelta_v;
	float3 cameraCenter = Camera[0].cameraCenter;

	float3 pixelCenter = pixel00_loc + (px.x * pixelDelta_u) + (px.y * pixelDelta_v);
	ray_t ray;
	ray.origin = cameraCenter;
	ray.dir = pixelCenter - cameraCenter;

	float3 color = ray_color(ray);
	Output[px] = float4(color, 1.0f);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
