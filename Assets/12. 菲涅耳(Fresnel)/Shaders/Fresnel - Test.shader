
Shader "Fresnel/Test" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Fresnel0 ("fresnel0", Float) = 0.1
		_Color ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader 
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _Fresnel0;

			struct vIN
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct vOUT
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				
			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.viewDir = WorldSpaceViewDir(v.vertex);

				return o;
			}

			float4 frag(vOUT i) :  COLOR
			{  
				float4 col = tex2D(_MainTex, i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				fixed3 normViewDir = normalize(i.viewDir);

				half nDotView = dot(fixed3(0, 1, 0), normViewDir);

				half fresnel = _Fresnel0 + (1.0 - _Fresnel0) * pow( (1.0 - nDotView ), 5.0);

				fresnel = max(0.0, fresnel - .1);

				return lerp(col,_Color, fresnel);

			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
