Shader "Qtz/Proj/Custom/LightMapDiffuse"
{
    Properties {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _LightMap ("Lightmap (RGB)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.1
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

		//ZWrite Off
		//Blend SrcAlpha OneMinusSrcAlpha
		

        LOD 200
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;
            float4 _MainTex_ST;
            float4 _LightMap_ST;
            sampler2D _MainTex;
            sampler2D _LightMap;
			float _Cutoff;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };

            struct v2f {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _LightMap);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 c = _Color * tex2D(_MainTex, i.texcoord);
				clip(c.a - _Cutoff);
                c.rgb *= DecodeLightmap(tex2D(_LightMap, i.texcoord1));
				//c.rgb *= tex2D(_LightMap, i.texcoord1);
                return c;
            }
            ENDCG
        }
    }
}
