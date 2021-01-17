Shader "Anil/Rim Normal"
{
	Properties
	{
		[Header(Lightings)] [Space]
		_Color("Color",Color) = (0,0,0,0)
		_SpecColor("Specular Color",Color) = (1,1,1,1)
		_Shininess("Shininess" , float) = 10
		_Ambient("Ambient",Range(0.5,2.5)) = 2
		_Atten("atten",Range(0,2)) = 1
		_Directional("Directional Light",Range(0,2)) = 1 
		_MainTex("Main Texture" , 2D) = "white" {}
		[Header(Rim)] [Space]
		_RimPower("RimPower",Range(0,10)) = 1
		_RimColor("RimColor",Color) = (0,0,0,0)
		[header(Normal map)] [Space]
		_BumpMap("Normal Texture" , 2D) = "bump" {}
		_Depth("Depth",Range(0,3)) = 1
	}

	SubShader
	{
		pass
		{
			Tags
            {
              "RenderType"="Opaque"
              "LightMode"="ForwardBase"
              "PassFlags"="OnlyDirectional"
            }

			CGPROGRAM

			// pragmas
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"

			// user defined
			uniform sampler2D _MainTex;
			uniform sampler2D _BumpMap;
			uniform half4 _MainTex_ST;
			uniform half4 _BumpMap_ST;
			uniform half4 _Color;	
			uniform half4 _RimColor;
			uniform half4 _SpecColor;
			uniform half _Shininess;
			uniform half _Ambient;
			uniform half _Atten;
			uniform half _Directional;
			uniform half _RimPower;
			uniform half _Depth;
			
			// unity defined
			uniform float4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texCoord0 : TEXCOORD0;
				half2 texCoord1 : TEXCOORD1;
				half4 tangent : TANGENT;
			};

			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				half2 tex :TEXCOORD0; // uv0
				half2 uv1 :TEXCOORD1; // lightmap
                half3 normalWorld :TEXCOORD2;
                half3 tangentWorld :TEXCOORD3;
                half3 binormalWorld :TEXCOORD4; 
            };

			vertexOutput vert(vertexInput i)
			{
				vertexOutput o;

                o.normalWorld = normalize(mul(float4(i.normal,0), unity_WorldToObject).xyz);
				o.tangentWorld = normalize(mul(unity_ObjectToWorld,i.tangent).xyz);
                o.binormalWorld =  normalize(cross(o.normalWorld,o.tangentWorld) * i.tangent);

                o.pos = UnityObjectToClipPos(i.vertex);
				o.tex = TRANSFORM_TEX(i.texCoord0.xy,_MainTex); 
				o.uv1 = i.texCoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				
                return o;
			}

			float4 frag(vertexOutput o) : COLOR
			{

				// normal
				half4 texNormal = tex2D(_BumpMap , o.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
				
				half3 localCoords = half3(2 * texNormal.ag - half2(1,1),0);
				localCoords.z = _Depth;

				half3x3 local2worldtranspose = half3x3
				(
					o.tangentWorld,
					o.binormalWorld,
					o.normalWorld
				);

				half3 normalDir = normalize(mul(localCoords,local2worldtranspose));

				// vectors
				half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.pos.xyz);
				half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz) * _Directional;
				// lighting
			    half3 difuseReflection = _Atten * _LightColor0 * _Color.xyz * saturate(dot(normalDir,lightDirection));
				half3 specularReflection = _Atten *  _SpecColor.xyz * saturate(dot(normalDir,lightDirection)) * pow(saturate(dot(reflect(-lightDirection,normalDir),viewDirection)),_Shininess);
				//Rim Lighting
				half rim = 1 - saturate(dot(normalize(viewDirection),normalDir));
				half3 rimLighting = _Atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDir,lightDirection)) * pow(rim,_RimPower);
				half3 lightFinal = rimLighting + difuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz * _Ambient * _Color.xyz;

				#ifdef LIGHTMAP_ON
				half4 tex = UNITY_SAMPLE_TEX2D(unity_Lightmap, o.uv1.xy) * tex2D(_MainTex, o.tex) * half4(lightFinal,1);
				#else
				half4 tex = tex2D(_MainTex, o.tex) * half4(lightFinal,1);
				#endif
				
				return tex;
			}


			ENDCG
		}
	}
}
