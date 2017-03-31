Shader "Camera/Crossfade" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "" {}
		_SrcTex("_SrcTex", 2D) = "" {}
		_DstTex("_DstTex", 2D) = "" {}
		_Alpha ("_Alpha", Range(0,1)) = 0
		
	}
	
	// Shader code pasted into all further CGPROGRAM blocks
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	sampler2D _SrcTex;
	sampler2D _DstTex;
	float _Alpha;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
#if UNITY_UV_STARTS_AT_TOP 
		o.uv = float2(v.texcoord.x, 1-v.texcoord.y);
#else
		o.uv = v.texcoord;
#endif
		return o;
	} 
	
	half4 frag(v2f i) : SV_Target 
	{
		fixed4 srcCol = tex2D(_SrcTex, i.uv);
		fixed4 dstCol = tex2D(_DstTex, i.uv);
		fixed4 col = srcCol * _Alpha + dstCol * (1 - _Alpha);
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
			//Blend SrcAlpha Zero
			//ColorMask RGBA

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		 }
	}

	
} // shader