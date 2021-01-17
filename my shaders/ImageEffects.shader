Shader "Anil/ImageEffect"
{
	Properties
	{
		[HideInInspector]
		_MainTex("Texture",2D) = "white" {}
		_Color ("Color" , Color) = (255,245,237,0) 
		_Brightness("Brightness",Range(0,3)) = 1.2
		//[Tooltip("kırmızı yeşil ve mavinin tonlarını ayarlamanızı sağlar")]
		_RGB("RGB", Vector) = (.9,.98,.86,0)
		_RgbMul("RGB Multipler",Range(0,2)) = 1.2
		_Saturate("Saturate",Range(0,3)) = 1
	}

	Subshader
	{
		Pass
		{
			Tags{"Lightmode" = "ForwardBase" "Queue" = "Opaque + 500"}

			CGPROGRAM

		    #pragma fragmentoption ARB_precision_hint_fastest

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			// user defined
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform half4 _Color;
			uniform half4 _RGB;
			uniform half _Brightness;
			uniform half _RgbMul;
			uniform half _Saturate;
			static const fixed maxValue = 1;
			static const fixed rgBoost = .1;
			static const fixed DetectValue = .3;
			// structs

			struct vertexInput
			{
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};
		
			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				half4 col : COLOR;
				half2 uv : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.col = _Color * (_RGB * _RgbMul);
				
				o.uv = v.texcoord;

				return o;
			}

			fixed4 frag(vertexOutput i) : COLOR
			{
				half4 tex = tex2D(_MainTex,i.uv);
				/*
				if (tex.r , maxValue) < DetectValue) 
				{
					tex.r *= _Saturate + rgBoost;
				}
			    
				if (Difrance(tex.g , maxValue) < DetectValue)
				{
					tex.g *= _Saturate + rgBoost;
				}
				
				if (Difrance(tex.b , maxValue) < DetectValue)
				{
					tex.b += _Saturate;
				}
				*/
				return i.col * tex * _Brightness;
			}
	
			half Difrance(half a,half b)
			{
				return abs(a-b);
			}

			ENDCG
		}
	}
}