                            #################################################
                            # Générateur / Réinitialisation de Mot de passe #
                            #                                               # 
                            # 08/2023                       Maxime Gaucher  #  
                            #################################################

#Ce script génère un mot de passe aléatoire respectant la politique de mot de passe
#Réinitialise le mot de passe de l'utilisateur 
#Débloque son compte dans le cas où celui-ci serait bloqué
#Il ne demande pas à l'utilisteur de changer son mdp à la prochaine connexion

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
$choix = Read-Host "`n 1 : Générer un Mot de passe `n`n 2 : Rénitialiser un mot de passe"

switch($choix){ 

"1"{
Write-host "`n Mot de passe généré : $NewRandomPassword" -ForegroundColor Green
Read-host "`n Appuyez sur Entrée pour quitter ... " 
}
"2"{
$Credentials = Get-Credential

$choix2 = Read-host "`n Recherche à l'aide de : `n`n 1 = Prénom Nom ? `n 2 = Login ?`n"

switch($choix2){

            "1"{$pn = Read-Host "`n Prénom Nom  ?"

            if( Get-aduser -credential $Credentials -filter {displayname -eq $pn}){

           
            Set-ADAccountPassword -credential $Credentials -Identity $login -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewRandomPassword" -Force)
            Unlock-ADAccount -credential $Credentials -Identity $login 

            Write-host "`n Le mot de passe de $pn a été modifié par : $NewRandomPassword" -ForegroundColor Green
            Read-host "`n Appuyez sur Entrée pour quitter ... "} 

            else{
            Write-host "`n Utilisateur introuvable" -ForegroundColor Red 
            Read-host "`n Appuyez sur Entrée pour quitter ... "}}



            "2" {$login = Read-Host "`n Login  ?"

            if( Get-aduser -credential $Credentials -filter {samaccountname -eq $login}){

            
            Set-ADAccountPassword -credential $Credentials -Identity $login -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewRandomPassword" -Force)
            Unlock-ADAccount -credential $Credentials -Identity $login

            Write-host "`n Le mot de passe de $login a été modifié par : $NewRandomPassword" -ForegroundColor Green
            Read-host "`n Appuyez sur Entrée pour quitter ... "}

            else{
            Write-host "`n Login introuvable" -ForegroundColor Red 
            Read-host "`n Appuyez sur Entrée pour quitter ... "}}}
}
}}


                                                                                    #Debug#

#  "Get-aduser : Le serveur a rejeté les informations d'identification du client."           = Mot de passe éronné
#  "Set-ADAccountPassword : Accès refusé"                                                    = L'utilisateur n'a pas les droits pour réinitialiser un mot de passe
