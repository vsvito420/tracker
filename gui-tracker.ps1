Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Initialize variables
$script:entries = @()
$dataFile = "timetracking_data.json"

# Custom colors
$darkBackground = [System.Drawing.Color]::FromArgb(22, 27, 34)
$darkerBackground = [System.Drawing.Color]::FromArgb(13, 17, 23)
$lightText = [System.Drawing.Color]::FromArgb(201, 209, 217)
$accentBlue = [System.Drawing.Color]::FromArgb(88, 166, 255)

# Load existing entries
if (Test-Path $dataFile) {
    $script:entries = Get-Content $dataFile | ConvertFrom-Json
}

# Create custom fonts
$defaultFont = New-Object System.Drawing.Font("Segoe UI", 9)
$timeFont = New-Object System.Drawing.Font("Segoe UI", 11)
$headerFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Time Tracker"
$form.Size = New-Object System.Drawing.Size(1400, 900)
$form.StartPosition = "CenterScreen"
$form.BackColor = $darkBackground
$form.ForeColor = $lightText
$form.Font = $defaultFont

# Create main layout container
$mainContainer = New-Object System.Windows.Forms.TableLayoutPanel
$mainContainer.Dock = "Fill"
$mainContainer.RowCount = 2
$mainContainer.ColumnCount = 2
$mainContainer.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50)))
$mainContainer.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50)))
$mainContainer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 70)))
$mainContainer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 30)))

# Create view panels
$timelinePanel = New-Object System.Windows.Forms.Panel
$timelinePanel.Dock = "Fill"
$timelinePanel.BackColor = $darkerBackground
$timelinePanel.Padding = New-Object System.Windows.Forms.Padding(10)

$dailyPanel = New-Object System.Windows.Forms.Panel
$dailyPanel.Dock = "Fill"
$dailyPanel.BackColor = $darkerBackground
$dailyPanel.Padding = New-Object System.Windows.Forms.Padding(10)

$weeklyPanel = New-Object System.Windows.Forms.Panel
$weeklyPanel.Dock = "Fill"
$weeklyPanel.BackColor = $darkerBackground
$weeklyPanel.Padding = New-Object System.Windows.Forms.Padding(10)

$monthlyPanel = New-Object System.Windows.Forms.Panel
$monthlyPanel.Dock = "Fill"
$monthlyPanel.BackColor = $darkerBackground
$monthlyPanel.Padding = New-Object System.Windows.Forms.Padding(10)

# Create view headers
function New-ViewHeader {
    param(
        [string]$title,
        [System.Windows.Forms.Panel]$panel
    )
    
    $header = New-Object System.Windows.Forms.Panel
    $header.Height = 30
    $header.Dock = "Top"
    $header.BackColor = $darkBackground
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $title
    $titleLabel.Font = $headerFont
    $titleLabel.ForeColor = $lightText
    $titleLabel.Location = New-Object System.Drawing.Point(5, 5)
    $titleLabel.AutoSize = $true
    
    $toggleButton = New-Object System.Windows.Forms.Button
    $toggleButton.Text = "−"
    $toggleButton.Width = 25
    $toggleButton.Height = 25
    $toggleButton.Location = New-Object System.Drawing.Point($panel.Width - 30, 2)
    $toggleButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $toggleButton.BackColor = $accentBlue
    $toggleButton.ForeColor = $lightText
    $toggleButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
    
    $toggleButton.Add_Click({
        if ($panel.Visible) {
            $panel.Visible = $false
            $toggleButton.Text = "+"
        } else {
            $panel.Visible = $true
            $toggleButton.Text = "−"
        }
    })
    
    $header.Controls.AddRange(@($titleLabel, $toggleButton))
    return $header
}

# Create timeline view
$timelineHeader = New-ViewHeader -title "Timeline" -panel $timelinePanel
$timelineFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$timelineFlow.Dock = "Fill"
$timelineFlow.FlowDirection = "TopDown"
$timelineFlow.AutoScroll = $true
$timelineFlow.WrapContents = $false
$timelineFlow.BackColor = $darkerBackground

# Create daily view
$dailyHeader = New-ViewHeader -title "Daily View" -panel $dailyPanel
$dailyFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$dailyFlow.Dock = "Fill"
$dailyFlow.FlowDirection = "TopDown"
$dailyFlow.AutoScroll = $true
$dailyFlow.WrapContents = $false
$dailyFlow.BackColor = $darkerBackground

# Create weekly view
$weeklyHeader = New-ViewHeader -title "Weekly View" -panel $weeklyPanel
$weeklyFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$weeklyFlow.Dock = "Fill"
$weeklyFlow.FlowDirection = "TopDown"
$weeklyFlow.AutoScroll = $true
$weeklyFlow.WrapContents = $false
$weeklyFlow.BackColor = $darkerBackground

# Create monthly view
$monthlyHeader = New-ViewHeader -title "Monthly View" -panel $monthlyPanel
$monthlyFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$monthlyFlow.Dock = "Fill"
$monthlyFlow.FlowDirection = "TopDown"
$monthlyFlow.AutoScroll = $true
$monthlyFlow.WrapContents = $false
$monthlyFlow.BackColor = $darkerBackground

# Add flows to panels
$timelinePanel.Controls.Add($timelineFlow)
$dailyPanel.Controls.Add($dailyFlow)
$weeklyPanel.Controls.Add($weeklyFlow)
$monthlyPanel.Controls.Add($monthlyFlow)

# Create view containers
$viewContainer1 = New-Object System.Windows.Forms.Panel
$viewContainer1.Dock = "Fill"
$viewContainer1.Controls.AddRange(@($timelineHeader, $timelinePanel))

$viewContainer2 = New-Object System.Windows.Forms.Panel
$viewContainer2.Dock = "Fill"
$viewContainer2.Controls.AddRange(@($dailyHeader, $dailyPanel))

$viewContainer3 = New-Object System.Windows.Forms.Panel
$viewContainer3.Dock = "Fill"
$viewContainer3.Controls.AddRange(@($weeklyHeader, $weeklyPanel))

$viewContainer4 = New-Object System.Windows.Forms.Panel
$viewContainer4.Dock = "Fill"
$viewContainer4.Controls.AddRange(@($monthlyHeader, $monthlyPanel))

# Create input panel
$inputPanel = New-Object System.Windows.Forms.Panel
$inputPanel.Dock = "Fill"
$inputPanel.BackColor = $darkerBackground
$inputPanel.Padding = New-Object System.Windows.Forms.Padding(10)

# Input Panel Title
$inputTitle = New-Object System.Windows.Forms.Label
$inputTitle.Text = "New Time Entry"
$inputTitle.Font = $headerFont
$inputTitle.ForeColor = $lightText
$inputTitle.Dock = "Top"
$inputTitle.Height = 30

# Description Input
$descriptionLabel = New-Object System.Windows.Forms.Label
$descriptionLabel.Text = "Description (Markdown)"
$descriptionLabel.ForeColor = $lightText
$descriptionLabel.Height = 25
$descriptionLabel.Dock = "Top"

$textBoxDescription = New-Object System.Windows.Forms.TextBox
$textBoxDescription.Multiline = $true
$textBoxDescription.ScrollBars = "Vertical"
$textBoxDescription.Height = 150
$textBoxDescription.Dock = "Top"
$textBoxDescription.BackColor = $darkBackground
$textBoxDescription.ForeColor = $lightText
$textBoxDescription.Font = New-Object System.Drawing.Font("Consolas", 10)

# Ticket Input
$ticketLabel = New-Object System.Windows.Forms.Label
$ticketLabel.Text = "Ticket ID/Link"
$ticketLabel.ForeColor = $lightText
$ticketLabel.Height = 25
$ticketLabel.Dock = "Top"

$textBoxTicket = New-Object System.Windows.Forms.TextBox
$textBoxTicket.Height = 25
$textBoxTicket.Dock = "Top"
$textBoxTicket.BackColor = $darkBackground
$textBoxTicket.ForeColor = $lightText

# Time Panel
$timePanel = New-Object System.Windows.Forms.Panel
$timePanel.Height = 60
$timePanel.Dock = "Top"
$timePanel.BackColor = $darkerBackground

# Start Time
$dateTimePickerStart = New-Object System.Windows.Forms.DateTimePicker
$dateTimePickerStart.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$dateTimePickerStart.CustomFormat = "HH:mm"
$dateTimePickerStart.ShowUpDown = $true
$dateTimePickerStart.Width = 100
$dateTimePickerStart.Location = New-Object System.Drawing.Point(0, 25)

# Duration
$comboBoxDuration = New-Object System.Windows.Forms.ComboBox
$comboBoxDuration.Width = 100
$comboBoxDuration.Location = New-Object System.Drawing.Point(110, 25)
$comboBoxDuration.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$durations = @("00:15", "00:30", "00:45", "01:00", "01:15", "01:30", "01:45", "02:00")
$comboBoxDuration.Items.AddRange($durations)
$comboBoxDuration.SelectedIndex = 0
$comboBoxDuration.BackColor = $darkBackground
$comboBoxDuration.ForeColor = $lightText

# Add Entry Button
$buttonAdd = New-Object System.Windows.Forms.Button
$buttonAdd.Text = "Add Entry"
$buttonAdd.Width = 100
$buttonAdd.Location = New-Object System.Drawing.Point(220, 24)
$buttonAdd.BackColor = $accentBlue
$buttonAdd.ForeColor = $lightText
$buttonAdd.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

# Time Labels
$startTimeLabel = New-Object System.Windows.Forms.Label
$startTimeLabel.Text = "Start Time"
$startTimeLabel.ForeColor = $lightText
$startTimeLabel.Width = 100
$startTimeLabel.Location = New-Object System.Drawing.Point(0, 5)

$durationLabel = New-Object System.Windows.Forms.Label
$durationLabel.Text = "Duration"
$durationLabel.ForeColor = $lightText
$durationLabel.Width = 100
$durationLabel.Location = New-Object System.Drawing.Point(110, 5)

# Add controls to time panel
$timePanel.Controls.AddRange(@(
    $startTimeLabel,
    $durationLabel,
    $dateTimePickerStart,
    $comboBoxDuration,
    $buttonAdd
))

# Add controls to input panel
$inputPanel.Controls.AddRange(@(
    $inputTitle,
    $descriptionLabel,
    $textBoxDescription,
    $ticketLabel,
    $textBoxTicket,
    $timePanel
))

# Add panels to main container
$mainContainer.Controls.Add($viewContainer1, 0, 0)
$mainContainer.Controls.Add($viewContainer2, 0, 1)
$mainContainer.Controls.Add($viewContainer3, 1, 0)
$mainContainer.Controls.Add($viewContainer4, 1, 1)
$mainContainer.Controls.Add($inputPanel, 2, 0)
$mainContainer.SetRowSpan($inputPanel, 2)

# Add main container to form
$form.Controls.Add($mainContainer)

# Helper functions
function ConvertTo-NearestQuarterHour {
    param([DateTime]$time)
    $minutes = $time.Minute
    $roundedMinutes = [Math]::Round($minutes / 15) * 15
    return $time.AddMinutes($roundedMinutes - $minutes).AddSeconds(-$time.Second)
}

function Convert-DurationToMinutes {
    param([string]$duration)
    if ($duration -match "(\d+):(\d+)") {
        return [int]$Matches[1] * 60 + [int]$Matches[2]
    }
    return 15
}

function Save-Entries {
    $script:entries | ConvertTo-Json | Set-Content $dataFile
}

function New-TimelineEntry {
    param(
        [string]$description,
        [string]$startTime,
        [string]$endTime,
        [string]$ticketId
    )
    
    $entryPanel = New-Object System.Windows.Forms.Panel
    $entryPanel.Height = 80
    $entryPanel.Width = $timelineFlow.Width - 25
    $entryPanel.BackColor = $darkBackground
    $entryPanel.Margin = New-Object System.Windows.Forms.Padding(5)
    
    $timeLabel = New-Object System.Windows.Forms.Label
    $timeLabel.Text = "$startTime - $endTime"
    $timeLabel.Font = $timeFont
    $timeLabel.ForeColor = $lightText
    $timeLabel.Location = New-Object System.Drawing.Point(10, 10)
    $timeLabel.AutoSize = $true
    
    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = $description
    $descLabel.ForeColor = $lightText
    $descLabel.Location = New-Object System.Drawing.Point(10, 35)
    $descLabel.Width = $entryPanel.Width - 20
    $descLabel.Height = 35
    
    if ($ticketId) {
        $ticketLabel = New-Object System.Windows.Forms.LinkLabel
        $ticketLabel.Text = "Ticket: $ticketId"
        $ticketLabel.LinkColor = $accentBlue
        $ticketLabel.Location = New-Object System.Drawing.Point($entryPanel.Width - 150, 10)
        $ticketLabel.AutoSize = $true
        $entryPanel.Controls.Add($ticketLabel)
    }
    
    $entryPanel.Controls.AddRange(@($timeLabel, $descLabel))
    return $entryPanel
}

function Update-Views {
    # Clear all views
    $timelineFlow.Controls.Clear()
    $dailyFlow.Controls.Clear()
    $weeklyFlow.Controls.Clear()
    $monthlyFlow.Controls.Clear()
    
    # Get current date ranges
    $today = Get-Date
    $weekStart = $today.AddDays(-$today.DayOfWeek.value__)
    $monthStart = Get-Date -Day 1
    
    # Update timeline view (all entries)
    $script:entries | Sort-Object StartTime -Descending | ForEach-Object {
        $entry = New-TimelineEntry -description $_.Description -startTime $_.StartTime -endTime $_.EndTime -ticketId $_.TicketId
        $timelineFlow.Controls.Add($entry)
    }
    
    # Update daily view (today's entries)
    $script:entries | Where-Object { 
        $entryDate = [DateTime]::ParseExact($_.StartTime, "HH:mm", $null).Date
        $entryDate -eq $today.Date 
    } | Sort-Object StartTime | ForEach-Object {
        $entry = New-TimelineEntry -description $_.Description -startTime $_.StartTime -endTime $_.EndTime -ticketId $_.TicketId
        $dailyFlow.Controls.Add($entry)
    }
    
    # Update weekly view
    $script:entries | Where-Object { 
        $entryDate = [DateTime]::ParseExact($_.StartTime, "HH:mm", $null).Date
        $entryDate -ge $weekStart -and $entryDate -le $today
    } | Sort-Object StartTime | ForEach-Object {
        $entry = New-TimelineEntry -description $_.Description -startTime $_.StartTime -endTime $_.EndTime -ticketId $_.TicketId
        $weeklyFlow.Controls.Add($entry)
    }
    
    # Update monthly view
    $script:entries | Where-Object { 
        $entryDate = [DateTime]::ParseExact($_.StartTime, "HH:mm", $null).Date
        $entryDate -ge $monthStart -and $entryDate -le $today
    } | Sort-Object StartTime | ForEach-Object {
        $entry = New-TimelineEntry -description $_.Description -startTime $_.StartTime -endTime $_.EndTime -ticketId $_.TicketId
        $monthlyFlow.Controls.Add($entry)
    }
}

# Button click event
$buttonAdd.Add_Click({
    $startTime = ConvertTo-NearestQuarterHour $dateTimePickerStart.Value
    $durationMinutes = Convert-DurationToMinutes $comboBoxDuration.SelectedItem
    $endTime = $startTime.AddMinutes($durationMinutes)
    
    $newEntry = [PSCustomObject]@{
        Description = $textBoxDescription.Text
        StartTime = $startTime.ToString("HH:mm")
        EndTime = $endTime.ToString("HH:mm")
        Duration = $comboBoxDuration.SelectedItem
        TicketId = if ($textBoxTicket.Text) { $textBoxTicket.Text } else { $null }
    }
    
    $script:entries += $newEntry
    Save-Entries
    Update-Views
    
    $textBoxDescription.Clear()
    $textBoxTicket.Clear()
    $dateTimePickerStart.Value = Get-Date
    $comboBoxDuration.SelectedIndex = 0
})

# Form keyboard navigation
$form.Add_KeyDown({
    param($eventSender, $eventArgs)
    if ($eventArgs.KeyCode -eq [System.Windows.Forms.Keys]::Enter -and $eventArgs.Control) {
        $buttonAdd.PerformClick()
    }
})

# Initial views update
Update-Views

# Show the form
$form.ShowDialog()
