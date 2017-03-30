Shader "Camera/Crossfade" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "" {}
		_Color ("Target Color", Color) = (0,0,0,1)
		
	}
	
	// Shader code pasted into all further CGPROGRAM blocks
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	fixed4 _Color;
	sampler2D _bgTex;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	half4 frag(v2f i) : SV_Target 
	{
		float4 col = tex2D(_MainTex, i.uv);
		col.a = col.a * _Color.a;
		return col;
	}

	ENDCG 
	
	Subshader {
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend SrcAlpha Zero
			//ColorMask RGBA

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		 }
	}

	
} // shader