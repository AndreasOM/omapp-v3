#pragma once

#include "application/application.hpp"

#include "renderer.hpp"

namespace OM
{
	class Filesystem;
	class Gamepad;
	class LayeredFilesystem;
	
	class OmAppV3 : public Application
	{
// :TODO:
		using BaseClass = Application;
	public:
		void			registerGamepad( Gamepad* pGamepad ){}
		void			deregisterGamepad( Gamepad* pGamepad ){}
		bool			isFullyInitialized() const { return true; }
		bool			isUiTestRunning() const { return false; }
		const char*		getAppStatus() const { return ""; }

		bool			initialize( int argc, char *argv[] ) override;
		void			shutdown() override;
		bool			update( double timeStep ) override;
		void			render( ) override;
	private:
		bool			setupFilesystem();
		void			teardownFilesystem();
		
		bool			setupRenderer();
		void			teardownRenderer();
		
		bool			addFilesystemLayerFromArchiveFile(Filesystem *pFilesystem, const char* pPakefilename);
		bool			addFilesystemLayerFromDiskPath(const char* pPath);

		LayeredFilesystem*		m_pLayeredFilesystem	= nullptr;
		Renderer*				m_pRenderer				= nullptr;
		
		double					m_totalTime				= 0.0f;
	};

}

