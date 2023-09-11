Try{
Import-Module MicrosoftTeams

$User = "support.avanade@calida365.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String "Supp0rtAv@n@d3" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

   Connect-MicrosoftTeams -Credential $credential     

$qui = read-host "Login ?"   
Set-CsPhoneNumberAssignment -Identity "$qui@lafuma-mobilier.fr" -EnterpriseVoiceEnabled $true 

Get-CsOnlineUser -Identity "$qui@lafuma-mobilier.fr" | fl UserPrincipalName,EntrepriseVoiceEnabled,OnPremSIPEnabled
 
}

Catch{Write-Host "Une erreur s'est produite"
      Write-HOst "$_"}

Write-host "`n ..." -ForegroundColor Green






