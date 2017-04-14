Shader "Unlit/HDSea"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		WAVE_HEIGHT ("WAVE_HEIGHT", float) = 10
		WAVE_MOVEMENT ("WAVE_MOVEMENT", float) = 10
		u_1DivLevelWidth ("u_1DivLevelWidth", float) = 1
		u_1DivLevelHeight ("u_1DivLevelHeight", float) = 1
		u_lightPos ("u_lightPos", Vector) = (0, 0, 0 ,0)
		SHORE_DARK ("SHORE_DARK", Color) = (1, 1, 1, 1)
		//SHORE_LIGHT
		SHORE_LIGHT ("SHORE_LIGHT", Color) = (1, 1, 1, 1)
		//SEA_DARK
		SEA_DARK ("SEA_DARK", Color) = (1, 1, 1, 1)
		//SEA_LIGHT
		SEA_LIGHT ("SEA_LIGHT", Color) = (1, 1, 1, 1)
		normal0 ("normal0", 2D) = "white" {}
		u_reflectionFactor ("u_reflectionFactor", float) = 1
		lightmapTex ("lightmap1", 2D) = "white" {}
		foam ("foam", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			//#define USE_FOAM
			//#define LIGHTMAP
			//#define REFLECTION
			/*
			#ifndef SIMPLE
				#define LIGHTMAP
				#define REFLECTION
			#endif // SIMPLE

			#ifdef FOAM
				#ifndef SIMPLE
					#define USE_FOAM
				#endif // SIMPLE
			#endif // FOAM
			*/
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

				// r = foam
				// g = wave
				// b = wind
				// a = depth
				float4 color : COLOR;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				
				float4 v_wave : TEXCOORD1;
				float2 v_bumpUv1 : TEXCOORD2;

			//#ifdef USE_FOAM
				float2 v_foamUv : TEXCOORD3;
			//#endif

			//#ifdef LIGHTMAP
				float2 v_worldPos : TEXCOORD4;
			//#endif

				float3 v_darkColor : TEXCOORD5;
				float3 v_lightColor : TEXCOORD6;
				float v_reflectionPower : TEXCOORD7;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			

			//------------
			float WAVE_HEIGHT;
			float WAVE_MOVEMENT;
			float u_1DivLevelWidth;
			float u_1DivLevelHeight;
			float4 u_lightPos;

			float4 SHORE_DARK;
			float4 SHORE_LIGHT;
			float4 SEA_DARK;
			float4 SEA_LIGHT;

			sampler2D normal0;
			float u_reflectionFactor;

			
		//#ifdef LIGHTMAP
			sampler2D lightmapTex;
		//#endif

		//#ifdef USE_FOAM
			sampler2D foam;
		//#endif

			v2f vert (appdata v)
			{
				/*
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
				*/

				// ----------------------------
				v2f o;
				v.color = fixed4(1, 1, 0.3, 0.5);
				float4 pos = v.vertex;

				// Calculate new vertex position with wave
				float animTime = v.uv.y + _Time.g;

				//float scaleFactor = 1.0 - (cos(u_time * 0.2) * 0.5 + 0.5) * 0.1;
				//animTime += sin((a_pos.x + a_pos.y * sin((u_time + a_pos.x) * 0.01)) * 0.4 * scaleFactor + u_time * 0.2) * 0.5 + 0.5;

				float wave = cos(animTime);
				float waveHeightFactor = (wave + 1.0) * 0.5;
				//pos.y += WAVE_MOVEMENT * waveHeightFactor * v.color.g * v.color.b;
				//pos.z += wave * WAVE_HEIGHT * v.color.b;
				pos.z += WAVE_MOVEMENT * waveHeightFactor * v.color.g * v.color.b;
				pos.y += wave * WAVE_HEIGHT * v.color.b;

				o.vertex = mul(UNITY_MATRIX_MVP, pos);

				// Water alpha
				float maxValue = 0.55;//0.5;
				o.v_wave.x = 1.0 - (v.color.a - maxValue) * (1.0 / maxValue);
				o.v_wave.x = o.v_wave.x * o.v_wave.x;
				o.v_wave.x = o.v_wave.x * 0.8 + 0.2;
				o.v_wave.x -= wave * v.color.b * 0.1;
				o.v_wave.x = min(1.0, o.v_wave.x);

				// UV coordinates
				//float2 texcoordMap = float2(v.vertex.x * u_1DivLevelWidth, v.vertex.y * u_1DivLevelHeight) * 4.0;
				float2 texcoordMap = float2(v.vertex.x * u_1DivLevelWidth, v.vertex.z * u_1DivLevelHeight) * 4.0;
				o.v_bumpUv1.xy = texcoordMap + float2(0.0, _Time.g * 0.005) * 1.5;			// bump uv
			//#ifdef USE_FOAM
				o.v_foamUv = (texcoordMap + float2(_Time.g * 0.005, _Time.g * 0.005)) * 5.5;
			//#endif

				//float3 lightDir = normalize(float3(-1.0, 1.0, 0.0));
				float3 lightDir = normalize(float3(-1.0, 0.0, 1.0));
				float3 lightVec = normalize(u_lightPos.xyz - pos.xyz);
				o.v_wave.z = (1.0 - abs(dot(lightDir, lightVec)));
				o.v_wave.z = o.v_wave.z * 0.2 + (o.v_wave.z * o.v_wave.z) * 0.8;
				o.v_wave.z = clamp(o.v_wave.z + 1.1 - (length(u_lightPos.xyz - pos.xyz) * 0.008), 0.0, 1.0);
				o.v_wave.w = (1.0 + (1.0 - o.v_wave.z * 0.5) * 7.0);

			//#ifdef LIGHTMAP
				//o.v_worldPos = float2(pos.x * u_1DivLevelWidth, pos.y * u_1DivLevelHeight);
				o.v_worldPos = float2(pos.x * u_1DivLevelWidth, pos.z * u_1DivLevelHeight);
			//#endif


				// Blend factor for normal maps
				//o.v_wave.y = (cos((v.vertex.x + _Time.g) * v.vertex.y * 0.003 + _Time.g) + 1.0) * 0.5;
				o.v_wave.y = (cos((v.vertex.x + _Time.g) * v.vertex.z * 0.003 + _Time.g) + 1.0) * 0.5;



				// Calculate colors
				float blendFactor = 1.0 - min(1.0, v.color.a * 1.6);
	
				float tx = v.vertex.x * u_1DivLevelWidth - 0.5;
				//float ty = v.vertex.y * u_1DivLevelHeight - 0.5;
				float ty = v.vertex.z * u_1DivLevelHeight - 0.5;
	
				float tmp = (tx * tx + ty * ty) / (0.75 * 0.75);
				float blendFactorMul = step(1.0, tmp);
				tmp = pow(tmp, 3.0);
				// Can't be above 1.0, so no clamp needed
				float blendFactor2 = max(blendFactor - (1.0 - tmp) * 0.5, 0.0);
				blendFactor = lerp(blendFactor2, blendFactor, blendFactorMul);

				o.v_darkColor = lerp(SHORE_DARK, SEA_DARK, blendFactor).rgb;
				o.v_lightColor = lerp(SHORE_LIGHT, SEA_LIGHT, blendFactor).rgb;

				o.v_reflectionPower = ((1.0 - v.color.a) + blendFactor) * 0.5;//blendFactor;
				// Put to log2 here because there's pow(x,y)*z in the fragment shader calculated as exp2(log2(x) * y + log2(z)), where this is is the log2(z)
				o.v_reflectionPower = log2(o.v_reflectionPower);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				//return col;

				// ---------------------------
				fixed4 resCol;
				float4 normalMapValue = tex2D(normal0, i.v_bumpUv1.xy);
				resCol = float4(lerp(i.v_lightColor, i.v_darkColor, (normalMapValue.x * i.v_wave.y) + (normalMapValue.y * (1.0 - i.v_wave.y))), i.v_wave.x)
				//#ifdef REFLECTION
				+ exp2(log2(((normalMapValue.z * i.v_wave.y) + (normalMapValue.w * (1.0 - i.v_wave.y))) * i.v_wave.z) * i.v_wave.w + i.v_reflectionPower) * u_reflectionFactor;
				//#else
				;
				//#endif
				//#ifdef USE_FOAM
				float3 lightmapValue = tex2D(lightmapTex, i.v_worldPos.xy).rga * float3(tex2D(foam, i.v_foamUv).r * 1.5, 1.3, 1.0);
				resCol = lerp(resCol, float4(0.92, 0.92, 0.92, lightmapValue.x), min(0.92, lightmapValue.x)) * lightmapValue.yyyz;
				//#endif

				return resCol;

				//resCol = tex2D(lightmapTex, i.v_worldPos.xy);
				//return resCol;


			}
			ENDCG
		}
	}
}
