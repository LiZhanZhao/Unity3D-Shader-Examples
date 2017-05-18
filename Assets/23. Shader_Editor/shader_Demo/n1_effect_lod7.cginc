#include "UnityCG.cginc"

half4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;
half4 _MainTexMove;
sampler2D _SubTex;
half4 _SubTex_ST;
half4 _SubTexMove;
sampler2D _MaskTex;
half4 _MaskTex_ST;

half _Cutoff;

#if NORMALMAP
	sampler2D _BumpMap;
#endif

#if VERTEX_WAVE
	sampler2D _VertexWaveMask;
	sampler2D _VertexWaveTex;
	half4 _VertexWaveCoord;
	half4 _VertexWaveForce;
#endif

#if TURBULENCE
	sampler2D _Blend_Texture;
	half4 _Blend_Texture_ST;
	sampler2D _Blend_Texture01;
	half4 _Blend_Texture01_ST;
	half4 _Color02;
	half4 _Color03;
	half4 _Speed_Brightness;
#endif

#if DISSOLVE_MODEL
	sampler2D _Dissolve_Texture;
	sampler2D _Dissolve_ColorTex;
	half4 _Dissolve_Texture_ST;
	half4 _DissolveParameters;
#endif

#if DISSOLVE_PARTICLE
	half4 _DissolveParameters;
#endif

#if RIM_LIGHT
	half4 _RimColor;
	half4 _RimParameters;
	#if RIM_TEXTURE
		sampler2D _Rim_Texture;
	#endif
#endif

struct appdata_fx {
	half4 vertex:POSITION;
	half4 texcoord:TEXCOORD;
	half4 color:COLOR;

	half4 normal:NORMAL;
	#if VERTEX_WAVE || NORMALMAP
		half4 tangent:TANGENT;
	#endif
};

struct v2f_fx {
	half4 position:SV_POSITION;
	half4 uv:TEXCOORD;
	#if TWO_LAYER
		half4 uv1:TEXCOORD1;
	#endif
	#if MASK_TEXTURE
		half4 uv_mask:TEXCOORD2;
	#endif
	#if TURBULENCE
		half4 uv_blend:TEXCOORD3;
	#endif
	half4 vcolor : TEXCOORD4;
	#if NORMALMAP
		half4 tangentToWorld[3]:TEXCOORD5;
	#else
		half4 worldNormal:TEXCOORD5;
	#endif
	#if RIM_LIGHT
		half4 viewDir:TEXCOORD8; // view direction
	#endif
};

half3x3 CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
	// For odd-negative scale transforms we need to flip the sign
	half sign = tangentSign * unity_WorldTransformParams.w;
	half3 binormal = cross(normal, tangent) * sign;
	return half3x3(tangent, binormal, normal);
}

v2f_fx vert_fx (appdata_fx v) {
	v2f_fx o;
	UNITY_INITIALIZE_OUTPUT(v2f_fx, o);
	#if VERTEX_WAVE
		half4 v_mask = tex2Dlod(_VertexWaveMask, half4(v.texcoord.xy, 0, 0) );
		half2 wuv = v.texcoord.xy * _VertexWaveCoord.xz + _VertexWaveCoord.yw * _Time.y;
		half4 v_wave = tex2Dlod(_VertexWaveTex, half4(wuv, 0, 0) );
		half w = lerp(0, v_wave.r* 2 - 1, v_mask.r);
		half3 binormal = cross(v.normal.xyz, v.tangent.xyz);
		half3 ww = w * _VertexWaveForce.xyz;
		v.vertex.xyz += ww.x * v.normal.xyz + ww.y * v.tangent.xyz + ww.z * binormal;
	#endif


	#if NORMALMAP
		float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
		half3x3 tangentToWorld = CreateTangentToWorldPerVertex(v.normal, tangentWorld.xyz, tangentWorld.w);
		o.tangentToWorld[0].xyz = tangentToWorld[0];
		o.tangentToWorld[1].xyz = tangentToWorld[1];
		o.tangentToWorld[2].xyz = tangentToWorld[2];
	#else
		o.worldNormal.xyz = v.normal.xyz;
	#endif

	o.position = mul(UNITY_MATRIX_MVP, v.vertex);
	o.uv = half4((v.texcoord.xy+ _MainTex_ST.zw) * _MainTex_ST.xy, 0, 0);
	#if TWO_LAYER
		o.uv1 = half4((v.texcoord.xy+ _SubTex_ST.zw) * _SubTex_ST.xy, 0, 0);
	#endif
	#if ANIMATED_TEXTURE
		o.uv = half4(o.uv.xy + _MainTexMove.xy * _Time.y, 0, 0);
		#if TWO_LAYER
			o.uv1 = half4(o.uv1.xy + _SubTexMove.xy * _Time.y, 0, 0);
		#endif
	#endif

	#if MASK_TEXTURE
		o.uv_mask = half4((v.texcoord.xy+ _MaskTex_ST.zw) * _MaskTex_ST.xy, v.texcoord.zw);
	#endif

	#if TURBULENCE
		o.uv_blend.xy = TRANSFORM_TEX(v.texcoord, _Blend_Texture);
		o.uv_blend.zw = TRANSFORM_TEX(v.texcoord, _Blend_Texture01);
		o.uv_blend.yw += _Speed_Brightness.xy * _Time.x;
	#endif
	#if RIM_LIGHT
		half4 posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.viewDir.xyz = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
	#endif
	o.vcolor = v.color * _Color;
	o.vcolor.rgb *= 2;
	o.vcolor.a = min(1, o.vcolor.a);
	return o;
}

half4 frag_fx(v2f_fx i):COLOR {
	half4 mainUV = i.uv;
	#if TWO_LAYER
		half4 mainUV1 = i.uv1;
	#endif
	half2 off_uv = i.uv.xy;

	half4 main = tex2D (_MainTex, mainUV.xy);
	#if TWO_LAYER
		half4 sub = tex2D (_SubTex, mainUV1.xy);
		main = main * sub;
	#endif

	half3 normal = 0;
	#if NORMALMAP
		half4 n = tex2D(_BumpMap, mainUV);
		normal = UnpackNormal(n);
		normal = normal.x * i.tangentToWorld[0].xyz + normal.y * i.tangentToWorld[1].xyz + normal.z * i.tangentToWorld[2].xyz;
	#else
		normal = i.worldNormal.xyz;
	#endif

	#if TURBULENCE
		half4 blendColor = tex2D(_Blend_Texture, i.uv_blend.xy) * _Color02;
		half4 blendColor1 = tex2D(_Blend_Texture01, i.uv_blend.zw) * _Color03;
		half4 blend = main * blendColor1 * blendColor * _Speed_Brightness.w;
		main = main + blend;
		main = main * _Speed_Brightness.z;
	#endif

	#if DISSOLVE_MODEL
		half dissolve = tex2D (_Dissolve_Texture, mainUV.xy * _DissolveParameters.w).r;
		dissolve -= _DissolveParameters.x;

		// clip(dissolve - 0.1);
		dissolve = smoothstep(0.1, _DissolveParameters.y ,dissolve);
		half3 dissolveColor = tex2D (_Dissolve_ColorTex, half2(dissolve, 0.5)).rgb;
		main.rgb = lerp(dissolveColor * dissolve * _DissolveParameters.z, main.rgb, dissolve);
		main.a = dissolve;
		// return main.a;
	#elseif DISSOLVE_PARTICLE
		half ds = saturate(1.0 - _DissolveParameters.y);
		ds = smoothstep(ds,  ds + 0.2, main.a);
		half da = (1-i.vcolor.a) * _DissolveParameters.x;
		main.a += ds - da;
	#endif


	#if RIM_LIGHT
		half ndv = 1-abs(dot(i.viewDir, normal));
		half4 rimColor = _RimColor;
		#if RIM_TEXTURE
			rimColor *= tex2D (_Rim_Texture, mainUV.xy * _RimParameters.w);
		#endif
		half3 rim = pow(ndv, _RimParameters.x) * rimColor.rgb * _RimParameters.y;
		main.rgb += rim;
	#endif

	#if MASK_TEXTURE
		half4 mask = tex2D (_MaskTex, i.uv_mask.xy);
		main = main * mask;
	#endif


	half4 c = main;
	c *= i.vcolor;

	// half mask_a = c.a;
	#if BLEND_ADD
		c = half4(c.rgb * c.a, c.a * 0.5);
		c = 0;
	#endif
	#if BLEND_MULT
		c = half4(lerp(c.rgb, 1, 1-c.a), 1);
	#endif
	return c;
}