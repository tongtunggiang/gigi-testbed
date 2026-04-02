// Rays, a Simple Camera, and Background technique, shader S4_CalculateGlobalCameraBuffer
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

    // ... and since the aspect ratio represents the actual ratio and not being rounded,
    // we can use it here
    float viewportHeight = 2.0f;
    float viewportWidth = viewportHeight * Camera[0].aspectRatio;

    // The rest is pretty identical to Shirley's implementation
    Camera[0].cameraCenter = float3(0, 0, 0);
	Camera[0].focalLength = 1.0f;

    float3 viewport_u = float3(viewportWidth, 0, 0);
    float3 viewport_v = float3(0, -viewportHeight, 0);

    Camera[0].pixelDelta_u = viewport_u / imageWidth;
    Camera[0].pixelDelta_v = viewport_v / imageHeight;

    float3 viewportUpperLeft = Camera[0].cameraCenter - float3(0, 0, Camera[0].focalLength) - viewport_u/2 - viewport_v/2;
    Camera[0].pixel00_loc = viewportUpperLeft + 0.5f * (Camera[0].pixelDelta_u + Camera[0].pixelDelta_v);

    Camera[0].numSamplesPerPixel = /*$(Variable:NumSamplesPerPixel)*/;
    Camera[0].pixelSampleScale = 1.0f / /*$(Variable:NumSamplesPerPixel)*/;
}

/*
Shader Resources:
	Buffer Camera (as UAV)
*/
