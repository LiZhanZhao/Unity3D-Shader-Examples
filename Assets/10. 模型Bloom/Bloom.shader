Shader "Hidden/Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// pass 0 - blur the main texture
		pass { 
		    
			ZTest Always Cull Off ZWrite Off Blend Off
		
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

		// pass 1 - glow
		Pass { 
			name "Glow"
			ZTest Always Cull Off ZWrite Off 
			Blend Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	
			#include "UnityCG.cginc"
	
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform float _GlowAlpha;
			uniform float4 _GlowColorMultiplier;
			uniform sampler2D _Blur;
			
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
				// 方法1
				/*
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				half4 glow = tex2D(_Blur, i.uv1) * _GlowColorMultiplier;	
				//根据alpha插值
				// lerp(a,b f) = (1-f) * a + b * f  ==> f = 0 -> a, f = 1 -> b
				fixed3 tempCol = lerp(mainTex.rgb, glow.rgb, _GlowAlpha) * glow.a;
				fixed4 res = fixed4(tempCol, mainTex.a);
				return res;
				*/

				
				// 方法二
				///*
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				half4 glow = tex2D(_Blur, i.uv1);
				fixed4 res;

				// 经过pass2，这里就是把alpha为1的，变成mainTex
				res.rgb = lerp(glow.rgb, mainTex.rgb, glow.a );
				res.rgb = lerp(mainTex.rgb, res.rgb, glow.a * _GlowColorMultiplier.a);
				res.a = mainTex.a;

				return res;
				//*/

				
			}
			ENDCG 
		}

		// pass 2 - modify glow
		Pass { 
			name "Modify"
			ZTest Always Cull Off ZWrite Off 
			//Blend Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	
			#include "UnityCG.cginc"
	
			uniform sampler2D _MainTex;
			uniform float4 _GlowColorMultiplier;
			
			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				
			};		
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
		       	o.uv = v.texcoord;
		       	
				
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				// 方法二
				
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				fixed4 res;
				// 颜色从外->内，慢慢加深
				res.rgb =  _GlowColorMultiplier.rgb * mainTex.a;
				// 主要就是把原来从外->内的alpha变大的，变成，从内->外的alpha变大
				res.a = 1 - mainTex.a;
				return res;

				
				
				
			}
			ENDCG 
		}
	}
}
