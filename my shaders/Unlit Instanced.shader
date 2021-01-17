Shader "Anil/Unlit Instanced"
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
			LOD 0
			CGPROGRAM

			//#include "./../../../GPUInstancer/Shaders/Include/GPUInstancerInclude.cginc"
			//#pragma multi_compile_instancing
		    //#pragma instancing_options procedural:setupGPUI
		    #pragma fragmentoption ARB_precision_hint_fastest

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			// user defined
			uniform fixed4 _Color;

			// structs
			struct vertexInput
			{
				fixed4 vertex : POSITION;
			};
		
			struct vertexOutput
			{
				fixed4 pos : SV_POSITION;
				fixed4 col : COLOR;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//o.col = _Color;

				return o;
			}

			fixed4 frag(vertexOutput i) : COLOR
			{
				return i.col;
			}
	
			ENDCG
		}
	}
}