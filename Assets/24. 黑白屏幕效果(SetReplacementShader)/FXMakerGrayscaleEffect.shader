Shader "FXMakerGrayscaleEffect" {
Properties {
	_MainTex("Texture", 2D) = "white" {}
	_GreyX("Grey Affect X", Range(0, 1)) = 0.299
	_GreyY("Grey Affect Y", Range(0, 1)) = 0.587
	_GreyZ("Grey Affect Z", Range(0, 1)) = 0.114
}

SubShader{
	Tags{ "RenderType" = "Effect" }
	Pass{
		Fog{ Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
				//#pragma fragmentoption ARB_precision_hint_fastest 
		#include "UnityCG.cginc"
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		fixed _GreyX, _GreyY, _GreyZ;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) : COLOR
		{
			fixed4 original = tex2D(_MainTex, i.uv);
			fixed grayscale = dot(original.rgb, fixed3(_GreyX, _GreyY, _GreyZ));
			fixed4 grayscaleCol = fixed4(grayscale, grayscale, grayscale, original.a);
			fixed4 output = grayscaleCol;
			//return output;
			return fixed4(0.5, 0, 0, 1);
		}
		ENDCG

	}
}

SubShader {
	Tags{ "RenderType" = "Opaque" }

	Pass {
		Fog { Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		//#pragma fragmentoption ARB_precision_hint_fastest 
		#include "UnityCG.cginc"
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		
		fixed _GreyX, _GreyY, _GreyZ;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 original = tex2D(_MainTex, i.uv);
			fixed grayscale = dot(original.rgb, fixed3(_GreyX, _GreyY, _GreyZ));
			fixed4 grayscaleCol = fixed4(grayscale, grayscale, grayscale, original.a);
			fixed4 output = grayscaleCol;
			return output;
		}
		ENDCG

	}
	
	
}

//Fallback off

}