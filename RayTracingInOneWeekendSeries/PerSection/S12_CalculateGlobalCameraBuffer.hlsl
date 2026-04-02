// Tweakable camera technique, shader S12_CalculateGlobalCameraBuffer
/*$(ShaderResources)*/

/*$(_compute:MainCS)*/(uint3 DTid : SV_DispatchThreadID)
{
    // As opposed to the book where the image height is calculated from image width and aspect ratio,
    // it's easier to do it the other way around here.
    int2 imageSize = /*$(Variable:ImageSize)*/;
    int imageWidth = imageSize.x;
    int imageHeight = imageSize.y;
    float aspectRatio = float(imageWidth) / float(imageHeight);
    Camera[0].aspectRatio = aspectRatio;

    float3 lookfrom = /*$(Variable:CameraPosition)*/;
    float3 lookat = /*$(Variable:CameraLookAt)*/;
    float3 vup = /*$(Variable:CameraUp)*/;

    Camera[0].cameraCenter = lookfrom;

	float3 theta = radians(/*$(Variable:CameraVFOV)*/);
	float h = tan(theta/2);
    float focusDistance = /*$(Variable:CameraFocusDistance)*/;
    float viewportHeight = 2.0f * h * focusDistance;
    // ... and since the aspect ratio represents the actual ratio and not being rounded,
    // we can use it here
    float viewportWidth = viewportHeight * Camera[0].aspectRatio;

    float3 w = normalize(lookfrom - lookat);
    float3 u = normalize(cross(vup, w));
    float3 v = cross(w, u);

    Camera[0].w = w;
    Camera[0].u = u;
    Camera[0].v = v; 

    float3 viewport_u = viewportWidth * u;
    float3 viewport_v = viewportHeight * -v;

    Camera[0].pixelDelta_u = viewport_u / imageWidth;
    Camera[0].pixelDelta_v = viewport_v / imageHeight;

    float3 viewportUpperLeft = Camera[0].cameraCenter - focusDistance * w - viewport_u/2 - viewport_v/2;
    Camera[0].pixel00_loc = viewportUpperLeft + 0.5f * (Camera[0].pixelDelta_u + Camera[0].pixelDelta_v);

    float defocusRadius = focusDistance * tan(radians(/*$(Variable:CameraDefocusAngle)*/ / 2));
    Camera[0].defocusDiskU = u * defocusRadius;
    Camera[0].defocusDiskV = v * defocusRadius;

    Camera[0].numSamplesPerPixel = /*$(Variable:NumSamplesPerPixel)*/;
    Camera[0].pixelSampleScale = 1.0f / /*$(Variable:NumSamplesPerPixel)*/;
}

/*
Shader Resources:
	Buffer Camera (as UAV)
*/
