Shader "N1/Effect/FX Transparent" {
	Properties {
		_Color ("Tint Color", Color) = (0.5,0.5,0.5,1)
		_AlphaBoost ("Alpha Boost", float) = 1
		_MainTex ("Main Texture (RGBA)", 2D) = "white" {}
		_MainTexMove ("Main Texture Movement (XY, Speed, ZW, Scale)", Vector) = (0,0,1,1)
		_BumpMap ("Normal Map", 2D) = "white" {}
		_SubTex ("Secondary Texture (RGBA)", 2D) = "white" {}
		_SubTexMove ("Main Texture Movement (XY, Speed, ZW, Scale)", Vector) = (0,0,1,1)
		_MaskTex ("Overall Mask (Gray)", 2D) = "white"{}

		//VertexWave
		_VertexWaveMask("Vertex Wave Mask", 2D) = "white"
		_VertexWaveTex("Vertex Wave Map", 2D)="white"
		_VertexWaveCoord("Vertex Wave Coord", Vector) = (1, 0, 1, 0)
		_VertexWaveForce("Vertex Wave Amp(xyz-normal, tangent and binormal)", Vector) = (0.1, 0.1, 0.1, 1)

		//Turbulence
		_Blend_Texture("Blend_Texture_01", 2D) = "white" {}
		_Color02("Color", Color) = (1,1,1,1)
		_Blend_Texture01("Blend_Texture_02", 2D) = "black" {}
		_Color03("Color", Color) = (1,1,1,1)
		_Speed_Brightness("X:Texture1Speed, Y:Texture2Speed, Z:MainBrightness, W:BlendBrightness", Vector) = (1,1,1,1)

		//Dissolve
		_Dissolve_Texture("Dissolve Texture", 2D) = "white" {}
		_Dissolve_ColorTex("Color Texture", 2D) = "white" {}
		_DissolveParameters("X:Dissolve Progress", Vector) = (0.5, 1, 1, 1)

		//RimLight
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimParameters("X:Dissolve Progress", Vector) = (0.5, 1, 1, 1)
		_Rim_Texture("Rim Texture", 2D) = "white" {}


		//blend modes etc
		[HideInInspector] _Mode ("_mode", float) = 0
		[HideInInspector] _SrcBlend ("_srcBlend", float) = 1
		// [HideInInspector] _SrcAlphaBlend ("_srcAlphaBlend", float) = 1
		[HideInInspector] _DstBlend ("_dstBlend", float) = 0
		// [HideInInspector] _DstAlphaBlend ("_dstAlphaBlend", float) = 1
		[HideInInspector] _BlendOp ("_blendOp", float) = 0
		[HideInInspector] _Culling ("_cull", float) = 0
		[HideInInspector] _ZTest ("_ztest", float) = 0
		[HideInInspector] _Queue ("_queue", float) = 3500
	}
	SubShader {
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent+200" "PreviewType"="Plane"}
		LOD 100
		// Blend [_SrcBlend] [_DstBlend], [_SrcAlphaBlend] [_DstAlphaBlend]
		Blend [_SrcBlend] [_DstBlend]
		BlendOp [_BlendOp]
		Cull [_Culling]
		ZTest [_ZTest]
		Fog {Mode Off}
		ZWrite Off

		Pass {
			Tags { "LightMode" = "Always" }
			CGPROGRAM
			#pragma target 3.0
			#pragma shader_feature TWO_LAYER
			#pragma shader_feature NORMALMAP
			#pragma shader_feature ANIMATED_TEXTURE
			#pragma shader_feature MASK_TEXTURE
			#pragma shader_feature VERTEX_WAVE
			#pragma shader_feature TURBULENCE
			#pragma shader_feature DISSOLVE_MODEL
			#pragma shader_feature DISSOLVE_PARTICLE
			#pragma shader_feature RIM_LIGHT
			#pragma shader_feature RIM_TEXTURE

			#pragma vertex vert_fx
			#pragma fragment frag_fx

			#include "n1_effect_lod7.cginc"

			ENDCG
		}
	}
	FallBack "Diffuse"
	CustomEditor "FX_EffectShaderGUI"
}
