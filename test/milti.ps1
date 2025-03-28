# Определение операционной системы
if ($IsWindows) {
    # Пути для Windows
    $targetDirs = @(
        "C:\distr\test\dev_build\grpedit",
        "C:\distr\test\dev_build\modservice",
        "C:\distr\test\dev_build\rsysconf",
        "C:\distr\test\dev_build\scada"
    )
} else {
    # Пути для Linux
    $targetDirs = @(
        "/mnt/distr/test/dev_build/grpedit",
        "/mnt/distr/test/dev_build/modservice",
        "/mnt/distr/test/dev_build/rsysconf",
        "/mnt/distr/test/dev_build/scada"
    )
}

# Функция для вычисления хэшей и сохранения результатов
function Compute-Hashes {
    param (
        [string]$targetDir,
        [string]$algorithm,
        [string]$outputFile
    )

    # Очистка файла с результатами (если он существует)
    if (Test-Path $outputFile) {
        Clear-Content $outputFile
    }

    # Рекурсивный обход директории и вычисление хэшей
    Get-ChildItem -Path $targetDir -Recurse -File | ForEach-Object {
        $hash = (Get-FileHash -Algorithm $algorithm $_.FullName).Hash
        $relativePath = $_.FullName.Substring($targetDir.Length + 1)
        "$hash  $relativePath" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    }

    Write-Host "$algorithm-хэши для директории '$targetDir' вычислены и сохранены в файл: $outputFile"
}

# Функция для создания архива 7z
function Create-7zArchive {
    param (
        [string]$sourceDir,
        [string]$archiveName
    )

    # Определение пути к 7z в зависимости от ОС
    if ($IsWindows) {
        $7zPath = "C:\Program Files\7-Zip\7z.exe"
    } else {
        $7zPath = "7z"
    }

    if (-not (Get-Command $7zPath -ErrorAction SilentlyContinue)) {
        Write-Host "7-Zip не найден. Убедитесь, что 7-Zip установлен и доступен в PATH."
        return
    }

    # Создание архива
    & "$7zPath" a -t7z "$archiveName" "$sourceDir/*"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Архив успешно создан: $archiveName"
    } else {
        Write-Host "Ошибка при создании архива: $archiveName"
    }
}

# Функция для вычисления хэша файла
function Compute-FileHash {
    param (
        [string]$filePath,
        [string]$algorithm
    )

    $hash = (Get-FileHash -Algorithm $algorithm $filePath).Hash
    return $hash
}

# Обработка каждой директории
foreach ($targetDir in $targetDirs) {
    # Проверка существования директории
    if (-not (Test-Path $targetDir)) {
        Write-Host "Директория '$targetDir' не существует. Пропускаем."
        continue
    }

    # Вычисление SHA256-хэшей для файлов в директории
    Compute-Hashes -targetDir $targetDir -algorithm "SHA256" -outputFile "$targetDir/sha256sums.txt"

    # Вычисление SHA1-хэшей для файлов в директории
    Compute-Hashes -targetDir $targetDir -algorithm "SHA1" -outputFile "$targetDir/sha1sums.txt"

    # Вычисление MD5-хэшей для файлов в директории
    Compute-Hashes -targetDir $targetDir -algorithm "MD5" -outputFile "$targetDir/md5sums.txt"

    # Формирование имени архива
    $dirName = Split-Path $targetDir -Leaf  # Имя директории (например, "grpedit")
    $archiveName = "$targetDir/${dirName}_artifacts.7z"  # Имя архива

    # Создание архива 7z, включающего все файлы и папки
    Create-7zArchive -sourceDir $targetDir -archiveName $archiveName

    # Вычисление хэшей для архива
    $archiveMD5Hash = Compute-FileHash -filePath $archiveName -algorithm "MD5"
    $archiveSHA1Hash = Compute-FileHash -filePath $archiveName -algorithm "SHA1"
    $archiveSHA256Hash = Compute-FileHash -filePath $archiveName -algorithm "SHA256"

    # Создание файлов с хэшами для архива
    "$archiveMD5Hash  $($archiveName | Split-Path -Leaf)" | Out-File -FilePath "$archiveName.md5" -Encoding UTF8
    "$archiveSHA1Hash  $($archiveName | Split-Path -Leaf)" | Out-File -FilePath "$archiveName.sha1" -Encoding UTF8
    "$archiveSHA256Hash  $($archiveName | Split-Path -Leaf)" | Out-File -FilePath "$archiveName.sha256" -Encoding UTF8

    Write-Host "Хэши для архива '$archiveName' вычислены и сохранены."

    # Добавление файлов с хэшами в архив
    Create-7zArchive -sourceDir $targetDir -archiveName $archiveName
}