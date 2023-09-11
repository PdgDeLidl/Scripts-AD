                                                ##################################################
                                                #                                                #
                                                #                                                #
                                                #       Départ / Désactivation d'un compte AD    #
                                                #                                                #
                                                #                                                #
                                                # Maxime Gaucher 07/2023                         #
                                                ##################################################


######################################### Création d'un MDP aléatoire ##############################################################

   [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$false)][int]$Length=15,
        [Parameter(Mandatory=$false)][int]$Uppercase=3,
        [Parameter(Mandatory=$false)][int]$Digits=3,
        [Parameter(Mandatory=$false)][int]$SpecialCharacters=3
        )
  
    Begin {
        $Lowercase = $Length - $SpecialCharacters - $Uppercase - $Digits
        $ArrayLowerCharacters = @('a','b','c','d','e','f','g','h','j','k','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
        $ArrayUpperCharacters = @('A','B','C','D','E','F','G','H','J','K','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
        $ArraySpecialCharacters = @('_','*','$','%','#','?','!','-')
    }
    Process {
            [string]$NewPassword = $ArrayLowerCharacters | Get-Random -Count $Lowercase
            $NewPassword += 0..9 | Get-Random -Count $Digits
            $NewPassword += $ArrayUpperCharacters | Get-Random -Count $Uppercase
            $NewPassword += $ArraySpecialCharacters | Get-Random -Count $SpecialCharacters

            $NewPassword = $NewPassword.Replace(' ','')

            $characterArray = $NewPassword.ToCharArray()  
            $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length    
            $NewRandomPassword = -join $scrambledStringArray
}

End{

$Credentials = Get-Credential


##########################  Suppression des Licences, Modification du MDP, Désactivation du compte ...  ################################

$login = Read-Host "`nQuel est le compte à désactiver ex: mgaucher ?" 

if (get-aduser -credential $Credentials -filter {SamAccountName -eq $login})
{
write-host "`nSuppression des Licences, Modification du MDP, Désactivation du compte ..." -ForegroundColor green 

Get-ADUser -credential $Credentials -Identity $login -properties emailaddress,title,department,manager,OfficePhone | Format-Table -AutoSize -Property emailaddress,title,department,manager,OfficePhone

Remove-AdGroupMember -credential $Credentials -Identity GG_App_Office_M365E3-LFM -Members $login -Confirm:$false
Remove-AdGroupMember -credential $Credentials -Identity GG_App_M365_Backup_LFM   -Members $login -Confirm:$false
Remove-AdGroupMember -credential $Credentials -Identity GG_App_Office_Phones-LFM -Members $login -Confirm:$false
Remove-AdGroupMember -credential $Credentials -Identity WEB-VIP                  -Members $login -Confirm:$false
Remove-AdGroupMember -credential $Credentials -Identity VPN-SSL-BASIC            -Members $login -Confirm:$false

Set-ADUser -credential $Credentials -Identity $login -CLear 'employeeID'
Set-ADUser -credential $Credentials -Identity $login -CLear 'telephonenumber'
Set-ADUser -credential $Credentials -Identity $login -Clear 'otherTelephone'
Set-ADUser -credential $Credentials -Identity $login -Clear 'ipPhone'
Set-ADUser -credential $Credentials -Identity $login -Clear 'msRTCSIP-DeploymentLocator'
Set-ADUser -credential $Credentials -Identity $login -Clear 'msRTCSIP-Line'
Set-ADUser -credential $Credentials -Identity $login -Clear 'proxyAddresses'
Set-ADUser -credential $Credentials -Identity $login -Clear 'proxyAddresses'


$SecureStringPassword = ConvertTo-SecureString -AsPlainText -Force $NewRandomPassword
Set-ADAccountPassword -credential $Credentials -Identity $login -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $SecureStringPassword -Force)


$DN = Get-ADUser -credential $Credentials -filter {samaccountname -eq $login} -properties DistinguishedName 
Move-ADObject -credential $Credentials -Identity "$DN" -TargetPath "OU=ZZ Deactivated,OU=ACCOUNTS,OU=_GLOBAL,DC=groupelafuma,DC=lafuma,DC=com"
Disable-ADAccount -credential $Credentials -Identity $login 


write-host "`nCompte désactivé" -ForegroundColor green 
}
else{write-host "`n Cet utilisateur n'existe pas" -ForegroundColor Red}
}


 
