#pragma once

#include "application/application.hpp"

namespace OM
{
	class Gamepad;

	class OmAppV3 : public Application
	{
// :TODO:
	public:
		void			registerGamepad( Gamepad* pGamepad ){}
		void			deregisterGamepad( Gamepad* pGamepad ){}
		bool			isFullyInitialized() const { return true; }
		bool			isUiTestRunning() const { return false; }
		const char*     getAppStatus() const { return ""; }

		bool	initialize( int argc, char *argv[] ) override;
		void	shutdown() override;
		bool	update( double timeStep ) override;
		void	render( ) override;
	};

}
