// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hand Painted 2D/Sprite Wind"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("Diffuse", 2D) = "white" {}
		_WindSpeed("Wind Speed", Float) = 1
		_WindMapping("WindMapping", Vector) = (-0.01,0.01,-0.01,0.01)
		_WindNoise("Wind Noise", Float) = 0
		_WindSway("Wind Sway", Float) = 0.2
		_ForegroundColor("Foreground Color", Color) = (0.4156863,0.3921569,0.4352941,1)
		_BackgroundColor("Background Color", Color) = (0.4980392,0.7137255,0.8,1)
		_BackgroundRange("Background Range", Vector) = (1,60,0,0)
		_ForegroundRange("Foreground Range", Vector) = (-1,-8,0,0)
		_MaskTex("Mask", 2D) = "white" {}
		[ASEEnd]_NormalMap("Normal Map", 2D) = "bump" {}
		[HideInInspector][Toggle(_FOG_ON)] _Fog("Fog", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Lit" "ShaderGraphShader"="true" "DisableBatching"="True" "PreviewType"="Plane" }

		Cull Off
		HLSLINCLUDE
		#pragma target 2.0
		
		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL

		
		Pass
		{
			Name "Sprite Lit"
			Tags { "LightMode"="Universal2D" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 999999


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_0
			#pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_1
			#pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_2
			#pragma multi_compile _ USE_SHAPE_LIGHT_TYPE_3

			#define _SURFACE_TYPE_TRANSPARENT 1

			#define SHADERPASS SHADERPASS_SPRITELIT
			#define SHADERPASS_SPRITELIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/LightingUtility.hlsl"
			
			#if USE_SHAPE_LIGHT_TYPE_0
			SHAPE_LIGHT(0)
			#endif

			#if USE_SHAPE_LIGHT_TYPE_1
			SHAPE_LIGHT(1)
			#endif

			#if USE_SHAPE_LIGHT_TYPE_2
			SHAPE_LIGHT(2)
			#endif

			#if USE_SHAPE_LIGHT_TYPE_3
			SHAPE_LIGHT(3)
			#endif

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/CombinedShapeLightShared.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma multi_compile_instancing
			#pragma shader_feature_local _FOG_ON


			sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _NormalMap;
			UNITY_INSTANCING_BUFFER_START(HandPainted2DSpriteWind)
				UNITY_DEFINE_INSTANCED_PROP(float4, _WindMapping)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MaskTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _NormalMap_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindNoise)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSway)
			UNITY_INSTANCING_BUFFER_END(HandPainted2DSpriteWind)
			CBUFFER_START( UnityPerMaterial )
			float4 _ForegroundColor;
			float4 _BackgroundColor;
			float2 _ForegroundRange;
			float2 _BackgroundRange;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float4 screenPosition : TEXCOORD2;
				float3 positionWS : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D(_AlphaTex); SAMPLER(sampler_AlphaTex);
				float _EnableAlphaTexture;
			#endif

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float _WindSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSpeed);
				float mulTime3_g11 = _TimeParameters.x * _WindSpeed_Instance;
				float2 temp_cast_0 = (( ase_worldPos.x + mulTime3_g11 )).xx;
				float simplePerlin2D33_g11 = snoise( temp_cast_0*0.1 );
				float _WindNoise_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindNoise);
				float _WindSway_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSway);
				float4 transform1_g11 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float temp_output_4_0_g11 = ( transform1_g11.x * transform1_g11.y );
				float4 _WindMapping_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindMapping);
				float2 temp_cast_1 = (( ase_worldPos.y + mulTime3_g11 )).xx;
				float simplePerlin2D27_g11 = snoise( temp_cast_1*0.1 );
				float3 appendResult40_g11 = (float3(( ( simplePerlin2D33_g11 * _WindNoise_Instance ) + ( ( ( _WindSway_Instance * sin( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.y - _WindMapping_Instance.x) * (1.0 - 0.0) / (_WindMapping_Instance.y - _WindMapping_Instance.x)) ) * step( 0.05 , ( abs( _WindMapping_Instance.x ) + abs( _WindMapping_Instance.y ) ) ) ) ) , ( ( _WindNoise_Instance * simplePerlin2D27_g11 ) + ( ( ( _WindSway_Instance * cos( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.x - _WindMapping_Instance.z) * (1.0 - 0.0) / (_WindMapping_Instance.w - _WindMapping_Instance.z)) ) * step( 0.05 , ( abs( _WindMapping_Instance.z ) + abs( _WindMapping_Instance.w ) ) ) ) ) , 0.0));
				
				o.ase_color = v.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult40_g11;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;
				o.screenPosition = vertexInput.positionNDC;
				o.positionWS = vertexInput.positionWS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				float3 positionWS = IN.positionWS.xyz;

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 temp_output_25_0 = ( IN.ase_color * tex2D( _MainTex, uv_MainTex ) );
				float4 temp_output_26_0_g12 = temp_output_25_0;
				float4 blendOpSrc17_g12 = _ForegroundColor;
				float4 blendOpDest17_g12 = temp_output_26_0_g12;
				float clampResult10_g12 = clamp( positionWS.z , _ForegroundRange.y , _ForegroundRange.x );
				float4 lerpBlendMode17_g12 = lerp(blendOpDest17_g12,( blendOpSrc17_g12 * blendOpDest17_g12 ),(1.0 + (clampResult10_g12 - _ForegroundRange.y) * (0.0 - 1.0) / (_ForegroundRange.x - _ForegroundRange.y)));
				float temp_output_3_0_g12 = step( _ForegroundRange.x , positionWS.z );
				float clampResult6_g12 = clamp( positionWS.z , _BackgroundRange.x , _BackgroundRange.y );
				float4 lerpResult4_g12 = lerp( temp_output_26_0_g12 , _BackgroundColor , ( 1.0 - pow( ( 1.0 - (0.0 + (clampResult6_g12 - _BackgroundRange.x) * (1.0 - 0.0) / (_BackgroundRange.y - _BackgroundRange.x)) ) , 2.0 ) ));
				float4 break23_g12 = ( ( ( saturate( lerpBlendMode17_g12 )) * ( 1.0 - temp_output_3_0_g12 ) ) + ( temp_output_3_0_g12 * lerpResult4_g12 ) );
				float4 appendResult24_g12 = (float4(break23_g12.r , break23_g12.g , break23_g12.b , temp_output_26_0_g12.a));
				#ifdef _FOG_ON
				float4 staticSwitch31 = appendResult24_g12;
				#else
				float4 staticSwitch31 = temp_output_25_0;
				#endif
				
				float4 _MaskTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MaskTex_ST);
				float2 uv_MaskTex = IN.texCoord0.xy * _MaskTex_ST_Instance.xy + _MaskTex_ST_Instance.zw;
				
				float4 _NormalMap_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_NormalMap_ST);
				float2 uv_NormalMap = IN.texCoord0.xy * _NormalMap_ST_Instance.xy + _NormalMap_ST_Instance.zw;
				
				float4 Color = staticSwitch31;
				float4 Mask = tex2D( _MaskTex, uv_MaskTex );
				float3 Normal = tex2D( _NormalMap, uv_NormalMap ).rgb;

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D(_AlphaTex, sampler_AlphaTex, IN.texCoord0.xy);
					Color.a = lerp ( Color.a, alpha.r, _EnableAlphaTexture);
				#endif
				
				Color *= IN.color;
			
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, Mask, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.texCoord0.xy, half2(IN.screenPosition.xy / IN.screenPosition.w), inputData);
				SETUP_DEBUG_DATA_2D(inputData, positionWS);
				return CombinedShapeLightShared(surfaceData, inputData);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Sprite Normal"
			Tags { "LightMode"="NormalsRendering" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 999999


			#pragma vertex vert
			#pragma fragment frag

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITENORMAL

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/NormalsRenderingShared.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_instancing
			#pragma shader_feature_local _FOG_ON


			sampler2D _MainTex;
			sampler2D _NormalMap;
			UNITY_INSTANCING_BUFFER_START(HandPainted2DSpriteWind)
				UNITY_DEFINE_INSTANCED_PROP(float4, _WindMapping)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _NormalMap_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindNoise)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSway)
			UNITY_INSTANCING_BUFFER_END(HandPainted2DSpriteWind)
			CBUFFER_START( UnityPerMaterial )
			float4 _ForegroundColor;
			float4 _BackgroundColor;
			float2 _ForegroundRange;
			float2 _BackgroundRange;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 normalWS : TEXCOORD2;
				float4 tangentWS : TEXCOORD3;
				float3 bitangentWS : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float _WindSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSpeed);
				float mulTime3_g11 = _TimeParameters.x * _WindSpeed_Instance;
				float2 temp_cast_0 = (( ase_worldPos.x + mulTime3_g11 )).xx;
				float simplePerlin2D33_g11 = snoise( temp_cast_0*0.1 );
				float _WindNoise_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindNoise);
				float _WindSway_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSway);
				float4 transform1_g11 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float temp_output_4_0_g11 = ( transform1_g11.x * transform1_g11.y );
				float4 _WindMapping_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindMapping);
				float2 temp_cast_1 = (( ase_worldPos.y + mulTime3_g11 )).xx;
				float simplePerlin2D27_g11 = snoise( temp_cast_1*0.1 );
				float3 appendResult40_g11 = (float3(( ( simplePerlin2D33_g11 * _WindNoise_Instance ) + ( ( ( _WindSway_Instance * sin( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.y - _WindMapping_Instance.x) * (1.0 - 0.0) / (_WindMapping_Instance.y - _WindMapping_Instance.x)) ) * step( 0.05 , ( abs( _WindMapping_Instance.x ) + abs( _WindMapping_Instance.y ) ) ) ) ) , ( ( _WindNoise_Instance * simplePerlin2D27_g11 ) + ( ( ( _WindSway_Instance * cos( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.x - _WindMapping_Instance.z) * (1.0 - 0.0) / (_WindMapping_Instance.w - _WindMapping_Instance.z)) ) * step( 0.05 , ( abs( _WindMapping_Instance.z ) + abs( _WindMapping_Instance.w ) ) ) ) ) , 0.0));
				
				o.ase_texcoord5.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult40_g11;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;

				float3 normalWS = TransformObjectToWorldNormal( v.normal );
				o.normalWS = -GetViewForwardDir();
				float4 tangentWS = float4( TransformObjectToWorldDir( v.tangent.xyz ), v.tangent.w );
				o.tangentWS = normalize( tangentWS );
				half crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
				o.bitangentWS = crossSign * cross( normalWS, tangentWS.xyz ) * tangentWS.w;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 temp_output_25_0 = ( IN.color * tex2D( _MainTex, uv_MainTex ) );
				float4 temp_output_26_0_g12 = temp_output_25_0;
				float4 blendOpSrc17_g12 = _ForegroundColor;
				float4 blendOpDest17_g12 = temp_output_26_0_g12;
				float3 ase_worldPos = IN.ase_texcoord5.xyz;
				float clampResult10_g12 = clamp( ase_worldPos.z , _ForegroundRange.y , _ForegroundRange.x );
				float4 lerpBlendMode17_g12 = lerp(blendOpDest17_g12,( blendOpSrc17_g12 * blendOpDest17_g12 ),(1.0 + (clampResult10_g12 - _ForegroundRange.y) * (0.0 - 1.0) / (_ForegroundRange.x - _ForegroundRange.y)));
				float temp_output_3_0_g12 = step( _ForegroundRange.x , ase_worldPos.z );
				float clampResult6_g12 = clamp( ase_worldPos.z , _BackgroundRange.x , _BackgroundRange.y );
				float4 lerpResult4_g12 = lerp( temp_output_26_0_g12 , _BackgroundColor , ( 1.0 - pow( ( 1.0 - (0.0 + (clampResult6_g12 - _BackgroundRange.x) * (1.0 - 0.0) / (_BackgroundRange.y - _BackgroundRange.x)) ) , 2.0 ) ));
				float4 break23_g12 = ( ( ( saturate( lerpBlendMode17_g12 )) * ( 1.0 - temp_output_3_0_g12 ) ) + ( temp_output_3_0_g12 * lerpResult4_g12 ) );
				float4 appendResult24_g12 = (float4(break23_g12.r , break23_g12.g , break23_g12.b , temp_output_26_0_g12.a));
				#ifdef _FOG_ON
				float4 staticSwitch31 = appendResult24_g12;
				#else
				float4 staticSwitch31 = temp_output_25_0;
				#endif
				
				float4 _NormalMap_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_NormalMap_ST);
				float2 uv_NormalMap = IN.texCoord0.xy * _NormalMap_ST_Instance.xy + _NormalMap_ST_Instance.zw;
				
				float4 Color = staticSwitch31;
				float3 Normal = tex2D( _NormalMap, uv_NormalMap ).rgb;
				
				Color *= IN.color;

				return NormalsRenderingShared( Color, Normal, IN.tangentWS.xyz, IN.bitangentWS, IN.normalWS);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Sprite Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 999999


			#pragma vertex vert
			#pragma fragment frag


			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITEFORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma multi_compile_instancing
			#pragma shader_feature_local _FOG_ON


			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(HandPainted2DSpriteWind)
				UNITY_DEFINE_INSTANCED_PROP(float4, _WindMapping)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindNoise)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSway)
			UNITY_INSTANCING_BUFFER_END(HandPainted2DSpriteWind)
			CBUFFER_START( UnityPerMaterial )
			float4 _ForegroundColor;
			float4 _BackgroundColor;
			float2 _ForegroundRange;
			float2 _BackgroundRange;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float _WindSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSpeed);
				float mulTime3_g11 = _TimeParameters.x * _WindSpeed_Instance;
				float2 temp_cast_0 = (( ase_worldPos.x + mulTime3_g11 )).xx;
				float simplePerlin2D33_g11 = snoise( temp_cast_0*0.1 );
				float _WindNoise_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindNoise);
				float _WindSway_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSway);
				float4 transform1_g11 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float temp_output_4_0_g11 = ( transform1_g11.x * transform1_g11.y );
				float4 _WindMapping_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindMapping);
				float2 temp_cast_1 = (( ase_worldPos.y + mulTime3_g11 )).xx;
				float simplePerlin2D27_g11 = snoise( temp_cast_1*0.1 );
				float3 appendResult40_g11 = (float3(( ( simplePerlin2D33_g11 * _WindNoise_Instance ) + ( ( ( _WindSway_Instance * sin( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.y - _WindMapping_Instance.x) * (1.0 - 0.0) / (_WindMapping_Instance.y - _WindMapping_Instance.x)) ) * step( 0.05 , ( abs( _WindMapping_Instance.x ) + abs( _WindMapping_Instance.y ) ) ) ) ) , ( ( _WindNoise_Instance * simplePerlin2D27_g11 ) + ( ( ( _WindSway_Instance * cos( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.xyz.x - _WindMapping_Instance.z) * (1.0 - 0.0) / (_WindMapping_Instance.w - _WindMapping_Instance.z)) ) * step( 0.05 , ( abs( _WindMapping_Instance.z ) + abs( _WindMapping_Instance.w ) ) ) ) ) , 0.0));
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = appendResult40_g11;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float3 positionWS = IN.positionWS.xyz;

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MainTex_ST);
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 temp_output_25_0 = ( IN.color * tex2D( _MainTex, uv_MainTex ) );
				float4 temp_output_26_0_g12 = temp_output_25_0;
				float4 blendOpSrc17_g12 = _ForegroundColor;
				float4 blendOpDest17_g12 = temp_output_26_0_g12;
				float clampResult10_g12 = clamp( positionWS.z , _ForegroundRange.y , _ForegroundRange.x );
				float4 lerpBlendMode17_g12 = lerp(blendOpDest17_g12,( blendOpSrc17_g12 * blendOpDest17_g12 ),(1.0 + (clampResult10_g12 - _ForegroundRange.y) * (0.0 - 1.0) / (_ForegroundRange.x - _ForegroundRange.y)));
				float temp_output_3_0_g12 = step( _ForegroundRange.x , positionWS.z );
				float clampResult6_g12 = clamp( positionWS.z , _BackgroundRange.x , _BackgroundRange.y );
				float4 lerpResult4_g12 = lerp( temp_output_26_0_g12 , _BackgroundColor , ( 1.0 - pow( ( 1.0 - (0.0 + (clampResult6_g12 - _BackgroundRange.x) * (1.0 - 0.0) / (_BackgroundRange.y - _BackgroundRange.x)) ) , 2.0 ) ));
				float4 break23_g12 = ( ( ( saturate( lerpBlendMode17_g12 )) * ( 1.0 - temp_output_3_0_g12 ) ) + ( temp_output_3_0_g12 * lerpResult4_g12 ) );
				float4 appendResult24_g12 = (float4(break23_g12.r , break23_g12.g , break23_g12.b , temp_output_26_0_g12.a));
				#ifdef _FOG_ON
				float4 staticSwitch31 = appendResult24_g12;
				#else
				float4 staticSwitch31 = temp_output_25_0;
				#endif
				
				float4 Color = staticSwitch31;

				#if defined(DEBUG_DISPLAY)
					SurfaceData2D surfaceData;
					InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
					InputData2D inputData;
					InitializeInputData(positionWS.xy, half2(IN.texCoord0.xy), inputData);
					half4 debugColor = 0;

					SETUP_DEBUG_DATA_2D(inputData, positionWS);

					if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
					{
						return debugColor;
					}
				#endif

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif

				Color *= IN.color;

				return Color;
			}

			ENDHLSL
		}
		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
            Cull Off
        
            HLSLPROGRAM
        
            #define ASE_SRP_VERSION 999999

        
            #pragma target 2.0
			#pragma exclude_renderers d3d11_9x 
			#pragma vertex vert
			#pragma fragment frag
        
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1
        
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_instancing
			#pragma shader_feature_local _FOG_ON


			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(HandPainted2DSpriteWind)
				UNITY_DEFINE_INSTANCED_PROP(float4, _WindMapping)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindNoise)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSway)
			UNITY_INSTANCING_BUFFER_END(HandPainted2DSpriteWind)
			CBUFFER_START( UnityPerMaterial )
			float4 _ForegroundColor;
			float4 _BackgroundColor;
			float2 _ForegroundRange;
			float2 _BackgroundRange;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
            
            int _ObjectId;
            int _PassValue;
            
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert(VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float _WindSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSpeed);
				float mulTime3_g11 = _TimeParameters.x * _WindSpeed_Instance;
				float2 temp_cast_0 = (( ase_worldPos.x + mulTime3_g11 )).xx;
				float simplePerlin2D33_g11 = snoise( temp_cast_0*0.1 );
				float _WindNoise_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindNoise);
				float _WindSway_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSway);
				float4 transform1_g11 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float temp_output_4_0_g11 = ( transform1_g11.x * transform1_g11.y );
				float4 _WindMapping_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindMapping);
				float2 temp_cast_1 = (( ase_worldPos.y + mulTime3_g11 )).xx;
				float simplePerlin2D27_g11 = snoise( temp_cast_1*0.1 );
				float3 appendResult40_g11 = (float3(( ( simplePerlin2D33_g11 * _WindNoise_Instance ) + ( ( ( _WindSway_Instance * sin( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.y - _WindMapping_Instance.x) * (1.0 - 0.0) / (_WindMapping_Instance.y - _WindMapping_Instance.x)) ) * step( 0.05 , ( abs( _WindMapping_Instance.x ) + abs( _WindMapping_Instance.y ) ) ) ) ) , ( ( _WindNoise_Instance * simplePerlin2D27_g11 ) + ( ( ( _WindSway_Instance * cos( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.x - _WindMapping_Instance.z) * (1.0 - 0.0) / (_WindMapping_Instance.w - _WindMapping_Instance.z)) ) * step( 0.05 , ( abs( _WindMapping_Instance.z ) + abs( _WindMapping_Instance.w ) ) ) ) ) , 0.0));
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult40_g11;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.clipPos = TransformWorldToHClip(positionWS);
		
				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 temp_output_25_0 = ( IN.ase_color * tex2D( _MainTex, uv_MainTex ) );
				float4 temp_output_26_0_g12 = temp_output_25_0;
				float4 blendOpSrc17_g12 = _ForegroundColor;
				float4 blendOpDest17_g12 = temp_output_26_0_g12;
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float clampResult10_g12 = clamp( ase_worldPos.z , _ForegroundRange.y , _ForegroundRange.x );
				float4 lerpBlendMode17_g12 = lerp(blendOpDest17_g12,( blendOpSrc17_g12 * blendOpDest17_g12 ),(1.0 + (clampResult10_g12 - _ForegroundRange.y) * (0.0 - 1.0) / (_ForegroundRange.x - _ForegroundRange.y)));
				float temp_output_3_0_g12 = step( _ForegroundRange.x , ase_worldPos.z );
				float clampResult6_g12 = clamp( ase_worldPos.z , _BackgroundRange.x , _BackgroundRange.y );
				float4 lerpResult4_g12 = lerp( temp_output_26_0_g12 , _BackgroundColor , ( 1.0 - pow( ( 1.0 - (0.0 + (clampResult6_g12 - _BackgroundRange.x) * (1.0 - 0.0) / (_BackgroundRange.y - _BackgroundRange.x)) ) , 2.0 ) ));
				float4 break23_g12 = ( ( ( saturate( lerpBlendMode17_g12 )) * ( 1.0 - temp_output_3_0_g12 ) ) + ( temp_output_3_0_g12 * lerpResult4_g12 ) );
				float4 appendResult24_g12 = (float4(break23_g12.r , break23_g12.g , break23_g12.b , temp_output_26_0_g12.a));
				#ifdef _FOG_ON
				float4 staticSwitch31 = appendResult24_g12;
				#else
				float4 staticSwitch31 = temp_output_25_0;
				#endif
				
				float4 Color = staticSwitch31;

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
            Cull Back
        
            HLSLPROGRAM
        
            #define ASE_SRP_VERSION 999999

        
            #pragma target 2.0
			#pragma exclude_renderers d3d11_9x 
			#pragma vertex vert
			#pragma fragment frag
        
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1
        
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        	#define ASE_NEEDS_VERT_POSITION
        	#define ASE_NEEDS_FRAG_COLOR
        	#pragma multi_compile_instancing
        	#pragma shader_feature_local _FOG_ON


			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(HandPainted2DSpriteWind)
				UNITY_DEFINE_INSTANCED_PROP(float4, _WindMapping)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindNoise)
				UNITY_DEFINE_INSTANCED_PROP(float, _WindSway)
			UNITY_INSTANCING_BUFFER_END(HandPainted2DSpriteWind)
			CBUFFER_START( UnityPerMaterial )
			float4 _ForegroundColor;
			float4 _BackgroundColor;
			float2 _ForegroundRange;
			float2 _BackgroundRange;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
            float4 _SelectionID;
        
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert(VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float _WindSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSpeed);
				float mulTime3_g11 = _TimeParameters.x * _WindSpeed_Instance;
				float2 temp_cast_0 = (( ase_worldPos.x + mulTime3_g11 )).xx;
				float simplePerlin2D33_g11 = snoise( temp_cast_0*0.1 );
				float _WindNoise_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindNoise);
				float _WindSway_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindSway);
				float4 transform1_g11 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float temp_output_4_0_g11 = ( transform1_g11.x * transform1_g11.y );
				float4 _WindMapping_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_WindMapping);
				float2 temp_cast_1 = (( ase_worldPos.y + mulTime3_g11 )).xx;
				float simplePerlin2D27_g11 = snoise( temp_cast_1*0.1 );
				float3 appendResult40_g11 = (float3(( ( simplePerlin2D33_g11 * _WindNoise_Instance ) + ( ( ( _WindSway_Instance * sin( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.y - _WindMapping_Instance.x) * (1.0 - 0.0) / (_WindMapping_Instance.y - _WindMapping_Instance.x)) ) * step( 0.05 , ( abs( _WindMapping_Instance.x ) + abs( _WindMapping_Instance.y ) ) ) ) ) , ( ( _WindNoise_Instance * simplePerlin2D27_g11 ) + ( ( ( _WindSway_Instance * cos( ( mulTime3_g11 + temp_output_4_0_g11 ) ) ) * (0.0 + (v.vertex.x - _WindMapping_Instance.z) * (1.0 - 0.0) / (_WindMapping_Instance.w - _WindMapping_Instance.z)) ) * step( 0.05 , ( abs( _WindMapping_Instance.z ) + abs( _WindMapping_Instance.w ) ) ) ) ) , 0.0));
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult40_g11;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.clipPos = TransformWorldToHClip(positionWS);
		
				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(HandPainted2DSpriteWind,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 temp_output_25_0 = ( IN.ase_color * tex2D( _MainTex, uv_MainTex ) );
				float4 temp_output_26_0_g12 = temp_output_25_0;
				float4 blendOpSrc17_g12 = _ForegroundColor;
				float4 blendOpDest17_g12 = temp_output_26_0_g12;
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float clampResult10_g12 = clamp( ase_worldPos.z , _ForegroundRange.y , _ForegroundRange.x );
				float4 lerpBlendMode17_g12 = lerp(blendOpDest17_g12,( blendOpSrc17_g12 * blendOpDest17_g12 ),(1.0 + (clampResult10_g12 - _ForegroundRange.y) * (0.0 - 1.0) / (_ForegroundRange.x - _ForegroundRange.y)));
				float temp_output_3_0_g12 = step( _ForegroundRange.x , ase_worldPos.z );
				float clampResult6_g12 = clamp( ase_worldPos.z , _BackgroundRange.x , _BackgroundRange.y );
				float4 lerpResult4_g12 = lerp( temp_output_26_0_g12 , _BackgroundColor , ( 1.0 - pow( ( 1.0 - (0.0 + (clampResult6_g12 - _BackgroundRange.x) * (1.0 - 0.0) / (_BackgroundRange.y - _BackgroundRange.x)) ) , 2.0 ) ));
				float4 break23_g12 = ( ( ( saturate( lerpBlendMode17_g12 )) * ( 1.0 - temp_output_3_0_g12 ) ) + ( temp_output_3_0_g12 * lerpResult4_g12 ) );
				float4 appendResult24_g12 = (float4(break23_g12.r , break23_g12.g , break23_g12.b , temp_output_26_0_g12.a));
				#ifdef _FOG_ON
				float4 staticSwitch31 = appendResult24_g12;
				#else
				float4 staticSwitch31 = temp_output_25_0;
				#endif
				
				float4 Color = staticSwitch31;
				half4 outColor = _SelectionID;
				return outColor;
			}

            ENDHLSL
        }
		
	}
	CustomEditor "NotSlot.HandPainted2D.Editor.SpriteShaderInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
57;72;1103;939;-312.2773;64.58633;2.189635;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;4;528.1331,534.3066;Inherit;True;Property;_MainTex;Diffuse;0;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;5;772.0703,536.0706;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;12;823.5005,274.4532;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;1131.708,384.5151;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;87;1297.177,453.0452;Inherit;False;Fog;6;;12;0af4f8e64e08f404a8159464b51699d5;0;1;26;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;18;1169.335,578.5339;Inherit;True;Property;_MaskTex;Mask;11;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;9;1418.068,587.7057;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;31;1545.937,378.1468;Inherit;False;Property;_Fog;Fog;13;0;Create;True;0;0;0;False;1;HideInInspector;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;10;1421.009,801.1342;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;160;1548.321,1025.227;Inherit;False;WindSprite;1;;11;97e1bfadcd8a346f08e4f26c39db68a1;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StickyNoteNode;88;1914.732,619.6392;Inherit;False;191;140;New Note;;1,1,1,1;We use a separate shader instead of a feature since we need to disable batching.;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;1172.262,799.5053;Inherit;True;Property;_NormalMap;Normal Map;12;0;Create;False;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;162;1913.951,984.0372;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;199187dac283dbe4a8cb1ea611d70c58;True;ScenePickingPass;0;4;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;161;1913.951,984.0372;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;199187dac283dbe4a8cb1ea611d70c58;True;SceneSelectionPass;0;3;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;16;1063.237,17.93402;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;199187dac283dbe4a8cb1ea611d70c58;True;Sprite Normal;0;1;Sprite Normal;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;3;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=NormalsRendering;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;17;1063.237,17.93402;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;199187dac283dbe4a8cb1ea611d70c58;True;Sprite Forward;0;2;Sprite Forward;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;3;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;15;1916.141,776.8475;Float;False;True;-1;2;NotSlot.HandPainted2D.Editor.SpriteShaderInspector;0;13;Hand Painted 2D/Sprite Wind;199187dac283dbe4a8cb1ea611d70c58;True;Sprite Lit;0;0;Sprite Lit;6;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;7;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;DisableBatching=True=DisableBatching;PreviewType=Plane;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;3;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;3;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;5;True;True;True;True;True;False;;False;0
WireConnection;5;0;4;0
WireConnection;5;7;4;1
WireConnection;25;0;12;0
WireConnection;25;1;5;0
WireConnection;87;26;25;0
WireConnection;9;0;18;0
WireConnection;9;7;18;1
WireConnection;31;1;25;0
WireConnection;31;0;87;0
WireConnection;10;0;19;0
WireConnection;10;7;19;1
WireConnection;15;1;31;0
WireConnection;15;2;9;0
WireConnection;15;3;10;0
WireConnection;15;4;160;0
ASEEND*/
//CHKSM=ACA9DDB587D5C5F090983D8A5AA672F96CE48CBB