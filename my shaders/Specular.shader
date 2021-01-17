Shader "Anil/Specular_Lightmap_Texture"
{
	Properties
	{
		_MainTex("Texture" , 2D) = "white" {}
		
		_Color("Color" , Color) = (1,1,1,1)
		_SpecColor("Specular Color",Color) = (1,1,1,1)
		_Shininess("Shininess" , float) = 10
		_Ambient("Ambient",Range(0.5,2.5)) = 2
		_Atten("atten",Range(0,2)) = 1
		_Directional("Directional Light",Range(0,2)) = 0 
	}

	Subshader
	{
		Tags {"LightMode" = "ForwardBase"}
		
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			
			// user defined
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float _Ambient;
			uniform float _Atten;
			uniform float _Directional;
			// unity defined
			uniform float4 _LightColor0;
			uniform half4 _MainTex_ST;

			// Structs
			struct vertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half2 texCoord0 : TEXCOORD0;
				half2 texCoord1 : TEXCOORD1;
			};

			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				half4 col : COLOR;
				half2 uv0 :TEXCOORD0;
				half2 uv1 :TEXCOORD1;
			};

			// verts

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				// vectors
				half3 normalDirection = normalize(mul(float4(v.normal,0),unity_WorldToObject).xyz) * _Directional;
				half3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz,1) - mul(unity_ObjectToWorld,v.vertex).xyz));
				half3 lightDirection;
				
				// Lighting
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				half3 difuseReflection = _LightColor0.xyz * max(0,dot(normalDirection,lightDirection));
				half3 specularReflection = _Atten * _SpecColor.rgb *  pow(max(0 ,dot( reflect(-lightDirection,normalDirection),viewDirection)),_Shininess);								
				half3 lightFinal = difuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT * _Ambient;

				o.uv0 = TRANSFORM_TEX(v.texCoord0,_MainTex); 
				o.uv1 = v.texCoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

				o.col = float4(lightFinal * _Color.rgb,1);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				half4 tex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1.xy) * tex2D(_MainTex, i.uv0) * i.col;
				return tex;
			}


			ENDCG
		}
	}

}