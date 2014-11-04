# Load the IntegrationServices Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;

# Store the IntegrationServices Assembly namespace to avoid typing it every time
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

Write-Host "Connecting to SQLDEMO01 ..."

# Create a connection to the server
$sqlConnectionString = "Data Source=SQL2014DEMO01\SQLDEMO01;Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString

# Create the Integration Services object
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection

Write-Host "Removing previous catalog ..."

# Drop the existing catalog if it exists
if ($integrationServices.Catalogs.Count -gt 0) { $integrationServices.Catalogs["SSISDB"].Drop() }

Write-Host "Connecting to SQLDEMO02 ..."

# Create a connection to the server
$sqlConnectionString2 = "Data Source=SQL2014DEMO01\SQLDEMO02;Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection2 = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString2

# Create the Integration Services object
$integrationServices2 = New-Object $ISNamespace".IntegrationServices" $sqlConnection2

Write-Host "Removing previous catalog ..."

# Drop the existing catalog if it exists
if ($integrationServices2.Catalogs.Count -gt 0) { $integrationServices2.Catalogs["SSISDB"].Drop() }



Write-Host "All done."