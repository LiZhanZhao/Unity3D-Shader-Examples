Shader "Hidden/Glow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		pass { // pass 0 - blur the main texture
		    
			ZTest Always Cull Off ZWrite Off

			Fog { Mode Off }

			Blend Off
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
				
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half _BlurSpread;
				
			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half2 uv2[4] : TEXCOORD1;
			};	
				
			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
		       	o.uv = v.texcoord;
		       	
		       	o.uv2[0] = v.texcoord + _MainTex_TexelSize.xy * half2(_BlurSpread, _BlurSpread);					
				o.uv2[1] = v.texcoord + _MainTex_TexelSize.xy * half2(-_BlurSpread, -_BlurSpread);
				o.uv2[2] = v.texcoord + _MainTex_TexelSize.xy * half2(_BlurSpread, -_BlurSpread);
				o.uv2[3] = v.texcoord + _MainTex_TexelSize.xy * half2(-_BlurSpread, _BlurSpread);
				return o;
			}	
			
			fixed4 frag ( v2f i ) : COLOR
			{
				fixed4 blur = tex2D(_MainTex, i.uv ) * 0.4;
				blur += tex2D(_MainTex, i.uv2[0]) * 0.15;
				blur += tex2D(_MainTex, i.uv2[1]) * 0.15;
				blur += tex2D(_MainTex, i.uv2[2]) * 0.15;	
				blur += tex2D(_MainTex, i.uv2[3]) * 0.15;
				return blur;
			}
				 			
			ENDCG	
		}


		Pass { // pass 1 - glow
			name "Glow"
			ZTest Always Cull Off ZWrite Off
			Fog { Mode Off }
			Blend Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	
			#include "UnityCG.cginc"
	
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;

			//传入 blur 好的Texture
			uniform sampler2D _Glow;
			uniform half _GlowStrength;
			uniform float4 _GlowColorMultiplier;
			
			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
			};	
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
		       	o.uv = v.texcoord;
		       	o.uv1 = v.texcoord;
		       	
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0) {
					o.uv1.y = 1 - o.uv1.y;
				}
				#endif
				
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				half4 glow = tex2D(_Glow, i.uv1) * _GlowStrength * _GlowColorMultiplier;	
				return mainTex + glow;

				/*
				#if GLOWEFFECT_BLEND_SCREEN
				return 1 - ((1 - mainTex) * (1 - glow));
				#elif GLOWEFFECT_BLEND_MULTIPLY		
				return mainTex * glow;
				#elif GLOWEFFECT_BLEND_SUBTRACT
				return mainTex - glow;
				#else // additive
				return mainTex + glow;
				#endif
				*/
			}
			ENDCG 
		}

		
	}
}
