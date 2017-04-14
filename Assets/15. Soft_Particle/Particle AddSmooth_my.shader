Shader "xxxxParticles/Additive (Soft) my" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend One OneMinusSrcColor
	ColorMask RGB
	Cull Off
	Lighting Off
	ZWrite Off

	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				
				float4 projPos : TEXCOORD2;
				
			};

			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				// *** o.projPos = ComputeScreenPos (o.vertex);
				// *** o.projPos.xy = (o.vertex.xy * fixed2(1, _ProjectionParams.x) + o.vertex.w) * 0.5;
				o.projPos.xy = (o.vertex.xy * fixed2(1, -1) + o.vertex.w) * 0.5;
				o.projPos.zw = o.vertex.zw;

				//COMPUTE_EYEDEPTH(o.projPos.z);
				o.projPos.z = -(mul( UNITY_MATRIX_MV, v.vertex ).z);


				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			uniform float4x4 _MVP;
			
			fixed4 frag (v2f i) : SV_Target
			{
				/*
				float sceneZ_Ndc = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float sceneZ_Eye = LinearEyeDepth(sceneZ_Ndc);
				*/

				/*
				// OpenGL
				// *** float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));

				i.projPos.xy = i.projPos.xy / i.projPos.w;
				// 这里的范围是[0-1]，OpenGL需要是[-1, 1]
				float sceneZ_Ndc = tex2D(_CameraDepthTexture, i.projPos.xy).r;
				//[0-1] -> [-1, 1]
				sceneZ_Ndc = sceneZ_Ndc * 2 - 1;

				// *** float sceneZ_Eye = LinearEyeDepth(sceneZ_Ndc);
				float near = _ProjectionParams.y;
				float far = _ProjectionParams.z;

				// openGL投影矩阵，[3][3], [3][4]
				// zn = ( A * ze + B ) / (-ze)
				// ze = -B / (zn + A)

				float A = -(far + near) / (far - near);
				float B = -2 * far * near / (far - near);
				float sceneZ_Eye = -B / (sceneZ_Ndc + A);
				sceneZ_Eye = -sceneZ_Eye;
				*/


				///*
				//dx
				// *** float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				i.projPos.xy = i.projPos.xy / i.projPos.w;
				// 这里的范围是[0-1]
				float sceneZ_Ndc = tex2D(_CameraDepthTexture, i.projPos.xy).r;

				// *** float sceneZ_Eye = LinearEyeDepth(sceneZ_Ndc);
				float near = _ProjectionParams.y;
				float far = _ProjectionParams.z;

				// dx投影矩阵，[3][3], [4][3]
				// zn = ( A * ze + B ) / (ze)
				// ze = B / (zn - A)

				//dx投影矩阵
				float A = far / (far - near);
				float B = far * near / (near - far);
				float sceneZ_Eye = B / (sceneZ_Ndc - A);
				//*/

				

				float partZ_Eye = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ_Eye - partZ_Eye));
				i.color.a *= fade;
				half4 col = i.color * tex2D(_MainTex, i.texcoord);
				col.rgb *= col.a;
				return col;
				
			}
			ENDCG 
		}
	} 
}
}

/*

// x = 1 or -1 (-1 if projection is flipped)
// y = near plane
// z = far plane
// w = 1/far plane
uniform float4 _ProjectionParams;
				
inline float4 ComputeScreenPos (float4 pos) {
	float4 o = pos * 0.5f;
	#if defined(UNITY_HALF_TEXEL_OFFSET)
	o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w * _ScreenParams.zw;
	#else
	o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
	#endif
	
	o.zw = pos.zw;
	return o;
}



#define COMPUTE_EYEDEPTH(o) o = -mul( UNITY_MATRIX_MV, v.vertex ).z

define SAMPLE_DEPTH_TEXTURE_PROJ(sampler, uv) (tex2Dproj(sampler, uv).r)


inline float LinearEyeDepth( float z )
{
	return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
}


//其中_ZBufferParams的定义如下：
//double zc0, zc1;
// OpenGL would be this:
// zc0 = (1.0 - m_FarClip / m_NearClip) / 2.0;
// zc1 = (1.0 + m_FarClip / m_NearClip) / 2.0;
// D3D is this:
//zc0 = 1.0 - m_FarClip / m_NearClip;
//zc1 = m_FarClip / m_NearClip;
// now set _ZBufferParams with (zc0, zc1, zc0/m_FarClip, zc1/m_FarClip);


*/