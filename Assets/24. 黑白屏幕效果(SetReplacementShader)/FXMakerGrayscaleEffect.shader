
// ���ɻ�ɫͼ���ͱ����Ч����һЩ����

Shader "FXMakerGrayscaleEffect" {
Properties {

}

SubShader{
	Tags{ "RenderType" = "Effect" }
	Pass{

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

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			return o;
		}

		fixed4 frag(v2f i) : COLOR
		{
			return fixed4(0, 0, 0, 0);
		}
		ENDCG

	}
}
SubShader{
			Tags{ "RenderType" = "Opaque" }
			Pass{

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

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			return o;
		}

		fixed4 frag(v2f i) : COLOR
		{
			return fixed4(1, 0, 0, 0);
		}
			ENDCG

		}
	}
//Fallback off

}