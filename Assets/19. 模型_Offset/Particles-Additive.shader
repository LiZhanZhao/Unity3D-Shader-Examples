// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "xxxx/Particles-Additive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_WorldPosOffset ("World Pos Offset", Range(0.1, 3)) = 1
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	AlphaTest Greater .01
	ColorMask RGB
	Cull Off 
	Lighting Off 
	ZWrite Off
	//Offset 100, -1000000

	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				
			};
			
			float _WorldPosOffset;
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				float3 camWorldPos = _WorldSpaceCameraPos;
				float4 vertexWorldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 vertex2CamDir = camWorldPos - vertexWorldPos.xyz;
				vertex2CamDir = normalize(vertex2CamDir);
				vertexWorldPos.xyz = vertexWorldPos.xyz + vertex2CamDir * _WorldPosOffset;
				o.vertex = mul(UNITY_MATRIX_VP, vertexWorldPos);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				return col;
			}
			ENDCG 
		}
	}	
}
}
