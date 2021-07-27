/**
************************
*
*  GBuffer
*
************************
*/
float4x4 matViewProjection;
float4x4 matWorld;

float fFarClipPlane;
float fNearClipPlane;

struct VS_INPUT 
{
   float3 Position : POSITION0;
   float2 TexCoord : TEXCOORD0;
   float3 Tangent  : TANGENT0;
   float3 Binormal : BINORMAL0;
   float3 Normal   : NORMAL0;
};

struct VS_OUTPUT 
{
   float4 Position : POSITION0;
   float3 WorldPos : TEXCOORD0;
   float2 TexCoord : TEXCOORD1;
   float Depth     : TEXCOORD2;
   float3x3 TBN    : TEXCOORD3;
};

VS_OUTPUT VS( VS_INPUT Input )
{
   VS_OUTPUT Output = (VS_OUTPUT)0;
   
   Output.Position = mul(float4(Input.Position.xyz, 1.0f), matWorld);
   Output.WorldPos = Output.Position.xyz;
   Output.Position = mul(Output.Position, matViewProjection);
   Output.TexCoord = Input.TexCoord;
   Output.TBN = float3x3(Input.Tangent, Input.Binormal, Input.Normal);

   //Output.TBN[0] = mul(float4(Input.Tangent, 0.0f), matViewProjection);
   //Output.TBN[1] = mul(float4(Input.Binormal, 0.0f), matViewProjection);
   //Output.TBN[2] = mul(float4(Input.Normal, 0.0f), matWorld);
   //Output.TBN[2] = mul(float4(Input.Normal, 0.0f), matViewProjection);
   //Output.TBN = mul(Output.TBN, (float3x3)matWorld);
   Output.TBN = mul(Output.TBN, (float3x3)matViewProjection);

   Output.Depth = (((Output.Position.z - fNearClipPlane) / (fFarClipPlane - fNearClipPlane)) - 0.5f) * 2.0f;

   return(Output);
}
