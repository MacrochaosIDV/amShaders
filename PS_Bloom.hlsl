/**
************************
*
*  Bloom 
*
************************
*/

sampler Texture0;
sampler Texture1;

float Exposition;

struct PS_INPUT
{
   float2 TexCoors : TEXCOORD0;
};

float4 PS(PS_INPUT Input) : COLOR0
{   
   float4 Color = tex2D(Texture0, Input.TexCoors);
   float4 Luminance = tex2D(Texture1, Input.TexCoors);
   
   float4 conv = Color + (Luminance * Exposition);
   
   return(pow(conv, 1.0f/2.2f));
}