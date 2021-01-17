 Shader "Anil/Best_AO"
 {
    Properties
    {
	    _MainTex("Texture",2D) = "white" {}
	 	_AOTex("AO Texture",2D) = "white" {}
      //   _Color ("Color", Color) = (1.0,1.0,1.0,1.0)
        _AOIntensity("AOIntensity" , Range(-2,2)) = 1
        _Ambient("Ambient intensity",Range(0,2)) = 1
		_Directional("Directional Light",Range(0,2)) = 1
    }
     
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "AutoLight.cginc"
    ENDCG
 
    SubShader
    {
        LOD 100
        Tags { "RenderType"="Opaque" }
        Pass 
        { 
            Lighting On
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            
			#pragma target 3.0
            #pragma vertex vert
            #pragma exclude_renderers gles
            #pragma fragment frag Lambert
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase_fullshadows LIGHTMAP_ON LIGHTMAP_OFF 
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma fragmentoption ARB_fragment_program_shadow

		    uniform sampler2D _MainTex;
		    uniform sampler2D _AOTex;
            uniform half4 _MainTex_ST;
		    uniform half _Ambient;
			uniform half _Directional;
			uniform half _Colorful;
			uniform half _ColorMul;
            uniform half _AOIntensity;

            static const fixed4 _Color = (1,1,1,1);
            // unity defined
            uniform half4 _LightColor0;

			struct vertexInput
            {
                half4     vertex     : POSITION;
                half3     normal     : NORMAL;
			    half4 texcoord0      : TEXCOORD0;
#ifdef LIGHTMAP_ON
                half2 texCoord1      : TEXCOORD1;
#endif
            };
             
            struct vertexOutput
            {
                half4 pos : SV_POSITION;
                half4 col : COLOR;
                half2 uv0 : TEXCOORD4;
#ifdef LIGHTMAP_ON 
                half2 uv1: TEXCOORD3;
#endif 
                LIGHTING_COORDS(5,6)
            };
 
            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                
                half4 posWorld = UnityObjectToClipPos(v.vertex);
                half3 normalWorld = normalize(v.normal).xyz;
                half4 ambient = UNITY_LIGHTMODEL_AMBIENT * _Ambient;
                half lightDirection = normalize(ObjSpaceLightDir(v.vertex));
                half NdotL =  saturate(dot(normalize(normalWorld),normalize(lightDirection)* _Directional));
                //half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
			 
                o.pos = posWorld;
	            o.uv0 = v.texcoord0;
                o.col = NdotL * _LightColor0 * _Color + ambient;
                
#ifdef LIGHTMAP_ON 
			    o.uv1 = v.texCoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif                
                TRANSFER_SHADOW(o);

                return o;
            }
             
            fixed4 frag(vertexOutput i) : COLOR
            {
                i.col *= SHADOW_ATTENUATION(i) * (tex2D(_AOTex, i.uv0 ).r + _AOIntensity);
               
#ifdef LIGHTMAP_ON                 
                return UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1.xy) * i.col * tex2D(_MainTex,i.uv0);
#else
                return i.col * tex2D(_MainTex,i.uv0) ;
#endif
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}