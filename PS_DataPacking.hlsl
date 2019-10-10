// Depth pass vertex shader
output.vPositionCS = mul(input.vPositionOS, g_matWorldViewProj);
output.vDepthCS.xy = output.vPositionCS.zw;

// Depth pass pixel shader (output z/w)
return input.vDepthCS.x / input.vDepthVS.y;

// Function for converting depth to view-space position
// in deferred pixel shader pass.  vTexCoord is a texture
// coordinate for a full-screen quad, such that x=0 is the
// left of the screen, and y=0 is the top of the screen.
float3 VSPositionFromDepth(float2 vTexCoord)
{
    // Get the depth value for this pixel
    float z = tex2D(DepthSampler, vTexCoord);  
    // Get x/w and y/w from the viewport position
    float x = vTexCoord.x * 2 - 1;
    float y = (1 - vTexCoord.y) * 2 - 1;
    float4 vProjectedPos = float4(x, y, z, 1.0f);
    // Transform by the inverse projection matrix
    float4 vPositionVS = mul(vProjectedPos, g_matInvProjection);  
    // Divide by w to get the view-space position
    return vPositionVS.xyz / vPositionVS.w;  
}