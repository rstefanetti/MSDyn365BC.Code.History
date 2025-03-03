table 5330 "CRM Connection Setup"
{
    Caption = 'Microsoft Dynamics 365 Connection Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; "Server Address"; Text[250])
        {
            Caption = 'Dynamics 365 Sales URL';

            trigger OnValidate()
            var
                EnvironmentInfo: Codeunit "Environment Information";
            begin
                CRMIntegrationManagement.CheckModifyCRMConnectionURL("Server Address");

                if "Server Address" <> '' then
                    if EnvironmentInfo.IsSaaS() or (StrPos("Server Address", '.dynamics.com') > 0) then
                        "Authentication Type" := "Authentication Type"::Office365
                    else
                        "Authentication Type" := "Authentication Type"::AD;
                UpdateConnectionString();
            end;
        }
        field(3; "User Name"; Text[250])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "User Name" := DelChr("User Name", '<>');
                CheckUserName;
                UpdateDomainName;
                UpdateConnectionString;
            end;
        }
        field(4; "User Password Key"; Guid)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;

            trigger OnValidate()
            begin
                if not IsTemporary() then
                    if "User Password Key" <> xRec."User Password Key" then
                        xRec.DeletePassword();
            end;
        }
        field(5; "Last Update Invoice Entry No."; Integer)
        {
            Caption = 'Last Update Invoice Entry No.';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved this field to Table 5328 - CRM Synch Status as this field is getting updated by job queue and it is blocking the record. ';
            ObsoleteTag = '15.0';
        }
        field(59; "Restore Connection"; Boolean)
        {
            Caption = 'Restore Connection';
        }
        field(60; "Is Enabled"; Boolean)
        {
            Caption = 'Is Enabled';

            trigger OnValidate()
            var
                CRMIntegrationTelemetry: Codeunit "CRM Integration Telemetry";
                CRMSetupDefaults: Codeunit "CRM Setup Defaults";
            begin
                EnableCRMConnection;
                UpdateIsEnabledState;
                RefreshDataFromCRM;
                if "Is Enabled" then begin
                    CRMIntegrationTelemetry.LogTelemetryWhenConnectionEnabled();
                    TestIntegrationUserRequirements;
                    CRMSetupDefaults.ResetSalesOrderMappingConfiguration(Rec);
                    SetUseNewestUI;
                    Session.LogMessage('0000CM8', CRMConnEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end else begin
                    CRMIntegrationTelemetry.LogTelemetryWhenConnectionDisabled;
                    Session.LogMessage('0000CM9', CRMConnDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end;
            end;
        }
        field(61; "Is User Mapping Required"; Boolean)
        {
            Caption = 'Business Central Users Must Map to Dynamics 365 Sales Users';

            trigger OnValidate()
            begin
                UpdateAllConnectionRegistrations;
                UpdateIsEnabledState;
            end;
        }
        field(62; "Is User Mapped To CRM User"; Boolean)
        {
            Caption = 'Is User Mapped To CRM User';
        }
        field(63; "CRM Version"; Text[30])
        {
            Caption = 'CRM Version';
        }
        field(64; "Use Newest UI"; Boolean)
        {
            Caption = 'Use Newest UI';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Use Newest UI" = false then
                    "Newest UI AppModuleId" := '';

                if "Use Newest UI" = true then
                    "Newest UI AppModuleId" := NewestUIAppModuleId;
            end;
        }
        field(65; "Newest UI AppModuleId"; Text[50])
        {
            Caption = 'Newest UI AppModuleId';
            DataClassification = SystemMetadata;
        }
        field(66; "Is S.Order Integration Enabled"; Boolean)
        {
            Caption = 'Is S.Order Integration Enabled';

            trigger OnValidate()
            begin
                if "Is S.Order Integration Enabled" then
                    if Confirm(StrSubstNo(SetCRMSOPEnableNoCredsReqQst, PRODUCTNAME.Short)) then
                        SetCRMSOPEnabled()
                    else
                        Error('')
                else
                    SetCRMSOPDisabled;
                RefreshDataFromCRM;

                if "Is S.Order Integration Enabled" then
                    Message(SetCRMSOPEnableConfirmMsg, CRMProductName.SHORT)
                else
                    Message(SetCRMSOPDisableConfirmMsg, CRMProductName.SHORT);
            end;
        }
        field(67; "Is CRM Solution Installed"; Boolean)
        {
            Caption = 'Is CRM Solution Installed';
        }
        field(68; "Is Enabled For User"; Boolean)
        {
            Caption = 'Is Enabled For User';
        }
        field(69; "Dynamics NAV URL"; Text[250])
        {
            Caption = 'Dynamics NAV URL';

            trigger OnValidate()
            begin
                CRMIntegrationManagement.SetCRMNAVConnectionUrl("Dynamics NAV URL");
            end;
        }
        field(70; "Dynamics NAV OData URL"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality is replaced with new item availability job queue entry.';
            ObsoleteTag = '18.0';
            Caption = 'Dynamics NAV OData URL';
        }
        field(71; "Dynamics NAV OData Username"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality is replaced with new item availability job queue entry.';
            ObsoleteTag = '18.0';
            Caption = 'Dynamics NAV OData Username';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(72; "Dynamics NAV OData Accesskey"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality is replaced with new item availability job queue entry.';
            ObsoleteTag = '18.0';
            Caption = 'Dynamics NAV OData Accesskey';
        }
        field(75; "Default CRM Price List ID"; Guid)
        {
            Caption = 'Default CRM Price List ID';
        }
        field(76; "Proxy Version"; Integer)
        {
            Caption = 'Proxy Version';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                UpdateProxyVersionInConnectionString();
            end;
        }
        field(80; "Auto Create Sales Orders"; Boolean)
        {
            Caption = 'Automatically Create Sales Orders';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                CRMSetupDefaults: Codeunit "CRM Setup Defaults";
            begin
                if "Auto Create Sales Orders" then
                    CRMSetupDefaults.RecreateAutoCreateSalesOrdersJobQueueEntry(DoReadCRMData)
                else
                    CRMSetupDefaults.DeleteAutoCreateSalesOrdersJobQueueEntry;
            end;
        }
        field(81; "Auto Process Sales Quotes"; Boolean)
        {
            Caption = 'Automatically Process Sales Quotes';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                CRMSetupDefaults: Codeunit "CRM Setup Defaults";
            begin
                if "Auto Process Sales Quotes" then
                    CRMSetupDefaults.RecreateAutoProcessSalesQuotesJobQueueEntry(DoReadCRMData)
                else
                    CRMSetupDefaults.DeleteAutoProcessSalesQuotesJobQueueEntry;
            end;
        }
        field(118; CurrencyDecimalPrecision; Integer)
        {
            Caption = 'Currency Decimal Precision';
            Description = 'Number of decimal places that can be used for currency.';
        }
        field(124; BaseCurrencyId; Guid)
        {
            Caption = 'Currency';
            Description = 'Unique identifier of the base currency of the organization.';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
        }
        field(133; BaseCurrencyPrecision; Integer)
        {
            Caption = 'Base Currency Precision';
            Description = 'Number of decimal places that can be used for the base currency.';
            MaxValue = 4;
            MinValue = 0;
        }
        field(134; BaseCurrencySymbol; Text[5])
        {
            Caption = 'Base Currency Symbol';
            Description = 'Symbol used for the base currency.';
        }
        field(135; "Authentication Type"; Option)
        {
            Caption = 'Authentication Type';
            OptionCaption = 'Office365,AD,IFD,OAuth';
            OptionMembers = Office365,AD,IFD,OAuth;

            trigger OnValidate()
            begin
                if xRec."Authentication Type" <> "Authentication Type" then
                    Validate("Is User Mapping Required", false);
                case "Authentication Type" of
                    "Authentication Type"::Office365:
                        Domain := '';
                    "Authentication Type"::AD:
                        UpdateDomainName;
                end;
                UpdateConnectionString;
            end;
        }
        field(136; "Connection String"; Text[250])
        {
            Caption = 'Connection String';
        }
        field(137; Domain; Text[250])
        {
            Caption = 'Domain';
            DataClassification = OrganizationIdentifiableInformation;
            Editable = false;
        }
        field(138; "Server Connection String"; BLOB)
        {
            Caption = 'Server Connection String';
        }
        field(139; "Disable Reason"; Text[250])
        {
            Caption = 'Disable Reason';
        }
        field(140; "Item Availability Enabled"; Boolean)
        {
            Caption = 'Item Availability Enabled';

            trigger OnValidate()
            var
                CRMSetupDefaults: Codeunit "CRM Setup Defaults";
            begin
                if "Item Availability Enabled" then
                    CRMSetupDefaults.RecreateItemAvailabilityJobQueueEntry(DoReadCRMData())
                else
                    CRMSetupDefaults.DeleteItemAvailabilityJobQueueEntry();
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        if IsTemporary() then
            exit;
        if "User Password Key" <> xRec."User Password Key" then
            xRec.DeletePassword();
    end;

    trigger OnDelete()
    begin
        if IsTemporary() then
            exit;
        DeletePassword();
    end;

    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
        CantRegisterDisabledConnectionErr: Label 'A disabled connection cannot be registered.';
        ConnectionErr: Label 'The connection setup cannot be validated. Verify the settings and try again.\Detailed error description: %1.', Comment = '%1 Error message from the provider (.NET exception message)';
        ConnectionStringFormatTok: Label 'Url=%1; UserName=%2; Password=%3; ProxyVersion=%4; %5', Locked = true;
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        ConnectionSuccessNotEnabledForCurrentUserMsg: Label 'The connection test was successful. The settings are valid.\\However, because the %2 Users Must Map to %3 Users field is set, %3 integration is not enabled for %1.', Comment = '%1 = Current User ID, %2 - product name, %3 = CRM product name';
        CannotResolveUserFromConnectionSetupErr: Label 'The %1 user that is specified in the CRM connection setup does not exist.', Comment = '%1 = CRM product name';
        DetailsMissingErr: Label 'A %1 URL and user name are required to enable a connection.', Comment = '%1 = CRM product name';
        MissingUsernameTok: Label '{USER}', Locked = true;
        MissingPasswordTok: Label '{PASSWORD}', Locked = true;
        AccessTokenTok: Label 'AccessToken', Locked = true;
        ClientSecretConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; ClientSecret=%4; ProxyVersion=%5', Locked = true;
        ClientSecretAuthTxt: Label 'AuthType=ClientSecret', Locked = true;
        ClientSecretTok: Label '{CLIENTSECRET}', Locked = true;
        CertificateConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; Certificate=%4; ProxyVersion=%5', Locked = true;
        CertificateAuthTxt: Label 'AuthType=Certificate', Locked = true;
        CertificateTok: Label '{CERTIFICATE}', Locked = true;
        ClientIdTok: Label '{CLIENTID}', Locked = true;
        UserCRMSetupTxt: Label 'User CRM Setup';
        CannotConnectCRMErr: Label 'The system is unable to connect to %2, and the connection has been disabled. Verify the credentials of the user account %1, and then enable the connection again in the Microsoft Dynamics 365 Connection Setup window.', Comment = '%1 - email of the user, %2 = CRM product name';
        LCYMustMatchBaseCurrencyErr: Label 'LCY Code %1 does not match ISO Currency Code %2 of the CRM base currency.', Comment = '%1,%2 - ISO currency codes';
        UserNameMustIncludeDomainErr: Label 'The user name must include the domain when the authentication type is set to Active Directory.';
        UserNameMustBeEmailErr: Label 'The user name must be a valid email address when the authentication type is set to Office 365.';
        ConnectionStringPwdPlaceHolderMissingErr: Label 'The connection string must include the password placeholder {PASSWORD}.';
        ConnectionStringPwdOrClientSecretPlaceHolderMissingErr: Label 'The connection string must include either the password placeholder {PASSWORD}, the client secret placeholder {CLIENTSECRET} or the certificate placeholder {CERTIFICATE}.', Comment = '{PASSWORD}, {CERTIFICATE} and {CLIENTSECRET} are locked strings - do not translate them.';
        CannotDisableSalesOrderIntErr: Label 'You cannot disable CRM sales order integration when a CRM sales order has the Submitted status.';
        SetCRMSOPEnableNoCredsReqQst: Label 'Enabling Sales Order Integration will allow you to create %1 Sales Orders from Dynamics CRM.\\Do you want to continue?', Comment = '%1 - product name';
        SetCRMSOPEnableConfirmMsg: Label 'Sales Order Integration with %1 is enabled.', Comment = '%1 = CRM product name';
        SetCRMSOPDisableConfirmMsg: Label 'Sales Order Integration with %1 is disabled.', Comment = '%1 = CRM product name';
        CRMProductName: Codeunit "CRM Product Name";
        SalesHubAppModuleNameTxt: Label 'Sales Hub', Locked = true;
        SystemAdminRoleTemplateIdTxt: Label '{627090FF-40A3-4053-8790-584EDC5BE201}', Locked = true;
        SystemAdminErr: Label 'User %1 has the %2 role on server %3.\\You must choose a user that does not have the %2 role.', Comment = '%1 user name, %2 - security role name, %3 - server address';
        BCRolesErr: Label 'User %1 does not have the required roles on server %4.\\You must choose a user that has the roles %2 and %3.', Comment = '%1 user name, %2 - security role name,  %3 - security role name, %4 - server address';
        UserNotLicensedErr: Label 'User %1 is not licensed on server %2.', Comment = '%1 user name, %2 - server address';
        UserNotActiveErr: Label 'User %1 is disabled on server %2.', Comment = '%1 user name, %2 - server address';
        UserHasNoRolesErr: Label 'User %1 has no user roles assigned on server %2.', Comment = '%1 user name, %2 - server address';
        BCIntegrationAdministratorRoleIdTxt: Label '{8c8d4f51-a72b-e511-80d9-3863bb349780}', Locked = true;
        BCIntegrationUserRoleIdTxt: Label '{6f960e32-a72b-e511-80d9-3863bb349780}', Locked = true;
        CDSConnectionMustBeEnabledErr: Label 'You must enable the connection to Dataverse before you can set up the connection to %1.\\Open the page %2 to enable the connection to Dataverse.', Comment = '%1 = CRM product name, %2 = Dataverse Connection Setup page caption.';
        DeploySucceedMsg: Label 'The solution, user roles, and entities have been deployed.';
        DeployFailedMsg: Label 'The deployment of the solution, user roles, and entities failed.';
        CategoryTok: Label 'AL Dataverse Integration', Locked = true;
        CRMConnDisabledTxt: Label 'CRM connection has been disabled.', Locked = true;
        CRMConnEnabledTxt: Label 'CRM connection has been enabled.', Locked = true;
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        TempUserPassword: Text;

    [Scope('OnPrem')]
    procedure EnsureCDSConnectionIsEnabled();
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        CDSConnectionSetupPage: Page "CDS Connection Setup";
    begin
        if Get() then
            if "Is Enabled" then
                exit;

        if CDSConnectionSetup.Get() then
            if CDSConnectionSetup."Is Enabled" then
                exit;

        Error(CDSConnectionMustBeEnabledErr, CRMProductName.SHORT(), CDSConnectionSetupPage.Caption());
    end;

    [Scope('OnPrem')]
    procedure LoadConnectionStringElementsFromCDSConnectionSetup();
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        CDSConnectionSetupPage: Page "CDS Connection Setup";
    begin
        if Get() then
            if "Is Enabled" then
                exit;

        if CDSConnectionSetup.Get() then
            if CDSConnectionSetup."Is Enabled" then begin
                "Server Address" := CDSConnectionSetup."Server Address";
                "User Name" := CDSConnectionSetup."User Name";
                "User Password Key" := CDSConnectionSetup."User Password Key";
                "Authentication Type" := CDSConnectionSetup."Authentication Type";
                "Proxy Version" := CDSConnectionSetup."Proxy Version";
                if not Modify() then
                    Insert();
                SetConnectionString(CDSConnectionSetup."Connection String");
                exit;
            end;

        Error(CDSConnectionMustBeEnabledErr, CRMProductName.SHORT(), CDSConnectionSetupPage.Caption());
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure DeployCRMSolution(ForceRedeploy: Boolean);
    var
        DummyCRMConnectionSetup: Record "CRM Connection Setup";
        AdminEmail: Text;
        AdminPassword: Text;
        AccessToken: Text;
        AdminADDomain: Text;
    begin
        if not ForceRedeploy and CRMIntegrationManagement.IsCRMSolutionInstalled() then
            exit;

        DummyCRMConnectionSetup.EnsureCDSConnectionIsEnabled();
        case "Authentication Type" of
            "Authentication Type"::Office365:
                CDSIntegrationImpl.GetAccessToken("Server Address", true, AccessToken);
            "Authentication Type"::AD:
                if not PromptForCredentials(AdminEmail, AdminPassword, AdminADDomain) then
                    exit;
            else
                if not PromptForCredentials(AdminEmail, AdminPassword) then
                    exit;
        end;

        if CRMIntegrationManagement.ImportCRMSolution("Server Address", "User Name", AdminEmail, AdminPassword, AccessToken, AdminADDomain, "Proxy Version", ForceRedeploy) then
            Message(DeploySucceedMsg)
        else
            Message(DeployFailedMsg);
    end;

    procedure CountCRMJobQueueEntries(var ActiveJobs: Integer; var TotalJobs: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not "Is Enabled" then begin
            TotalJobs := 0;
            ActiveJobs := 0;
        end else begin
            if "Is CRM Solution Installed" then
                JobQueueEntry.SetFilter("Object ID to Run", GetJobQueueEntriesObjectIDToRunFilter)
            else
                JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"Integration Synch. Job Runner");
            TotalJobs := JobQueueEntry.Count();

            JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
            ActiveJobs := JobQueueEntry.Count();
        end;
    end;

    [Scope('OnPrem')]
    procedure HasPassword(): Boolean
    begin
        exit(GetPassword <> '');
    end;

    [Scope('OnPrem')]
    procedure SetPassword(PasswordText: Text)
    begin
        if IsTemporary() then begin
            TempUserPassword := PasswordText;
            exit;
        end;
        if IsNullGuid("User Password Key") then
            "User Password Key" := CreateGuid;

        IsolatedStorageManagement.Set("User Password Key", PasswordText, DATASCOPE::Company);
    end;

    [Scope('OnPrem')]
    procedure DeletePassword()
    begin
        if IsTemporary() then begin
            Clear(TempUserPassword);
            exit;
        end;

        if IsNullGuid("User Password Key") then
            exit;

        IsolatedStorageManagement.Delete(Format("User Password Key"), DATASCOPE::Company);
    end;

    procedure UpdateAllConnectionRegistrations()
    begin
        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, GetDefaultTableConnection(TABLECONNECTIONTYPE::CRM));

        UnregisterConnection;
        if "Is Enabled" then
            RegisterUserConnection;
    end;

    procedure UpdateIsEnabledState()
    begin
        "Is User Mapped To CRM User" := IsCurrentUserMappedToCrmSystemUser;
        "Is Enabled For User" :=
          "Is Enabled" and
          ((not "Is User Mapping Required") or ("Is User Mapping Required" and "Is User Mapped To CRM User"));
    end;

    procedure RegisterConnection()
    begin
        if not HasTableConnection(TABLECONNECTIONTYPE::CRM, "Primary Key") then
            RegisterConnectionWithName("Primary Key");
    end;

    procedure RegisterConnectionWithName(ConnectionName: Text)
    begin
        RegisterTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName, GetConnectionStringWithCredentials());
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(ConnectionName));
    end;

    procedure UnregisterConnection(): Boolean
    begin
        exit(UnregisterConnectionWithName("Primary Key"));
    end;

    [TryFunction]
    procedure UnregisterConnectionWithName(ConnectionName: Text)
    begin
        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName);
    end;

    local procedure ConstructConnectionStringWithCalledID(CallerID: Text): Text
    begin
        exit(GetConnectionStringWithCredentials() + 'CallerID=' + CallerID);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetConnectionStringWithCredentials() ConnectionString: Text
    var
        PasswordPlaceHolderPos: Integer;
    begin
        ConnectionString := GetConnectionString();

        // if the setup record is temporary and connection string contains access token, this is a temp setup record constructed for the admin log-on
        // in this case just use the connection string
        if IsTemporary() and ConnectionString.Contains(AccessTokenTok) then
            exit(ConnectionString);

        if ConnectionString = '' then
            ConnectionString := UpdateConnectionString();

        // if auth type is Office365 and connection string contains {ClientSecret} token
        // then we will connect via OAuth client credentials grant flow, and construct the connection string accordingly, with the actual client secret
        if "Authentication Type" = "Authentication Type"::Office365 then begin
            if ConnectionString.Contains(ClientSecretTok) then begin
                ConnectionString := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, "Server Address", CDSIntegrationImpl.GetCDSConnectionClientId(), CDSIntegrationImpl.GetCDSConnectionClientSecret(), "Proxy Version");
                exit(ConnectionString);
            end;

            if ConnectionString.Contains(CertificateTok) then begin
                ConnectionString := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, "Server Address", CDSIntegrationImpl.GetCDSConnectionFirstPartyAppId(), CDSIntegrationImpl.GetCDSConnectionFirstPartyAppCertificate(), "Proxy Version");
                exit(ConnectionString);
            end;
        end;

        PasswordPlaceHolderPos := StrPos(ConnectionString, MissingPasswordTok);
        ConnectionString :=
          CopyStr(ConnectionString, 1, PasswordPlaceHolderPos - 1) + GetPassword +
          CopyStr(ConnectionString, PasswordPlaceHolderPos + StrLen(MissingPasswordTok));
    end;

    procedure RegisterUserConnection() ConnectionName: Text
    var
        SyncUser: Record User;
        CallerID: Guid;
    begin
        RegisterConnection;
        SyncUser."User Name" := CopyStr("User Name", 1, MaxStrLen(SyncUser."User Name"));
        SyncUser."Authentication Email" := "User Name";
        if not TryGetSystemUserId(SyncUser, CallerID) then begin
            UnregisterConnection;
            Validate("Is Enabled", false);
            Validate("Is User Mapping Required", false);
            Modify;
            ShowError(UserCRMSetupTxt, StrSubstNo(CannotConnectCRMErr, "User Name", CRMProductName.SHORT));
        end else
            ConnectionName := RegisterAuthUserConnection;
    end;

    local procedure RegisterAuthUserConnection() ConnectionName: Text
    var
        User: Record User;
        CallerID: Guid;
    begin
        if GetUser(User) then
            if not TryGetSystemUserId(User, CallerID) then begin
                UnregisterConnection;
                ShowError(UserCRMSetupTxt, StrSubstNo(CannotConnectCRMErr, User."Authentication Email"));
            end else
                if not IsNullGuid(CallerID) then begin
                    UnregisterConnection;
                    ConnectionName := RegisterConnectionWithCallerID(CallerID);
                end;
    end;

    local procedure RegisterConnectionWithCallerID(CallerID: Text) ConnectionName: Text
    begin
        if "Is Enabled" then begin
            RegisterTableConnection(TABLECONNECTIONTYPE::CRM, "Primary Key", ConstructConnectionStringWithCalledID(CallerID));
            ConnectionName := "Primary Key";
            if "Primary Key" = '' then begin
                ConnectionName := GetDefaultCRMConnection("Primary Key");
                SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName);
            end;
        end else
            ShowError(UserCRMSetupTxt, CantRegisterDisabledConnectionErr);
    end;

    procedure GetIntegrationUserID() IntegrationUserID: Guid
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        Get;
        TestField("Is Enabled");
        FilterCRMSystemUser(CRMSystemuser);
        if CRMSystemuser.FindFirst then
            IntegrationUserID := CRMSystemuser.SystemUserId;
        if IsNullGuid(IntegrationUserID) then
            ShowError(UserCRMSetupTxt, StrSubstNo(CannotResolveUserFromConnectionSetupErr, CRMProductName.SHORT));
    end;

    [Scope('OnPrem')]
    procedure GetPassword(): Text
    var
        Value: Text;
    begin
        if IsTemporary() then
            exit(TempUserPassword);
        if not IsNullGuid("User Password Key") then
            IsolatedStorageManagement.Get("User Password Key", DATASCOPE::Company, Value);
        exit(Value);
    end;

    local procedure GetUser(var User: Record User): Boolean
    begin
        if User.Get(DATABASE.UserSecurityId) then
            exit(true);
        User.Reset();
        User.SetRange("Windows Security ID", Sid);
        exit(User.FindFirst);
    end;

    local procedure GetUserName() UserName: Text
    begin
        if "User Name" = '' then
            UserName := MissingUsernameTok
        else
            UserName := CopyStr("User Name", StrPos("User Name", '\') + 1);
    end;

    procedure GetJobQueueEntriesObjectIDToRunFilter(): Text
    begin
        exit(
          StrSubstNo(
            '%1|%2|%3|%4|%5',
            CODEUNIT::"Integration Synch. Job Runner",
            CODEUNIT::"CRM Statistics Job",
            CODEUNIT::"Auto Create Sales Orders",
            CODEUNIT::"Auto Process Sales Quotes",
            CODEUNIT::"Int. Uncouple Job Runner"));
    end;

    [Scope('OnPrem')]
    procedure PerformTestConnection()
    begin
        VerifyTestConnection;

        if "Is User Mapping Required" and "Is Enabled" then
            if not IsCurrentUserMappedToCrmSystemUser then begin
                Message(ConnectionSuccessNotEnabledForCurrentUserMsg, UserId, PRODUCTNAME.Short, CRMProductName.SHORT);
                exit;
            end;

        Message(ConnectionSuccessMsg);
    end;

    [Scope('OnPrem')]
    procedure VerifyTestConnection(): Boolean
    begin
        if ("Server Address" = '') or ("User Name" = '') then
            Error(DetailsMissingErr, CRMProductName.SHORT);

        CRMIntegrationManagement.ClearState;

        if not TestConnection then
            Error(ConnectionErr, CRMIntegrationManagement.GetLastErrorMessage);

        TestIntegrationUserRequirements;

        exit(true);
    end;

    procedure TestConnection() Success: Boolean
    var
        TestConnectionName: Text;
    begin
        TestConnectionName := Format(CreateGuid);
        UnregisterConnectionWithName(TestConnectionName);
        RegisterConnectionWithName(TestConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(TestConnectionName), true);
        Success := TryReadSystemUsers;

        UnregisterConnectionWithName(TestConnectionName);
    end;

    procedure TestIntegrationUserRequirements()
    var
        CRMRole: Record "CRM Role";
        TempCRMRole: Record "CRM Role" temporary;
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMSystemuser: Record "CRM Systemuser";
        BCIntAdminCRMRoleName: Text;
        BCIntUserCRMRoleName: Text;
        SystemAdminCRMRoleName: Text;
        TestConnectionName: Text;
        BCIntegrationAdminRoleDeployed: Boolean;
        BCIntegrationUserRoleDeployed: Boolean;
        BCIntegrationRolesDeployed: Boolean;
        ChosenUserIsSystemAdmin: Boolean;
        ChosenUserIsBCIntegrationAdmin: Boolean;
        ChosenUserIsBCIntegrationUser: Boolean;
    begin
        TestConnectionName := Format(CreateGuid);
        UnregisterConnectionWithName(TestConnectionName);
        RegisterConnectionWithName(TestConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(TestConnectionName), true);

        if CRMRole.FindSet then
            repeat
                TempCRMRole.TransferFields(CRMRole);
                TempCRMRole.Insert();
                if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationAdministratorRoleIdTxt then begin
                    BCIntegrationAdminRoleDeployed := true;
                    BCIntAdminCRMRoleName := TempCRMRole.Name;
                end;
                if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationUserRoleIdTxt then begin
                    BCIntegrationUserRoleDeployed := true;
                    BCIntUserCRMRoleName := TempCRMRole.Name;
                end;
            until CRMRole.Next() = 0;

        BCIntegrationRolesDeployed := BCIntegrationAdminRoleDeployed and BCIntegrationUserRoleDeployed;

        CRMSystemuser.SetFilter(InternalEMailAddress, StrSubstNo('@%1', "User Name"));
        if CRMSystemuser.FindFirst then begin
            if CRMSystemuser.IsDisabled then
                Error(UserNotActiveErr, "User Name", "Server Address");
            if "Authentication Type" <> "Authentication Type"::Office365 then
                if not CRMSystemuser.IsLicensed then
                    Error(UserNotLicensedErr, "User Name", "Server Address");

            CRMSystemuserroles.SetRange(SystemUserId, CRMSystemuser.SystemUserId);
            if CRMSystemuserroles.FindSet then
                repeat
                    if TempCRMRole.Get(CRMSystemuserroles.RoleId) then begin
                        if UpperCase(Format(TempCRMRole.RoleTemplateId)) = SystemAdminRoleTemplateIdTxt then begin
                            ChosenUserIsSystemAdmin := true;
                            SystemAdminCRMRoleName := TempCRMRole.Name
                        end;
                        if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationAdministratorRoleIdTxt then
                            ChosenUserIsBCIntegrationAdmin := true;
                        if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationUserRoleIdTxt then
                            ChosenUserIsBCIntegrationUser := true;
                    end;
                until CRMSystemuserroles.Next() = 0
            else
                if ("Server Address" <> '') and ("Server Address" <> '@@test@@') then
                    Error(UserHasNoRolesErr, "User Name", "Server Address");

            if ChosenUserIsSystemAdmin then
                Error(SystemAdminErr, "User Name", SystemAdminCRMRoleName, "Server Address");

            if BCIntegrationRolesDeployed and not (ChosenUserIsBCIntegrationAdmin and ChosenUserIsBCIntegrationUser) then
                Error(BCRolesErr, "User Name", BCIntAdminCRMRoleName, BCIntUserCRMRoleName, "Server Address");
        end;

        UnregisterConnectionWithName(TestConnectionName);
    end;

    [TryFunction]
    procedure TryReadSystemUsers()
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        CRMSystemuser.FindFirst;
    end;

    local procedure CreateOrganizationService(var CRMHelper: DotNet CrmHelper)
    begin
        CRMHelper := CRMHelper.CrmHelper(GetConnectionStringWithCredentials());
    end;

    [TryFunction]
    local procedure GetCrmVersion(var Version: Text)
    var
        CRMHelper: DotNet CrmHelper;
    begin
        if not DoReadCRMData then
            exit;

        Version := '';
        CreateOrganizationService(CRMHelper);
        Version := CRMHelper.GetConnectedCrmVersion;
    end;

    procedure IsVersionValid(): Boolean
    var
        Version: DotNet Version;
    begin
        if "CRM Version" <> '' then
            if Version.TryParse("CRM Version", Version) then
                exit((Version.Major > 6) and not ((Version.Major = 7) and (Version.Minor = 1)));
        exit(false);
    end;

    procedure IsCurrentUserMappedToCrmSystemUser(): Boolean
    var
        User: Record User;
        CRMSystemUserId: Guid;
    begin
        if GetUser(User) then
            if TryGetSystemUserId(User, CRMSystemUserId) then
                exit(not IsNullGuid(CRMSystemUserId));
    end;

    [TryFunction]
    local procedure TryGetSystemUserId(User: Record User; var SystemUserId: Guid)
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        // Returns FALSE if CRMSystemuser.FINDFIRST throws an exception, e.g. due to wrong credentials;
        // Returns TRUE regardless of CRMSystemuser.FINDFIRST result,
        // further check of ISNULLGUID(SystemUserId) is required to identify if the user exists
        Clear(SystemUserId);
        if "Is Enabled" then
            if "Is User Mapping Required" then begin
                CRMSystemuser.SetRange(IsDisabled, false);
                case "Authentication Type" of
                    "Authentication Type"::AD, "Authentication Type"::IFD:
                        CRMSystemuser.SetRange(DomainName, User."User Name");
                    "Authentication Type"::Office365, "Authentication Type"::OAuth:
                        CRMSystemuser.SetRange(InternalEMailAddress, User."Authentication Email");
                end;
                if CRMSystemuser.FindFirst then
                    SystemUserId := CRMSystemuser.SystemUserId;
            end;
    end;

    procedure UpdateFromWizard(var SourceCRMConnectionSetup: Record "CRM Connection Setup"; PasswordText: Text)
    begin
        if not Get then begin
            Init;
            Insert;
        end;
        Validate("Server Address", SourceCRMConnectionSetup."Server Address");
        Validate("Authentication Type", "Authentication Type"::Office365);
        Validate("User Name", SourceCRMConnectionSetup."User Name");
        SetPassword(PasswordText);
        Validate("Proxy Version", SourceCRMConnectionSetup."Proxy Version");
        "Is S.Order Integration Enabled" := SourceCRMConnectionSetup."Is S.Order Integration Enabled";
        "Item Availability Enabled" := SourceCRMConnectionSetup."Item Availability Enabled";
        Modify(true);
    end;

    local procedure EnableCRMConnection()
    begin
        if "Is Enabled" = xRec."Is Enabled" then
            exit;

        if not UnregisterConnection then
            ClearLastError;

        if "Is Enabled" then begin
            VerifyTestConnection;
            RegisterUserConnection;
            VerifyBaseCurrencyMatchesLCY;
            InstallIntegrationSolution();
            EnableIntegrationTables;
            if "Disable Reason" <> '' then
                CRMIntegrationManagement.ClearConnectionDisableReason(Rec);
        end else begin
            "CRM Version" := '';
            "Is S.Order Integration Enabled" := false;
            "Is CRM Solution Installed" := false;
            CurrencyDecimalPrecision := 0;
            Clear(BaseCurrencyId);
            BaseCurrencyPrecision := 0;
            BaseCurrencySymbol := '';
            UpdateCRMJobQueueEntriesStatus;
            CRMIntegrationManagement.ClearState;
        end;
    end;

    [NonDebuggable]
    local procedure InstallIntegrationSolution()
    var
        AdminEmail: Text;
        AdminPassword: Text;
        AccessToken: Text;
        AdminADDomain: Text;
    begin
        if CRMIntegrationManagement.IsCRMSolutionInstalled() then
            exit;

        case "Authentication Type" of
            "Authentication Type"::Office365:
                CDSIntegrationImpl.GetAccessToken("Server Address", true, AccessToken);
            "Authentication Type"::AD:
                if not PromptForCredentials(AdminEmail, AdminPassword, AdminADDomain) then
                    exit;
            else
                if not PromptForCredentials(AdminEmail, AdminPassword) then
                    exit;
        end;

        CRMIntegrationManagement.ImportCRMSolution(
            "Server Address", "User Name", AdminEmail, AdminPassword, AccessToken, AdminADDomain, "Proxy Version", false);
    end;

    local procedure EnableIntegrationTables()
    var
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
    begin
        Modify; // Job Queue to read "Is Enabled"
        Commit();
        CRMSetupDefaults.ResetConfiguration(Rec);
    end;

    procedure EnableCRMConnectionFromWizard()
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        Get;
        "Is User Mapping Required" := false;
        Validate("Is Enabled", true);
        Modify(true);

        FilterCRMSystemUser(CRMSystemuser);
        CRMSystemuser.FindFirst;
        if (CRMSystemuser.InviteStatusCode <> CRMSystemuser.InviteStatusCode::InvitationAccepted) or
           (not CRMSystemuser.IsIntegrationUser)
        then begin
            CRMSystemuser.InviteStatusCode := CRMSystemuser.InviteStatusCode::InvitationAccepted;
            CRMSystemuser.IsIntegrationUser := true;
            CRMSystemuser.Modify(true);
        end;
    end;

    procedure RestoreConnection()
    begin
        // This function should be called from OnAfterUpgradeComplete trigger (when introduced)
        if "Restore Connection" then begin
            "Restore Connection" := false;
            Modify;
            Commit();
            if TestConnection then
                Validate("Is Enabled", true);
            Modify;
        end;
    end;

    procedure SetCRMSOPEnabled()
    begin
        TestField("Is CRM Solution Installed", true);
        SetCRMSOPEnabledWithCredentials('', '', true);
    end;

    procedure SetCRMSOPDisabled()
    var
        CRMSalesorder: Record "CRM Salesorder";
    begin
        CRMSalesorder.SetRange(StateCode, CRMSalesorder.StateCode::Submitted);
        if not CRMSalesorder.IsEmpty() then
            Error(CannotDisableSalesOrderIntErr);
        SetCRMSOPEnabledWithCredentials('', '', false);
        Validate("Auto Create Sales Orders", false);
    end;

    [Scope('OnPrem')]
    procedure SetCRMSOPEnabledWithCredentials(AdminEmail: Text; AdminPassword: Text; SOPIntegrationEnable: Boolean)
    var
        CRMOrganization: Record "CRM Organization";
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        CRMConnectionSetup: Record "CRM Connection Setup";
        ConnectionName: Text;
    begin
        CreateTempAdminConnection(TempCRMConnectionSetup);
        if (AdminEmail <> '') and (AdminPassword <> '') then begin
            TempCRMConnectionSetup.SetPassword(AdminPassword);
            TempCRMConnectionSetup.Validate("User Name", COPYSTR(AdminEmail, 1, MaxStrLen(TempCRMConnectionSetup."User Name")));
            TempCRMConnectionSetup.SetConnectionString(Rec.GetConnectionString());
        end
        else begin
            CRMConnectionSetup.Get();
            TempCRMConnectionSetup.Validate("User Name", CRMConnectionSetup."User Name");
            TempCRMConnectionSetup.SetPassword(CRMConnectionSetup.GetPassword());
            TempCRMConnectionSetup.SetConnectionString(CRMConnectionSetup.GetConnectionString());
        end;
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(ConnectionName), true);

        CRMOrganization.FindFirst;
        if CRMOrganization.IsSOPIntegrationEnabled <> SOPIntegrationEnable then begin
            CRMOrganization.IsSOPIntegrationEnabled := SOPIntegrationEnable;
            CRMOrganization.Modify(true);
        end;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
    end;

    procedure SetUserAsIntegrationUser()
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        ConnectionName: Text;
    begin
        CreateTempAdminConnection(TempCRMConnectionSetup);
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(ConnectionName), true);
        FilterCRMSystemUser(CRMSystemuser);
        CRMSystemuser.FindFirst;

        if (CRMSystemuser.InviteStatusCode <> CRMSystemuser.InviteStatusCode::InvitationAccepted) or
           (not CRMSystemuser.IsIntegrationUser)
        then begin
            CRMSystemuser.InviteStatusCode := CRMSystemuser.InviteStatusCode::InvitationAccepted;
            CRMSystemuser.IsIntegrationUser := true;
            CRMSystemuser.Modify(true);
        end;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
    end;

    local procedure CreateTempAdminConnection(var CRMConnectionSetup: Record "CRM Connection Setup")
    begin
        CreateTempNoDelegateConnection(CRMConnectionSetup);
        Clear(CRMConnectionSetup."User Password Key");
        CRMConnectionSetup.Validate("User Name", '');
    end;

    local procedure CreateTempNoDelegateConnection(var CRMConnectionSetup: Record "CRM Connection Setup")
    begin
        CRMConnectionSetup.Init();
        CalcFields("Server Connection String");
        CRMConnectionSetup.TransferFields(Rec);
        CRMConnectionSetup.SetConnectionString(Rec.GetConnectionString());
        CRMConnectionSetup."Primary Key" := CopyStr('TEMP' + "Primary Key", 1, MaxStrLen(CRMConnectionSetup."Primary Key"));
        CRMConnectionSetup."Is Enabled" := true;
        CRMConnectionSetup."Is User Mapping Required" := false;
    end;

    [Scope('OnPrem')]
    procedure RefreshDataFromCRM()
    begin
        RefreshDataFromCRM(true);
    end;

    [Scope('OnPrem')]
    procedure RefreshDataFromCRM(ResetSalesOrderMappingConfiguration: Boolean)
    var
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        ConnectionName: Text;
    begin
        if "Is Enabled" then begin
            if "Is User Mapping Required" then begin
                CreateTempNoDelegateConnection(TempCRMConnectionSetup);
                ConnectionName := Format(CreateGuid);
                TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
                "Is User Mapped To CRM User" := IsCurrentUserMappedToCrmSystemUser;
            end;

            "Is CRM Solution Installed" := CRMIntegrationManagement.IsCRMSolutionInstalled;
            RefreshFromCRMConnectionInformation;
            if TryRefreshCRMSettings then
                if ResetSalesOrderMappingConfiguration then
                    CRMSetupDefaults.ResetSalesOrderMappingConfiguration(Rec);

            if ConnectionName <> '' then
                TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);
        end;
    end;

    local procedure RefreshFromCRMConnectionInformation()
    var
        CRMNAVConnection: Record "CRM NAV Connection";
    begin
        if "Is CRM Solution Installed" then
            if CRMNAVConnection.FindFirst then
                "Dynamics NAV URL" := CRMNAVConnection."Dynamics NAV URL";
    end;

    [TryFunction]
    local procedure TryRefreshCRMSettings()
    var
        CRMOrganization: Record "CRM Organization";
    begin
        GetCrmVersion("CRM Version");
        Validate("CRM Version");

        if CRMOrganization.FindFirst then begin
            "Is S.Order Integration Enabled" := CRMOrganization.IsSOPIntegrationEnabled;
            CurrencyDecimalPrecision := CRMOrganization.CurrencyDecimalPrecision;
            BaseCurrencyId := CRMOrganization.BaseCurrencyId;
            BaseCurrencyPrecision := CRMOrganization.BaseCurrencyPrecision;
            BaseCurrencySymbol := CRMOrganization.BaseCurrencySymbol;
        end else
            "Is S.Order Integration Enabled" := false;
    end;

    local procedure VerifyBaseCurrencyMatchesLCY()
    var
        CRMOrganization: Record "CRM Organization";
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        GLSetup: Record "General Ledger Setup";
    begin
        CRMOrganization.FindFirst;
        CRMTransactioncurrency.Get(CRMOrganization.BaseCurrencyId);
        GLSetup.Get();
        if DelChr(CRMTransactioncurrency.ISOCurrencyCode) <> DelChr(GLSetup."LCY Code") then
            Error(LCYMustMatchBaseCurrencyErr, GLSetup."LCY Code", CRMTransactioncurrency.ISOCurrencyCode);
    end;

    [Scope('OnPrem')]
    procedure PerformWebClientUrlReset()
    var
        TempCRMConnectionSetup: Record "CRM Connection Setup" temporary;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
        ConnectionName: Text;
    begin
        CreateTempNoDelegateConnection(TempCRMConnectionSetup);
        ConnectionName := Format(CreateGuid);
        TempCRMConnectionSetup.RegisterConnectionWithName(ConnectionName);
        SetDefaultTableConnection(
          TABLECONNECTIONTYPE::CRM, GetDefaultCRMConnection(ConnectionName), true);

        CRMSetupDefaults.ResetCRMNAVConnectionData;

        TempCRMConnectionSetup.UnregisterConnectionWithName(ConnectionName);

        RefreshDataFromCRM;
    end;

    procedure SynchronizeNow(DoFullSynch: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
    begin
        CRMSetupDefaults.GetPrioritizedMappingList(TempNameValueBuffer);

        TempNameValueBuffer.Ascending(true);
        if not TempNameValueBuffer.FindSet() then
            exit;

        repeat
            if IntegrationTableMapping.Get(TempNameValueBuffer.Value) then
                IntegrationTableMapping.SynchronizeNow(DoFullSynch);
        until TempNameValueBuffer.Next() = 0;
    end;

    procedure PromptForCredentials(var AdminEmail: Text; var AdminPassword: Text): Boolean
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
    begin
        if TempOfficeAdminCredentials.IsEmpty() then begin
            TempOfficeAdminCredentials.Init();
            TempOfficeAdminCredentials.Insert(true);
            Commit();
            if PAGE.RunModal(PAGE::"Dynamics CRM Admin Credentials", TempOfficeAdminCredentials) <> ACTION::LookupOK then
                exit(false);
        end;
        if (not TempOfficeAdminCredentials.FindFirst) or
           (TempOfficeAdminCredentials.Email = '') or (TempOfficeAdminCredentials.Password = '')
        then begin
            TempOfficeAdminCredentials.DeleteAll(true);
            exit(false);
        end;

        AdminEmail := TempOfficeAdminCredentials.Email;
        AdminPassword := TempOfficeAdminCredentials.Password;
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure PromptForCredentials(var AdminEmail: Text; var AdminPassword: Text; var AdminADDomain: Text): Boolean
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
        BackslashPos: Integer;
    begin
        if TempOfficeAdminCredentials.IsEmpty() then begin
            TempOfficeAdminCredentials.Init();
            TempOfficeAdminCredentials.Insert(true);
            Commit();
            if PAGE.RunModal(PAGE::"Dynamics CRM Admin Credentials", TempOfficeAdminCredentials) <> ACTION::LookupOK then
                exit(false);
        end;
        if (not TempOfficeAdminCredentials.FindFirst) or
           (TempOfficeAdminCredentials.Email = '') or (TempOfficeAdminCredentials.Password = '')
        then begin
            TempOfficeAdminCredentials.DeleteAll(true);
            exit(false);
        end;

        BackslashPos := StrPos(TempOfficeAdminCredentials.Email, '\');
        if (BackslashPos <= 1) or (BackslashPos = StrLen(TempOfficeAdminCredentials.Email)) then
            Error(UserNameMustIncludeDomainErr);
        AdminADDomain := CopyStr(TempOfficeAdminCredentials.Email, 1, BackslashPos - 1);
        AdminEmail := CopyStr(TempOfficeAdminCredentials.Email, BackslashPos + 1);
        AdminPassword := TempOfficeAdminCredentials.Password;
        exit(true);
    end;

    local procedure ShowError(ActivityDescription: Text[128]; ErrorMessage: Text)
    var
        MyNotifications: Record "My Notifications";
        SystemInitialization: Codeunit "System Initialization";
    begin
        if (not SystemInitialization.IsInProgress) and (GetExecutionContext() = ExecutionContext::Normal) then
            Error(ErrorMessage);

        MyNotifications.InsertDefault(GetCRMNotificationId, ActivityDescription, ErrorMessage, true);
    end;

    local procedure GetCRMNotificationId(): Guid
    begin
        exit('692A2701-4BBB-4C5B-B4C0-629D96B60644');
    end;

    procedure DoReadCRMData(): Boolean
    var
        SkipReading: Boolean;
    begin
        OnReadingCRMData(SkipReading);
        exit(not SkipReading);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadingCRMData(var SkipReading: Boolean)
    begin
    end;

    [Scope('OnPrem')]
    procedure GetDefaultCRMConnection(ConnectionName: Text): Text
    begin
        OnGetDefaultCRMConnection(ConnectionName);
        exit(ConnectionName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDefaultCRMConnection(var ConnectionName: Text)
    begin
    end;

    local procedure CrmAuthenticationType(): Text
    begin
        case "Authentication Type" of
            "Authentication Type"::Office365:
                exit('AuthType=Office365;');
            "Authentication Type"::AD:
                exit('AuthType=AD;' + GetDomain);
            "Authentication Type"::IFD:
                exit('AuthType=IFD;' + GetDomain + 'HomeRealmUri= ;');
            "Authentication Type"::OAuth:
                exit('AuthType=OAuth;' + 'AppId= ;' + 'RedirectUri= ;' + 'TokenCacheStorePath= ;' + 'LoginPrompt=Auto;');
        end;
    end;

    [Scope('OnPrem')]
    procedure UpdateConnectionString() ConnectionString: Text
    begin
        if "Authentication Type" <> "Authentication Type"::Office365 then
            ConnectionString := StrSubstNo(ConnectionStringFormatTok, "Server Address", GetUserName, MissingPasswordTok, "Proxy Version", CrmAuthenticationType)
        else
            if CDSIntegrationImpl.GetCDSConnectionFirstPartyAppId() <> '' then
                ConnectionString := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, "Server Address", ClientIdTok, CertificateTok, "Proxy Version")
            else
                ConnectionString := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, "Server Address", ClientIdTok, ClientSecretTok, "Proxy Version");

        SetConnectionString(ConnectionString);
    end;

    local procedure UpdateProxyVersionInConnectionString() ConnectionString: Text
    var
        LeftPart: Text;
        RightPart: Text;
        ProxyVersionTok: Text;
        IndexOfProxyVersion: Integer;
    begin
        ProxyVersionTok := 'ProxyVersion=';
        ConnectionString := GetConnectionString();

        // if the connection string is empty, just initialize it the standard way
        if ConnectionString = '' then begin
            ConnectionString := UpdateConnectionString();
            exit;
        end;

        IndexOfProxyVersion := ConnectionString.IndexOf(ProxyVersionTok);

        // if there is no proxy version in the connection string, just add it to the end
        if IndexOfProxyVersion = 0 then begin
            ConnectionString += ('; ' + ProxyVersionTok + Format("Proxy Version"));
            SetConnectionString(ConnectionString);
            exit;
        end;

        LeftPart := CopyStr(ConnectionString, 1, IndexOfProxyVersion - 1);
        RightPart := CopyStr(ConnectionString, IndexOfProxyVersion);

        // RightPart starts with ProxyVersion=
        // if there is no ; in it, then this is the end of the original connection string
        // just add proxy version to the end of LeftPart
        if RightPart.IndexOf(';') = 0 then begin
            ConnectionString := LeftPart + ProxyVersionTok + Format("Proxy Version");
            SetConnectionString(ConnectionString);
            exit;
        end;

        // in the remaining case, ProxyVersion=XYZ is in the middle of the string
        RightPart := CopyStr(RightPart, RightPart.IndexOf(';'));
        ConnectionString := LeftPart + ProxyVersionTok + Format("Proxy Version") + RightPart;
        SetConnectionString(ConnectionString);
    end;

    local procedure UpdateDomainName()
    begin
        if "User Name" <> '' then
            if StrPos("User Name", '\') > 0 then
                Validate(Domain, CopyStr("User Name", 1, StrPos("User Name", '\') - 1))
            else
                Domain := '';
    end;

    local procedure CheckUserName()
    begin
        if "User Name" <> '' then
            case "Authentication Type" of
                "Authentication Type"::AD:
                    if StrPos("User Name", '\') = 0 then
                        Error(UserNameMustIncludeDomainErr);
                "Authentication Type"::Office365:
                    if StrPos("User Name", '@') = 0 then
                        Error(UserNameMustBeEmailErr);
            end;
    end;

    local procedure GetDomain(): Text
    begin
        if Domain <> '' then
            exit(StrSubstNo('Domain=%1;', Domain));
    end;

    local procedure FilterCRMSystemUser(var CRMSystemuser: Record "CRM Systemuser")
    begin
        case "Authentication Type" of
            "Authentication Type"::Office365, "Authentication Type"::OAuth:
                CRMSystemuser.SetRange(InternalEMailAddress, "User Name");
            "Authentication Type"::AD, "Authentication Type"::IFD:
                CRMSystemuser.SetRange(DomainName, "User Name");
        end;
    end;

    procedure UpdateCRMJobQueueEntriesStatus()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        NewStatus: Option;
        JobQueueEntryCodeunitFilter: Text;
    begin
        if "Is Enabled" then
            NewStatus := JobQueueEntry.Status::Ready
        else
            NewStatus := JobQueueEntry.Status::"On Hold";
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"CRM Integration Table Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if CDSIntegrationImpl.IsIntegrationEnabled() then
            IntegrationTableMapping.SetFilter("Table ID", StrSubstNo('<>%1&<>%2&<>%3&<>%4&<>%5', Database::Currency, Database::"Salesperson/Purchaser", Database::Contact, Database::Customer, Database::Vendor));
        if IntegrationTableMapping.FindSet then
            repeat
                JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId);
                if JobQueueEntry.FindSet then
                    repeat
                        JobQueueEntry.SetStatus(NewStatus);
                    until JobQueueEntry.Next() = 0;
            until IntegrationTableMapping.Next() = 0;
        JobQueueEntryCodeunitFilter := StrSubstNo('%1|%2|%3|%4|%5', CODEUNIT::"Auto Create Sales Orders", CODEUNIT::"Auto Process Sales Quotes", CODEUNIT::"CRM Notes Synch Job", CODEUNIT::"CRM Order Status Update Job", CODEUNIT::"CRM Statistics Job");
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", JobQueueEntryCodeunitFilter);
        if JobQueueEntry.FindSet then
            repeat
                JobQueueEntry.SetStatus(NewStatus);
            until JobQueueEntry.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure GetConnectionString() ConnectionString: Text
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        InStream: InStream;
    begin
        if CRMConnectionSetup.Get("Primary Key") then
            CalcFields("Server Connection String");
        "Server Connection String".CreateInStream(InStream);
        InStream.ReadText(ConnectionString);
    end;

    [Scope('OnPrem')]
    procedure SetConnectionString(ConnectionString: Text)
    var
        OutStream: OutStream;
    begin
        if ConnectionString = '' then
            Clear("Server Connection String")
        else begin
            if "Authentication Type" <> "Authentication Type"::Office365 then
                if StrPos(ConnectionString, MissingPasswordTok) = 0 then
                    Error(ConnectionStringPwdPlaceHolderMissingErr);

            if "Authentication Type" = "Authentication Type"::Office365 then
                if (StrPos(ConnectionString, MissingPasswordTok) = 0) and (StrPos(ConnectionString, ClientSecretTok) = 0) and (StrPos(ConnectionString, CertificateTok) = 0) then
                    Error(ConnectionStringPwdOrClientSecretPlaceHolderMissingErr);

            Clear("Server Connection String");
            "Server Connection String".CreateOutStream(OutStream);
            OutStream.WriteText(ConnectionString);
        end;
        if not Modify then;
    end;

    procedure IsEnabled(): Boolean
    begin
        if not Get then
            exit(false);
        exit("Is Enabled");
    end;

    local procedure NewestUIAppModuleId(): Text[50]
    var
        CRMAppmodule: Record "CRM Appmodule";
        TypeHelper: Codeunit "Type Helper";
    begin
        if not TryFindAppModuleIdByName(CRMAppmodule, SalesHubAppModuleNameTxt) then
            exit('');
        if CRMAppmodule.Name <> SalesHubAppModuleNameTxt then
            exit('');
        exit(TypeHelper.GetGuidAsString(CRMAppmodule.AppModuleId));
    end;

    [TryFunction]
    local procedure TryFindAppModuleIdByName(var CRMAppmodule: Record "CRM Appmodule"; AppModuleName: Text)
    begin
        CRMAppmodule.SetRange(Name, AppModuleName);
        if CRMAppmodule.FindFirst then;
    end;

    procedure SetUseNewestUI()
    begin
        "Newest UI AppModuleId" := NewestUIAppModuleId;
        if "Newest UI AppModuleId" <> '' then
            "Use Newest UI" := true;
    end;
}

