Shader "Anil/Lambert fog"
{
	Properties
	{
		_Color ("Color" , Color) = (0,0,0,0)
	}

	Subshader
	{

		Pass
		{
			Tags{"Lightmode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			// make fog work
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			// user defined
			uniform float4 _Color;

			// unity defined
			uniform float4 _LightColor0;

			// structs

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
		
			struct vertexOutput
			{
				UNITY_FOG_COORDS(1)
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				float3 normalDirection = normalize(mul(float4(v.normal,0), unity_WorldToObject).xyz);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 difuseReflection = _LightColor0 *_Color.rgb * max(0,dot(normalDirection, lightDirection));

				o.col = float4(difuseReflection, 1);

				o.pos = UnityObjectToClipPos(v.vertex);
	
				UNITY_TRANSFER_FOG(o, o.pos);

				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				UNITY_APPLY_FOG(i.fogCoord, i.col);
				return i.col;
			}
	
			ENDCG
		}

		// GÖLGE
		Pass
		{
			Tags {"LightMode" = "ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}

	}
}