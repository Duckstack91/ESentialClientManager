#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

# Sample function that provides the location of the script
function Get-ScriptDirectory
{
    <#
    .SYNOPSIS
        Get-ScriptDirectory returns the proper location of the script.

    .OUTPUTS
        System.String

    .NOTES
        Returns the correct path within a packaged executable.
    #>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}
#Passwort Verlängern Suchen Button
function findtext2
{
	if ($textboxFind.Text.Length -eq 0)
	{
		return
	}
	
	$user = $textboxFind.text
	$Today = Get-Date
	
	# Assuming $User contains the search string
	$UserInfo = Get-ADUser -Filter "surname -like '$User*' -or Givenname -like '$User*' -or name -like '*$User*'" -Properties DisplayName, msDS-UserPasswordExpiryTimeComputed, lockedout
	
	# Überprüfen, ob der Benutzer gefunden wurde
	if ($null -eq $UserInfo)
	{
		$UserMiss = "Der Benutzer wurde nicht gefunden"
		
		$label1.ForeColor = 'red'
		$label1.Text = $UserMiss
		$lockedUser.Text = ""
		$Ausrufezeichen.Visible = $true
		$Schloss_auf.Visible = $false
		$Schloss_zu.Visible = $false
	}
	elseif ($UserInfo.Count -eq 0)
	{
		$UserMiss = "Der Benutzer wurde nicht gefunden"
		
		$label1.ForeColor = 'red'
		$label1.Text = $UserMiss
		$lockedUser.Text = ""
		$Ausrufezeichen.Visible = $true
		$Schloss_auf.Visible = $false
		$Schloss_zu.Visible = $false
	}
	elseif ($UserInfo.Count -gt 1)
	{
		$label1.text = "Es wurden mehrere Benutzer gefunden, bitte auswählen"
		$label1.ForeColor = 'red'
		
		$combobox1.Visible = $true
		$combobox1.Items.Clear() # Combobox leeren
		
		# Combobox Dropdown für mehrere Ergebnisse
		foreach ($item in $UserInfo)
		{
			$displayText = "{0} ({1})" -f $item.DisplayName, $item.name
			$combobox1.Items.Add($displayText) | Out-Null
		}
		
		# Make sure UserInfo is treated as an array
		$global:UserInfoArray = @($UserInfo)
		
		# Event-Handler für die Auswahl eines Benutzers
		$combobox1.add_SelectedIndexChanged({
				$selectedIndex = $combobox1.SelectedIndex
				
				if ($selectedIndex -ge 0)
				{
					$selectedUserInfo = $global:UserInfoArray[$selectedIndex]
					DisplayUserInfo $selectedUserInfo
					#Auswahl aus Dropdown wird in die Textbox geschrieben
					$textboxfind.text = $selectedUserInfo.name
				}
			})
		
		# Hide the lock/unlock status when multiple users are found
		$Schloss_auf.Visible = $false
		$Schloss_zu.Visible = $false
		$lockedUser.Text = ""
		$lockedUser.ForeColor = 'red'
		$Ausrufezeichen.Visible = $false
	}
	else
	{
		# Nur ein Benutzer gefunden
		$combobox1.Visible = $false
		DisplayUserInfo $UserInfo
	}
}

function DisplayUserInfo
{
	param ($UserInfo)
	
	$ExpiryDate = [datetime]::FromFileTimeUtc($UserInfo."msDS-UserPasswordExpiryTimeComputed").ToLocalTime()
	
	if ($UserInfo.lockedout -eq $true)
	{
		$Schloss_auf.Visible = $true
		$Schloss_zu.Visible = $false
		$lockedUser.Text = "User $($UserInfo.DisplayName) ist gesperrt"
		$lockedUser.ForeColor = 'red'
		$Ausrufezeichen.Visible = $false
		$ButtonEntsperren.Visible = $True
	}
	else
	{
		$Schloss_auf.Visible = $false
		$Schloss_zu.Visible = $true
		$lockedUser.Text = "User $($UserInfo.DisplayName) ist nicht gesperrt"
		$lockedUser.ForeColor = 'green'
		$Ausrufezeichen.Visible = $false
		$ButtonEntsperren.Visible = $False
	}
	
	$Today = Get-Date
	
	if ($ExpiryDate -lt $Today)
	{
		$g = "Alarm: Das Passwort des Benutzers $($UserInfo.DisplayName) ($($UserInfo.Name)) ist bereits am $($ExpiryDate.ToString("dd.MM.yyyy")) abgelaufen"
		$label1.ForeColor = 'red'
		$label1.Text = $g
		$Schloss_zu.Visible = $true
		$Schloss_auf.Visible = $false
	}
	elseif ($ExpiryDate -lt $Today.AddDays($Days))
	{
		$g = "Alarm: Der Benutzer $($UserInfo.DisplayName) ($($UserInfo.Name)) läuft am $($ExpiryDate.ToString("dd.MM.yyyy")) ab"
		$label1.ForeColor = 'red'
		$label1.Text = $g
		$Schloss_zu.Visible = $true
		$Schloss_auf.Visible = $false
	}
	else
	{
		$g1 = "OK: Der Benutzer $($UserInfo.DisplayName) ($($UserInfo.Name)) läuft am $($ExpiryDate.ToString("dd.MM.yyyy")) ab"
		$label1.ForeColor = 'Green'
		$label1.Text = $g1
		$Schloss_auf.Visible = $true
		$Schloss_zu.Visible = $false
	}
}

# Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory
