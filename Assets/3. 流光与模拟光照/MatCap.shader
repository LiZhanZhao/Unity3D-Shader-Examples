Shader "Q5/Proj/Custom/MatCap"
{
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MatCap ("Mat (RGB)", 2D) = "white" {}
        _Strongth ("Strongth", Range(0, 2)) = 1
        //_Rotate ("Rotate", float) = 1
        _LightTex ("Light Texture(A)", 2D) = "black" {}
        _MaskTex ("Mask Texture(A)", 2D) = "black" {}
        _Brightness ("Brightness", Range(0, 5)) = 1
        _uSpeed ("U Speed", float) = 0
        _vSpeed ("V Speed", float) = 0
    }

    SubShader {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 200
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _MatCap;
            float _Strongth;
            //float _Rotate;
            float4 _Color;
            float4 _MainTex_ST;

            uniform float4 _TimeEditor;
            sampler2D _LightTex;
            sampler2D _MaskTex;
            float4 _LightTex_ST;
            float _uSpeed;
            float _vSpeed;
            float _Brightness;

            struct v2f {
                float4 pos    : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float2 cap    : TEXCOORD1;
                float2 light  : TEXCOORD2;
            };

            /*
            float2 rotate2d (in float2 v, in float a) {
                float sinA = sin(a);
                float cosA = cos(a);
                return float2(v.x * cosA - v.y * sinA, v.y * cosA + v.x * sinA);
            }

            float2 rotmatrix (in float a) {
                float sinA = sin(a);
                float cosA = cos(a);
                return float4(cosA, sinA, -sinA, cosA);
            }

            float moveSpeed(float xSpeed) {
                return fmod(_Time.y * xSpeed, 1);
            }

            float2 uvSpeed(float uSpeed, float vSpeed) {
                return float2(moveSpeed(uSpeed), moveSpeed(vSpeed));
            }
            */

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                half2 capCoord;
                capCoord.x = dot(UNITY_MATRIX_IT_MV[0].xyz, v.normal);
                capCoord.y = dot(UNITY_MATRIX_IT_MV[1].xyz, v.normal);
                o.cap = capCoord * 0.5 + 0.5;
                //o.cap = mul(capCoord - float2(0.5, 0.5), rotmatrix(_Rotate)) + float2(0.5, 0.5);
                //o.cap = rotate2d(o.cap, _Rotate);
                o.light = TRANSFORM_TEX(v.texcoord, _LightTex);// * uvSpeed(_uSpeed, _vSpeed);
                float4 moveUv = _Time + _TimeEditor;
                o.light = (o.light + moveUv.g * float2(_uSpeed, _vSpeed));
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 mc = tex2D(_MatCap, i.cap);
                fixed4 lightC = tex2D(_LightTex, i.light) * _Brightness;
                fixed4 mask = tex2D(_MaskTex, i.uv);
                fixed4 c = (tex + (((mc * 2.0) - 1.0) * _Color) * _Strongth);
                c.rgb += lightC.rgb * mask.rgb;
                return c;
            }
            ENDCG
        }
    }
}
