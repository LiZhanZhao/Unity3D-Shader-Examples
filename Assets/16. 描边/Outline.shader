// ����1
// Ӧ����Ҫ��UNITY_MATRIX_P����ת�þ���ȥ�任������Ϊʲô�����أ�
// ���һ������������������ôת��������ȣ�������ת�þ͵���ԭ���ľ���UNITY_MATRIX_P == ��������
// ��C#�ϴ�ӡ�ˣ�Camera.main.projectionMatrix.inverse, Camera.main.projectionMatrix.transpose,������ͬ��

// Ŀǰ��⣺
// ������UNITY_MATRIX_P����ת�ñ任���ߣ��õ��ķ��߿��ܻ�ƫ�ˣ����ǣ����ڷ���ƫ�˲���Ӱ������������չ
// ���ԣ������ں����ߵķ����Ƿ���ȷ��

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
			// ����1
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			float2 offset = TransformViewToProjection(norm.xy); //float2 offset =  mul((float2x2)UNITY_MATRIX_P, norm.xy);
			o.pos.xy += offset * o.pos.z * _Outline;


			// ����2
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
