// Book of shaders 05 - shaping functions technique, shader PlotPS
/*$(ShaderResources)*/

#define PI 3.14159265359


struct PSInput // AKA VSOutput
{
	float4 position   : SV_POSITION;
	float2 uv         : TEXCOORD;
};

struct PSOutput
{
	float4 colorTarget : SV_Target0;
};

float Plot(float2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

PSOutput MainPS(PSInput input)
{
	PSOutput ret = (PSOutput)0;

	float2 st = input.uv;

	// Setup background
	float y = st.x; // Defaulted to linear
	switch(/*$(Variable:PlotMode)*/)
	{
		case PlotMode::Expo:
		{
			y = pow(st.x, /*$(Variable:Expo_Power)*/);
			break;
		}
		case PlotMode::Sin:
		{
			y = (sin(st.x * 2 * PI) + 1) / 2;
			break;
		}
		case PlotMode::Cos:
		{
			y = (cos(st.x * 2 * PI) + 1) / 2;
			break;
		}
		case PlotMode::Mod:
		{
			y = fmod(st.x, /*$(Variable:Mod_Value)*/);
			break;
		}
		case PlotMode::Fraction:
		{
			y = frac(st.x * /*$(Variable:Multiplier)*/);
			break;
		}
		case PlotMode::Ceil:
		{
			y = ceil(st.x);
			break;
		}
		case PlotMode::Floor:
		{
			y = floor(st.x);
			break;
		}
		default:
			break;
	}

	float3 color = st.x;
	if (/*$(Variable:PlotBackground)*/)
	{
		color = y;
	}
	
	// Draw plot line
	float pct = Plot(st,y);
	color = (1.0-pct)*color+pct*float3(0.0,1.0,0.0);

	ret.colorTarget = float4(color, 1.0f);

	return ret;
}
