 Shader "Anil/Best Instanced"
 {
     Properties
     {
         /*
         _Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		 _ColorMul("Colour Multipler",Range(0,5)) = 1
		_MainTex("Texture",2D) = "white" {}
	 	_Ambient("Ambient intensity",Range(0,4)) = 1
		 _Directional("Directional Light",Range(0,4)) = 1
		 _Colorful("Colourful",Range(0,3)) = 1 
	    */
     }
     
     CGINCLUDE
     //#include "UnityCG.cginc"
     //#include "AutoLight.cginc"
     //#include "Lighting.cginc"
	 //#include "./../../../GPUInstancer/Shaders/Include/GPUInstancerInclude.cginc"
     ENDCG
 
  SubShader
  {
      LOD 100
      Tags { "RenderType"="Opaque" }
      Pass { 
             Lighting On
             Tags {"LightMode" = "ForwardBase"}
             CGPROGRAM
			 #pragma target 3.0
             #pragma vertex vert
             #pragma fragment frag Lambert
             //#pragma multi_compile_fwdbase 
			 //#pragma multi_compile_instancing
			 //#pragma instancing_options procedural:setupGPUI
		     
 /*
             uniform half4 _Color;
		     uniform sampler2D _MainTex;
			 uniform half4 _MainTex_ST;
		     uniform half _Ambient;
			 uniform half _Directional;
			 uniform half _Colorful;
			 uniform half _ColorMul;
*/
			 struct vertexInput
             {
                  /*
                 half4     vertex    :   POSITION;
                 half3     normal    :   NORMAL;
				 half4 texcoord0     :   TEXCOORD0;
                 half2 texCoord1     :   TEXCOORD1;
			     */
             };
             
             struct vertexOutput
             {
                  /*
                 half4   pos               :    SV_POSITION;
                 half4   col               :    COLOR;
				 fixed   lightDirection    :    TEXCOORD1;
                 fixed3  viewDirection     :    TEXCOORD2;
                 fixed3  normalWorld       :    TEXCOORD3;
                 half2   uv0               :    TEXCOORD7;
				 half2   uv1               :    TEXCOORD4;
				 LIGHTING_COORDS(5,6)
             */
             };
 
            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
               /* 
                half4 posWorld = mul( unity_ObjectToWorld, v.vertex );
                half3 normalWorld = normalize( mul(half4(v.normal, 0), unity_WorldToObject).xyz );
                half4 ambient = UNITY_LIGHTMODEL_AMBIENT * _Ambient;
                half lightDirection = normalize(_WorldSpaceLightPos0.xyz) * _Directional;
                half NdotL =  max(_Colorful,dot(normalWorld, lightDirection));
                //half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
			 
                o.pos = UnityObjectToClipPos(v.vertex);
	            o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);
                o.col =_LightColor0 * _Color * _ColorMul * NdotL + ambient;
                
                #ifdef LIGHTMAP_ON 
			    o.uv1 = v.texCoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                */
                return o;
            }
             
            half4 frag(vertexOutput i) : COLOR
            {
                /*
                i.col = SHADOW_ATTENUATION(i);
                #ifdef LIGHTMAP_ON 
                return UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1.xy) * i.col * tex2D(_MainTex,i.uv0);
                #else
                return i.col * tex2D(_MainTex,i.uv0);
                #endif
                */
                return 0;
            }
             
              ENDCG
          }
      }
      FallBack "Diffuse"
  }