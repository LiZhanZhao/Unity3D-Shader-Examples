Shader "Toon/Outline" {
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range (.002, 0.3)) = 0.03
		_MainTex ("Base (RGB)", 2D) = "white" { }
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 pos : POSITION;
		float4 color : COLOR;
		half2 texcoord : TEXCOORD0;
	};
	
	uniform float _Outline;
	uniform float4 _OutlineColor;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform float4 _Color;
	
	v2f vertMain(appdata v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	float4 fragMain(v2f i) : COLOR
	{
		float4 col = _Color * tex2D(_MainTex, i.texcoord);
		return col;
	}

	v2f vertOutLine(appdata v) {
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		float2 offset = TransformViewToProjection(norm.xy);
		o.pos.xy += offset * o.pos.z * _Outline;
		o.color = _OutlineColor;
		return o;
	}

	half4 fragOutLine(v2f i) :COLOR{ return i.color; }
		
	ENDCG

	SubShader {
		Pass {
			// 卡通效果
			Cull Front
			// 描边效果
			//ZWrite Off
			CGPROGRAM
			#pragma vertex vertOutLine
			#pragma fragment fragOutLine
			ENDCG
		}

		Pass{
			CGPROGRAM
			#pragma vertex vertMain
			#pragma fragment fragMain
			ENDCG

		}
	}
}
