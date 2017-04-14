Shader "Qtz/Proj/Effect/Mask-Alpha" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (1, 1, 1, 1)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Mask ("Mask ( R Channel )", 2D) = "white" {}
		
	}

	SubShader 
	{

		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off 

		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _Mask;
			fixed4 _TintColor;
			
			struct appdata_t 
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoordMask : TEXCOORD1;
			};
			
			float4 _MainTex_ST;
			float4 _Mask_ST;

				

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoordMask = TRANSFORM_TEX(v.texcoord, _Mask);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 baseCol = tex2D(_MainTex, i.texcoord);
				fixed4 maskCol = tex2D(_Mask, i.texcoordMask);
				baseCol.a *= maskCol.r;
				return i.color * _TintColor * baseCol;
			}
			ENDCG 
		}
	}
	
	
}
