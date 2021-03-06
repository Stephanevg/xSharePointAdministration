Configuration MyTestConfig
{
    param([string]$LiteralPath)

    Import-DscResource -ModuleName xSharePointAdministration -Name ALIS_xFarmSolution
    Import-DscResource -ModuleName xSharePointAdministration -Name ALIS_xSite
    Import-DscResource -ModuleName xSharePointAdministration -Name ALIS_xWeb
    Import-DscResource -ModuleName xSharePointAdministration -Name ALIS_xList
    Import-DscResource -ModuleName xSharePointAdministration -Name ALIS_xFeature
    

    Node localhost
    {
        Site TestSite
        {
            Url = "http://localhost/sites/testsite"
            Ensure = "Present"
            OwnerAlias = "spfarm\mkaufmann"
            Name = "Test Site"
            Description = "A site for testing dsc resources..."
            Template = "COMMUNITY#0"
        }

        Web SubWeb
        {
            Url = "http://localhost/sites/testsite/subsite"
            Ensure = "Present"
            Name = "Susite"
            Description = "A demo subsite with some parameters..."
            Template = "STS#0"
            DependsOn = "[Site]TestSite"
            UseParentTopNav = $true
        }

        List GenericList
        {
            Url = "http://localhost/sites/testsite/subsite/Lists/GenericList"
            Ensure = "Present"
            Title = "Generic List"
            Description = "A sample generic list"
        }

        List DocumentLibrary
        {
            Url = "http://localhost/sites/testsite/subsite/MyDocs"
            Ensure = "Present"
            Title = "My Documents"
            FeatureId = "00BFEA71-E717-4E80-AA17-D0C71B360101"
            TemplateId = "101"
            DocTemplateType = "101"
        }

        FarmSolution TestSolution.wsp
        {
            Name = "TestSolution.wsp"
            LiteralPath = $LiteralPath
            Version = "2.4"
            Ensure = "Present"
            Local = $true
            Deployed = $true
            Force = $false
        }

        Feature FarmFeature
        {
            ID = "b80acc14-17ab-4f62-a7ac-41d4a62b1323"
            Url = "http://localhost"
            Ensure = "Present"
            DependsOn = "[FarmSolution]TestSolution.wsp"
        }

        Feature WebAppFeature
        {
            ID = "c15f7007-d0ff-403c-88cb-697f811e8572"
            Url = "http://localhost"
            Ensure = "Present"
            DependsOn = "[FarmSolution]TestSolution.wsp"
        }

        Feature SiteFeature
        {
            ID = "06780b45-1731-4bf9-8686-d734703e0d0c"
            Url = "http://localhost"
            Ensure = "Present"
            DependsOn = "[FarmSolution]TestSolution.wsp"
        }

        Feature WebFeature
        {
            ID = "8fed3a9c-e338-475f-bab0-cded858378b4"
            Url = "http://localhost"
            Ensure = "Present"
            DependsOn = "[FarmSolution]TestSolution.wsp"
        }
    }
}

$literalPath = Resolve-Path .\TestSolution.wsp

MyTestConfig -literalPath $literalPath

Restart-Service Winmgmt -force

Start-DscConfiguration -Path .\MyTestConfig -Wait -Force -Verbose