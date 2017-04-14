// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Q3_Sea_Temp"
{
	Properties
	{
		u_normalTex ("u_normalTex", 2D) = "white" {}
		u_foamTex ("u_foamTex", 2D) = "white" {}
		u_backgroundTex ("u_backgroundTex", 2D) = "white" {}

		u_vertexWaveArg ("u_vertexWaveArg", Vector) = (-0.5, 2.82, 0.4, 0.05)
		u_vertexWaveDir ("u_vertexWaveDir", Vector) = (1, 10, 0, -18.54)
		u_uvSpeed ("u_uvSpeed", Vector) = (0, 0, 0.004, 0)
		u_normalMovement ("u_normalMovement", float) = 1.91
		u_centerColor1 ("u_centerColor1", Color) = (1, 1, 1, 1)
		u_edgeColor1 ("u_edgeColor1", Color) = (1, 1, 1, 1)
		u_centerColor2 ("u_centerColor2", Color) = (0.0549, 0.7573529, 0.7573529, 0.423)
		u_edgeColor2 ("u_edgeColor2", Color) = (0, 0.1961968, 0.3897059, 0.8588235)
		u_shiness ("u_shiness", Vector) =  (0, 50, 6, 1)
		u_colorProgress ("u_colorProgress", float) =  1
		u_specularColor ("u_specularColor", Color) = (1, 1, 1, 1)
		u_shinessIntensity ("u_shinessIntensity", float) =  1
		u_backgroundAlphaOffset ("u_backgroundAlphaOffset", float) = 0
	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always
		Tags { "RenderType"="Opaque" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 v_normalTexUV : TEXCOORD1;
				float2 v_foamTexUV : TEXCOORD2;
				float2 v_backgroundTexUV : TEXCOORD3;
				float4 v_color1 : TEXCOORD4;
				float4 v_color2 : TEXCOORD5;
				float3 v_normalArgs : TEXCOORD6;

			};

			

			float4 u_vertexWaveArg;
			float4 u_vertexWaveDir;
			// 1个方向的波动
			float4 Gerstner(float4 position)
			{
				float4 worldPosition = mul(unity_ObjectToWorld, position);
	
				float3 offsets;
				float3 wavedir = float3(u_vertexWaveDir.x, 0.0, u_vertexWaveDir.y);
				float2 dir = normalize(wavedir).xz;

				float amplitude = u_vertexWaveArg.x;
				float length = u_vertexWaveArg.y;
				float speed = u_vertexWaveArg.z;
				float steepness = u_vertexWaveArg.w;
				float pi = 3.14;
				// 2.0 * pi / length  = frequency
				float angle = (dot(dir, worldPosition.xz) + _Time.g * speed) * 2.0 * pi / length;
				offsets.y = amplitude * sin(angle);
				offsets.xz = dir * steepness * amplitude * cos(angle); 
				position.xyz += offsets;
	
				return position;			
			}

			float4 u_uvSpeed;
			float4 u_normalTex_ST;
			float4 u_foamTex_ST;
			float4 u_backgroundTex_ST;

			void calcUV(inout v2f o, float2 a_uv, float2 coffset, float2 roffset)
			{
				float2 uv = a_uv;
				uv.x += coffset.y;
				uv.y += roffset.y;

				float4 uvOffset = _Time.g * u_uvSpeed;

				// 计算normalTex, foamTex, backgroundTex的uv坐标
				o.v_normalTexUV = (uv + uvOffset.zw) * u_normalTex_ST.xy + u_normalTex_ST.zw;
				o.v_foamTexUV = (uv + uvOffset.xy) * u_foamTex_ST.xy + u_foamTex_ST.zw;
	
				//#if defined(BACKGROUND)
				o.v_backgroundTexUV = uv * u_backgroundTex_ST.xy + u_backgroundTex_ST.zw;
				//#endif

				o.v_color1 = float4(1, 1, 1, 1);
				o.v_color2 = float4(1, 1, 1, 1);
				o.v_normalArgs = float3 (1, 1, 1);
			}

			float u_normalMovement;
			float4 u_centerColor1;
			float4 u_edgeColor1;
			float4 u_centerColor2;
			float4 u_edgeColor2;
			float4 u_shiness;
			float u_colorProgress; 

			void calcLight(inout v2f o, float4 position)
			{
				//[-1,1]
				float blender = cos(position.x + position.z + position.y + _Time.g * 6.28 / u_normalMovement);
				//[0,1]
				o.v_normalArgs.x = (blender + 1.0) * 0.5;


				// 考虑这里是正交投影矩阵，out_pos.xy = [-1,1]
				float4 out_pos = mul(UNITY_MATRIX_MVP, position);
				// dxy2 = out_pos.x *　out_pos.x + out_pos.y *　out_pos.y
				// dxy2 = [0,2]
				float dxy2 = dot(out_pos.xy, out_pos.xy);

				float m =  dxy2/(2.0 * u_colorProgress);
				float dm = 1.0 - m;
				o.v_color1 = u_centerColor1 * dm + u_edgeColor1 * m ;
				o.v_color2 = u_centerColor2 * dm + u_edgeColor2 * m;
	
				//#if defined(SPECULAR)
				//v_normalArgs.y = u_shinessPower;
				//v_normalArgs.z =  ((1.0 - u_baseColor.a) + blender) * 0.5;
	
				float minangle = u_shiness.x * 3.14/180.0;
				float maxangle = u_shiness.y * 3.14/180.0;
				float span = maxangle - minangle;
				// dxy2/2.0 = [0,1]
				float angle = minangle + span * dxy2/2.0;
				o.v_normalArgs.y = cos(angle);

				o.v_normalArgs.z = u_shiness.z + o.v_normalArgs.y * u_shiness.w;
				//#endif
			}

			v2f vert (appdata v)
			{
				v2f o;
				float4 pos = Gerstner(v.vertex);
				o.vertex = mul(UNITY_MATRIX_MVP, pos);
				calcUV(o, v.uv, float2(0, 0), float2(0, 0));
				calcLight(o, pos);
				return o;
			}
			
			sampler2D u_normalTex;
			sampler2D u_foamTex;
			sampler2D u_backgroundTex;
			float4 u_specularColor;
			float u_shinessIntensity;
			float u_backgroundAlphaOffset;
			

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 resCol;
				float4 normal = tex2D(u_normalTex, i.v_normalTexUV);
				float2 n = float2(i.v_normalArgs.x, 1.0 - i.v_normalArgs.x);
				float diff = dot(normal.xy, n);

				float4 c = i.v_color1 * (1.0 - diff) + i.v_color2 * diff;
				float4 texcolor = tex2D(u_foamTex, i.v_foamTexUV);
				c *= texcolor;
	
				//#if defined(SPECULAR)
				float nh = clamp(i.v_normalArgs.y * dot(normal.zw, n), 0.0, 1.0);
				float spec = max(0.0, pow(nh, i.v_normalArgs.z));
				c.rgb += u_specularColor.rgb * spec *  u_shinessIntensity;
				//c.rgb += u_specularColor.rgb * spec;
				//#endif

				//#if defined(BACKGROUND)
				float4 background = tex2D(u_backgroundTex, i.v_backgroundTexUV);
				c.a *= (u_backgroundAlphaOffset + background.a);
				c.rgb = c.rgb * c.a + background.rgb * (1.0 - c.a);;
				//#endif

				resCol = c;
				return resCol; 
			}
			ENDCG
		}
	}
}
