Shader "ImageEffect/Unlit/GaussianBlue" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	CGINCLUDE
		#include "UnityCG.cginc"
		#pragma target 3.0

		
		static const half curve[7] = { 0.0205, 0.0855, 0.232, 0.324, 0.232, 0.0855, 0.0205 };

		static const half4 curve4[7] = { half4(0.0205,0.0205,0.0205,0), 
										 half4(0.0855,0.0855,0.0855,0), 
										 half4(0.232,0.232,0.232,0),
										 half4(0.324,0.324,0.324,1), 
										 half4(0.232,0.232,0.232,0), 
										 half4(0.0855,0.0855,0.0855,0), 
										 half4(0.0205,0.0205,0.0205,0) };
										 
		
		struct v2f_withBlurCoords8 
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			half4 offs : TEXCOORD1;
		};	

		sampler2D _MainTex;
		//  if it's a 1k x 1k texture, both x and y will be 1.0/1024.0
		uniform half4 _MainTex_TexelSize;

		uniform float _BlurSize;


		v2f_withBlurCoords8 vertBlurHorizontal (appdata_img v)
		{
			v2f_withBlurCoords8 o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			// 水平方向的偏差值
			o.offs = half4(_MainTex_TexelSize.xy * half2(1.0, 0.0) * _BlurSize,1,1);

			return o; 
		}
		
		v2f_withBlurCoords8 vertBlurVertical (appdata_img v)
		{
			v2f_withBlurCoords8 o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			o.offs = half4(_MainTex_TexelSize.xy * half2(0.0, 1.0) * _BlurSize,1,1);
			 
			return o; 
		}	

		half4 fragBlur8 ( v2f_withBlurCoords8 i ) : SV_Target
		{
			half2 uv = i.uv.xy; 
			half2 netFilterWidth = i.offs.xy;  

			// 这里从中心点偏移3个间隔，从最左边或者是最上边开始进行加权累加
			half2 coords = uv - netFilterWidth * 3.0;  
			
			half4 color = 0;
			// 加权平均
  			for( int i = 0; i < 7; i++ )  
  			{   
				half4 tap = tex2D(_MainTex, coords);
				// 像素值乘上对应的权值
				color += tap * curve4[i];
				// 移到下一个像素
				coords += netFilterWidth;
  			}
			return color;
		}

	ENDCG


	SubShader {	
		ZTest Off Cull Off ZWrite Off Blend Off
		Fog {Mode off}
		
		
		
		Pass 	//0 Blur Vertical
		{ 	
			CGPROGRAM			
			#pragma vertex vertBlurVertical
			#pragma fragment fragBlur8
			//#pragma fragmentoption ARB_precision_hint_fastest 			
			ENDCG		 
		}
		
		Pass 	//1 Blur Horizontal
		{ 	
			CGPROGRAM			
			#pragma vertex vertBlurHorizontal
			#pragma fragment fragBlur8
			//#pragma fragmentoption ARB_precision_hint_fastest 			
			ENDCG		 
		}
	}
	Fallback off
}
