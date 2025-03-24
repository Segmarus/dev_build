# Makefile для PowerShell проекта

install:
	pwsh -Command "Install-Module -Name Pester -Force -SkipPublisherCheck"

test:
	pwsh -Command "Invoke-Pester ./tests -Output Detailed"

run:
	pwsh -Command "./src/artifact_packaging.ps1"

clean:
	pwsh -Command "Remove-Item -Recurse -Force C:\temp\artifact_test -ErrorAction SilentlyContinue"

help:
	@echo "Доступные команды:"
	@echo "  make install  - Установить зависимости"
	@echo "  make test     - Запустить тесты"
	@echo "  make run      - Запустить скрипт"
	@echo "  make clean    - Очистить временные файлы"