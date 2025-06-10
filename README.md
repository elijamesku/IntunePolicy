# Intune Compliance Policy

This Intune solution uses a custom compliance policy and a lightweight PowerShell discovery script to prevent Windows 11 upgrade attempts on Windows 10 devices that have less than 32 GB of free disk space. Devices below this threshold will be marked as noncompliant and excluded from upgrade targeting, avoiding mid-upgrade failures.


## Features

- Checks C: drive for minimum free space (32 GB)
- Marks device noncompliant if below threshold
- No user interruption — runs silently in the background
- Excludes noncompliant devices from Windows 11 update ring using filters
- Track compliant/noncompliant state via reports or Endpoint Analytics


## Files Included

| File | Purpose |
|------|---------|
| `Check-LowDisk.ps1` | PowerShell discovery script that checks free disk space |
| `LowDiskCompliance.json` | JSON rule to define compliance logic in Intune |

---

## Prereqs

- Intune-managed Windows 10 and 11 devices
- Microsoft Intune admin access
- PowerShell script upload and custom compliance access
- Compliance reporting and Endpoint Analytics (optional for visual dashboards)



## Step-by-Step Setup

### 1. Create and Upload the Discovery Script

1. Go to: `Devices > Compliance > Scripts > Add`
2. Click **+ Add Windows 10 or later**
3. Name: `Low Disk Detector`
4. Upload `______.ps1` as the **discovery script**
5. Run script in 64 bit PowerShell Host = Yes
6. Click **Create**

> This script checks if free space on the C: drive is below 32 GB and outputs `LowDisk=1` or `LowDisk=0`.
### PowerShell Script: `_____.ps1`

```powershell
$requiredGB = 32
$freeGB = [math]::Round((Get-PSDrive -Name C).Free / 1GB, 2)

if ($freeGB -lt $requiredGB) {
    Write-Output "LowDisk=1"
} else {
    Write-Output "LowDisk=0"
}
```

---

### 2. Create the Compliance Policy

1. Go to: `Devices > Compliance > + Create Policy`
2. Platform: `Windows 10 and later`
3. Profile type: `Windows 10/11 compliance policy`
4. Name: `Windows 10 Disk Space`
5. Under **Custom Compliance**, toggle `Require`
6. Click to select the discovery script → choose `Low Disk Detector`
7. Upload the same JSON file (`______.json`)
8. Click **Next**
   
### JSON File: `_____.ps1`
```JSON
{
  "Rules": [
    {
      "SettingName": "LowDisk",
      "Operator": "notEquals",
      "DataType": "String",
      "Operand": "1",
      "MoreInfoUrl": "https://support.____.com/win11-requirements", #used a dummy link since intune requires more info
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "Device Not Eligible for Windows 11",
          "Description": "This device has less than 32 GB of free space. Free up space to receive Windows 11."
        }
      ]
    }
  ]
}
```


### 3. Configure Noncompliance Actions

- Leave default: `Mark device noncompliant: Immediately`
- No end-user alerts required
- Click **Next**


### 4. Assign the Policy

- Include: `AADJ - Devices` or equivalent device group
- **Filter**: Exclude `Windows 11` devices using a filter like:
  ```kusto
  osVersion -startsWith "10.0.2"
  ```

### 5. Ensure only Windows 10 devices get the policy.

- Create Compliance Filter  
`Go to: Devices > Filters > + Create`

- Name
`Compliant Devices Only`

- Rule syntax
```kusto
device.complianceState -eq "compliant"
```
### 6. Apply Filter to Update Ring
- Go to
`Devices > Update rings for Windows 10 and later`

- Edit your Windows 11 upgrade ring

- Assign to
`same group (e.g., AADJ - Devices)`

- Filter Mode
`Include`

- Filter
`Compliant Devices Only`

### 7. Reporting and Monitoring
- Device compliance reports
`Reports > Device compliance > Select your policy`

**Customization Ideas**
- Adjust free space threshold 

