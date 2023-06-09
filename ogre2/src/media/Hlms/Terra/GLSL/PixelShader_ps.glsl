@insertpiece( SetCrossPlatformSettings )
@property( GL3+ < 430 )
	@property( hlms_tex_gather )#extension GL_ARB_texture_gather: require@end
@end
@insertpiece( SetCompatibilityLayer )

@insertpiece( DeclareUvModifierMacros )

layout(std140) uniform;
#define FRAG_COLOR		0


@insertpiece( DefaultTerraHeaderPS )

// START UNIFORM DECLARATION
@property( !hlms_shadowcaster )
	@insertpiece( PassStructDecl )
	@insertpiece( TerraMaterialStructDecl )
	@insertpiece( TerraInstanceStructDecl )
@end
@insertpiece( custom_ps_uniformDeclaration )
// END UNIFORM DECLARATION

in block
{
	@insertpiece( Terra_VStoPS_block )
} inPs;

@property( !hlms_render_depth_only )
	@property( !hlms_shadowcaster )
		@property( !hlms_prepass )
			layout(location = @counter(rtv_target), index = 0) out vec4 outColour;
		@end
		@property( hlms_gen_normals_gbuffer )
			#define outPs_normals outNormals
			layout(location = @counter(rtv_target)) out vec4 outNormals;
		@end
		@property( hlms_prepass )
			#define outPs_shadowRoughness outShadowRoughness
			layout(location = @counter(rtv_target)) out vec2 outShadowRoughness;
		@end
	@else
		layout(location = @counter(rtv_target), index = 0) out float outColour;
	@end
@end

@property( !hlms_shadowcaster )

@property( hlms_use_prepass )
	@property( !hlms_use_prepass_msaa )
		uniform sampler2D gBuf_normals;
		uniform sampler2D gBuf_shadowRoughness;
	@else
		uniform sampler2DMS gBuf_normals;
		uniform sampler2DMS gBuf_shadowRoughness;
		uniform sampler2DMS gBuf_depthTexture;
	@end

	@property( hlms_use_ssr )
		uniform sampler2D ssrTexture;
	@end
@end

@insertpiece( DeclPlanarReflTextures )
@insertpiece( DeclAreaApproxTextures )

@property( hlms_vpos )
in vec4 gl_FragCoord;
@end

uniform sampler2D terrainNormals;
uniform sampler2D terrainShadows;

@property( hlms_forwardplus )
/*layout(binding = 1) */uniform usamplerBuffer f3dGrid;
/*layout(binding = 2) */uniform samplerBuffer f3dLightList;
@end
@property( irradiance_volumes )
	uniform sampler3D irradianceVolume;
@end

@foreach( num_textures, n )
	uniform sampler2DArray textureMaps@n;@end

@property( !hlms_enable_cubemaps_auto )
	@property( use_envprobe_map )uniform samplerCube		texEnvProbeMap;@end
@else
	@property( !hlms_cubemaps_use_dpm )
		@property( use_envprobe_map )uniform samplerCubeArray	texEnvProbeMap;@end
	@else
		@property( use_envprobe_map )uniform sampler2DArray	texEnvProbeMap;@end
		@insertpiece( DeclDualParaboloidFunc )
	@end
@end

@property( use_parallax_correct_cubemaps )
	@insertpiece( DeclParallaxLocalCorrect )
@end

@insertpiece( DeclDecalsSamplers )

@insertpiece( DeclShadowMapMacros )
@insertpiece( DeclShadowSamplers )
@insertpiece( DeclShadowSamplingFuncs )

@insertpiece( DeclAreaLtcTextures )
@insertpiece( DeclAreaLtcLightFuncs )

@insertpiece( DeclVctTextures )

@insertpiece( custom_ps_functions )

void main()
{
	@insertpiece( custom_ps_preExecution )
	@insertpiece( DefaultTerraBodyPS )
	@insertpiece( custom_ps_posExecution )
}
@else /// !hlms_shadowcaster

@insertpiece( DeclShadowCasterMacros )
@property( hlms_shadowcaster_point || exponential_shadow_maps )
	@insertpiece( PassStructDecl )
@end

void main()
{
	@insertpiece( custom_ps_preExecution )
	@insertpiece( DefaultBodyPS )
	@insertpiece( custom_ps_posExecution )
}
@end
