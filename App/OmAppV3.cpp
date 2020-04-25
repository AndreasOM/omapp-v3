#include "OmAppV3.hpp"

#include "base/archivefilesystem.hpp"
#include "base/debug.hpp"
#include "base/diskfilesystem.hpp"
#include "base/layeredfilesystem.hpp"
#include "base/nativefilesystem.hpp"

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
		
		m_pRenderer = Renderer::createDefault();
		m_pRenderer->initialize();

		// :TODO: register render effects
		// :TODO: load texture atlas(es)
		// :TODO: register fonts
		
		m_pRenderer->setSize( m_width, m_height );
		
		return true;
	}

	void OmAppV3::shutdown()
	{
		OM_TRACE( "OmAppV3::shutdown\n" );
		
		m_pRenderer->shutdown();
		delete m_pRenderer;
		m_pRenderer = nullptr;
		
		teardownFilesystem();
	}

	bool OmAppV3::update( double timeStep )
	{
		OM_TRACE( "OmAppV3::update\n" );
		return false;	// NOT done
	}

	void OmAppV3::render( )
	{
		OM_TRACE( "OmAppV3::render\n" );
		float l = -1.0f;
		float r =  1.0f;
		float t =  1.0f;
		float b = -1.0f;
		float n =  1.0f;
		float f = -1.0f;
		m_pRenderer->setMVPMatrixOrtho( l, r, b, t, n, f );
		m_pRenderer->beginFrame();
		
		// :TODO: render something
		
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
