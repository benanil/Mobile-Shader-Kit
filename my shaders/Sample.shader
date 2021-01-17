
Shader "Anil/Sample AO" 
{
  Properties 
  {
    _MainTex ("Diffuse Texture", 2D) = "white" {}
    _AOTex ("AO Texture", 2D) = "white"{}
    _AOIntensity ("AO Intensity", float) = .1
    _Color ("Diffuse Tint", Color) = (1, 1, 1, 1)
    //_Directional("directional",Range(0,8)) = 1   
  }

  SubShader 
  {
    Tags { "RenderType"="Opaque" }

    pass
    {		
      Tags { "LightMode"="ForwardBase"}

      CGPROGRAM

      #pragma target 3.0
      #pragma vertex vert
      #pragma fragment frag Lambert

      #pragma multi_compile_fwdbase_fullshadows LIGHTMAP_ON LIGHTMAP_OFF
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma fragmentoption ARB_fragment_program_shadow

      #include "UnityCG.cginc"
      #include "AutoLight.cginc"

      uniform sampler2D _MainTex;
      uniform sampler2D _AOTex;
      uniform sampler2D _AOTex_ST;
      uniform half4 _Color;
      uniform half4 _LightColor0;
      uniform half _Directional;
      uniform half _AOIntensity;

      struct vertexInput
      {
          half4 vertex : POSITION;
          half3 normal : NORMAL;
	      half4 texcoord : TEXCOORD0;
#ifdef LIGHTMAP_ON
          half2 texCoord1 : TEXCOORD1;
#endif
      };

      struct vertexOutput
      {
        half4 pos : SV_POSITION;
        half2 uv : TEXCOORD2;

        half4 diffuseTerm : TEXCOORD6;
#ifdef LIGHTMAP_ON
        half2 uv1 : TEXCOORD3;
#endif
        LIGHTING_COORDS(4, 5)
      };

      vertexOutput vert(vertexInput v)
      {
        vertexOutput o;

        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;
#ifdef LIGHTMAP_ON
        o.uv1 = v.texCoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

        half3 L = normalize(ObjSpaceLightDir(v.vertex)) * 3.5h;
        half3 N = normalize(v.normal.xyz);	 
        half NdotL = saturate(dot(N, L));

        o.diffuseTerm = NdotL * _LightColor0 * _Color;

        TRANSFER_VERTEX_TO_FRAGMENT(o);

        return o; 
      }

      half4 frag(vertexOutput i) : COLOR
      {					
        half attenuation = LIGHT_ATTENUATION(i);
        half4 ambient = UNITY_LIGHTMODEL_AMBIENT;

        half4 diffuse = tex2D(_MainTex, i.uv);

        i.diffuseTerm *= attenuation * tex2D(_AOTex,i.uv).r + _AOIntensity;

        half4 finalColor = (ambient + i.diffuseTerm) * diffuse ;
#ifdef LIGHTMAP_ON
        finalColor *= UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1.xy);
#endif
        return finalColor;
      }

      ENDCG
    }		

  } 
  FallBack "Diffuse"
}