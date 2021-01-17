Shader "Anil/Lambert Ambient"
{
	Properties
	{
		_Color ("Color" , Color) = (0,0,0,0)
		_Ambient("Ambient intensity",Range(0,2)) = 1
		_Directional("Directional Light",Range(0,2)) = 0 
	}

	CGINCLUDE
    #include "UnityCG.cginc"
    #include "AutoLight.cginc"
    #include "Lighting.cginc"
    ENDCG

	Subshader
	{
		Pass
		{
			Tags{"Lightmode" = "ForwardBase"}

			Lighting On
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma exclude_renderers gles
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest
            #pragma fragmentoption ARB_fragment_program_shadow

			// user defined
			uniform half4 _Color;
			uniform half _Ambient;
			uniform half _Directional;

			// structs

			struct vertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};
		
			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				half4 col : COLOR;
				LIGHTING_COORDS(1,2)
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				half3 normalDirection = normalize(mul(half4(v.normal,0), unity_WorldToObject).xyz);
				half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz)*_Directional;
				half3 difuseReflection = _LightColor0 * max(0,dot(normalDirection, lightDirection));
				half3 lightFinal = difuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz * _Ambient;
				
				o.col = half4(lightFinal * _Color.rgb,1);

				o.pos = UnityObjectToClipPos(v.vertex);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			half4 frag(vertexOutput i) : COLOR
			{
				i.col *= SHADOW_ATTENUATION(i);
				return i.col;
			}
	
			ENDCG
		}

	}
	FallBack "Diffuse"
}