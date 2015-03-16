[CmdletBinding()]
Param(
[Parameter(Mandatory=$True, Position=1)]
$solutionFile,
[Parameter(Mandatory=$True, Position=2)]
$duplicateReportFile, 
[int]$discardcost=10
)

$scriptPath= (split-path -parent -Path $MyInvocation.MyCommand.Definition)
$xsl ="$scriptPath\dupfinder.xsl"
$dupFinder = "$scriptPath\..\..\Lib\Resharper\CLI\Dupfinder.exe"
$discards = ("/discard-fields=$false", "/discard-literals=$true", "/discard-local-vars=$false", "/discard-cost=$discardcost")

if(!(Test-Path $dupFinder)){
  Write-Host $dupFInder "is not found. Download Resharper API. By convention, this script expects under ..\Resharper\CLI. Update this script with the right path if it's at different location"
  exit -1
}

function TransformXml ($xmlFile,$xslFile,$output)
{
	$uri = New-Object System.Uri($xslFile)
	[string]$xslUri = $uri.AbsoluteUri
	$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
	$xslt.Load($xslUri)
	$xslt.Transform($xmlFile, $output)
}

function MakeXmlFileNameFromReportFileName($html){
	$ext = [io.path]::GetExtension($html)
	$xml= $html -replace $ext, ".xml" 
	return $xml
}

$xml = MakeXmlFileNameFromReportFileName($duplicateReportFile)
& $dupFinder $discards /show-text $solutionFile /output=$xml
TransformXml $xml $xsl $duplicateReportFile
write-host "report is generated at" $duplicateReportFile
& $duplicateReportFile
