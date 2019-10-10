/**
************************
*
*  Generic Vertex Shader
*
************************
*/
struct VS_INPUT 
{
   float3 Position : POSITION0;
   float2 TexCoords : TEXCOORD0; 
};

struct VS_OUTPUT 
{
   float4 Position  : POSITION0;
   float2 TexCoords : TEXCOORD0;
};

VS_OUTPUT VS(VS_INPUT Input)
{
   VS_OUTPUT Output;

   Output.Position = float4(Input.Position, 1.0f);
   Output.TexCoords = Input.TexCoords;
   
   return(Output);
}