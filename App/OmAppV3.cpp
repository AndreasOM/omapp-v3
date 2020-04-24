#include "OmAppV3.hpp"

#include "base/debug.hpp"

namespace OM
{

	bool OmAppV3::initialize( int argc, char *argv[] )
	{
		OM_TRACE( "OmAppV3::initialize\n" );
		
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

}
