BeforeAll {
    # Подключаем наш скрипт
    $scriptPath = Join-Path $PSScriptRoot "../src/artifact_packaging.ps1"
    . $scriptPath
    
    # Создаём временную папку для теста
    $TestDir = Join-Path $env:TEMP "test_dir"
    New-Item -Path $TestDir -ItemType Directory -Force
    "test" | Out-File "$TestDir/test_file.txt"
}

Describe "Простые тесты" {
    It "Проверяем создание хэшей" {
        $output = "$TestDir/hashes.txt"
        Compute-Hashes -targetDir $TestDir -algorithm "MD5" -outputFile $output
        Test-Path $output | Should -Be $true
    }
}

AfterAll {
    # Удаляем временную папку
    Remove-Item $TestDir -Recurse -Force
}