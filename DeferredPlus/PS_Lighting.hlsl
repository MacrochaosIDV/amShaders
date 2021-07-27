/**
************************
*
*  Lighting
*
************************
*/
sampler Texture0;
sampler Texture1;
sampler Texture2;
sampler Texture3;
sampler Texture4;
float4 vViewPosition;
float3 LightPos;
float SpecPower;

struct PS_INPUT 
{
   float4 Position : POSITION0;
   float2 TexCoords : TEXCOORD0;
};

struct PS_OUTPUT 
{
   float4 Luminance : COLOR0;
   float4 Light     : COLOR1;
};

PS_OUTPUT PS(PS_INPUT Input)
{  
   PS_OUTPUT Output = (PS_OUTPUT)0;
   
   float4 position = tex2D(Texture1, Input.TexCoords);
   if(position.w <1.0f) {
      return Output;
   }
   
   float4 normal = tex2D(Texture0, Input.TexCoords);
   float4 color = tex2D(Texture2, Input.TexCoords);
   float4 ao = tex2D(Texture3, Input.TexCoords);
   float4 ilb = pow(texCUBE(Texture4, normal), 2.2f) * 2.5f;
   
   float3 DirLight = normalize(LightPos - position.xyz);
   float3 DirView = normalize(vViewPosition.xyz - position);
   float3 Reflection = normalize(reflect(-DirLight, normal));
   
   float DiffIncidence = saturate(dot(DirLight, normal));
   float SpecularIncidence = max(0.0f, dot(DirView, Reflection));
   SpecularIncidence = pow(SpecularIncidence, SpecPower);
   
   float4 finalColor = ((color * DiffIncidence) + ilb + SpecularIncidence);// * ao; 
   float3 LumFactor = float3(0.3f, 0.6f, 0.03f);
   float Luminance = log(dot(finalColor.xyz, LumFactor) + 0.00001f);
   
   Output.Light = finalColor;
   Output.Luminance = Luminance;
   
   return Output;
}