/**
************************
*
*  GBuffer
*
************************
*/

samplerCUBE Texture3;
sampler Diffuse;
sampler AO;
sampler Normals;
float4 AmbientColor;
float4 vViewPosition;
float3 LightPos;
float SpecPower;

struct PS_INPUT 
{
   float3 WorldPos : TEXCOORD0;
   float2 TexCoord : TEXCOORD1;
   float3x3 TBN    : TEXCOORD2;
   float Depth     : TEXCOORD5;
};

struct PS_OUPUT 
{
   float4 Position : COLOR0;
   float4 Normal   : COLOR1;
   float4 Color    : COLOR2;
   float4 Depth    : COLOR3;
};


PS_OUPUT ps_main(PS_INPUT Input)
{   
   PS_OUPUT Output = (PS_OUPUT)0;
   
   //Normals
   float3 normal = normalize(2.0f * tex2D(Normals, Input.TexCoord) - 1.0f);
   normal = normalize(mul(normal, Input.TBN));
   //return float4(normal, 1.0f);
   
   //Diffuse
   float3 lightDir = normalize(LightPos - Input.WorldPos);
   float DiffIncidence = saturate(dot(lightDir, normal));
   
   //Specular
   float3 DirView = normalize(vViewPosition.xyz - Input.WorldPos);
   float3 Reflection = normalize(reflect(-lightDir, normal));
   float SpecularIncidence = max(0.0f, dot(DirView, Reflection));
   SpecularIncidence = pow(SpecularIncidence, SpecPower);
   
   //Half
   float3 Half = normalize(DirView + lightDir);
   float BlinnIncidence = max(0, dot(DirView, Half));
   BlinnIncidence = pow(SpecularIncidence, 1.0f);
   //return BlinnIncidence;
   
   //Texture colors
   float4 Diffusecolor = tex2D(Diffuse, Input.TexCoord);
   float AmbientOcclusion = tex2D(AO, Input.TexCoord);
   
   //Reflections
   float3 RefV = normalize(reflect(-DirView, normal));
   float4 RefColor = texCUBE(Texture3, RefV);
   
   //return RefColor;
   
   Output.Position = float4(Input.WorldPos, 1.0f);
   Output.Normal = float4(normal, 1.0f);
   Output.Color = Diffusecolor;
   Output.Depth = Input.Depth;
   //Output.Position = float4(Input.WorldPos, 1.0f);
   
   return Output;
   
   //return (DiffIncidence * Diffusecolor)  
   //        + (SpecularIncidence) 
   //        + (BlinnIncidence) 
   //        + (RefColor * AmbientColor)
   //        * (AmbientOcclusion);
}