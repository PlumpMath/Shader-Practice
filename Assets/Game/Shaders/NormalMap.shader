Shader "Practices/NormalMap" {
	Properties {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpTex ("Normal Texture", 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(-2.0, 2.0)) = 1.0
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
	}
	SubShader {
		Pass {
			Tags { "LightMode"="ForwardBase" }	
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			uniform sampler2D _BumpTex;
			uniform float4 _BumpTex_ST;
			uniform float _BumpDepth;

			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _Shininess;
			uniform float _RimPower;

			uniform float4 _LightColor0;

			struct vertInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct vertOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};

			vertOutput vert(vertInput v)
			{
				vertOutput o;

				o.normalWorld = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
				o.tangentWorld = normalize(mul(_Object2World, v.tangent).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);

				o.posWorld = mul(_Object2World, v.vertex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;

				return o;
			}

			float4 frag(vertOutput i) : COLOR
			{
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				
				float3 lightDirection;
				float atten;

				if (_WorldSpaceLightPos0.w == 0.0)
				{
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1.0/distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				// Texture maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				float4 texIn = tex2D(_BumpTex, i.tex.xy * _BumpTex_ST.xy + _BumpTex_ST.zw);

				// Normal functions
				float3 localCoords = float3(2.0 * texIn.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;
				//localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);

				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

				// Light
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
			
				//  Rim
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = saturate(dot(normalDirection, lightDirection) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower));

				float3 lightFinal = diffuseReflection + specularReflection + rimLighting;

				return float4(tex.xyz * lightFinal * _Color.xyz + UNITY_LIGHTMODEL_AMBIENT.xyz, 1.0);
			}

			ENDCG
		}
		Pass {
			Tags { "LightMode"="ForwardAdd" }	
			Blend One One
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			uniform sampler2D _BumpTex;
			uniform float4 _BumpTex_ST;
			uniform float _BumpDepth;

			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _Shininess;
			uniform float _RimPower;

			uniform float4 _LightColor0;

			struct vertInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct vertOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};

			vertOutput vert(vertInput v)
			{
				vertOutput o;

				o.normalWorld = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
				o.tangentWorld = normalize(mul(_Object2World, v.tangent).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);

				o.posWorld = mul(_Object2World, v.vertex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;

				return o;
			}

			float4 frag(vertOutput i) : COLOR
			{
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				
				float3 lightDirection;
				float atten;

				if (_WorldSpaceLightPos0.w == 0.0)
				{
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1.0/distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				// Texture maps
				float4 texIn = tex2D(_BumpTex, i.tex.xy * _BumpTex_ST.xy + _BumpTex_ST.zw);

				// Normal functions
				float3 localCoords = float3(2.0 * texIn.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;
				//localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);

				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

				// Light
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
			
				//  Rim
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = saturate(dot(normalDirection, lightDirection) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower));

				float3 lightFinal = diffuseReflection + specularReflection + rimLighting;

				return float4(lightFinal * _Color.xyz, 1.0);
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
