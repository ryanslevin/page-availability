# Page-Availability
Page-Availability is a PowerShell script created to automate page availability checks with a goal of improving customer experience on the site.

# Code style
<a href="https://github.com/PoshCode/PowerShellPracticeAndStyle">PoshCode - PowerShellPracticeAndStyle</a>

# Tech/framework used
Windows PowerShell 5.1

# Installation
Clone repo to local folder, populate ExampleConfig.ini with the InitialUrl, Domain, and Category values. Add "results" folder.

# How to use?

<strong>PowerShell ISE</strong>
<ol>
<li>Open Page-Availability.ps1 in PowerShell ISE</li>
<li>Click the Green Run button.</li>
</ol>

<strong>PowerShell</strong>
<ol>
<li>Open PowerShell</li>
<li>Enter the command '& "YOURDRIVE:\YOURPATH\Page-Availability.ps1"</li>
</ol>

<strong>Task Scheduler</strong>
<ol>
<li>Open Task Scheduler</li>
<li>Click Create a Basic Task</li>
<li>Fill in name and description of task</li>
  <li>Choose trigger</li>
  <li>Choose "Start a program" for Action and list "powershell"</li>
  <li>In the Arguments field enter "-File YOURDRIVE:\YOURPATH\Page-Availability.ps1"</li>
</ol>


