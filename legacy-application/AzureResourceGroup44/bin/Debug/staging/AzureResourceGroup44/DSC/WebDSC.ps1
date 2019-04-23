Configuration Main
{

Param ( [string] $nodeName, [string] $webDeployPackage )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
   		# Install the IIS role 
		WindowsFeature IIS 
		{ 
			Ensure          = "Present" 
			Name            = "Web-Server" 
		} 
		# Install the ASP .NET 4.5 role 
		WindowsFeature AspNet45 
		{ 
			Ensure          = "Present" 
			Name            = "Web-Asp-Net45" 
		} 
	   
		Script DeployWebPackage
		{
			GetScript = {@{Result = "DeployWebPackage"}}
			TestScript = {$false}
			SetScript ={
				[system.io.directory]::CreateDirectory("C:\WebApp")
				$dest = "C:\WebApp\Site.zip" 
				Remove-Item -path "C:\inetpub\wwwroot" -Force -Recurse -ErrorAction SilentlyContinue
				Invoke-WebRequest $using:webDeployPackage -OutFile $dest
				Add-Type -assembly "system.io.compression.filesystem"
				[io.compression.zipfile]::ExtractToDirectory($dest, "C:\inetpub\wwwroot")
			}
			DependsOn  = "[WindowsFeature]IIS"
		}

		# Copy the website content 
		File WebContent 
		{ 
			Ensure          = "Present" 
			SourcePath      = "C:\WebApp"
			DestinationPath = "C:\Inetpub\wwwroot"
			Recurse         = $true 
			Type            = "Directory" 
			DependsOn       = "[Script]DeployWebPackage" 
		}    
	
  }
}