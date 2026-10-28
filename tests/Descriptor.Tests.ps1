BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $script:DescriptorPath = Join-Path $script:RepoRoot "descriptor.mod"
    $script:ThumbnailPath = Join-Path $script:RepoRoot "thumbnail.png"
    $script:BookmarkPath = Join-Path $script:RepoRoot "common\bookmarks\the_gathering_storm.txt"
    $script:StandaloneBookmarkPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Paradox Interactive\Hearts of Iron IV\mod\rt56-vnr-utt-standalone-v15\common\bookmarks\the_gathering_storm.txt"

    function Test-HasUtf8Bom {
        param([Parameter(Mandatory = $true)][string]$Path)
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        return ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    }

    function Remove-UsaMajorBlock {
        param([Parameter(Mandatory = $true)][string]$Text)
        return [regex]::Replace($Text, "(?s)\r?\n\t\tUSA = \{\r?\n.*?\r?\n\t\t\}", "", 1)
    }

    $script:AnozinDescriptorPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Paradox Interactive\Hearts of Iron IV\mod\frozen_3683330006_2026-10-28\descriptor.mod"
    $script:AnozinLauncherModPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Paradox Interactive\Hearts of Iron IV\mod\frozen_3683330006_2026-10-28.mod"
}

Describe "descriptor.mod Invariants" {
    It "descriptor.mod exists" {
        Test-Path -LiteralPath $script:DescriptorPath | Should -Be $true
    }

    It "descriptor.mod is saved without UTF-8 BOM" {
        Test-HasUtf8Bom -Path $script:DescriptorPath | Should -Be $false
    }

    It "descriptor.mod has valid name matching mod configuration" {
        $content = [System.IO.File]::ReadAllText($script:DescriptorPath, [System.Text.Encoding]::UTF8)
        $content | Should -Match ([regex]::Escape('name="RT56 - Anozin''s USA Bookmark Merge"'))
    }

    It "descriptor.mod has supported_version matching semver pattern" {
        $content = [System.IO.File]::ReadAllText($script:DescriptorPath, [System.Text.Encoding]::UTF8)
        $content | Should -Match 'supported_version="\d+\.\d+(\.\*|\.\d+)?"'
    }

    It "descriptor.mod specifies picture attribute and thumbnail file exists" {
        $content = [System.IO.File]::ReadAllText($script:DescriptorPath, [System.Text.Encoding]::UTF8)
        $content | Should -Match 'picture="thumbnail\.png"'
        Test-Path -LiteralPath $script:ThumbnailPath | Should -Be $true
    }

    It "descriptor.mod declares dependencies on both required mods and has no remote_file_id" {
        $content = [System.IO.File]::ReadAllText($script:DescriptorPath, [System.Text.Encoding]::UTF8)
        $content | Should -Match '(?s)dependencies=\{.*?"RT56 - VNR - UTT Standalone v15".*?\}'
        $content | Should -Match '(?s)dependencies=\{.*?"RT56 - VNR - UTT Standalone v14".*?\}'
        $content | Should -Match '(?s)dependencies=\{.*?"Anozin''s USA Reimagined".*?\}'
        $content | Should -Not -Match 'remote_file_id'
    }
}

Describe "Bookmark Merge Invariants" {
    It "ships only common/bookmarks/the_gathering_storm.txt under common" {
        $commonRoot = Join-Path $script:RepoRoot "common"
        $files = @(Get-ChildItem -LiteralPath $commonRoot -Recurse -File -Force | ForEach-Object { $_.FullName.Substring($script:RepoRoot.Length + 1).Replace("\", "/") })
        $files | Should -Be @("common/bookmarks/the_gathering_storm.txt")
    }

    It "the_gathering_storm.txt is saved without UTF-8 BOM" {
        Test-HasUtf8Bom -Path $script:BookmarkPath | Should -Be $false
    }

    It "the_gathering_storm.txt preserves RT56 filters and sets Anozin ideas and focuses for USA" {
        $content = [System.IO.File]::ReadAllText($script:BookmarkPath, [System.Text.Encoding]::UTF8)
        $content | Should -Match 'filters\s*=\s*\{\s*label\s*\}'
        $usaMatch = [regex]::Match($content, "(?s)\t\tUSA = \{\r?\n.*?\r?\n\t\t\}")
        $usaMatch.Success | Should -Be $true
        $usaBlock = $usaMatch.Value
        $usaBlock | Should -Match 'history = "USA_GATHERING_STORM_DESC"'
        $usaBlock | Should -Match 'version = base_game'
        $usaBlock | Should -Match 'usa_army_fake_tgs1936'
        $usaBlock | Should -Match 'usa_great_depression_fake_tgs1936'
        $usaBlock | Should -Match 'undisturbed_isolation'
        $usaBlock | Should -Not -Match 'rt56_rushed_r_n_d'
        $usaBlock | Should -Match 'USA_fulfill_manifest_destiny'
        $usaBlock | Should -Match 'USA_the_goldstar_network'
        $usaBlock | Should -Match 'USA_an_american_five_year_plan'
        $usaBlock | Should -Not -Match 'r56_USA_foundation_of_NATO'
    }

    It "matches the standalone bookmark outside the USA entry when the standalone is installed" {
        if (-not (Test-Path -LiteralPath $script:StandaloneBookmarkPath)) {
            Set-ItResult -Skipped -Because "RT56 - VNR - UTT Standalone v15 is not installed in the local mod folder"
            return
        }
        $mergedContent = [System.IO.File]::ReadAllText($script:BookmarkPath, [System.Text.Encoding]::UTF8)
        $standaloneContent = [System.IO.File]::ReadAllText($script:StandaloneBookmarkPath, [System.Text.Encoding]::UTF8)
        (Remove-UsaMajorBlock -Text $mergedContent) | Should -BeExactly (Remove-UsaMajorBlock -Text $standaloneContent)
    }

    It "ensures Anozin's USA Reimagined depends on RT56 - VNR - UTT Standalone v15 and v14 when installed" {
        if (-not (Test-Path -LiteralPath $script:AnozinDescriptorPath)) {
            Set-ItResult -Skipped -Because "frozen_3683330006_2026-10-28 is not installed in the local mod folder"
            return
        }
        foreach ($anozinFile in @($script:AnozinDescriptorPath, $script:AnozinLauncherModPath)) {
            $anozinText = [System.IO.File]::ReadAllText($anozinFile, [System.Text.Encoding]::UTF8)
            $anozinText | Should -Match '(?s)dependencies=\{.*?"RT56 - VNR - UTT Standalone v15".*?\}'
            $anozinText | Should -Match '(?s)dependencies=\{.*?"RT56 - VNR - UTT Standalone v14".*?\}'
        }
    }
}
