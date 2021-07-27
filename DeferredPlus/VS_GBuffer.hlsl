/**
************************
*
*  GBuffer
*
************************
*/
float4x4 matViewProjection;
//float4x4 matViewProjectionInverse;
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
   
   //float angle = fTime0_2PI * 5;
   
   //float4x4 matRot = { cos(angle),  0, sin(angle), 0,
   //                    0,           1, 0,          0,
   //                    -sin(angle), 0, cos(angle), 0,
   //                    0,           0, 0,          1};
                       
   //float4x4 matTransform = mul(matWorld, matRot);
   //matTrans = mul(matTrans, matView);

   //float4 tmpPosW = mul(Input.Position, matTransform);
   //Output.WorldPos = tmpPosW.xyz;
   //Output.Position = mul( tmpPosW, matViewProjection );
   //Output.TexCoord = float2(Input.TexCoord.x, 1.0f - Input.TexCoord.y);


   Output.Position = mul(float4(Input.Position.xyz, 1.0f), matWorld);
   Output.WorldPos = Output.Position.xyz;
   Output.Position = mul(Output.Position, matViewProjection);
   Output.TexCoord = Input.TexCoord;
   Output.TBN = float3x3(Input.Tangent, Input.Binormal, Input.Normal);
   Output.TBN = mul(Output.TBN, (float3x3)matWorld);
   //Output.Depth = (1.f - (Output.Position.z - fNearClipPlane) / (fFarClipPlane - fNearClipPlane));
   //Output.Depth = (1.f - ((Output.Position.z - fNearClipPlane) / (fFarClipPlane - fNearClipPlane)) * 2);
   Output.Depth = 1.0f - (Output.Position.z - fNearClipPlane) / (fFarClipPlane - fNearClipPlane);
   //Output.Depth = Output.Position.z;

   return(Output);
}
