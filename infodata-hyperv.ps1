# Definir o caminho para o arquivo CSV de saída
$csvPath = "C:\vms_info.csv"

# Obter todas as máquinas virtuais no servidor Hyper-V
$vms = Get-VM

# Inicializar um array para armazenar as informações coletadas
$vmInfo = @()

# Iterar sobre cada máquina virtual para obter informações detalhadas
foreach ($vm in $vms) {
    $vmName = $vm.Name
    $vmMemoryBytes = $vm.MemoryAssigned
    $vmMemoryMB = [math]::Round($vmMemoryBytes / 1MB)  # Converter bytes para megabytes
    $vmProcessor = $vm.ProcessorCount
    
    # Obter informações sobre os discos virtuais da VM
    $vmDisks = $vm | Get-VMHardDiskDrive | ForEach-Object {
        $vhd = Get-VHD -Path $_.Path
        [PSCustomObject]@{
            Path = $_.Path
            SizeGB = [math]::Round($vhd.Size / 1GB)  # Converter bytes para gigabytes
        }
    }

    # Criar um objeto com as informações coletadas e adicioná-lo ao array
    $vmDetails = [PSCustomObject]@{
        VMName = $vmName
        MemoryAssignedMB = $vmMemoryMB
        ProcessorCount = $vmProcessor
        Disks = ($vmDisks | Select-Object -ExpandProperty Path) -join ", "
        DiskSizeGB = $vmDisks | Measure-Object -Property SizeGB -Sum | Select-Object -ExpandProperty Sum
    }
    
    $vmInfo += $vmDetails
}

# Exibir as informações na tela (opcional)
$vmInfo | Format-Table -AutoSize

# Exportar as informações para um arquivo CSV
$vmInfo | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Informações das VMs exportadas para: $csvPath"
