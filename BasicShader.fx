//--------------------------------------------------------------------------------------
// File: Tutorial07.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D txDiffuse : register( t0 );
SamplerState samLinear : register( s0 );

cbuffer cbVP : register( b0 )
{
    float4x4 matViewProjection;
};


//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float3 Pos   : POSITION0;
    float2 Tex   : TEXCOORD0;
	float3 Normal: NORMAL0;
    
};

struct PS_INPUT
{
    float4 Pos   : SV_Position;
	float4 Color : COLOR0;
    float2 Tex   : TEXCOORD0;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;
    //output.Pos = mul( input.Pos, matViewProjection );
	output.Pos = float4(input.Pos.xyz, 1.0f);
    output.Tex = input.Tex;
	output.Color = input.Color;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input) : SV_Target0
{
	return float4(input.Color.xyz, 1.0f);
    //return float4(0.3f, 0.6f, 0.03f, 1.0f);
    //return txDiffuse.Sample( samLinear, input.Tex ) * input.Color;
}
