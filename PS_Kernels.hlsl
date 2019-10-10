/**
************************
*
*  Kernels
*
************************
*/

sampler Texture0;

float2 fViewportDimensions;

struct PS_INPUT
{
   float2 TexCoords : TEXCOORD0;
};

float4 PS(PS_INPUT Input) : COLOR0
{   
   float2 Defaz = float2(1.0f/fViewportDimensions.x , 1.0f/fViewportDimensions.y);
   
   float a0 = tex2D(Texture0, float2(Input.TexCoords.x - Defaz.x, Input.TexCoords.y + Defaz.y)).x * 0.0625f;
   float a1 = tex2D(Texture0, float2(Input.TexCoords.x,           Input.TexCoords.y + Defaz.y)).x * 0.125f;
   float a2 = tex2D(Texture0, float2(Input.TexCoords.x + Defaz.x, Input.TexCoords.y + Defaz.y)).x * 0.0625f;
   
   float b0 = tex2D(Texture0, float2(Input.TexCoords.x - Defaz.x, Input.TexCoords.y)).x * 0.125f;
   float b1 = tex2D(Texture0, float2(Input.TexCoords.x,           Input.TexCoords.y)).x * 0.25f;
   float b2 = tex2D(Texture0, float2(Input.TexCoords.x + Defaz.x, Input.TexCoords.y)).x * 0.125f;
   
   float c0 = tex2D(Texture0, float2(Input.TexCoords.x - Defaz.x, Input.TexCoords.y - Defaz.y)).x * 0.0625f;
   float c1 = tex2D(Texture0, float2(Input.TexCoords.x,           Input.TexCoords.y - Defaz.y)).x * 0.125f;
   float c2 = tex2D(Texture0, float2(Input.TexCoords.x + Defaz.x, Input.TexCoords.y - Defaz.y)).x * 0.0625f;
   
   return a0 + a1 + a2 + b0 + b1 + b2 + c0 + c1 + c2;
   
}

float4 Kernel(int kFlag, float2 kTexCoordInput, float2 Defaz, sampler Texture0, float3x3 custom = (float3x3)0) {
   float a, b, c, d, e, f, g, h, i;
   /**
   ************************
   *  1 : Blur
   *  2 : Bottom Sobel
   *  3 : Top Sobel
   *  4 : Right Sobel
   *  5 : Left Sobel
   *  6 : Emboss
   *  7 : Outline
   *  8 : Sharpen
   *  9 : Custom
   ************************
   */
   if(kFlag == 1) {
      a = c = g = i = 0.0625f;
      b = d = f = h = 0.125f;
      e = 0.25f;
   }
   else if(kFlag == 2) {
      a = c = -1.0f;
      d = e = f = 0.0f;
      g = i = 1.0f;
      b = -2.0f;
      h = -b;
   }
   else if (kFlag == 3) {
      a = c = 1.0f;
      d = e = f = 0.0f;
      g = i = -1.0f;
      b = 2.0f;
      h = -b;
   }
   else if (kFlag == 4) {
      b = e = h = 0.0f;
      c = i = 1.0f;
      a = g = -1.0f;
      d = -2.0f;
      f = -d;
   }
   else if (kFlag == 5) {
      b = e = h = 0.0f;
      c = i = -1.0f;
      a = g = 1.0f;
      d = 2.0f;
      f = -d;
   }
   else if (kFlag == 6) {
      e = f = h = 1.0f;
      c = g = 0.0f;
      b = d = -1.0f;
      a = -2.0f;
      i = -a;
   }
   else if (kFlag == 7) {
      e = 8.0f;
      a = c = g = i = b = d = f = h = -1.0f;
   }
   else if (kFlag == 8) {
      e = 5.0f;
      a = c = g = i = 0.0f; 
      b = d = f = h = -1.0f;
   }
   else if (kFlag == 9) {
      a = custom[0][0];
      b = custom[0][1];
      c = custom[0][2];

      d = custom[1][0];
      e = custom[1][1];
      f = custom[1][2];

      g = custom[2][0];
      h = custom[2][1];
      i = custom[2][2];
   }
   else {
      a = c = g = i = b = d = f = h = 0.0f;
      e = 1.0f;
   }
   a *= tex2D(Texture0, float2(kTexCoordInput.x - Defaz.x, kTexCoordInput.y + Defaz.y)).x;
   b *= tex2D(Texture0, float2(kTexCoordInput.x,           kTexCoordInput.y + Defaz.y)).x;
   c *= tex2D(Texture0, float2(kTexCoordInput.x + Defaz.x, kTexCoordInput.y + Defaz.y)).x;
   d *= tex2D(Texture0, float2(kTexCoordInput.x - Defaz.x, kTexCoordInput.y)          ).x;
   e *= tex2D(Texture0, float2(kTexCoordInput.x,           kTexCoordInput.y)          ).x;
   f *= tex2D(Texture0, float2(kTexCoordInput.x + Defaz.x, kTexCoordInput.y)          ).x;
   g *= tex2D(Texture0, float2(kTexCoordInput.x - Defaz.x, kTexCoordInput.y - Defaz.y)).x;
   h *= tex2D(Texture0, float2(kTexCoordInput.x,           kTexCoordInput.y - Defaz.y)).x;
   i *= tex2D(Texture0, float2(kTexCoordInput.x + Defaz.x, kTexCoordInput.y - Defaz.y)).x;

   return a + b + c + d + e + f + g + h + i;
}
