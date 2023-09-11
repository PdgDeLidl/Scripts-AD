                        ###########################################################
                        #              Création de comptes AD                     #
                        #           (A exec avec compte ope ou adm)               #
                        #                                                         #
                        # Maxime Gaucher 07/2023               v1                 #
                        ###########################################################



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
    
############################################## Informations de l'utilisateur #######################################################################
  
  $Credentials = Get-Credential

  Write-Host "`n`nCréation d'un utilisateur Active Directory `n" -foregroundcolor green
                           
                            $name = Read-Host "Prénom ?"
                            $sn = Read-Host "Nom ?"
                            $login = Read-Host "Login ?"
                            $mailsuffixe = Read-Host "@.... ?"
                            $mail = "$login@$mailsuffixe"
                            $title = Read-Host "Fonction ?"
                            $department = Read-Host "Service ?"
                            $company = Read-Host "Société ?"
                            $manager1 = Read-Host "Responsable (Prénom NOM) ?"
                            $manager2 = Get-ADUser -filter "cn -eq '$manager1'"
                            $SecureStringPassword = ConvertTo-SecureString -AsPlainText -Force $NewRandomPassword
                            

                            
                            $telephoneNumber = Read-Host "Numéro de téléphone ?"
                            $ipPhone = Read-Host "IpPhone ?"

                            
                            $employeeID = Read-Host "Matricule Horoquartz  ?"


################################################ Création de l'utilisateur #####################################################################################

                New-ADUser -credential $Credentials `
                `
                           -Name "$name $sn" `
                           -DisplayName "$name $sn" `
                           -givenname $name `
                           -samAccountName $login `
                           -userPrincipalName $mail `
                           -emailAddress $mail `
                           -title "$title" `
                           -department "$department" `
                           -company "$company" `
                           -manager "$manager2" `
                           -OfficePhone $telephoneNumber `
                           -Path "OU=USERS,OU=ACCOUNTS,OU=FR,OU=_EMEA,DC=groupelafuma,DC=lafuma,DC=com" `
                           -AccountPassword $SecureStringPassword `
                           -ChangePasswordAtLogon $false `
                           -Enabled $false `

Add-ADGroupMember -Credential $Credentials -Identity "GG_App_Office_M365E3-LFM" -Members "$login"
Add-ADGroupMember -Credential $Credentials -Identity "GG_App_Office_Phones-LFM" -Members "$login"
Add-ADGroupMember -Credential $Credentials -Identity "GG_App_M365_Backup_LFM"   -Members "$login"
Add-ADGroupMember -Credential $Credentials -Identity "WEB-VIP"                  -Members "$login"
Add-ADGroupMember -Credential $Credentials -Identity "VPN-SSL-BASIC"            -Members "$login"

Set-ADUser -Credential $Credentials -Identity $login -Replace @{'employeeID'=$employeeID}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'otherTelephone'=$telephoneNumber}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'ipPhone'=$ipPhone}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'msRTCSIP-DeploymentLocator'="sipfed.online.lync.com"}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'msRTCSIP-Line'=$telephoneNumber}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'proxyAddresses'="SMTP:$mail"}
Set-ADUser -Credential $Credentials -Identity $login -Replace @{'proxyAddresses'="smtp:$name.$sn@calida365.onmicrosoft.com"}


if (Get-ADUser -Credential $Credentials -Filter {SamAccountName -eq $login})
    {
        Write-Host "`nL'utilisateur : $UtilisateurLogin ($sn $name) a été créé" -ForegroundColor Green
        Write-Host "`n Informations de connexion : $mail / $NewRandomPassword" -ForegroundColor Yellow

        Read-Host "`n Appuyer sur 'Entrée' pour quitter ... "
       
        
    }
else{
    Write-Host "Une erreur est survenue" -ForegroundColor Red 
    
    Read-Host "`n Appuyez sur 'Entrée' pour quitter ... "                     
}
}
