Shader "Custom/SingleMat"
{
    Properties
    {
        _Specular ("Specular", Color ) = (1,1,1,1)
        _Gloss ("Gloss", Range(0, 1)) = 0.5
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.texcord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
               
                fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz);
                //fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 h = (viewDir + worldLight)/2;
                fixed3 emmi = albedo * _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(h, i.normal)) ,_Gloss);
                fixed3 color = ambient + emmi;
                return fixed4(color,1.0);
            }


            ENDCG
        }
    }
    Fallback "Diffuse"
}