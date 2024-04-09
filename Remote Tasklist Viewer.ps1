Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# Function to execute tasklist command remotely and redirect output to a custom file
function Get-RemoteTasklist {
    param(
        [string]$remoteHost,
        [string]$outputFile
    )
    try {
        Invoke-Command -ComputerName $remoteHost -ScriptBlock { tasklist } | Out-File -FilePath $outputFile -Force
        return $outputFile
    } catch {
        return "Error: $_"
    }
}

# Function to display tasklist output from custom file
function Show-Tasklist {
    $remoteHost = $textBox.Text
    $outputFile = $outputFileTextBox.Text
    $result = Get-RemoteTasklist -remoteHost $remoteHost -outputFile $outputFile
    if ($result -match "Error:") {
        [System.Windows.Forms.MessageBox]::Show($result, "Error", "OK", "Error")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Tasklist output redirected to $outputFile", "Tasklist on $remoteHost", "OK", "Information")
    }
}

# Function to browse and select custom output file
function Browse-OutputFile {
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Title = "Select Output File"
    $saveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    $result = $saveFileDialog.ShowDialog()
    if ($result -eq "OK") {
        $outputFileTextBox.Text = $saveFileDialog.FileName
    }
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Tasklist Viewer"
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = "CenterScreen"

$remoteHostLabel = New-Object System.Windows.Forms.Label
$remoteHostLabel.Location = New-Object System.Drawing.Point(10,20)
$remoteHostLabel.Size = New-Object System.Drawing.Size(100,20)
$remoteHostLabel.Text = "Remote Host:"
$form.Controls.Add($remoteHostLabel)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(120,20)
$textBox.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($textBox)

$outputFileLabel = New-Object System.Windows.Forms.Label
$outputFileLabel.Location = New-Object System.Drawing.Point(10,50)
$outputFileLabel.Size = New-Object System.Drawing.Size(100,20)
$outputFileLabel.Text = "Output File:"
$form.Controls.Add($outputFileLabel)

$outputFileTextBox = New-Object System.Windows.Forms.TextBox
$outputFileTextBox.Location = New-Object System.Drawing.Point(120,50)
$outputFileTextBox.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($outputFileTextBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(310,50)
$browseButton.Size = New-Object System.Drawing.Size(80,23)
$browseButton.Text = "Browse"
$browseButton.Add_Click({ Browse-OutputFile })
$form.Controls.Add($browseButton)

$form.ShowDialog() | Out-Null
