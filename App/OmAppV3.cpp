#include "OmAppV3.hpp"

#include "base/debug.hpp"

namespace OM
{

	bool OmAppV3::initialize( int argc, char *argv[] )
	{
		OM_TRACE( "OmAppV3::initialize" );
		return true;
	}

	void OmAppV3::shutdown()
	{
		OM_TRACE( "OmAppV3::shutdown" );
	}

	bool OmAppV3::update( double timeStep )
	{
		OM_TRACE( "OmAppV3::update" );
	}

	void OmAppV3::render( )
	{
		OM_TRACE( "OmAppV3::render" );
	}

}
