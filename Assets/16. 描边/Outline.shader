// 方法1
// 应该是要用UNITY_MATRIX_P的逆转置矩阵去变换，这样为什么不用呢？
// 如果一个矩阵是正交矩阵，那么转置与逆相等，所以逆转置就等于原来的矩阵，UNITY_MATRIX_P == 正交矩阵？
// 在C#上打印了，Camera.main.projectionMatrix.inverse, Camera.main.projectionMatrix.transpose,不是相同的

// 目前理解：
// 不利用UNITY_MATRIX_P的逆转置变换法线，得到的法线可能会偏了，但是，现在法线偏了并不影响轮廓向外扩展
// 所以，并不在乎法线的方向是否正确。

Shader "Custom/OutLine" {Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		//_Outline ("Outline width", Range (0.0, 0.03)) = .005
		_Outline ("Outline width", Range (0.0, 0.5)) = .005
		_MainTex ("Base (RGB)", 2D) = "white" { }
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};
		struct v2f {
			float4 pos : POSITION;
			float4 color : COLOR;
		};
		uniform float _Outline;
		uniform float4 _OutlineColor;
		v2f vert(appdata v) {
			v2f o;
			// 方法1
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			float2 offset = TransformViewToProjection(norm.xy); //float2 offset =  mul((float2x2)UNITY_MATRIX_P, norm.xy);
			o.pos.xy += offset * o.pos.z * _Outline;


			// 方法2
			//float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
			//float3 viewNorm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			//float3 offset =  normalize(viewNorm) * _Outline;
			//viewPos.xyz += offset;
			//o.pos = mul(UNITY_MATRIX_P, viewPos);


			o.color = _OutlineColor;
			return o;
		}
	ENDCG
	SubShader {
		Tags{ "RenderType"="Transparent" "Queue"="Transparent" }
		/*
		Pass {
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			half4 frag(v2f i) :COLOR {
				return i.color;
			}
			ENDCG
		}
		*/

		Pass {  
			
			//Blend SrcFactor DstFactor, SrcFactorA DstFactorA:
			//BlendOp OpColor, OpAlpha
			
			Blend SrcAlpha OneMinusSrcAlpha, Zero Zero
			BlendOp Add, Add
			
			//ZWrite On

		CGPROGRAM
			#pragma vertex vert2
			#pragma fragment frag2
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f2 {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f2 vert2 (appdata_t v)
			{
				v2f2 o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag2 (v2f2 i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				return col;
				//return fixed4(col.rgb, 0.1);
				
				
			}
		ENDCG
		}

		
		Pass {
			Blend DstAlpha OneMinusDstAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			half4 frag(v2f i) :COLOR {
				return i.color;
			}
			ENDCG
		}
		
		
	}
	Fallback "Diffuse"
}
