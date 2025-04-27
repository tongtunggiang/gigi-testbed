// Rays, a Simple Camera, and Background technique, shader S4_RaySimpleCameraBackground
/*$(ShaderResources)*/

struct ray_t
{
	float3 origin;
	float3 dir;
};

float3 ray_at(ray_t ray, float t)
{
	return ray.origin + ray.dir * t;
};

float3 ray_color(ray_t ray)
{
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
