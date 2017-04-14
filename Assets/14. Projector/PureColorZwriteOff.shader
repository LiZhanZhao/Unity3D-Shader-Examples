Shader "Qtz/Proj/Custom/PureColorZwriteOff"
{
	Properties
	{
		_MainColor ("Tint", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags 
		{
			"Queue"="Transparent" 
			"RenderType"="Transparent" 
		}
		ZWrite Off
		//LOD 100
		
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _MainColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _MainColor;
			}
			ENDCG
		}
	}
}
