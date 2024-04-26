package shaders;

// - guisende maded that and he is suffing about that

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxBasic;

class VHSTapeShitEffect extends FlxBasic 
{
    public var shader:VHSTape = new VHSTape();

    //var iTime:Float = 0;

    public function new():Void
    {
        super();
        /*shader.iTime.value = [0];
		shader.iTime.value = [FlxG.random.float(0,8)];*/
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed); // - work shadar
        //shader.iTime.value[0] += elapsed;
    }
}

class VHSTape extends FlxShader {

    @:glFragmentSource('
	#pragma header
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
	//uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	#define round(a) floor(a + 0.5)
	#define texture flixel_texture2D
	#define iResolution openfl_TextureSize
	#define iChannelResolution openfl_TextureSize
	#define iChannel0 bitmap
	
	#define lerp mix
	
	#define NTSC 0
	#define PAL 1
	
	// Effect params
	#define VIDEO_STANDARD PAL
	
	#if VIDEO_STANDARD == NTSC
		const vec2 maxResLuminance = vec2(333.0, 480.0);
		const vec2 maxResChroma = vec2(40.0, 480.0);
	#elif VIDEO_STANDARD == PAL
		const vec2 maxResLuminance = vec2(335.0, 576.0);
		const vec2 maxResChroma = vec2(40.0, 240.0);
	#endif
	
	const vec2 blurAmount = vec2(0.2, 0.2);
	
	// End effect params
	
	#define VIDEO_TEXTURE iChannel0
	
	
	
	mat3 rgb2yiq = mat3(0.299, 0.596, 0.211,
							0.587, -0.274, -0.523,
							0.114, -0.322, 0.312);
	
	mat3 yiq2rgb = mat3(1, 1, 1,
							0.956, -0.272, -1.106,
							0.621, -0.647, 1.703);
	
	// from http://www.java-gaming.org/index.php?topic=35123.0
	vec4 cubic(float v)
	{
		vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
		vec4 s = n * n * n;
		float x = s.x;
		float y = s.y - 4.0 * s.x;
		float z = s.z - 4.0 * s.y + 6.0 * s.x;
		float w = 6.0 - x - y - z;
		return vec4(x, y, z, w) * (1.0/6.0);
	}
	
	// Downsample buffer A and convert to YIQ color space
	
	
	vec3 downsampleVideo(vec2 uv, vec2 pixelSize, ivec2 samples)
	{
		//return texture(VIDEO_TEXTURE, uv).rgb * rgb2yiq;
		
		vec2 uvStart = uv - pixelSize / 2.0;
		vec2 uvEnd = uv + pixelSize;
		
		vec3 result = vec3(0.0, 0.0, 0.0);
		for (int i_u = 0; i_u < samples.x; i_u++)
		{
			float u = lerp(uvStart.x, uvEnd.x, float(i_u) / float(samples.x));
			
			for (int i_v = 0; i_v < samples.y; i_v++)
			{
				float v = lerp(uvStart.y, uvEnd.y, float(i_v) / float(samples.y));
				
				result += texture(VIDEO_TEXTURE, vec2(u, v)).rgb;
			}
		}    
		
		return (result / float(samples.x * samples.y)) * rgb2yiq;
	}
	
	vec3 downsampleVideo(vec2 fragCoord, vec2 downsampledRes)
	{
	   
		if (fragCoord.x > downsampledRes.x || fragCoord.y > downsampledRes.y)
		{
			return vec3(0.0);
		}
		
		vec2 uv = fragCoord / downsampledRes;
		vec2 pixelSize = 1.0 / downsampledRes;
		ivec2 samples = ivec2(8, 3);
		
		pixelSize *= 1.0 + blurAmount; // Slight box blur to avoid aliasing
		
		return downsampleVideo(uv, pixelSize, samples);
	}
	
	vec4 bufferB(vec2 uv)
	{
		vec2 resLuminance = min(maxResLuminance, vec2(iResolution));
		vec2 resChroma = min(maxResChroma, vec2(iResolution));    
		
		float luminance = downsampleVideo(uv * iResolution.xy, resLuminance).r;
		vec2 chroma = downsampleVideo(uv * iResolution.xy, resChroma).gb;
		return vec4(luminance, chroma, 1);
	}
	
	vec4 textureBicubic(vec2 texCoords)
	{
	
		vec2 texSize = vec2(iChannelResolution[0]);
		vec2 invTexSize = vec2(1.0) / texSize;
	
		texCoords = texCoords * texSize - 0.5;
	
	
		vec2 fxy = fract(texCoords);
		texCoords -= fxy;
	
		vec4 xcubic = cubic(fxy.x);
		vec4 ycubic = cubic(fxy.y);
	
		vec4 c = texCoords.xxyy + vec2 (-0.5, +1.5).xyxy;
	
		vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
		vec4 offset = c + vec4 (xcubic.yw, ycubic.yw) / s;
	
		offset *= invTexSize.xxyy;
	
		vec4 sample0 = bufferB(offset.xz);
		vec4 sample1 = bufferB(offset.yz);
		vec4 sample2 = bufferB(offset.xw);
		vec4 sample3 = bufferB(offset.yw);
	
		float sx = s.x / (s.x + s.y);
		float sy = s.z / (s.z + s.w);
	
		return mix(
		   mix(sample3, sample2, sx), mix(sample1, sample0, sx)
		, sy);
	}
	
	vec2 rotate(vec2 v, float a)
	{
		float s = sin(a);
		float c = cos(a);
		mat2 m = mat2(c, -s, s, c);
		return m * v;
	}
	
	void main()
	{
		vec2 uv = fragCoord / iResolution.xy;
		
		vec2 resLuminance = min(maxResLuminance, vec2(iResolution));
		vec2 resChroma = min(maxResChroma, vec2(iResolution));
		
		vec2 uvLuminance = uv * (resLuminance / vec2(iResolution));
		vec2 uvChroma = uv * (resChroma / vec2(iResolution));
		
		vec3 result;
		
		float luminance = textureBicubic(uvLuminance).x;
		vec2 chroma = textureBicubic(uvChroma).yz;
		result = vec3(luminance, chroma) * yiq2rgb;
		
		fragColor = vec4(result, texture(iChannel0, uv).a);
	}
    ')
    public function new()
    {
        super();
    }
}