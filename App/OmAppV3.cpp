#include "OmAppV3.hpp"

#include "base/archivefilesystem.hpp"
#include "base/debug.hpp"
#include "base/diskfilesystem.hpp"
#include "base/layeredfilesystem.hpp"
#include "base/nativefilesystem.hpp"

#include "rendereffecttexturedcolored.hpp"

namespace OM
{

	bool OmAppV3::initialize( int argc, char *argv[] )
	{
		OM_TRACE( "OmAppV3::initialize\n" );
		
		if( !BaseClass::initialize(argc, argv))
		{
			return false;
		}
		
		setupFilesystem();
		setupRenderer();
		
		return true;
	}

	void OmAppV3::shutdown()
	{
		OM_TRACE( "OmAppV3::shutdown\n" );
		
		teardownRenderer();
		teardownFilesystem();
	}

	bool OmAppV3::update( double timeStep )
	{
//		OM_TRACE( "OmAppV3::update\n" );
		m_totalTime += timeStep;
		return false;	// NOT done
	}

	void OmAppV3::render( )
	{
//		OM_TRACE( "OmAppV3::render\n" );
		float fs = ( 1024.0f/m_height );	// fixed "virtual height" of 1024;
		
		float s = 0.5f * fs;
		float r =  s*m_width;
		float l = -s*m_width;
		float b = -s*m_height;
		float t =  s*m_height;

		float n =  1.0f;
		float f = -1.0f;
		
		m_pRenderer->setMVPMatrixOrtho( l, r, b, t, n, f );
		m_pRenderer->beginFrame();
		
		// :TODO: render something
	
		m_pRenderer->useRenderEffect( 1 );
		m_pRenderer->useTexture( 0 );
		f32 x = -0.5f;
		f32 y = -0.5f;
		
//		const float col4[4] = { 0.8f, 0.2f, 0.2f, 0.9f };
		const float col4[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
		m_pRenderer->setColorV4( col4 );

		m_pRenderer->addTexturedFullscreenQuad();
		m_pRenderer->addTexturedQuad( x, y, 256, 256, 0.1f*m_totalTime );
		
		m_pRenderer->endFrame();
	}

	
	// :TODO: in future versions of the framework the bootstrap filesystem, and the save filesystem will be passed in by the startup code
	
	bool OmAppV3::setupFilesystem()
	{
		m_pLayeredFilesystem = new LayeredFilesystem();
		
		Filesystem* pBootstrapFilesystem = new DiskFilesystem( "." );
		pBootstrapFilesystem->initialize();
		
		Filesystem::setDefault( pBootstrapFilesystem );
		
		if( !addFilesystemLayerFromArchiveFile( pBootstrapFilesystem, "data/base.omar" ) )
		{
			OM_BREAK( "Base archive not found!" );
			return false;
		}

		Filesystem::setDefault( m_pLayeredFilesystem );

		return true;
	}

	void OmAppV3::teardownFilesystem()
	{
		
	}
	
	
	bool OmAppV3::setupRenderer()
	{
		m_pRenderer = Renderer::createDefault();
		m_pRenderer->initialize();

		{
			RenderEffect* pRenderEffect = new RenderEffect();
			pRenderEffect->initialize( 0 );											// :TODO: handle base rendereffect ids
			pRenderEffect->loadShaders( "RenderEffect.vsh", "RenderEffect.fsh" );
	//		pRenderEffect->loadShaders( "RenderEffectColored.vsh", "RenderEffectColored.fsh" );
			m_pRenderer->registerRenderEffect( pRenderEffect );
		}
		{
			RenderEffect* pRenderEffect = new RenderEffectTexturedColored();
			pRenderEffect->initialize( 1 );											// :TODO: handle base rendereffect ids
	//		pRenderEffect->loadShaders( "RenderEffect.vsh", "RenderEffect.fsh" );
			pRenderEffect->loadShaders( "RenderEffectTexturedColored.vsh", "RenderEffectTexturedColored.fsh" );
			m_pRenderer->registerRenderEffect( pRenderEffect );
		}
		
		
		// :TODO: register render effects
		// :TODO: load texture atlas(es)
		// :TODO: register fonts

		m_pRenderer->setSize( m_width, m_height );

		// set some sane backup defaults
		m_pRenderer->useRenderEffect( 0 );
		m_pRenderer->useLayer( 0 );
		m_pRenderer->useTexture( 0 );

		return true;
	}
	
	void OmAppV3::teardownRenderer()
	{
		m_pRenderer->shutdown();
		delete m_pRenderer;
		m_pRenderer = nullptr;
	}
	
#pragma MARK - helper
	bool OmAppV3::addFilesystemLayerFromArchiveFile(Filesystem *pFilesystem, const char *pPakefilename)
	 {
		char filename[ 1024 ];
		NativeFilesystem::getDataPathFor( pPakefilename, filename, sizeof( filename ) );
		File* pArchiveFileBase = new File( filename, FileAccessMode_Read );
		if( pArchiveFileBase->isReady() )
		{
			auto pArchiveFilesystem = new ArchiveFilesystem( pArchiveFileBase, 20 );
			m_pLayeredFilesystem->addFilesystem( *pArchiveFilesystem );
			return true;
		}
		else
		{
			return false;
		}
	 }
	 
	 bool OmAppV3::addFilesystemLayerFromDiskPath(const char *pPath)
	 {
		auto pDiskFilesystem = new DiskFilesystem(pPath, 16);
		m_pLayeredFilesystem->addFilesystem(*pDiskFilesystem);
		
		return true;
	 }

}
