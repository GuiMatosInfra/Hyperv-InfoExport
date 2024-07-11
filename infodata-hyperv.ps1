# Definir o caminho para o arquivo CSV de sa�da
$csvPath = "C:\vms_info.csv"

# Obter todas as m�quinas virtuais no servidor Hyper-V
$vms = Get-VM

# Inicializar um array para armazenar as informa��es coletadas
$vmInfo = @()

# Iterar sobre cada m�quina virtual para obter informa��es detalhadas
foreach ($vm in $vms) {
    $vmName = $vm.Name
    $vmMemoryBytes = $vm.MemoryAssigned
    $vmMemoryMB = [math]::Round($vmMemoryBytes / 1MB)  # Converter bytes para megabytes
    $vmProcessor = $vm.ProcessorCount
    
    # Obter informa��es sobre os discos virtuais da VM
    $vmDisks = $vm | Get-VMHardDiskDrive | ForEach-Object {
        $vhd = Get-VHD -Path $_.Path
        [PSCustomObject]@{
            Path = $_.Path
            SizeGB = [math]::Round($vhd.Size / 1GB)  # Converter bytes para gigabytes
        }
    }

    # Criar um objeto com as informa��es coletadas e adicion�-lo ao array
    $vmDetails = [PSCustomObject]@{
        VMName = $vmName
        MemoryAssignedMB = $vmMemoryMB
        ProcessorCount = $vmProcessor
        Disks = ($vmDisks | Select-Object -ExpandProperty Path) -join ", "
        DiskSizeGB = $vmDisks | Measure-Object -Property SizeGB -Sum | Select-Object -ExpandProperty Sum
    }
    
    $vmInfo += $vmDetails
}

# Exibir as informa��es na tela (opcional)
$vmInfo | Format-Table -AutoSize

# Exportar as informa��es para um arquivo CSV
$vmInfo | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Informa��es das VMs exportadas para: $csvPath"
