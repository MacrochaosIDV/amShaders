float m_PI = 3.14159262f;

float ndfGGX(float dotLightHalf, float RoughnessSQR) {
    float alpha = RoughnessSQR * RoughnessSQR;
    float alphaSQR = alpha * alpha;

    float denom = (dotLightHalf * dotLightHalf) * (alphaSQR - 1.0f) + 1.0f;
    return alphaSQR / (m_PI * denom * denom);
}

float gaSchlickG1(float cosTheta, float k) {
    return( cosTheta/(cosTheta * (1.0f - k) + k));
}

float gaSchlickGGX(float cosLi, float cosLo, float roughness) {
    float r = roughness + 1.0f;
    float k = (r * r) / 8.0f;
    return gaSchlickG1(cosLi, k) * gaSchlickG1(cosLo, k);
}

float3 fresnelSchlick(float3 F0, float cosTheta) {
    return F0 + (1.0f - F0) * pow(1.0f - cosTheta, 5.0f);
}

float3 m_lightPos;
float4 m_eyePos;
sampler AlbedoSampler;
sampler NormalSampler;
sampler MetalnessSampler;
sampler RoughnessSampler;
sampler EmissiveSampler;

sampler IrradianceSampler;
sampler SpecularIBL;
sampler BRDFLut;

struct PS_INPUT
{
   float4 Position : POSITION0;
   float3 PosWorld : TEXCOORD0;
   float2 TexCoord : TEXCOORD1;
   float Depth     : TEXCOORD2;
   float3x3 TBN    : TEXCOORD3;
};

struct PS_OUTPUT
{
   float4 Color : COLOR0;
   float4 NormalDepth : COLOR1;
   float4 Emissive : COLOR2;
   //TODO: add metal, ao, rough & depth
};

PS_OUTPUT PS(PS_INPUT Input) {
    PS_OUTPUT Output = (PS_OUTPUT)0;
    float Epsilon = 0.00001f;
    float fDiElectric = 0.03f;

    float4 albedo = tex2D(AlbedoSampler, Input.TexCoord);
    float3 normal = tex2D(NormalSampler, Input.TexCoord).xyz;
    float metalness = tex2D(MetalnessSampler, Input.TexCoord);
    float roughness = tex2D(RoughnessSampler, Input.TexCoord);
    float3 emissive = tex2D(EmissiveSampler, Input.TexCoord);
    
    normal =  2.0f * normal - 1.0f;
    normal = mul(normal, Input.TBN);
    normal = normalize(normal);

    //return float4(normal, 1.0f);

    float3 lightDir = normalize(m_lightPos - Input.PosWorld);
    float3 viewDir = normalize(m_eyePos.xyz - Input.PosWorld);
    float3 h = normalize(lightDir + viewDir);

    float NdL = max(0.0f, dot(normal, lightDir));
    float NdH = max(0.0f, dot(normal, h));
    float NdV = max(0.0f, dot(normal, viewDir));

    float3 F0 = lerp(fDiElectric, albedo, metalness);

    float G = gaSchlickGGX(NdL, NdV, roughness);
    float3 F = fresnelSchlick(F0, max(0.0f, dot(viewDir, h)));
    float D = ndfGGX(NdH, roughness);

    float3 kd = lerp(1.0f - F, 0.0f, metalness);
    float3 diffuseBRDF = kd * albedo;
    float3 specularBRDF = (F * D * G) / max(Epsilon, 4.0f * NdL * NdV);

    float3 directLighting = (pow(diffuseBRDF, 2.2f) + pow(specularBRDF, 2.2f));
    directLighting = pow(directLighting, 1.0f / 2.2f) * NdL;

    float3 ambienLighting;
    {
        float3 irradiance = texCUBE(IrradianceSampler, normal);
        float3 F2 = fresnelSchlick(F0, NdV);
        float kd2 = lerp(1.0f - F2, 0.0f, metalness);

        float3 diffuseIBL = kd2 * albedo * irradiance;

        uint specularTextureLevels = 9;
        float3 Lr = 2.0f * NdV * normal - viewDir;
        float4 fullReflection = float4(Lr, roughness * specularTextureLevels);
        float3 specularIrradiance = texCUBElod(SpecularIBL, fullReflection).rgb;

        float2 specularBRDF = tex2D(BRDFLut, float2(NdV, roughness)).rg;

        float3 specIBL = (F0 * specularBRDF.x + specularBRDF.y) * specularIrradiance;
        
        ambienLighting = pow(pow(diffuseIBL, 2.2f) + pow(specIBL, 2.2f), 1.0f / 2.2f);
    }

    // Output.Color = flaot4(directLighting + ambienLighting, 1);
    // Output.Emissive = float4(emissive, 1);

    Output.Color = float4( pow(
        pow(directLighting, 2.2f) + pow(ambienLighting,2.2f), 1.0f/2.2f), albedo.w);
    Output.NormalDepth = float4(normal, Input.Depth);
    Output.Emissive = float4(pow(emissive, 2.2f), 1.0f);
    return Output;


    //return float4( pow(
        //pow(directLighting, 2.2f) +
        //pow(ambienLighting,2.2f) +
        //pow(emissive, 2.2f), 1.0f/2.2f), albedo.w);
}