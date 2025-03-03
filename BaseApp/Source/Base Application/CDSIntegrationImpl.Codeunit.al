codeunit 7201 "CDS Integration Impl."
{
    SingleInstance = true;

    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        EnvironmentInfo: Codeunit "Environment Information";
        CachedCompanyIdFieldNo: Dictionary of [Integer, Integer];
        CachedOwnerIdFieldNo: Dictionary of [Integer, Integer];
        CachedOwnerTypeFieldNo: Dictionary of [Integer, Integer];
        CachedOwningTeamCheckWithoutBusinessUnit: Dictionary of [Guid, Boolean];
        CachedOwningTeamCheckWithBusinessUnit: Dictionary of [Guid, Boolean];
        CachedOwningUserCheckWithoutBusinessUnit: Dictionary of [Guid, Boolean];
        CachedOwningUserCheckWithBusinessUnit: Dictionary of [Guid, Boolean];
        CachedCompanyId: Guid;
        CachedDefaultOwningTeamId: Guid;
        CachedOwningBusinessUnitId: Guid;
        AreCompanyValuesCached: Boolean;
        CategoryTok: Label 'AL Dataverse Integration', Locked = true;
        TimeoutTxt: Label 'timeout', Locked = true;
        RetryAfterTimeoutErr: Label 'The operation timed out. Try again.\\%1', Comment = '%1 - exception message ';
        IntegrationNotConfiguredTxt: Label 'Integration is not configured.', Locked = true;
        IntegrationDisabledTxt: Label 'Integration is disabled.', Locked = true;
        ActivateConnectionTxt: Label 'Activate connection.', Locked = true;
        ConnectionActiveTxt: Label 'Connection is active.', Locked = true;
        ConnectionNotActiveTxt: Label 'Connection is not active.', Locked = true;
        NoConnectionTxt: Label 'Connection is not registered.', Locked = true;
        OnBeforeActivateConnectionTxt: Label 'On before activate connection.', Locked = true;
        OnAfterActivateConnectionTxt: Label 'On after activate connection.', Locked = true;
        ConnectionActivatedTxt: Label 'Connection has been actived.', Locked = true;
        HasConnectionTxt: Label 'Connection is registered.', Locked = true;
        OnBeforeRegisterConnectionTxt: Label 'On before register connection.', Locked = true;
        OnAfterRegisterConnectionTxt: Label 'On after register connection.', Locked = true;
        OnBeforeUnregisterConnectionTxt: Label 'On before unregister connection.', Locked = true;
        OnAfterUnregisterConnectionTxt: Label 'On after unregister connection.', Locked = true;
        OnEnableIntegrationTxt: Label 'On enable integration.', Locked = true;
        OnDisableIntegrationTxt: Label 'On disable integration.', Locked = true;
        DisableIntegrationTxt: Label 'Disable integration.', Locked = true;
        NoPermissionsTxt: Label 'No permissions.', Locked = true;
        UpdateSetupTxt: Label 'Update setup.', Locked = true;
        SetupUpdatedTxt: Label 'Setup has been updated.', Locked = true;
        ConnectionFailureTxt: Label 'Connection failure.', Locked = true;
        EntityHasNoOwnerIdFieldTxt: Label 'Entity has no OwnerId field.', Locked = true;
        EntityHasNoOwnerTypeFieldTxt: Label 'Entity has no OwnerIdType field.', Locked = true;
        OwnerSetTxt: Label 'Owner has been set.', Locked = true;
        UnsupportedOwnerTypeTxt: Label 'Unsupported owner type.', Locked = true;
        OwnerCheckedTxt: Label 'Owner check is succeed.', Locked = true;
        CheckOwnerTxt: Label 'Check owner.', Locked = true;
        SetOwnerTxt: Label 'Set owner.', Locked = true;
        EntityHasNoCompanyIdFieldTxt: Label 'Entity has no CompanyId field.', Locked = true;
        CompanyIdSetTxt: Label 'CompanyId has been set.', Locked = true;
        CompanyIdCheckedTxt: Label 'CompanyId check is succeed.', Locked = true;
        CheckCompanyIdTxt: Label 'Check CompanyId.', Locked = true;
        SetCompanyIdTxt: Label 'Set CompanyId.', Locked = true;
        InitializeCompanyCacheTxt: Label 'Initialize company cache.', Locked = true;
        SetCachedOwningTeamCheckTxt: Label 'Set cache for team check. Team: %1, skip business unit check: %2.', Locked = true;
        SetCachedOwningUserCheckTxt: Label 'Set cache for user check. User: %1, skip business unit check: %2.', Locked = true;
        ClearCacheTxt: Label 'Clear cache.', Locked = true;
        CannotFindCompanyIdFieldErr: Label 'There is no CompanyId field in table %1 %2.', Comment = '%1 = table ID, %2 = table name';
        CompanyIdDiffersFromExpectedTxt: Label 'CompanyId differs from the expected one.', Locked = true;
        SetDefaultOwningTeamTxt: Label 'Set default owning team.', Locked = true;
        TeamNotFoundTxt: Label 'Team has not been found.', Locked = true;
        UserNotFoundTxt: Label 'User has not been found.', Locked = true;
        UpdateUserNameTxt: Label 'Update integration user name.', Locked = true;
        UpdateUserEmailTxt: Label 'Update integration user email.', Locked = true;
        UserNameNotUpdatedTxt: Label 'Integration user name has not been updated.', Locked = true;
        UserEmailNotUpdatedTxt: Label 'Integration user email has not been updated.', Locked = true;
        CannotUpdateUserNameAndEmailTxt: Label 'Cannot update integration user name and email.', Locked = true;
        CoupledUsersNotFoundTxt: Label 'Coupled users have not been found.', Locked = true;
        BusinessUnitNotFoundTxt: Label 'Business unit has not been found.', Locked = true;
        BusinessUnitMismatchTxt: Label 'Business unit in BC does not match business unit in Dataverse.', Locked = true;
        CompanyNotFoundTxt: Label 'Company has not been found.', Locked = true;
        OrganizationNotFoundTxt: Label 'Organization has not been found.', Locked = true;
        CurrencyNotFoundTxt: Label 'Organization has not been found.', Locked = true;
        GLSetupNotFoundTxt: Label 'GL setup has not been found.', Locked = true;
        IntegrationRoleNotFoundTxt: Label 'Integration role has not been found.', Locked = true;
        IntegrationRoleNotAssignedToTeamTxt: Label 'Integration role is not assigned to team.', Locked = true;
        RoleNotFoundForBusinessUnitTxt: Label 'Integration role is not found for business unit.', Locked = true;
        TeamBusinessUnitDiffersFromSelectedTxt: Label 'Team business unit differs from the selected one.', Locked = true;
        UserBusinessUnitDiffersFromSelectedTxt: Label 'User business unit differs from the selected one.', Locked = true;
        CannotAssignRoleToUserTxt: Label 'Cannot assign role to user.', Locked = true;
        CannotAssignRoleToTeamTxt: Label 'Cannot assign role to team.', Locked = true;
        CannotAddUserToTeamTxt: Label 'Cannot add user to team.', Locked = true;
        ConnectionRequiredFieldsTxt: Label 'A URL, user name and password are required.', Locked = true;
        Office365ConnectionRequiredFieldsTxt: Label 'A URL is required.', Locked = true;
        ConnectionRequiredFieldsMismatchTxt: Label 'The URL, user name, password, and authentication type must be the same on the Dataverse Connection Setup and Microsoft Dynamics 365 Connection Setup pages.', Locked = true;
        IgnoredAdminCredentialsTxt: Label 'Ignored administrator credentials.', Locked = true;
        InvalidAdminCredentialsTxt: Label 'Invalid administrator credentials.', Locked = true;
        InvalidUserCredentialsTxt: Label 'Invalid user credentials.', Locked = true;
        ConfigureSolutionTxt: Label 'Import and configure integration solution.', Locked = true;
        ImportSolutionTxt: Label 'Import integration solution.', Locked = true;
        SolutionConfiguredTxt: Label 'Integration solution has been imported and configured.', Locked = true;
        SolutionNotInstalledTxt: Label 'Integration solution is not installed.', Locked = true;
        SolutionInstalledTxt: Label 'Integration solution is installed.', Locked = true;
        ConnectionNotRegisteredTxt: Label 'Connection is not registered.', Locked = true;
        IntegrationRequirementsMetTxt: Label 'Integration requirements are met.', Locked = true;
        DefaultOwningTeamSetTxt: Label 'Default owning team has been set.', Locked = true;
        CannotSetDefaultOwningTeamTxt: Label 'Cannot set default owning team.', Locked = true;
        BusinessUnitFixedTxt: Label 'Business unit has been fixed.', Locked = true;
        ConnectionTestSucceedTxt: Label 'Connection test succeed.', Locked = true;
        ConnectionTestFailedTxt: Label 'Connection test failed.', Locked = true;
        IntegrationRequirementsNotMetTxt: Label 'Integration requirements are not met.', Locked = true;
        SolutionRequirementsNotMetTxt: Label 'Integration solution requirements are not met.', Locked = true;
        IntegrationUserRequirementsNotMetTxt: Label 'Integration user requirements are not met.', Locked = true;
        OwningTeamRequirementsNotMetTxt: Label 'Owning team requirements are not met.', Locked = true;
        InvalidSolutionVersionTxt: Label 'Solution version is invalid.', Locked = true;
        OwnerDiffersFromExpectedTxt: Label 'Owner differs from the expected one.', Locked = true;
        SynchronizeCompanyTxt: Label 'Synchronize company entity.', Locked = true;
        CompanySynchronizedTxt: Label 'Company has been synchronized.', Locked = true;
        PreviousIntegrationUserRolesAddedTxt: Label 'Previous integration user security roles added to current integration user.', Locked = true;
        RoleAssignedToTeamTxt: Label 'Role is assigned to team.', Locked = true;
        RoleAssignedToUserTxt: Label 'Role is assigned to user.', Locked = true;
        UserAddedToTeamTxt: Label 'User is added to team.', Locked = true;
        CannotCreateBusinessUnitTxt: Label 'Cannot create business unit.', Locked = true;
        BusinessUnitCreatedTxt: Label 'Business unit has been created.', Locked = true;
        CannotCreateTeamTxt: Label 'Cannot create team.', Locked = true;
        TeamCreatedTxt: Label 'Team has been created.', Locked = true;
        CannotCreateCompanyTxt: Label 'Cannot create company.', Locked = true;
        CompanyCreatedTxt: Label 'Company has been created.', Locked = true;
        AddCoupledUsersToTeamTxt: Label 'Add coupled users to the default owning team.', Locked = true;
        AddingCoupledUsersToTeamMsg: Label 'Adding coupled users to the default owning team.\#1##############################', Comment = '#1 place holder for ProcessingUserMsg';
        ProcessingUserMsg: Label 'Processing user %1 of %2.', Comment = '%1 - user number, %2 - user count';
        SetUserAsIntegrationUserTxt: Label 'Set user as an integration user.', Locked = true;
        CannotSetUserAsIntegrationUserTxt: Label 'Cannot set user as an integration user.', Locked = true;
        UserAlreadySetAsIntegrationUserTxt: Label 'User has already been set as an integration user.', Locked = true;
        UserSetAsIntegrationUserTxt: Label 'User has been set as an integration user.', Locked = true;
        SetAccessModeToNonInteractiveTxt: Label 'Set the user''s access mode to Non-Interactive.', Locked = true;
        CannotSetAccessModeToNonInteractiveTxt: Label 'Cannot set the user''s access mode to Non-Interactive.', Locked = true;
        AccessModeAlreadySetToNonInteractiveTxt: Label 'The user''s access mode is already set to Non-Interactive.', Locked = true;
        AccessModeSetToNonInteractiveTxt: Label 'The access mode for the user specified for the integration is set to Non-Interactive.', Locked = true;
        AccessModeSetToNonInteractiveMsg: Label 'The access mode for the user specified for the integration is set to Non-Interactive.';
        FindOrCreateIntegrationUserTxt: Label 'Find or create integration user.', Locked = true;
        FoundNoIntegrationUserTxt: Label 'Found no user with application id %1 on %2. Injecting a new application user.', Locked = true;
        FoundOneIntegrationUserTxt: Label 'Found one user with application id %1 on %2.', Locked = true;
        FoundMoreThanOneIntegrationUserTxt: Label 'Found more than one user with application id %1 on %2.', Locked = true;
        FoundMoreThanOneIntegrationUserErr: Label 'There are two or more users with application id %1 on %2.\\You must make sure that there is only one user with application id %1 on %2.', Comment = '%1 - this is a Guid; %2 - this is a URL';
        FailedToInsertApplicationUserErr: Label 'Inserting application user with application id %1 on %2 has failed.', Comment = '%1 - this is a Guid; %2 - this is a URL';
        FailedToInsertApplicationUserTxt: Label 'Inserting application user with application id %1 on %2 has failed.', Locked = true;
        IntegrationUserFullNameTxt: Label 'Business Central Integration', Locked = true;
        IntegrationUserFirstNameTxt: Label 'Business Central', Locked = true;
        IntegrationUserLastNameTxt: Label 'Integration', Locked = true;
        IntegrationUserPrimaryEmailStartTxt: Label 'john', Locked = true;
        IntegrationUserPrimaryEmailEndTxt: Label '@contoso.com', Locked = true;
        IntegrationUserPrimaryEmailTxt: Label 'john%1@contoso.com', Locked = true;
        CompanyAlreadyExistsTxt: Label 'Company already exists.', Locked = true;
        BusinessUnitAlreadyExistsTxt: Label 'Business unit already exists.', Locked = true;
        TeamAlreadyExistsTxt: Label 'Team already exists.', Locked = true;
        CheckBusinessUnitTxt: Label 'Check business unit.', Locked = true;
        CheckOwningTeamTxt: Label 'Check owning team.', Locked = true;
        CheckTeamRolesTxt: Label 'Check team roles.', Locked = true;
        CheckCompanyTxt: Label 'Check company.', Locked = true;
        CreateCompanyTxt: Label 'Create company.', Locked = true;
        BusinessUnitCoupledTxt: Label 'Busness unit is correctly coupled.', Locked = true;
        SolutionVersionReceivedTxt: Label 'Solution version has been received.', Locked = true;
        CannotGetSolutionVersionTxt: Label 'Cannot get solution version.', Locked = true;
        CurrencyMismatchTxt: Label 'LCY Code does not match ISO Currency Code of the Dataverse base currency.', Locked = true;
        UserHasNoRolesTxt: Label 'User has no roles.', Locked = true;
        SystemAdminRoleTxt: Label 'The user is assigned to the system administrator role.', Locked = true;
        NoSystemAdminRoleTxt: Label 'The admin user is not assigned to the System Administrator role.', Locked = true;
        NoSystemCustomizerRoleTxt: Label 'The admin user is not assigned to the System Customizer role.', Locked = true;
        NoIntegrationRoleTxt: Label 'The user is not assigned to the integration role.', Locked = true;
        UserNotLicensedTxt: Label 'The user''s access mode is not Non-Interactive, but the user is not a licensed user.', Locked = true;
        UserNotActiveTxt: Label 'The user account is disabled.', Locked = true;
        NotIntegrationUserTxt: Label 'User is not an integration user.', Locked = true;
        NotNonInteractiveAccessModeTxt: Label 'The user''s access mode is not Non-Interactive.', Locked = true;
        InvalidAccessModeTxt: Label 'The user''s access mode is not Read-Write or Non-Interactive.', Locked = true;
        ClearDisabledReasonTxt: Label 'Clear disabled reason.', Locked = true;
        CannotCreateCompanyErr: Label 'Cannot create company %1.', Comment = '%1 = company name';
        CannotCreateBusinessUnitErr: Label 'Cannot create business unit %1.', Comment = '%1 = business unit name';
        CannotCreateTeamErr: Label 'Cannot create team %1 for business unit %2.', Comment = '%1 = team name, %2 = business unit name';
        CannotSetDefaultOwningTeamErr: Label 'Cannot set default owning team.';
        CannotFindOwnerIdFieldErr: Label 'There is no OwnerId field in table %1 %2.', Comment = '%1 = table ID, %2 = table name';
        CannotFindOwnerTypeFieldErr: Label 'There is no OwnerIdType field in table %1 %2.', Comment = '%1 = table ID, %2 = table name';
        CannotFindOrganizationErr: Label 'Cannot find organization in Dataverse.';
        BaseCurrencyNotFoundErr: Label 'Cannot find base currency in Dataverse.';
        GLSetupNotFoundErr: Label 'Cannot find GL setup.';
        CompanyNotFoundErr: Label 'There is no company with external ID %1 in Dataverse.', Comment = '%1 = company external ID';
        TeamNotFoundErr: Label 'There is no team with ID %1 in Dataverse.', Comment = '%1 = team ID';
        UserNotFoundErr: Label 'There is no user with ID %1 in Dataverse.', Comment = '%1 = system user ID';
        RoleNotFoundErr: Label 'There is no role with ID %1 in Dataverse.', Comment = '%1 = role ID';
        BusinessUnitNotFoundErr: Label 'There is no business unit with ID %1 in Dataverse.', Comment = '%1 = business unit ID';
        BusinessUnitMismatchErr: Label 'Business unit in BC does not match the business unit in Dataverse.';
        OwnerIdTypeErr: Label 'Owner type must be either team or systemuser.';
        OwnerDiffersFromExpectedErr: Label 'Entity owner differs from the expected one.';
        TeamBusinessUnitDiffersFromSelectedErr: Label 'Team business unit differs from the selected one.';
        UserBusinessUnitDiffersFromSelectedErr: Label 'User business unit differs from the selected one.';
        UserDoesNotExistErr: Label 'There is no user with email address %1 in Dataverse. Enter a valid email address.', Comment = '%1 = User email address';
        IntegrationRoleNotFoundErr: Label 'There is no integration role %1 for business unit %2.', Comment = '%1 = role name, %2 = business unit name';
        SolutionFileNotFoundErr: Label 'A file for a Dataverse solution could not be found.';
        IntegrationUserPasswordWrongErr: Label 'Enter valid integration user credentials.';
        AdminUserPasswordWrongErr: Label 'Enter valid administrator credentials.';
        GeneralFailureErr: Label 'The import of a Dataverse solution failed. This may be because the solution file is broken or because the specified administrator does not have sufficient privileges.';
        OrganizationServiceFailureErr: Label 'The import of a Dataverse solution failed. This may be because the solution file is broken or because the specified administrator does not have sufficient privileges.';
        InvalidUriErr: Label 'The value entered is not a valid URL.';
        MustUseHttpsErr: Label 'The application is set up to support secure connections (HTTPS) to the Dataverse environment only. You cannot use HTTP.';
        ReplaceServerAddressQst: Label 'The URL is not valid. Do you want to replace it with the URL suggested below?\\Entered URL: "%1".\Suggested URL: "%2".', Comment = '%1 and %2 are URLs';
        CDSConnectionURLWrongErr: Label 'The URL is incorrect. Enter the URL for the Dataverse environment.';
        TemporaryConnectionPrefixTok: Label 'TEMP-Dataverse-', Locked = true;
        TestServerAddressTok: Label '@@test@@', Locked = true;
        NewBusinessUnitNameTemplateTok: Label '<New> %1', Comment = '%1 = Business unit name', Locked = true;
        BusinessUnitNameTemplateTok: Label '%1 (%2)', Comment = '%1 = Company name, %2 = Company ID', Locked = true;
        BusinessUnitNameSuffixTok: Label ' (%1)', Comment = '%1 = Company ID', Locked = true;
        TeamNameTemplateTok: Label 'BCI - %1', Comment = '%1 = Business unit name', Locked = true;
        OAuthConnectionStringFormatTxt: Label 'Url=%1; AccessToken=%2; ProxyVersion=%3; %4', Locked = true;
        ClientSecretConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; ClientSecret=%4; ProxyVersion=%5', Locked = true;
        CertificateConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; Certificate=%4; ProxyVersion=%5', Locked = true;
        ClientSecretAuthTxt: Label 'AuthType=ClientSecret', Locked = true;
        CertificateAuthTxt: Label 'AuthType=Certificate', Locked = true;
        ClientSecretTok: Label '{CLIENTSECRET}', Locked = true;
        CertificateTok: Label '{CERTIFICATE}', Locked = true;
        ClientIdTok: Label '{CLIENTID}', Locked = true;
        ConnectionStringFormatTok: Label 'Url=%1; UserName=%2; Password=%3; ProxyVersion=%4; %5', Locked = true;
        ConnectionBrokenMsg: Label 'The connection to Dataverse is disabled due to the following error: %1.\\Please contact your system administrator.', Comment = '%1 = Error text received from Dataverse';
        ConnectionDisabledNotificationMsg: Label 'Connection to Dataverse is broken and that it has been disabled due to an error: %1', Comment = '%1 = Error text received from Dataverse';
        CDSConnectionSetupTitleTxt: Label 'Set up a connection to Dataverse';
        CDSConnectionSetupShortTitleTxt: Label 'Connect to Dataverse';
        CDSConnectionSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2115257', Locked = true;
        CDSConnectionSetupDescriptionTxt: Label 'Connect to Dataverse for better insights across business applications. Data will flow between the apps for better productivity.', Comment = 'Dataverse is the name of a Microsoft Service and should not be translated';
        BaseIntegrationSolutionNotInstalledErr: Label 'Base Dataverse integration solution %1 is not installed.', Comment = '%1 = Dataverse solution name';
        SolutionVersionErr: Label 'Version of the base Dataverse integration solution %1 is not the last one.', Comment = '%1 = solution version';
        SystemAdminErr: Label 'User %1 has the %2 role on server %3.\\You must choose a user that does not have the %2 role.', Comment = '%1 = user name, %2 = security role name, %3 = server address';
        UserRolesErr: Label 'User %1 does not have the required roles on server %3.\\You must choose a user that has the role %2.', Comment = '%1 = user name, %2 = security role name, %3 = server address';
        TeamRolesErr: Label 'Team %1 for business unit %2 does not have the required role %3.', Comment = '%1 = team name, %2 = business unit name, %3 = security role name';
        CannotAssignRoleToTeamErr: Label 'Cannot assign role %3 to team %1 for business unit %2.', Comment = '%1 = team name, %2 = business unit name, %3 = security role name';
        CannotAssignRoleToIntegrationUserErr: Label 'Cannot assign the integration role to the integration user.';
        UserNotLicensedErr: Label 'User %1 with access mode %3 is not licensed on server %2.', Comment = '%1 = user name, %2 = server address, %3 = access mode';
        UserNotActiveErr: Label 'User %1 is disabled on server %2.', Comment = '%1 = user name, %2 = server address';
        NotIntegrationUserErr: Label 'User %1 is not an integration user on server %2.', Comment = '%1 = user name, %2 = server address';
        NotNonInteractiveAccessModeErr: Label 'User %1 has invalid access mode %3 on server %2. Valid access mode is Non-Interactive.', Comment = '%1 = user name, %2 = server address, %3 = actual access mode';
        InvalidAccessModeErr: Label 'User %1 has invalid access mode %3 on server %2. Valid access modes are Read-Write or Non-Interactive.', Comment = '%1 = user name, %2 = server address, %3 = actual access mode';
        UserHasNoRolesErr: Label 'User %1 has no user roles assigned on server %2.', Comment = '%1 = user name, %2 = server address';
        NoSystemAdminRoleErr: Label 'Admin user %1 is not assigned to the System Administrator role on server %2.', Comment = '%1 = user name, %2 = server address';
        ConnectionRequiredFieldsErr: Label 'A URL, user name and password are required.';
        Office365ConnectionRequiredFieldsErr: Label 'A URL is required.';
        ConnectionRequiredFieldsMismatchErr: Label 'The values of the Server Address, User Name, User Password and Authentication Type fields must match the corresponding field values on the Microsoft Dynamics 365 Connection Setup page.';
        ConnectionStringPwdPlaceHolderMissingErr: Label 'The connection string must include the password placeholder {PASSWORD}.';
        UserNameMustIncludeDomainErr: Label 'The user name must include the domain when the authentication type is set to Active Directory.';
        UserNameMustBeEmailErr: Label 'The user name must be a valid email address when the authentication type is set to Office 365.';
        LCYMustMatchBaseCurrencyErr: Label 'LCY Code %1 does not match ISO Currency Code %2 of the Dataverse base currency.', Comment = '%1,%2 - ISO currency codes';
        UserSetupTxt: Label 'User Dataverse Setup';
        CannotResolveUserFromConnectionSetupErr: Label 'The user that is specified in the Dataverse Connection Setup does not exist.';
        MissingUsernameTok: Label '{USER}', Locked = true;
        MissingPasswordTok: Label '{PASSWORD}', Locked = true;
        SystemAdminRoleTemplateIdTxt: Label '627090ff-40a3-4053-8790-584edc5be201', Locked = true;
        SystemCustomizerRoleTemplateIdTxt: Label '119f245c-3cc8-4b62-b31c-d1a046ced15d', Locked = true;
        IntegrationRoleIdTxt: Label 'a2b18661-9ff5-e911-a812-000d3a0b9028', Locked = true;
        ErrorNotificationIdTxt: Label '5e9ed8ec-dc7d-42b5-b7fc-da8c08cea60f', Locked = true;
        ConnectionDisabledNotificationIdTxt: Label 'db1b4430-99b7-48c4-94ba-0e4975353134', Locked = true;
        ConnectionDefaultNameTok: Label 'Dataverse', Locked = true;
        BaseSolutionUniqueNameTxt: Label 'bcbi_CdsBaseIntegration', Locked = true;
        BaseSolutionDisplayNameTxt: Label 'Business Central Dataverse Base Integration', Locked = true;
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        TemporaryConnectionName: Text;
        CDSConnectionClientIdAKVSecretNameLbl: Label 'globaldisco-clientid', Locked = true;
        CDSConnectionFirstPartyAppIdAKVSecretNameLbl: Label 'bctocdsappid', Locked = true;
        CDSConnectionClientSecretAKVSecretNameLbl: Label 'globaldisco-clientsecret', Locked = true;
        CDSConnectionFirstPartyAppCertificateNameAKVSecretNameLbl: Label 'bctocdsappcertificatename', Locked = true;
        MissingClientIdOrSecretTelemetryTxt: Label 'The client id or client secret have not been initialized.', Locked = true;
        MissingFirstPartyappIdOrCertificateTelemetryTxt: Label 'The first-party app id or certificate have not been initialized.', Locked = true;
        MissingClientIdOrSecretErr: Label 'The client id or client secret have not been initialized.';
        MissingClientIdOrSecretOnPremErr: Label 'You must register an Azure Active Directory application that will be used to connect to the Dataverse environment and specify the application id, secret and redirect URL in the Dataverse Connection Setup page.', Comment = 'Dataverse and Azure Active Directory are names of a Microsoft service and a Microsoft Azure resource and should not be translated.';
        AuthTokenOrCodeNotReceivedErr: Label 'No access token or authorization error code received.', Locked = true;
        AccessTokenNotReceivedErr: Label 'Failed to acquire an access token for %1.', Comment = '%1 URL to the Dataverse environment.';
        GuiNotAllowedTxt: Label 'GUI not allowed, so acquiring the auth code through the interactive experience is not possible', Locked = true;
        FixPermissionsUrlTxt: Label 'https://docs.microsoft.com/en-us/power-platform/admin/troubleshooting-user-needs-read-write-access-organization#user-doesnt-have-sufficient-permissions', Locked = true;
        InsufficientPriviegesTxt: Label 'The Dataverse user has insufficient privileges to perform this task. Navigate to this link to read about how to add privileges to the user: %1', Comment = '%1 A URL';
        AttemptingAuthCodeTokenWithCertTxt: Label 'Attempting to acquire a CDS access token via authorization code flow with a SNI certificate', Locked = true;
        AttemptingAuthCodeTokenFromCacheWithCertTxt: Label 'Attempting to acquire a CDS access token via authorization code flow from cache, with a SNI certificate', Locked = true;
        AttemptingAuthCodeTokenWithClientSecretTxt: Label 'Attempting to acquire a CDS access token via authorization code flow with a client secret', Locked = true;
        AttemptingAuthCodeTokenFromCacheWithClientSecretTxt: Label 'Attempting to acquire a CDS access token via authorization code flow from cache, with a client secret', Locked = true;
        SuccessfulJITProvisioningTelemetryMsg: Label 'Service principal successfully provisioned for tenant.', Locked = true;

    [Scope('OnPrem')]
    procedure GetBaseSolutionUniqueName(): Text
    begin
        exit(BaseSolutionUniqueNameTxt);
    end;

    [Scope('OnPrem')]
    procedure GetBaseSolutionDisplayName(): Text
    begin
        exit(BaseSolutionDisplayNameTxt);
    end;

    [Scope('OnPrem')]
    procedure IsConnectionActive(): Boolean
    begin
        exit(IsConnectionActive(GetConnectionDefaultName()));
    end;

    [Scope('OnPrem')]
    procedure IsConnectionActive(ConnectionName: Text): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AQP', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        exit(IsConnectionActive(CDSConnectionSetup, ConnectionName));
    end;

    local procedure IsConnectionActive(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionName: Text): Boolean
    var
        ActiveConnectionName: Text;
    begin
        if not CDSConnectionSetup."Is Enabled" then begin
            Session.LogMessage('0000AQQ', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if not HasTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName) then begin
            Session.LogMessage('0000AQR', NoConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        ActiveConnectionName := GetDefaultTableConnection(TABLECONNECTIONTYPE::CRM);
        if ConnectionName = ActiveConnectionName then begin
            Session.LogMessage('0000AQS', ConnectionActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;
        Session.LogMessage('0000AQT', ConnectionNotActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ActivateConnection(): Boolean
    begin
        exit(ActivateConnection(GetConnectionDefaultName()));
    end;

    [Scope('OnPrem')]
    procedure ActivateConnection(ConnectionName: Text): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AQU', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if not CDSConnectionSetup."Is Enabled" then begin
            Session.LogMessage('0000BFQ', IntegrationDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        exit(ActivateConnection(CDSConnectionSetup, ConnectionName));
    end;

    local procedure ActivateConnection(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionName: Text): Boolean
    var
        ActiveConnectionName: Text;
    begin
        Session.LogMessage('0000AQV', ActivateConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if IsConnectionActive(CDSConnectionSetup, ConnectionName) then begin
            Session.LogMessage('0000AQW', ConnectionActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        if not HasTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName) then begin
            Session.LogMessage('0000AQX', NoConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        ActiveConnectionName := GetDefaultTableConnection(TABLECONNECTIONTYPE::CRM);
        if ConnectionName = ActiveConnectionName then begin
            Session.LogMessage('0000AQY', ConnectionActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        if not CDSConnectionSetup.IsTemporary() then begin
            Session.LogMessage('0000AQZ', OnBeforeActivateConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnBeforeActivateConnection();
        end;

        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName, false);

        if not CDSConnectionSetup.IsTemporary() then begin
            Session.LogMessage('0000AR0', OnAfterActivateConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnAfterActivateConnection();
        end;

        Session.LogMessage('0000AR1', ConnectionActivatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure HasConnection(): Boolean
    begin
        exit(HasConnection(GetConnectionDefaultName()));
    end;

    local procedure HasConnection(ConnectionName: Text): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AR2', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        exit(HasConnection(CDSConnectionSetup, ConnectionName));
    end;

    local procedure HasConnection(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionName: Text): Boolean
    begin
        if not CDSConnectionSetup."Is Enabled" then begin
            Session.LogMessage('0000AR3', IntegrationDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if HasTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName) then begin
            Session.LogMessage('0000AR4', HasConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        Session.LogMessage('0000AR5', NoConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(): Boolean
    begin
        exit(RegisterConnection(true));
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(KeepExisting: Boolean): Boolean
    var
        ConnectionName: Text;
    begin
        ConnectionName := GetConnectionDefaultName();
        exit(RegisterConnection(ConnectionName, KeepExisting));
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(ConnectionName: Text): Boolean
    begin
        exit(RegisterConnection(ConnectionName, false));
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(ConnectionName: Text; KeepExisting: Boolean): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AR6', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if not CDSConnectionSetup."Is Enabled" then begin
            Session.LogMessage('0000AR7', IntegrationDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        exit(RegisterConnection(CDSConnectionSetup, ConnectionName, KeepExisting));
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(var CDSConnectionSetup: Record "CDS Connection Setup"; KeepExisting: Boolean): Boolean
    var
        ConnectionName: Text;
    begin
        ConnectionName := GetConnectionDefaultName();
        exit(RegisterConnection(CDSConnectionSetup, ConnectionName, KeepExisting));
    end;

    [Scope('OnPrem')]
    procedure RegisterConnection(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionName: Text): Boolean
    begin
        exit(RegisterConnection(CDSConnectionSetup, ConnectionName, false));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure RegisterConnection(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionName: Text; KeepExisting: Boolean): Boolean
    var
        ConnectionString: Text;
        IsTemporary: Boolean;
    begin
        IsTemporary := CDSConnectionSetup.IsTemporary();
        if not IsTemporary then
            if KeepExisting then
                if HasTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName) then begin
                    Session.LogMessage('0000AR9', HasConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    exit(true);
                end;

        ConnectionString := GetConnectionStringWithCredentials(CDSConnectionSetup);
        if ConnectionString = '' then
            exit(false);

        if not UnregisterConnection(ConnectionName) then
            ClearLastError();

        if not IsTemporary then begin
            Session.LogMessage('0000ARA', OnBeforeRegisterConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnBeforeRegisterConnection();
        end;

        if not TryRegisterTableConnection(ConnectionName, ConnectionString) then
            exit(false);

        if not IsTemporary then begin
            Session.LogMessage('0000ARB', OnAfterRegisterConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnAfterRegisterConnection();
        end;

        exit(true);
    end;

    [TryFunction]
    local procedure TryRegisterTableConnection(ConnectionName: Text; ConnectionString: Text)
    begin
        RegisterTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName, ConnectionString);
    end;

    [Scope('OnPrem')]
    procedure UnregisterConnection(): Boolean
    begin
        exit(UnregisterConnection(GetConnectionDefaultName()));
    end;

    [TryFunction]
    [Scope('OnPrem')]
    procedure UnregisterConnection(ConnectionName: Text)
    var
        IsTemporary: Boolean;
    begin
        if not HasTableConnection(TableConnectionType::CRM, ConnectionName) then begin
            Session.LogMessage('0000ARE', NoConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        IsTemporary := ConnectionName.StartsWith(TemporaryConnectionPrefixTok);
        if not IsTemporary then begin
            Session.LogMessage('0000ARF', OnBeforeUnregisterConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnBeforeUnregisterConnection();
        end;
        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, ConnectionName);
        if not IsTemporary then begin
            Session.LogMessage('0000ARG', OnAfterUnregisterConnectionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CDSIntegrationMgt.OnAfterUnregisterConnection();
        end;

    end;

    [Scope('OnPrem')]
    procedure IsIntegrationEnabled(): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        IsDetailedLoggingEnabled: Boolean;
    begin
        CDSIntegrationMgt.OnGetDetailedLoggingEnabled(IsDetailedLoggingEnabled);

        if not CDSConnectionSetup.ReadPermission() then
            exit(false);

        if not CDSConnectionSetup.Get() then begin
            if IsDetailedLoggingEnabled then
                Session.LogMessage('0000ARI', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if not CDSConnectionSetup."Is Enabled" then begin
            if IsDetailedLoggingEnabled then
                Session.LogMessage('0000ARJ', IntegrationDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        OnAfterIntegrationEnabled();
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure IsTeamOwnershipModelSelected(): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if IsIntegrationEnabled() then
            if CDSConnectionSetup.Get() then
                exit(CDSConnectionSetup."Ownership Model" = CDSConnectionSetup."Ownership Model"::Team);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure GetConnectionDefaultName(): Text
    begin
        exit(ConnectionDefaultNameTok);
    end;

    [Scope('OnPrem')]
    procedure IsSolutionInstalled(): Boolean
    begin
        exit(IsSolutionInstalled(GetBaseSolutionUniqueName()));
    end;

    [Scope('OnPrem')]
    procedure IsSolutionInstalled(var CDSConnectionSetup: Record "CDS Connection Setup"): Boolean
    begin
        exit(IsSolutionInstalled(CDSConnectionSetup, GetBaseSolutionUniqueName()));
    end;

    [Scope('OnPrem')]
    procedure IsSolutionInstalled(UniqueName: Text): Boolean
    var
        CDSSolution: Record "CDS Solution";
    begin
        CDSSolution.SetRange(UniqueName, UniqueName);
        if CDSSolution.FindFirst() then
            if CDSSolution.InstalledOn <> 0DT then begin
                Session.LogMessage('0000ARM', SolutionInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(true);
            end;
        Session.LogMessage('0000ARN', SolutionNotInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure IsSolutionInstalled(var CDSConnectionSetup: Record "CDS Connection Setup"; UniqueName: Text): Boolean
    var
        Installed: Boolean;
    begin
        if TryCheckSolutionInstalled(CDSConnectionSetup, UniqueName, Installed) then
            if Installed then begin
                Session.LogMessage('0000ARO', SolutionInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(true);
            end;
        Session.LogMessage('0000ARP', SolutionNotInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [TryFunction]
    local procedure TryCheckSolutionInstalled(var CDSConnectionSetup: Record "CDS Connection Setup"; UniqueName: Text; var Installed: Boolean)
    var
        CDSSolution: Record "CDS Solution";
        TempConnectionName: Text;
    begin
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        CDSSolution.SetRange(UniqueName, UniqueName);
        if CDSSolution.FindFirst() then
            Installed := CDSSolution.InstalledOn <> 0DT
        else
            Installed := false;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    procedure GetSolutionVersion(var Version: Text): Boolean
    begin
        exit(GetSolutionVersion(GetBaseSolutionUniqueName(), Version));
    end;

    [Scope('OnPrem')]
    procedure GetSolutionVersion(var CDSConnectionSetup: Record "CDS Connection Setup"; var Version: Text): Boolean
    begin
        exit(GetSolutionVersion(CDSConnectionSetup, GetBaseSolutionUniqueName(), Version));
    end;

    [Scope('OnPrem')]
    procedure GetSolutionVersion(UniqueName: Text; var Version: Text): Boolean
    var
        CDSSolution: Record "CDS Solution";
    begin
        CDSSolution.SetRange(UniqueName, UniqueName);
        if CDSSolution.FindFirst() then
            if CDSSolution.InstalledOn <> 0DT then begin
                Version := CDSSolution.Version;
                Session.LogMessage('0000ARQ', SolutionVersionReceivedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(true);
            end;
        Version := '';
        Session.LogMessage('0000ARL', CannotGetSolutionVersionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure GetSolutionVersion(var CDSConnectionSetup: Record "CDS Connection Setup"; UniqueName: Text; var Version: Text): Boolean
    begin
        if TryGetSolutionVersion(CDSConnectionSetup, UniqueName, Version) then begin
            Session.LogMessage('0000ARR', SolutionVersionReceivedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if Version <> '' then
                exit(true);
        end;
        Version := '';
        Session.LogMessage('0000ARS', CannotGetSolutionVersionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [TryFunction]
    local procedure TryGetSolutionVersion(var CDSConnectionSetup: Record "CDS Connection Setup"; UniqueName: Text; var Version: Text)
    var
        CDSSolution: Record "CDS Solution";
        TempConnectionName: Text;
    begin
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        Version := '';
        CDSSolution.SetRange(UniqueName, UniqueName);
        if CDSSolution.FindFirst() then
            if CDSSolution.InstalledOn <> 0DT then
                Version := CDSSolution.Version;
        if Version <> '' then
            Session.LogMessage('0000AVR', SolutionNotInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            Session.LogMessage('0000ART', SolutionNotInstalledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [NonDebuggable]
    local procedure SetUserAsIntegrationUser(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text)
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        TempConnectionName: Text;
    begin
        Session.LogMessage('0000ARW', SetUserAsIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        FilterUser(CDSConnectionSetup, CRMSystemuser);
        if not CRMSystemuser.FindFirst() then begin
            Session.LogMessage('0000ARX', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotResolveUserFromConnectionSetupErr);
        end;
        if (CRMSystemuser.InviteStatusCode <> CRMSystemuser.InviteStatusCode::InvitationAccepted) or
           (not CRMSystemuser.IsIntegrationUser)
        then begin
            Session.LogMessage('0000ARY', SetUserAsIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CRMSystemuser.InviteStatusCode := CRMSystemuser.InviteStatusCode::InvitationAccepted;
            CRMSystemuser.IsIntegrationUser := true;
            if not CRMSystemuser.Modify() then
                Session.LogMessage('0000ARZ', CannotSetUserAsIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                Session.LogMessage('0000AS0', UserSetAsIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end else
            Session.LogMessage('0000AS1', UserAlreadySetAsIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [NonDebuggable]
    local procedure SetAccessModeToNonInteractive(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text): Boolean
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        TempConnectionName: Text;
        ChangedToNonInteractive: Boolean;
    begin
        Session.LogMessage('0000B2I', SetAccessModeToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        FilterUser(CDSConnectionSetup, CRMSystemuser);
        if not CRMSystemuser.FindFirst() then begin
            Session.LogMessage('0000B2J', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotResolveUserFromConnectionSetupErr);
        end;

        if CRMSystemuser.AccessMode <> CRMSystemuser.AccessMode::"Non-interactive" then begin
            Session.LogMessage('0000B2A', SetAccessModeToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CRMSystemuser.AccessMode := CRMSystemuser.AccessMode::"Non-interactive";
            if not CRMSystemuser.Modify() then
                Session.LogMessage('0000B2B', CannotSetAccessModeToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else begin
                ChangedToNonInteractive := CRMSystemuser.AccessMode = CRMSystemuser.AccessMode::"Non-interactive";
                if ChangedToNonInteractive then
                    Session.LogMessage('0000B2C', AccessModeSetToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
                else
                    Session.LogMessage('0000B2H', CannotSetAccessModeToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            end;
        end else
            Session.LogMessage('0000B2D', AccessModeAlreadySetToNonInteractiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);

        exit(ChangedToNonInteractive);
    end;

    [NonDebuggable]
    local procedure FindOrCreateIntegrationUser(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: Text; AdminPassword: Text; AccessToken: Text)
    var
        CRMSystemuser: Record "CRM Systemuser";
        RootBusinessUnit: Record "CRM Businessunit";
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        TempConnectionName: Text;
        CDSConnectionClientIdTxt: Text;
        CDSConnectionFirstPartyAppIdTxt: Text;
        CDSConnectionFirstPartyAppCertificateTxt: Text;
        NewConnectionString: Text;
        IntegrationUsernameEmailTxt: Text[100];
        CDSConnectionClientId: Guid;
        EmptyGuid: Guid;
        ExistingApplicationUserCount: Integer;
    begin
        if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then
            exit;
        Session.LogMessage('0000C4J', FindOrCreateIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, '');
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        CDSConnectionClientIdTxt := GetCDSConnectionClientId();
        CDSConnectionFirstPartyAppIdTxt := GetCDSConnectionFirstPartyAppId();
        CDSConnectionFirstPartyAppCertificateTxt := GetCDSConnectionFirstPartyAppCertificate();

        if CDSConnectionFirstPartyAppIdTxt <> '' then
            CDSConnectionClientId := CDSConnectionFirstPartyAppIdTxt
        else
            CDSConnectionClientId := CDSConnectionClientIdTxt;
        CRMSystemuser.SetRange(CRMSystemuser.ApplicationId, CDSConnectionClientId);
        ExistingApplicationUserCount := CRMSystemuser.Count();

        if ExistingApplicationUserCount > 1 then begin
            Session.LogMessage('0000C4K', StrSubstNo(FoundMoreThanOneIntegrationUserTxt, CDSConnectionClientId, CDSConnectionSetup."Server Address"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(FoundMoreThanOneIntegrationUserErr, CDSConnectionClientId, CDSConnectionSetup."Server Address");
        end;

        if ExistingApplicationUserCount = 1 then begin
            Session.LogMessage('0000C4L', StrSubstNo(FoundOneIntegrationUserTxt, CDSConnectionClientId, CDSConnectionSetup."Server Address"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CrmSystemUser.FindFirst();
        end else begin
            Session.LogMessage('0000C4M', StrSubstNo(FoundNoIntegrationUserTxt, CDSConnectionClientId, CDSConnectionSetup."Server Address"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            IntegrationUsernameEmailTxt := CopyStr(GetAvailableIntegrationUserEmail(), 1, MaxStrLen(CRMSystemuser.InternalEMailAddress));
            if IntegrationUsernameEmailTxt = '' then begin
                Session.LogMessage('0000D1D', StrSubstNo(FailedToInsertApplicationUserTxt, CDSConnectionClientId, CDSConnectionSetup."Server Address"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(FailedToInsertApplicationUserErr, CDSConnectionClientId, CDSConnectionSetup."Server Address");
            end;
            CRMSystemuser.ApplicationId := CDSConnectionClientId;
            CRMSystemuser.FirstName := IntegrationUserFirstNameTxt;
            CRMSystemuser.LastName := IntegrationUserLastNameTxt;
            CRMSystemuser.FullName := IntegrationUserFullNameTxt;
            RootBusinessunit.SetRange(ParentBusinessUnitId, EmptyGuid);
            RootBusinessunit.FindFirst();
            CRMSystemUser.BusinessUnitId := RootBusinessUnit.BusinessUnitId;
            CRMSystemuser.InternalEMailAddress := IntegrationUsernameEmailTxt;
            if not CRMSystemuser.Insert() then begin
                Session.LogMessage('0000C4N', StrSubstNo(FailedToInsertApplicationUserTxt, CDSConnectionClientId, CDSConnectionSetup."Server Address"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(FailedToInsertApplicationUserErr, CDSConnectionClientId, CDSConnectionSetup."Server Address");
            end;
        end;
        if not UpdateIntegrationUserNameAndEmailIfNeeded(CRMSystemuser) then
            Session.LogMessage('0000ENR', CannotUpdateUserNameAndEmailTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        CDSConnectionSetup."User Name" := CRMSystemuser.InternalEMailAddress;
        CDSConnectionSetup.SetPassword('');
        if (CDSConnectionFirstPartyAppIdTxt <> '') and (CDSConnectionFirstPartyAppCertificateTxt <> '') then
            NewConnectionString := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, CDSConnectionSetup."Server Address", ClientIdTok, CertificateTok, CDSConnectionSetup."Proxy Version")
        else
            NewConnectionString := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, CDSConnectionSetup."Server Address", ClientIdTok, ClientSecretTok, CDSConnectionSetup."Proxy Version");
        SetConnectionString(CDSConnectionSetup, NewConnectionString);

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetupCertificateAuthentication(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CrmHelper: DotNet CRMHelper;
        CDSConnectionFirstPartyAppIdTxt: Text;
        CDSConnectionFirstPartyAppCertificateTxt: Text;
        AdminAccessToken: Text;
        TempConnectionString: Text;
        JITProvisioningTelemetryMessageTxt: Text;
        PreviousIntegrationUserName: Text[250];
    begin
        CDSConnectionFirstPartyAppIdTxt := GetCDSConnectionFirstPartyAppId();
        CDSConnectionFirstPartyAppCertificateTxt := GetCDSConnectionFirstPartyAppCertificate();
        if (CDSConnectionFirstPartyAppIdTxt = '') or (CDSConnectionFirstPartyAppCertificateTxt = '') then
            exit;

        PreviousIntegrationUserName := CDSConnectionSetup."User Name";

        // sign in as admin in interactive auth code flow
        GetAccessToken(CDSConnectionSetup."Server Address", false, AdminAccessToken);

        // register connection with CrmHelper
        TempConnectionString := StrSubstNo(OAuthConnectionStringFormatTxt, CDSConnectionSetup."Server Address", AdminAccessToken, CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup));
        if not InitializeConnection(CrmHelper, TempConnectionString) then begin
            Session.LogMessage('0000AU2', ConnectionNotRegisteredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ProcessConnectionFailures();
            exit;
        end;

        // JIT provision (backfill) the 1st party app service principal
        JITProvisioningTelemetryMessageTxt := CrmHelper.ProvisionServicePrincipal(CDSConnectionFirstPartyAppIdTxt, CDSConnectionFirstPartyAppCertificateTxt);
        if JITProvisioningTelemetryMessageTxt <> '' then
            if JITProvisioningTelemetryMessageTxt.Contains(SuccessfulJITProvisioningTelemetryMsg) then
                Session.LogMessage('0000ENK', JITProvisioningTelemetryMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                Session.LogMessage('0000F0A', JITProvisioningTelemetryMessageTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        // even though CrmHelper.ProvisionServicePrincipal contains an async Graph call, you can't expect Dataverse to be aware of the newly provisioned service principal right away.
        // It has been tested that it fails if you try to create the application user right after you provision the service principal
        Sleep(5000);

        if not JITProvisioningTelemetryMessageTxt.Contains(SuccessfulJITProvisioningTelemetryMsg) then begin
            // try one more time, it could have failed because of a timeout
            JITProvisioningTelemetryMessageTxt := CrmHelper.ProvisionServicePrincipal(CDSConnectionFirstPartyAppIdTxt, CDSConnectionFirstPartyAppCertificateTxt);
            if JITProvisioningTelemetryMessageTxt <> '' then
                if JITProvisioningTelemetryMessageTxt.Contains(SuccessfulJITProvisioningTelemetryMsg) then
                    Session.LogMessage('0000ENK', JITProvisioningTelemetryMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
                else
                    Session.LogMessage('0000F0A', JITProvisioningTelemetryMessageTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end;

        // even though CrmHelper.ProvisionServicePrincipal contains an async Graph call, you can't expect Dataverse to be aware of the newly provisioned service principal right away.
        // It has been tested that it fails if you try to create the application user right after you provision the service principal
        Sleep(10000);

        // this will create integration user and update the proxy version and connection string
        FindOrCreateIntegrationUser(CDSConnectionSetup, '', '', AdminAccessToken);
        AssignPreviousIntegrationUserRoles(CrmHelper, PreviousIntegrationUserName, CDSConnectionSetup, AdminAccessToken);
    end;

    [TryFunction]
    local procedure UpdateIntegrationUserNameAndEmailIfNeeded(var CRMSystemuser: Record "CRM Systemuser")
    var
        Email: Text[100];
        EmailChanged: Boolean;
        NameChanged: Boolean;
    begin
        // update email address as insert could set an autogenerated email instead of the specified
        if (not CRMSystemuser.InternalEMailAddress.StartsWith(IntegrationUserPrimaryEmailStartTxt)) or
           (not CRMSystemuser.InternalEMailAddress.EndsWith(IntegrationUserPrimaryEmailEndTxt))
        then begin
            Session.LogMessage('0000ENS', UpdateUserEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Email := CopyStr(GetAvailableIntegrationUserEmail(), 1, MaxStrLen(CRMSystemuser.InternalEMailAddress));
            if Email <> '' then begin
                CRMSystemuser.InternalEMailAddress := Email;
                EmailChanged := true;
            end;
        end;
        // add last name to first name as insert could set an autogenerated last name instead of the specified
        if CRMSystemuser.LastName <> IntegrationUserLastNameTxt then begin
            Session.LogMessage('0000ENT', UpdateUserNameTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            CRMSystemuser.FirstName := IntegrationUserFullNameTxt;
            NameChanged := true;
        end;
        if (not EmailChanged) and (not NameChanged) then
            exit;

        CRMSystemuser.Modify();
        if EmailChanged and (
           (not CRMSystemuser.InternalEMailAddress.StartsWith(IntegrationUserPrimaryEmailStartTxt)) or
           (not CRMSystemuser.InternalEMailAddress.EndsWith(IntegrationUserPrimaryEmailEndTxt)))
        then
            Session.LogMessage('0000ENU', UserEmailNotUpdatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        if NameChanged and (CRMSystemuser.FirstName <> IntegrationUserFullNameTxt) then
            Session.LogMessage('0000ENW', UserNameNotUpdatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure GetAvailableIntegrationUserEmail(): Text
    var
        IntegrationCRMSystemUser: Record "CRM Systemuser";
        IntegrationUsernameEmailTxt: Text;
        EmailSuffix: Integer;
    begin
        IntegrationUsernameEmailTxt := StrSubstNo(IntegrationUserPrimaryEmailTxt, '');
        IntegrationCRMSystemuser.SetRange(InternalEMailAddress, IntegrationUsernameEmailTxt);
        while not IntegrationCRMSystemuser.IsEmpty() and (EmailSuffix < 100) do begin
            EmailSuffix += 1;
            IntegrationUsernameEmailTxt := StrSubstNo(IntegrationUserPrimaryEmailTxt, EmailSuffix);
            IntegrationCRMSystemuser.SetRange(InternalEMailAddress, IntegrationUsernameEmailTxt);
        end;

        if EmailSuffix >= 100 then
            exit('');

        exit(IntegrationUsernameEmailTxt);
    end;

    [NonDebuggable]
    local procedure SyncCompany(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text)
    var
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        Company: Record Company;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CDSCompany: Record "CDS Company";
        RootCRMBusinessunit: Record "CRM Businessunit";
        DefaultCRMBusinessunit: Record "CRM Businessunit";
        UpdatedCRMBusinessunit: Record "CRM Businessunit";
        CRMBusinessunit: Record "CRM Businessunit";
        DefaultCRMTeam: Record "CRM Team";
        InitialCRMTeam: Record "CRM Team";
        UpdatingCRMTeam: Record "CRM Team";
        UpdatedCRMTeam: Record "CRM Team";
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        CRMOrganization: Record "CRM Organization";
        CRMRole: Record "CRM Role";
        CrmHelper: DotNet CrmHelper;
        TempConnectionName: Text;
        CompanyId: Text[36];
        CompanyName: Text[30];
        BusinessUnitName: Text[160];
        TeamName: Text[160];
        IntegrationRoleName: Text[100];
        EmptyGuid: Guid;
        UpdateOwningTeam: Boolean;
        OwningTeamUpdated: Boolean;
        DefaultBusinessUnitFound: Boolean;
    begin
        Session.LogMessage('0000AS2', SynchronizeCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        ResetCache();

        Company.Get(CompanyName());
        CompanyId := GetCompanyExternalId(Company);
        CompanyName := CopyStr(Company.Name, 1, MaxStrLen(CompanyName));
        BusinessUnitName := GetDefaultBusinessUnitName(CompanyName, CompanyId);

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        InitializeConnection(CrmHelper, TempAdminCDSConnectionSetup);
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        Session.LogMessage('0000AS3', CheckBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        RootCRMBusinessunit.SetRange(ParentBusinessUnitId, EmptyGuid);
        RootCRMBusinessunit.FindFirst();
        DefaultCRMBusinessunit.SetRange(ParentBusinessUnitId, RootCRMBusinessunit.BusinessUnitId);
        DefaultCRMBusinessunit.SetRange(Name, BusinessUnitName);
        DefaultBusinessUnitFound := DefaultCRMBusinessunit.FindFirst();
        if not DefaultBusinessUnitFound then begin
            DefaultCRMBusinessunit.SetFilter(Name, '*' + CompanyId + '*');
            if DefaultCRMBusinessunit.FindFirst() then
                DefaultBusinessUnitFound := DefaultCRMBusinessunit.Name.EndsWith(StrSubstNo(BusinessUnitNameSuffixTok, CompanyId))
        end;
        if not DefaultBusinessUnitFound then begin
            DefaultCRMBusinessunit.Name := BusinessUnitName;
            DefaultCRMBusinessunit.TransactionCurrencyId := CRMTransactioncurrency.TransactionCurrencyId;
            DefaultCRMBusinessunit.ParentBusinessUnitId := RootCRMBusinessunit.BusinessUnitId;
            if not DefaultCRMBusinessunit.Insert() then begin
                Session.LogMessage('0000AS4', CannotCreateBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(EnrichWithDotNetException(CannotCreateBusinessUnitErr), BusinessUnitName);
            end;
            Session.LogMessage('0000AS5', BusinessUnitCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end else
            Session.LogMessage('0000AS6', BusinessUnitAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        Session.LogMessage('0000AS7', CheckOwningTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        TeamName := GetOwningTeamName(DefaultCRMBusinessunit.Name);
        FilterTeam(DefaultCRMBusinessunit.BusinessUnitId, TeamName, DefaultCRMTeam);
        if not DefaultCRMTeam.FindFirst() then begin
            DefaultCRMTeam.Name := TeamName;
            DefaultCRMTeam.BusinessUnitId := DefaultCRMBusinessunit.BusinessUnitId;
            DefaultCRMTeam.TeamType := DefaultCRMTeam.TeamType::Owner;
            if not DefaultCRMTeam.Insert() then begin
                Session.LogMessage('0000AS8', CannotCreateTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(EnrichWithDotNetException(CannotCreateTeamErr), TeamName, BusinessUnitName);
            end;
            Session.LogMessage('0000AS9', TeamCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end else
            Session.LogMessage('0000ASA', TeamAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        Session.LogMessage('0000ASB', CheckTeamRolesTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        if not CRMRole.Get(GetIntegrationRoleId()) then begin
            Session.LogMessage('0000ASC', IntegrationRoleNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(IntegrationRoleNotFoundErr, IntegrationRoleName, RootCRMBusinessunit.Name);
        end;
        IntegrationRoleName := CRMRole.Name;

        CRMRole.SetRange(ParentRoleId, GetIntegrationRoleId());
        CRMRole.SetRange(BusinessUnitId, DefaultCRMBusinessunit.BusinessUnitId);
        if not CRMRole.FindFirst() then begin
            Session.LogMessage('0000ASD', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(IntegrationRoleNotFoundErr, IntegrationRoleName, DefaultCRMBusinessunit.Name);
        end;
        if not AssignTeamRole(CrmHelper, DefaultCRMTeam.TeamId, CRMRole.RoleId) then begin
            Session.LogMessage('0000ASE', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(EnrichWithDotNetException(CannotAssignRoleToTeamErr), DefaultCRMTeam.Name, DefaultCRMBusinessunit.Name, IntegrationRoleName);
        end;
        Session.LogMessage('0000ASF', RoleAssignedToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        Session.LogMessage('0000ASG', CheckCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        CDSCompany.SetRange(ExternalId, CompanyId);
        if not CDSCompany.FindFirst() then begin
            Session.LogMessage('0000ASH', CreateCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if not CRMOrganization.FindFirst() then begin
                Session.LogMessage('0000ASI', OrganizationNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(CannotFindOrganizationErr);
            end;
            if not CRMTransactioncurrency.Get(CRMOrganization.BaseCurrencyId) then begin
                Session.LogMessage('0000ASJ', CurrencyNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(BaseCurrencyNotFoundErr);
            end;
            if not GeneralLedgerSetup.Get() then begin
                Session.LogMessage('0000ASK', GLSetupNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(GLSetupNotFoundErr);
            end;
            if DelChr(CRMTransactioncurrency.ISOCurrencyCode) <> DelChr(GeneralLedgerSetup."LCY Code") then begin
                Session.LogMessage('0000ASL', CurrencyMismatchTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(LCYMustMatchBaseCurrencyErr, GeneralLedgerSetup."LCY Code", CRMTransactioncurrency.ISOCurrencyCode);
            end;
            CDSCompany.ExternalId := CompanyId;
            CDSCompany.Name := CompanyName;
            CDSCompany.DefaultOwningTeam := DefaultCRMTeam.TeamId;
            CDSCompany.OwnerIdType := CDSCompany.OwnerIdType::team;
            CDSCompany.OwnerId := DefaultCRMTeam.TeamId;
            if not CDSCompany.Insert() then begin
                Session.LogMessage('0000ASM', CannotCreateCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(EnrichWithDotNetException(CannotCreateCompanyErr), CompanyName);
            end;
            Session.LogMessage('0000ASN', CompanyCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end else begin
            Session.LogMessage('0000ASO', CompanyAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if IsNullGuid(CDSCompany.DefaultOwningTeam) then begin
                CDSCompany.DefaultOwningTeam := DefaultCRMTeam.TeamId;
                if not CDSCompany.Modify() then begin
                    Session.LogMessage('0000ASP', CannotSetDefaultOwningTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(EnrichWithDotNetException(CannotSetDefaultOwningTeamErr));
                end;
                Session.LogMessage('0000ASQ', DefaultOwningTeamSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end;
        end;

        UpdateOwningTeam := true;
        if InitialCRMTeam.Get(CDSCompany.DefaultOwningTeam) then
            if CRMBusinessunit.Get(InitialCRMTeam.BusinessUnitId) then
                UpdateOwningTeam :=
                    (CDSConnectionSetup."Business Unit Id" <> CRMBusinessunit.BusinessUnitId) or
                    (CDSConnectionSetup."Business Unit Name" <> CRMBusinessunit.Name);

        if UpdateOwningTeam and not IsNullGuid(CDSConnectionSetup."Business Unit Id") then
            if UpdatedCRMBusinessunit.Get(CDSConnectionSetup."Business Unit Id") then begin
                // update default owning team field on CDS company
                Session.LogMessage('0000ASR', CheckOwningTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                TeamName := GetOwningTeamName(UpdatedCRMBusinessunit.Name);
                FilterTeam(UpdatedCRMBusinessunit.BusinessUnitId, TeamName, UpdatingCRMTeam);
                if not UpdatingCRMTeam.FindFirst() then begin
                    UpdatingCRMTeam.Name := TeamName;
                    UpdatingCRMTeam.BusinessUnitId := UpdatedCRMBusinessunit.BusinessUnitId;
                    UpdatingCRMTeam.TeamType := UpdatingCRMTeam.TeamType::Owner;
                    if not UpdatingCRMTeam.Insert() then begin
                        Session.LogMessage('0000ASS', CannotCreateTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        Error(EnrichWithDotNetException(CannotCreateTeamErr), TeamName, UpdatedCRMBusinessunit.Name);
                    end;
                    Session.LogMessage('0000AST', TeamCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end else
                    Session.LogMessage('0000ASU', TeamAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

                CRMRole.SetRange(ParentRoleId, GetIntegrationRoleId());
                CRMRole.SetRange(BusinessUnitId, UpdatedCRMBusinessunit.BusinessUnitId);
                if not CRMRole.FindFirst() then begin
                    Session.LogMessage('0000ASV', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(IntegrationRoleNotFoundErr, IntegrationRoleName, UpdatedCRMBusinessunit.Name);
                end;
                if not AssignTeamRole(CrmHelper, UpdatingCRMTeam.TeamId, CRMRole.RoleId) then begin
                    Session.LogMessage('0000ASW', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(EnrichWithDotNetException(CannotAssignRoleToTeamErr), UpdatingCRMTeam.Name, UpdatedCRMBusinessunit.Name, IntegrationRoleName);
                end;
                Session.LogMessage('0000ASX', RoleAssignedToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

                CDSCompany.DefaultOwningTeam := UpdatingCRMTeam.TeamId;
                if not CDSCompany.Modify() then begin
                    Session.LogMessage('0000ASY', CannotSetDefaultOwningTeamTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(EnrichWithDotNetException(CannotSetDefaultOwningTeamErr));
                end;
                OwningTeamUpdated := true;
                Session.LogMessage('0000ASZ', DefaultOwningTeamSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end else
                Session.LogMessage('0000AT0', BusinessUnitNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if not OwningTeamUpdated then begin
            UpdatedCRMTeam.Get(CDSCompany.DefaultOwningTeam);
            if not UpdatedCRMBusinessunit.Get(UpdatedCRMTeam.BusinessUnitId) then begin
                Session.LogMessage('0000AT1', BusinessUnitNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(BusinessUnitNotFoundErr, UpdatedCRMTeam.BusinessUnitId);
            end;
            if (CDSConnectionSetup."Business Unit Id" <> UpdatedCRMBusinessunit.BusinessUnitId) or
                (CDSConnectionSetup."Business Unit Name" <> UpdatedCRMBusinessunit.Name) then begin
                // fix business unit related fields in the setup table
                Session.LogMessage('0000AT2', BusinessUnitFixedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                CDSConnectionSetup."Business Unit Id" := UpdatedCRMBusinessunit.BusinessUnitId;
                CDSConnectionSetup."Business Unit Name" := UpdatedCRMBusinessunit.Name;
                ModifyBusinessUnitCoupling(CDSConnectionSetup);
            end else
                Session.LogMessage('0000AT3', BusinessUnitCoupledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);

        Session.LogMessage('0000AT4', CompanySynchronizedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure EnrichWithDotNetException(ErrorMessage: Text): Text
    var
        DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
        DotNetExceptionMessage: Text;
        EnrichedErrorMessage: Text;
    begin
        DotNetExceptionHandler.Collect();
        DotNetExceptionMessage := DotNetExceptionHandler.GetMessage();
        if DotNetExceptionMessage = '' then
            exit(ErrorMessage);

        EnrichedErrorMessage := ErrorMessage + ' ' + DotNetExceptionMessage;

        if StrPos(DotNetExceptionMessage, 'PrivilegeId') = 0 then
            exit(EnrichedErrorMessage);

        EnrichedErrorMessage := EnrichedErrorMessage + ' ' + StrSubstNo(InsufficientPriviegesTxt, FixPermissionsUrlTxt);
        exit(EnrichedErrorMessage);
    end;

    [Scope('OnPrem')]
    procedure AddCoupledUsersToDefaultOwningTeam(var CDSConnectionSetup: Record "CDS Connection Setup"): Integer;
    var
        TempCRMSystemuser: Record "CRM Systemuser" temporary;
    begin
        GetCoupledUsers(TempCRMSystemuser);
        exit(AddUsersToDefaultOwningTeam(CDSConnectionSetup, TempCRMSystemuser));
    end;

    [Scope('OnPrem')]
    procedure AddCoupledUsersToDefaultOwningTeam(var CDSConnectionSetup: Record "CDS Connection Setup"; var TempCRMSystemuser: Record "CRM Systemuser" temporary): Integer;
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        TempSelectedCRMSystemuser: Record "CRM Systemuser" temporary;
    begin
        CRMIntegrationRecord.SetRange("Table ID", Database::"Salesperson/Purchaser");

        if TempCRMSystemuser.FindSet() then
            repeat
                CRMIntegrationRecord.SetRange("CRM ID", TempCRMSystemuser.SystemUserId);
                if not CRMIntegrationRecord.IsEmpty() then begin
                    TempSelectedCRMSystemuser.Init();
                    TempSelectedCRMSystemuser.TransferFields(TempCRMSystemuser);
                    TempSelectedCRMSystemuser.Insert();
                end;
            until TempCRMSystemuser.Next() = 0;
        exit(AddUsersToDefaultOwningTeam(CDSConnectionSetup, TempSelectedCRMSystemuser));
    end;

    [Scope('OnPrem')]
    procedure AddUsersToDefaultOwningTeam(var CDSConnectionSetup: Record "CDS Connection Setup"; var TempCRMSystemuser: Record "CRM Systemuser" temporary): Integer;
    var
        TempCDSTeammembership: Record "CDS Teammembership" temporary;
        TempSelectedCRMSystemuser: Record "CRM Systemuser" temporary;
        CrmHelper: DotNet CrmHelper;
        AdminUser: Text;
        AdminPassword: Text;
        AccessToken: Text;
        AdminADDomain: Text;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);
        GetDefaultOwningTeamMembership(CDSConnectionSetup, TempCDSTeammembership);
        if TempCRMSystemuser.FindSet() then
            repeat
                TempCDSTeammembership.SetRange(SystemUserId, TempCRMSystemuser.SystemUserId);
                if TempCDSTeammembership.IsEmpty() then begin
                    TempSelectedCRMSystemuser.Init();
                    TempSelectedCRMSystemuser.TransferFields(TempCRMSystemuser);
                    TempSelectedCRMSystemuser.Insert();
                end;
            until TempCRMSystemuser.Next() = 0;

        if TempSelectedCRMSystemuser.IsEmpty() then
            exit(0);

        SignInCDSAdminUser(CDSConnectionSetup, CrmHelper, AdminUser, AdminPassword, AccessToken, AdminADDomain, true);
        exit(AddUsersToDefaultOwningTeam(CDSConnectionSetup, CrmHelper, TempSelectedCRMSystemuser));
    end;

    [Scope('OnPrem')]
    procedure AddCoupledUsersToDefaultOwningTeam(var CDSConnectionSetup: Record "CDS Connection Setup"; var CrmHelper: DotNet CrmHelper): Integer
    var
        TempCRMSystemuser: Record "CRM Systemuser" temporary;
    begin
        GetCoupledUsers(TempCRMSystemuser);
        exit(AddUsersToDefaultOwningTeam(CDSConnectionSetup, CrmHelper, TempCRMSystemuser));
    end;

    [Scope('OnPrem')]
    procedure AddUsersToDefaultOwningTeam(var CDSConnectionSetup: Record "CDS Connection Setup"; var CrmHelper: DotNet CrmHelper; var TempCRMSystemuser: Record "CRM Systemuser" temporary): Integer
    var
        Window: Dialog;
        TeamId: Guid;
        Added: Integer;
        UserNumber: Integer;
        UserCount: Integer;
    begin
        Session.LogMessage('0000C9M', AddCoupledUsersToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        UserCount := TempCRMSystemuser.Count();
        if UserCount = 0 then begin
            Session.LogMessage('0000C9O', CoupledUsersNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(0);
        end;

        TeamId := GetOwningTeamId(CDSConnectionSetup);
        if IsNullGuid(TeamId) then begin
            Session.LogMessage('0000C9P', TeamNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(0);
        end;

        if GuiAllowed then begin
            Window.Open(AddingCoupledUsersToTeamMsg);
            Window.Update(1, '');
        end;

        if TempCRMSystemuser.FindSet() then
            repeat
                if GuiAllowed then begin
                    UserNumber += 1;
                    Window.Update(1, StrSubstNo(ProcessingUserMsg, UserNumber, UserCount));
                end;
                if AddUserToTeam(CrmHelper, TempCRMSystemuser.SystemUserId, TeamId) then
                    Added += 1;
            until TempCRMSystemuser.Next() = 0;

        if GuiAllowed then
            Window.Close();

        exit(Added);
    end;

    local procedure GetCoupledUsers(var TempCRMSystemuser: Record "CRM Systemuser" temporary)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        CRMIntegrationRecord.SetRange("Table ID", Database::"Salesperson/Purchaser");
        if CRMIntegrationRecord.FindSet() then
            repeat
                TempCRMSystemuser.Init();
                TempCRMSystemuser.SystemUserId := CRMIntegrationRecord."CRM ID";
                TempCRMSystemuser.Insert();
            until CRMIntegrationRecord.Next() = 0;
    end;

    [NonDebuggable]
    local procedure GetTempAdminConnectionSetup(var TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary; var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUser: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text);
    begin
        TempAdminCDSConnectionSetup.Init();
        TempAdminCDSConnectionSetup."Proxy Version" := CDSConnectionSetup."Proxy Version";
        TempAdminCDSConnectionSetup."Server Address" := CDSConnectionSetup."Server Address";
        if CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::Office365 then begin
            TempAdminCDSConnectionSetup.SetAccessToken(AccessToken);
            SetConnectionString(TempAdminCDSConnectionSetup, OAuthConnectionStringFormatTxt);
        end;

        if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then begin
            TempAdminCDSConnectionSetup."Authentication Type" := CDSConnectionSetup."Authentication Type";
            TempAdminCDSConnectionSetup.Domain := CopyStr(AdminADDomain, 1, MaxStrLen(TempAdminCDSConnectionSetup.Domain));
            TempAdminCDSConnectionSetup."User Name" := CopyStr(AdminUser, 1, MaxStrLen(TempAdminCDSConnectionSetup."User Name"));
            TempAdminCDSConnectionSetup.SetPassword(AdminPassword);
            if TempAdminCDSConnectionSetup."Authentication Type" = TempAdminCDSConnectionSetup."Authentication Type"::OAuth then
                SetConnectionString(TempAdminCDSConnectionSetup, ReplaceUserNamePasswordInConnectionstring(CDSConnectionSetup, AdminUser, Format(MissingPasswordTok)))
            else
                UpdateConnectionString(TempAdminCDSConnectionSetup);
        end;
    end;

    [Scope('OnPrem')]
    procedure TestActiveConnection(): Boolean
    begin
        if TryCheckEntitiesAvailability() then begin
            Session.LogMessage('0000AT5', ConnectionTestSucceedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;
        Session.LogMessage('0000AT6', ConnectionTestFailedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure TestSystemUsersAvailability()
    begin
        CheckSystemUsersAvailability();
    end;


    [Scope('OnPrem')]
    procedure CheckIntegrationRequirements(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    begin
        if Silent then begin
            if not TryCheckIntegrationRequirements(CDSConnectionSetup) then begin
                Session.LogMessage('0000AT7', IntegrationRequirementsNotMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;

            Session.LogMessage('0000AU0', IntegrationRequirementsMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        CheckIntegrationRequirements(CDSConnectionSetup);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure CheckIntegrationSolutionRequirements(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    begin
        if Silent then begin
            if not TryCheckIntegrationSolutionRequirements(CDSConnectionSetup) then begin
                Session.LogMessage('0000AT8', SolutionRequirementsNotMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;
            exit(true);
        end;
        CheckIntegrationSolutionRequirements(CDSConnectionSetup);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure CheckIntegrationUserRequirements(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    begin
        if Silent then begin
            if not TryCheckIntegrationUserRequirements(CDSConnectionSetup) then begin
                Session.LogMessage('0000AT9', IntegrationUserRequirementsNotMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;
            exit(true);
        end;
        CheckIntegrationUserRequirements(CDSConnectionSetup);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure CheckOwningTeamRequirements(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    begin
        if Silent then begin
            if not TryCheckOwningTeamRequirements(CDSConnectionSetup) then begin
                Session.LogMessage('0000ATA', OwningTeamRequirementsNotMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;
            exit(true);
        end;
        CheckOwningTeamRequirements(CDSConnectionSetup);
        exit(true);
    end;

    [TryFunction]
    local procedure TryCheckIntegrationRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckIntegrationRequirements(CDSConnectionSetup);
    end;

    local procedure CheckIntegrationRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckIntegrationSolutionRequirements(CDSConnectionSetup);
        CheckIntegrationUserRequirements(CDSConnectionSetup);
        CheckOwningTeamRequirements(CDSConnectionSetup);
        CheckEntitiesAvailability(CDSConnectionSetup);
    end;

    [TryFunction]
    local procedure TryCheckIntegrationSolutionRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckIntegrationSolutionRequirements(CDSConnectionSetup);
    end;

    local procedure CheckIntegrationSolutionRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        Version: Text;
    begin
        if not GetSolutionVersion(CDSConnectionSetup, Version) then begin
            Session.LogMessage('0000ATC', SolutionNotInstalledTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(BaseIntegrationSolutionNotInstalledErr, GetBaseSolutionDisplayName());
        end;

        if not IsSolutionVersionValid(Version) then begin
            Session.LogMessage('0000ATD', InvalidSolutionVersionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(SolutionVersionErr);
        end;
    end;

    [TryFunction]
    local procedure TryCheckIntegrationUserRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckIntegrationUserRequirements(CDSConnectionSetup);
    end;

    local procedure CheckIntegrationUserRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMRole: Record "CRM Role";
        TempCRMRole: Record "CRM Role" temporary;
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMSystemuser: Record "CRM Systemuser";
        IntegrationRoleName: Text;
        SystemAdminRoleName: Text;
        TempConnectionName: Text;
        IntegrationRoleDeployed: Boolean;
        ChosenUserHasSystemAdminRole: Boolean;
        ChosenUserHasIntegrationRole: Boolean;
    begin
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);

        if CRMRole.FindSet() then
            repeat
                TempCRMRole.TransferFields(CRMRole);
                TempCRMRole.Insert();
                if TempCRMRole.RoleId = GetIntegrationRoleId() then begin
                    IntegrationRoleDeployed := true;
                    IntegrationRoleName := TempCRMRole.Name;
                end;
            until CRMRole.Next() = 0;

        FilterUser(CDSConnectionSetup, CRMSystemuser);
        if CRMSystemuser.FindFirst() then begin
            if CRMSystemuser.IsDisabled then begin
                Session.LogMessage('0000ATF', UserNotActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(UserNotActiveErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address");
            end;

            if not CDSConnectionSetup."Connection String".Contains(ClientSecretAuthTxt) and not CDSConnectionSetup."Connection String".Contains(CertificateAuthTxt) then begin
                if not CRMSystemuser.IsIntegrationUser then begin
                    Session.LogMessage('0000B2E', NotIntegrationUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(NotIntegrationUserErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address");
                end;

                if CRMSystemuser.AccessMode <> CRMSystemuser.AccessMode::"Non-interactive" then begin
                    Session.LogMessage('0000B2F', NotNonInteractiveAccessModeTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(NotNonInteractiveAccessModeErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address", CRMSystemuser.AccessMode);
                end;
            end;

            CRMSystemuserroles.SetRange(SystemUserId, CRMSystemuser.SystemUserId);
            if CRMSystemuserroles.FindSet() then
                repeat
                    if TempCRMRole.Get(CRMSystemuserroles.RoleId) then begin
                        if TempCRMRole.RoleTemplateId = GetSystemAdminRoleTemplateId() then begin
                            ChosenUserHasSystemAdminRole := true;
                            SystemAdminRoleName := TempCRMRole.Name
                        end;
                        if TempCRMRole.RoleId = GetIntegrationRoleId() then
                            ChosenUserHasIntegrationRole := true;
                    end;
                until CRMSystemuserroles.Next() = 0
            else
                if (CDSConnectionSetup."Server Address" <> '') and (CDSConnectionSetup."Server Address" <> TestServerAddressTok) then begin
                    Session.LogMessage('0000ATH', UserHasNoRolesTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(UserHasNoRolesErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address");
                end;

            if ChosenUserHasSystemAdminRole then begin
                Session.LogMessage('0000ATI', SystemAdminRoleTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(SystemAdminErr, CDSConnectionSetup."User Name", SystemAdminRoleName, CDSConnectionSetup."Server Address");
            end;

            if IntegrationRoleDeployed and (not ChosenUserHasIntegrationRole) then begin
                Session.LogMessage('0000ATJ', NoIntegrationRoleTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(UserRolesErr, CDSConnectionSetup."User Name", IntegrationRoleName, CDSConnectionSetup."Server Address");
            end;
        end;

        UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CheckIntegrationUserPrerequisites(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: text; AdminPassword: text; AccessToken: Text; AdminADDomain: Text)
    var
        TempCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        CRMRole: Record "CRM Role";
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMSystemuser: Record "CRM Systemuser";
        TempConnectionName: Text;
    begin
        GetTempAdminConnectionSetup(TempCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);

        FilterUser(CDSConnectionSetup, CRMSystemuser);
        if not CRMSystemuser.FindFirst() then begin
            Session.LogMessage('0000BNG', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserDoesNotExistErr, CDSConnectionSetup."User Name");
        end;

        if CRMSystemuser.IsDisabled then begin
            Session.LogMessage('0000BNH', UserNotActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserNotActiveErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address");
        end;

        if not (CRMSystemuser.AccessMode in [CRMSystemuser.AccessMode::"Read-Write", CRMSystemuser.AccessMode::"Non-interactive"]) then begin
            Session.LogMessage('0000B2G', InvalidAccessModeTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(InvalidAccessModeErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address", CRMSystemuser.AccessMode);
        end;

        if (not CRMSystemuser.IsLicensed) and (CRMSystemuser.AccessMode <> CRMSystemuser.AccessMode::"Non-interactive") then begin
            Session.LogMessage('0000ATG', UserNotLicensedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserNotLicensedErr, CDSConnectionSetup."User Name", CDSConnectionSetup."Server Address", CRMSystemuser.AccessMode);
        end;

        CRMSystemuserroles.SetRange(SystemUserId, CRMSystemuser.SystemUserId);
        if CRMSystemuserroles.FindSet() then
            repeat
                if CRMRole.Get(CRMSystemuserroles.RoleId) then
                    if CRMRole.RoleTemplateId = GetSystemAdminRoleTemplateId() then begin
                        Session.LogMessage('0000BNJ', SystemAdminRoleTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        Error(SystemAdminErr, CDSConnectionSetup."User Name", CRMRole.Name, CDSConnectionSetup."Server Address");
                    end;
            until CRMSystemuserroles.Next() = 0;

        UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CheckAdminUserPrerequisites(var CDSConnectionSetup: Record "CDS Connection Setup"; AdminUserName: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text)
    var
        TempCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        CRMRole: Record "CRM Role";
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMSystemuser: Record "CRM Systemuser";
        TempConnectionName: Text;
        HasSystemAdminRole: Boolean;
        HasSystemCustomizerRole: Boolean;
    begin
        GetTempAdminConnectionSetup(TempCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        CheckConnectionRequiredFields(TempCDSConnectionSetup, false);
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);

        FilterUser(TempCDSConnectionSetup, CRMSystemuser);
        if not CRMSystemuser.FindFirst() then begin
            Session.LogMessage('0000BNK', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserDoesNotExistErr, TempCDSConnectionSetup."User Name");
        end;

        if CRMSystemuser.IsDisabled then begin
            Session.LogMessage('0000BNL', UserNotActiveTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserNotActiveErr, TempCDSConnectionSetup."User Name", TempCDSConnectionSetup."Server Address");
        end;

        if not CRMSystemuser.IsLicensed then begin
            Session.LogMessage('0000BNM', UserNotLicensedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserNotLicensedErr, TempCDSConnectionSetup."User Name", TempCDSConnectionSetup."Server Address", CRMSystemuser.AccessMode);
        end;

        CRMSystemuserroles.SetRange(SystemUserId, CRMSystemuser.SystemUserId);
        if not CRMSystemuserroles.FindSet() then
            if (CDSConnectionSetup."Server Address" <> '') and (CDSConnectionSetup."Server Address" <> TestServerAddressTok) then begin
                Session.LogMessage('0000BNN', UserHasNoRolesTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(UserHasNoRolesErr, TempCDSConnectionSetup."User Name", TempCDSConnectionSetup."Server Address");
            end;

        repeat
            if CRMRole.Get(CRMSystemuserroles.RoleId) then begin
                if CRMRole.RoleTemplateId = GetSystemAdminRoleTemplateId() then
                    HasSystemAdminRole := true;
                if CRMRole.RoleTemplateId = GetSystemCustomizerRoleTemplateId() then
                    HasSystemCustomizerRole := true;
            end;
        until CRMSystemuserroles.Next() = 0;

        if not HasSystemAdminRole then begin
            Session.LogMessage('0000BNO', NoSystemAdminRoleTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(NoSystemAdminRoleErr, TempCDSConnectionSetup."User Name", TempCDSConnectionSetup."Server Address");
        end;

        if not HasSystemCustomizerRole then
            Session.LogMessage('0000BNP', NoSystemCustomizerRoleTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);
    end;

    [TryFunction]
    local procedure TryCheckOwningTeamRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckOwningTeamRequirements(CDSConnectionSetup);
    end;

    local procedure CheckOwningTeamRequirements(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMRole: Record "CRM Role";
        CDSCompany: Record "CDS Company";
        CDSTeamroles: Record "CDS Teamroles";
        CRMTeam: Record "CRM Team";
        CRMBusinessunit: Record "CRM Businessunit";
        IntegrationRoleName: Text;
        TempConnectionName: Text;
    begin
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        if not CRMRole.Get(GetIntegrationRoleId()) then begin
            Session.LogMessage('0000ATK', IntegrationRoleNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(RoleNotFoundErr, GetIntegrationRoleId());
        end;
        IntegrationRoleName := CRMRole.Name;

        CDSCompany.SetRange(ExternalId, GetCompanyExternalId());
        if not CDSCompany.FindFirst() then begin
            Session.LogMessage('0000ATL', CompanyNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CompanyNotFoundErr, GetCompanyExternalId());
        end;

        if not CRMTeam.Get(CDSCompany.DefaultOwningTeam) then begin
            Session.LogMessage('0000ATM', TeamNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(TeamNotFoundErr, CDSCompany.DefaultOwningTeam);
        end;

        if not CRMBusinessunit.Get(CRMTeam.BusinessUnitId) then begin
            Session.LogMessage('0000ATN', BusinessUnitNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(BusinessUnitNotFoundErr, CRMTeam.BusinessUnitId);
        end;

        if (CRMBusinessunit.BusinessUnitId <> CDSConnectionSetup."Business Unit Id") or
           (CRMBusinessunit.Name <> CDSConnectionSetup."Business Unit Name") then begin
            Session.LogMessage('0000B24', BusinessUnitMismatchTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(BusinessUnitMismatchErr);
        end;

        CRMRole.Reset();
        CRMRole.SetRange(BusinessUnitId, CRMBusinessunit.BusinessUnitId);
        CRMRole.SetRange(ParentRoleId, GetIntegrationRoleId());
        if not CRMRole.FindFirst() then begin
            Session.LogMessage('0000ATO', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(IntegrationRoleNotFoundErr, IntegrationRoleName, CRMBusinessunit.Name);
        end;

        CDSTeamroles.SetRange(TeamId, CRMTeam.TeamId);
        CDSTeamroles.SetRange(RoleId, CRMRole.RoleId);
        if CDSTeamroles.IsEmpty() then begin
            Session.LogMessage('0000ATP', IntegrationRoleNotAssignedToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(TeamRolesErr, CRMTeam.Name, CRMBusinessunit.Name, IntegrationRoleName);
        end;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    procedure CheckEntitiesAvailability(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    begin
        if Silent then
            exit(TryCheckEntitiesAvailability(CDSConnectionSetup));
        CheckEntitiesAvailability(CDSConnectionSetup);
        exit(true);
    end;

    [TryFunction]
    local procedure TryCheckEntitiesAvailability(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckEntitiesAvailability(CDSConnectionSetup);
    end;

    local procedure CheckEntitiesAvailability(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMSystemuser: Record "CRM Systemuser";
        CRMTeam: Record "CRM Team";
        CRMRole: Record "CRM Role";
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMBusinessunit: Record "CRM Businessunit";
        CRMAccount: Record "CRM Account";
        CRMContact: Record "CRM Contact";
        CDSCompany: Record "CDS Company";
        Id: Guid;
        TempConnectionName: Text;
    begin
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        if CRMTeam.FindFirst() then
            Id := CRMTeam.TeamId;

        if CRMRole.FindFirst() then
            Id := CRMRole.RoleId;

        if CRMSystemuser.FindFirst() then
            Id := CRMSystemuser.SystemUserId;

        if CRMSystemuserroles.FindFirst() then
            Id := CRMSystemuserroles.SystemUserId;

        if CRMBusinessunit.FindFirst() then
            Id := CRMBusinessunit.BusinessUnitId;

        if CDSCompany.FindFirst() then
            Id := CDSCompany.CompanyId;

        if CRMAccount.FindFirst() then
            Id := CRMAccount.CompanyId;

        if CRMContact.FindFirst() then
            Id := CRMContact.CompanyId;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    local procedure CheckSystemUsersAvailability()
    var
        CDSSystemuser: Record "CRM Systemuser";
        Id: Guid;
    begin
        if CDSSystemuser.FindFirst() then
            Id := CDSSystemuser.SystemUserId;
    end;

    [TryFunction]
    local procedure TryCheckEntitiesAvailability()
    var
        CRMSystemuser: Record "CRM Systemuser";
        CRMTeam: Record "CRM Team";
        CRMRole: Record "CRM Role";
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMBusinessunit: Record "CRM Businessunit";
        CRMAccount: Record "CRM Account";
        CRMContact: Record "CRM Contact";
        CDSCompany: Record "CDS Company";
        Id: Guid;
    begin
        if CRMTeam.FindFirst() then
            Id := CRMTeam.TeamId;

        if CRMRole.FindFirst() then
            Id := CRMRole.RoleId;

        if CRMSystemuser.FindFirst() then
            Id := CRMSystemuser.SystemUserId;

        if CRMSystemuserroles.FindFirst() then
            Id := CRMSystemuserroles.SystemUserId;

        if CRMBusinessunit.FindFirst() then
            Id := CRMBusinessunit.BusinessUnitId;

        if CDSCompany.FindFirst() then
            Id := CDSCompany.CompanyId;

        if CRMAccount.FindFirst() then
            Id := CRMAccount.CompanyId;

        if CRMContact.FindFirst() then
            Id := CRMContact.CompanyId;
    end;

    [Scope('OnPrem')]
    procedure SelectSDKVersion(var CDSConnectionSetup: Record "CDS Connection Setup"): Boolean
    var
        TempStack: Record TempStack temporary;
    begin
        if PAGE.RunModal(PAGE::"SDK Version List", TempStack) = ACTION::LookupOK then begin
            CDSConnectionSetup.Validate("Proxy Version", TempStack.StackOrder);
            exit(true);
        end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure SelectBusinessUnit(var CDSConnectionSetup: Record "CDS Connection Setup"): Boolean
    var
        TempCRMBusinessUnit: Record "CRM Businessunit" temporary;
        EmptyGuid: Guid;
        PrevBusinessUnitId: Guid;
        DefaultBusinessUnitName: Text[160];
        Changed: Boolean;
        AddArtificialDefaultBusinessUnit: Boolean;
    begin
        PrevBusinessUnitId := CDSConnectionSetup."Business Unit Id";
        DefaultBusinessUnitName := GetDefaultBusinessUnitName();

        if not GetFirstLevelBusinessUnits(CDSConnectionSetup, TempCRMBusinessUnit) then begin
            Changed := not IsNullGuid(PrevBusinessUnitId);
            if Changed then begin
                CDSConnectionSetup."Business Unit Id" := EmptyGuid;
                CDSConnectionSetup."Business Unit Name" := DefaultBusinessUnitName;
            end;
            exit(Changed);
        end;

        TempCRMBusinessUnit.SetRange(Name, DefaultBusinessUnitName);
        AddArtificialDefaultBusinessUnit := TempCRMBusinessUnit.IsEmpty();
        TempCRMBusinessUnit.SetRange(Name);
        if AddArtificialDefaultBusinessUnit then begin
            TempCRMBusinessUnit.Init();
            TempCRMBusinessUnit.BusinessUnitId := EmptyGuid;
            TempCRMBusinessUnit.Name := StrSubstNo(NewBusinessUnitNameTemplateTok, DefaultBusinessUnitName);
            TempCRMBusinessUnit.Insert();
        end;

        if PAGE.RunModal(PAGE::"CDS Business Units", TempCRMBusinessUnit) <> ACTION::LookupOK then
            exit(false);

        Changed := TempCRMBusinessUnit.BusinessUnitId <> PrevBusinessUnitId;
        if Changed then begin
            CDSConnectionSetup."Business Unit Id" := TempCRMBusinessUnit.BusinessUnitId;
            if IsNullGuid(CDSConnectionSetup."Business Unit Id") then
                CDSConnectionSetup."Business Unit Name" := DefaultBusinessUnitName
            else
                CDSConnectionSetup."Business Unit Name" := TempCRMBusinessUnit.Name;
        end;
        exit(Changed);
    end;

    [TryFunction]
    local procedure GetFirstLevelBusinessUnits(var CDSConnectionSetup: Record "CDS Connection Setup"; var TempCRMBusinessunit: Record "CRM Businessunit" temporary)
    var
        CRMBusinessunit: Record "CRM Businessunit";
        TempConnectionName: Text;
        RootBusinessUnitId: Guid;
        EmptyGuid: Guid;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);

        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        CRMBusinessunit.SetRange(ParentBusinessUnitId, EmptyGuid);
        if CRMBusinessunit.FindFirst() then begin
            RootBusinessUnitId := CRMBusinessunit.BusinessUnitId;
            CRMBusinessunit.SetRange(ParentBusinessUnitId, RootBusinessUnitId);
            CRMBusinessunit.SetRange(IsDisabled, false);
            if CRMBusinessunit.FindSet() then
                repeat
                    TempCRMBusinessunit.Init();
                    TempCRMBusinessUnit.BusinessUnitId := CRMBusinessunit.BusinessUnitId;
                    TempCRMBusinessUnit.Name := CRMBusinessUnit.Name;
                    TempCRMBusinessunit.Insert();
                until CRMBusinessunit.Next() = 0;
            if TempCRMBusinessunit.FindFirst() then;
        end;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    procedure CheckConnectionRequiredFields(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    var
        Success: Boolean;
        TelemetryTxt: Text;
        ErrorTxt: Text;
    begin
        Success := true;
        if CDSConnectionSetup."Server Address" = '' then
            Success := false;
        if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then begin
            if CDSConnectionSetup."User Name" = '' then
                Success := false;
            if not CDSConnectionSetup.HasPassword() then
                Success := false;
        end;
        if not Success then begin
            if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then begin
                TelemetryTxt := ConnectionRequiredFieldsTxt;
                ErrorTxt := ConnectionRequiredFieldsErr;
            end else begin
                TelemetryTxt := Office365ConnectionRequiredFieldsTxt;
                ErrorTxt := Office365ConnectionRequiredFieldsErr;
            end;

            Session.LogMessage('0000ATQ', TelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if not Silent then
                Error(ErrorTxt);
        end;
        exit(Success);
    end;


    [Scope('OnPrem')]
    procedure CheckConnectionRequiredFieldsMatch(var CDSConnectionSetup: Record "CDS Connection Setup"; Silent: Boolean): Boolean
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        Success: Boolean;
    begin
        Success := true;

        if not CRMConnectionSetup.Get() then
            exit(true);

        if not CRMConnectionSetup."Is Enabled" then
            exit(true);

        if CDSConnectionSetup."Server Address" <> CRMConnectionSetup."Server Address" then
            Success := false;
        if CDSConnectionSetup."User Name" <> CRMConnectionSetup."User Name" then
            Success := false;
        if CDSConnectionSetup."User Password Key" <> CRMConnectionSetup."User Password Key" then
            Success := false;
        if CDSConnectionSetup."Authentication Type" <> CRMConnectionSetup."Authentication Type" then
            Success := false;
        if not Success then begin
            Session.LogMessage('0000BCM', ConnectionRequiredFieldsMismatchTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if not Silent then
                Error(ConnectionRequiredFieldsMismatchErr);
        end;
        exit(Success);
    end;

    local procedure FilterUser(var CDSConnectionSetup: Record "CDS Connection Setup"; var CRMSystemuser: Record "CRM Systemuser")
    begin
        case CDSConnectionSetup."Authentication Type" of
            CDSConnectionSetup."Authentication Type"::Office365, CDSConnectionSetup."Authentication Type"::OAuth:
                CRMSystemuser.SetFilter(InternalEMailAddress, StrSubstNo('@%1', CDSConnectionSetup."User Name"));
            CDSConnectionSetup."Authentication Type"::AD, CDSConnectionSetup."Authentication Type"::IFD:
                CRMSystemuser.SetFilter(DomainName, StrSubstNo('@%1', CDSConnectionSetup."User Name"));
        end;
    end;

    local procedure FilterTeam(BusinessUnitId: Guid; TeamName: Text; var CRMTeam: Record "CRM Team")
    begin
        CRMTeam.SetRange(Name, TeamName);
        CRMTeam.SetRange(BusinessUnitId, BusinessUnitId);
        CRMTeam.SetRange(IsDefault, false);
    end;

    local procedure GetUserName(var CDSConnectionSetup: Record "CDS Connection Setup") UserName: Text
    begin
        if CDSConnectionSetup."User Name" = '' then
            UserName := MissingUsernameTok
        else
            UserName := CopyStr(CDSConnectionSetup."User Name", StrPos(CDSConnectionSetup."User Name", '\') + 1);
    end;

    [Scope('OnPrem')]
    procedure RegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        ModuleInfo: ModuleInfo;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        CurrentGlobalLanguage: Integer;
    begin
        if GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"CDS Connection Setup Wizard") then
            exit;

        CurrentGlobalLanguage := GLOBALLANGUAGE;
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        GuidedExperience.InsertAssistedSetup(CDSConnectionSetupTitleTxt, CDSConnectionSetupShortTitleTxt, CDSConnectionSetupDescriptionTxt, 10, ObjectType::Page,
            Page::"CDS Connection Setup Wizard", AssistedSetupGroup::Connect, '', VideoCategory::Connect, CDSConnectionSetupHelpTxt);
        GLOBALLANGUAGE(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            Page::"CDS Connection Setup Wizard", Language.GetDefaultApplicationLanguageId(), CDSConnectionSetupTitleTxt);
        GLOBALLANGUAGE(CurrentGlobalLanguage);
    end;

    [NonDebuggable]
    local procedure GetConnectionStringWithCredentials(var CDSConnectionSetup: Record "CDS Connection Setup"): Text
    var
        ConnectionStringWithPassword: Text;
        ConnectionStringWithClientSecret: Text;
        ConnectionStringWithCertificate: Text;
        ConnectionStringWithAccessToken: Text;
        PasswordPlaceHolderPos: Integer;
    begin
        if CDSConnectionSetup."Connection String" = '' then
            exit('');

        // if the setup record is temporary and user name is empty, this is a temp setup record constructed for the admin log-on
        // in this case, the connection string contains the URL and access token, so just use the connection string
        if CDSConnectionSetup.IsTemporary() then
            if CDSConnectionSetup."User Name" = '' then begin
                ConnectionStringWithAccessToken := StrSubstNo(OAuthConnectionStringFormatTxt, CDSConnectionSetup."Server Address", CDSConnectionSetup.GetAccessToken(), CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup));
                exit(ConnectionStringWithAccessToken);
            end;

        // if auth type is Office365 and connection string contains {ClientSecret} token
        // then we will connect via OAuth client credentials grant flow, and construct the connection string accordingly, with the actual client secret
        if CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::Office365 then begin
            if CDSConnectionSetup."Connection String".Contains(ClientSecretTok) then begin
                ConnectionStringWithClientSecret := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, CDSConnectionSetup."Server Address", GetCDSConnectionClientId(), GetCDSConnectionClientSecret(), CDSConnectionSetup."Proxy Version");
                exit(ConnectionStringWithClientSecret);
            end;

            if CDSConnectionSetup."Connection String".Contains(CertificateTok) then begin
                ConnectionStringWithCertificate := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, CDSConnectionSetup."Server Address", GetCDSConnectionFirstPartyAppId(), GetCDSConnectionFirstPartyAppcertificate(), CDSConnectionSetup."Proxy Version");
                exit(ConnectionStringWithCertificate);
            end;
        end;

        PasswordPlaceHolderPos := StrPos(CDSConnectionSetup."Connection String", MissingPasswordTok);
        ConnectionStringWithPassword :=
          CopyStr(CDSConnectionSetup."Connection String", 1, PasswordPlaceHolderPos - 1) + CDSConnectionSetup.GetPassword() +
          CopyStr(CDSConnectionSetup."Connection String", PasswordPlaceHolderPos + StrLen(MissingPasswordTok));

        exit(ConnectionStringWithPassword);
    end;

    [Scope('OnPrem')]
    procedure UpdateConnectionString(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        ConnectionString: Text;
        ConnectionStringWithClientSecret: Text;
        ConnectionStringWithCertificate: Text;
    begin
        if CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::Office365 then begin
            if CDSConnectionSetup."Connection String".Contains(ClientSecretAuthTxt) then begin
                ConnectionStringWithClientSecret := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, CDSConnectionSetup."Server Address", ClientIdTok, ClientSecretTok, CDSConnectionSetup."Proxy Version");
                SetConnectionString(CDSConnectionSetup, ConnectionStringWithClientSecret);
                exit;
            end;

            if CDSConnectionSetup."Connection String".Contains(CertificateAuthTxt) then begin
                ConnectionStringWithCertificate := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, CDSConnectionSetup."Server Address", ClientIdTok, CertificateTok, CDSConnectionSetup."Proxy Version");
                SetConnectionString(CDSConnectionSetup, ConnectionStringWithCertificate);
                exit;
            end;
        end;

        ConnectionString :=
          StrSubstNo(
            ConnectionStringFormatTok, CDSConnectionSetup."Server Address", GetUserName(CDSConnectionSetup), MissingPasswordTok, CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup));
        SetConnectionString(CDSConnectionSetup, ConnectionString);
    end;

    [Scope('OnPrem')]
    procedure GetConnectionString(var CDSConnectionSetup: Record "CDS Connection Setup") ConnectionString: Text
    begin
        ConnectionString := CDSConnectionSetup."Connection String";
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetConnectionString(var CDSConnectionSetup: Record "CDS Connection Setup"; ConnectionString: Text)
    begin
        if ConnectionString = '' then
            Clear(CDSConnectionSetup."Connection String")
        else begin
            if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then
                if StrPos(ConnectionString, MissingPasswordTok) = 0 then
                    Error(ConnectionStringPwdPlaceHolderMissingErr);
            CDSConnectionSetup."Connection String" := CopyStr(ConnectionString, 1, MaxStrLen(CDSConnectionSetup."Connection String"));
        end;
        if not CDSConnectionSetup.Modify() then;
    end;

    [Scope('OnPrem')]
    [TryFunction]
    procedure TryGetCDSCompany(var CDSCompany: Record "CDS Company")
    begin
        GetCDSCompany(CDSCompany);
    end;

    [Scope('OnPrem')]
    procedure GetCDSCompany(var CDSCompany: Record "CDS Company")
    begin
        CDSCompany.SetRange(ExternalId, GetCompanyExternalId());
        CDSCompany.FindFirst();
    end;

    [Scope('OnPrem')]
    [TryFunction]
    procedure TryGetCompanyId(var CompanyId: Guid)
    begin
        CompanyId := GetCachedCompanyId();
    end;

    [Scope('OnPrem')]
    procedure GetCoupledBusinessUnitId(): Guid
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        EmptyGuid: Guid;
    begin
        if CDSConnectionSetup.Get() then
            exit(CDSConnectionSetup."Business Unit Id");
        exit(EmptyGuid);
    end;

    [Scope('OnPrem')]
    procedure GetIntegrationUserId(var CDSConnectionSetup: Record "CDS Connection Setup") IntegrationUserId: Guid
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempConnectionName: Text;
        HasPersistentConnection: Boolean;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);

        HasPersistentConnection := IsConnectionActive(CDSConnectionSetup, GetConnectionDefaultName());
        if not HasPersistentConnection then begin
            TempConnectionName := GetTempConnectionName();
            RegisterConnection(CDSConnectionSetup, TempConnectionName);
            SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);
        end;

        FilterUser(CDSConnectionSetup, CRMSystemuser);
        if CRMSystemuser.FindFirst() then
            IntegrationUserID := CRMSystemuser.SystemUserId;

        if not HasPersistentConnection then
            UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);

        if IsNullGuid(IntegrationUserID) then
            ShowError(UserSetupTxt, CannotResolveUserFromConnectionSetupErr);
    end;

    [Scope('OnPrem')]
    procedure GetOwningTeamId(var CDSConnectionSetup: Record "CDS Connection Setup"): Guid
    var
        CRMBusinessUnit: Record "CRM Businessunit";
        CRMTeam: Record "CRM team";
        BusinessUnitId: Guid;
        TeamId: Guid;
        TeamName: Text;
        TempConnectionName: Text;
        HasPersistentConnection: Boolean;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);
        BusinessUnitId := CDSConnectionSetup."Business Unit Id";
        if IsNullGuid(BusinessUnitId) then
            exit(TeamId);

        HasPersistentConnection := IsConnectionActive(CDSConnectionSetup, GetConnectionDefaultName());
        if not HasPersistentConnection then begin
            TempConnectionName := GetTempConnectionName();
            RegisterConnection(CDSConnectionSetup, TempConnectionName);
            SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);
        end;

        if CRMBusinessUnit.Get(BusinessUnitId) then begin
            TeamName := GetOwningTeamName(CRMBusinessUnit.Name);
            FilterTeam(BusinessUnitId, TeamName, CRMTeam);
            if CRMTeam.FindFirst() then
                TeamId := CRMTeam.TeamId;
        end;

        if not HasPersistentConnection then
            UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);

        exit(TeamId);
    end;

    [Scope('OnPrem')]
    procedure GetDefaultOwningTeamMembership(var TempCDSTeammembership: Record "CDS Teammembership" temporary)
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if CDSConnectionSetup.Get() then
            GetDefaultOwningTeamMembership(CDSConnectionSetup, TempCDSTeammembership);
    end;

    [Scope('OnPrem')]
    procedure GetDefaultOwningTeamMembership(var CDSConnectionSetup: Record "CDS Connection Setup"; var TempCDSTeammembership: Record "CDS Teammembership" temporary)
    var
        CDSTeammembership: Record "CDS Teammembership";
        BusinessUnitId: Guid;
        TeamId: Guid;
        TempConnectionName: Text;
        HasPersistentConnection: Boolean;
    begin
        if not CheckConnectionRequiredFields(CDSConnectionSetup, true) then
            exit;

        BusinessUnitId := CDSConnectionSetup."Business Unit Id";
        if IsNullGuid(BusinessUnitId) then
            exit;

        TeamId := GetOwningTeamId(CDSConnectionSetup);
        if not IsNullGuid(TeamId) then begin
            HasPersistentConnection := IsConnectionActive(CDSConnectionSetup, GetConnectionDefaultName());
            if not HasPersistentConnection then begin
                TempConnectionName := GetTempConnectionName();
                RegisterConnection(CDSConnectionSetup, TempConnectionName);
                SetDefaultTableConnection(TableConnectionType::CRM, TempConnectionName, true);
            end;

            TempCDSTeammembership.Reset();
            TempCDSTeammembership.DeleteAll();

            CDSTeammembership.SetRange(TeamId, TeamId);
            if CDSTeammembership.FindSet() then
                repeat
                    TempCDSTeammembership.Init();
                    TempCDSTeammembership.TransferFields(CDSTeammembership);
                    TempCDSTeammembership.Insert();
                until CDSTeammembership.Next() = 0;

            if not HasPersistentConnection then
                UnregisterTableConnection(TableConnectionType::CRM, TempConnectionName);
        end;
    end;

    local procedure AssignUserRole(var CrmHelper: DotNet CrmHelper; UserId: Guid; RoleId: Guid): Boolean
    begin
        if CrmHelper.CheckRoleAssignedToUser(UserId, RoleId) then
            exit(true);

        if not TryAssignUserRole(CrmHelper, UserId, RoleId) then begin
            Session.LogMessage('0000ATR', CannotAssignRoleToUserTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if CrmHelper.CheckRoleAssignedToUser(UserId, RoleId) then
            exit(true);

        Session.LogMessage('0000ATS', CannotAssignRoleToUserTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [TryFunction]
    local procedure TryAssignUserRole(var CrmHelper: DotNet CrmHelper; UserId: Guid;
                                                         RoleId: Guid)
    begin
        CrmHelper.AssociateUserWithRole(UserId, RoleId);
    end;

    [TryFunction]
    local procedure TryGetUserId(var CrmHelper: DotNet CrmHelper; UserName: Text;

    var
        UserId: Guid)
    begin
        UserId := CrmHelper.GetUserId(UserName);
    end;

    [NonDebuggable]
    local procedure AssignPreviousIntegrationUserRoles(var CrmHelper: DotNet CrmHelper; var CDSConnectionSetup: Record "CDS Connection Setup"; AccessToken: Text)
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        Company: Record Company;
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        CRMSystemUserRoles: Record "CRM Systemuserroles";
        RootCRMBusinessunit: Record "CRM Businessunit";
        DefaultCRMBusinessunit: Record "CRM Businessunit";
        DefaultCRMTeam: Record "CRM Team";
        CRMRole: Record "CRM Role";
        PreviousIntegrationUserRole: Record "CRM Role";
        TeamName: Text[160];
        CompanyId: Text[36];
        CompanyName: Text[30];
        BusinessUnitName: Text[160];
        TempConnectionName: Text;
        PreviousIntegrationUserId: Guid;
        CurrentIntegrationUserId: Guid;
        EmptyGuid: Guid;
    begin
        if not CRMConnectionSetup.Get() then
            exit;

        if CRMConnectionSetup."User Name" = '' then
            exit;

        if CRMConnectionSetup."User Name" = CDSConnectionSetup."User Name" then
            exit;

        if not TryGetUserId(CrmHelper, CRMConnectionSetup."User Name", PreviousIntegrationUserId) then begin
            Session.LogMessage('0000D4A', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not TryGetUserId(CrmHelper, CDSConnectionSetup."User Name", CurrentIntegrationUserId) then begin
            Session.LogMessage('0000D4B', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        ResetCache();

        Company.Get(CompanyName());
        CompanyId := GetCompanyExternalId(Company);
        CompanyName := CopyStr(Company.Name, 1, MaxStrLen(CompanyName));
        BusinessUnitName := GetDefaultBusinessUnitName(CompanyName, CompanyId);

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, '', '', AccessToken, '');
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        RootCRMBusinessunit.SetRange(ParentBusinessUnitId, EmptyGuid);
        RootCRMBusinessunit.FindFirst();
        DefaultCRMBusinessunit.SetRange(ParentBusinessUnitId, RootCRMBusinessunit.BusinessUnitId);
        DefaultCRMBusinessunit.SetRange(Name, BusinessUnitName);
        if not DefaultCRMBusinessunit.FindFirst() then
            exit;
        TeamName := GetOwningTeamName(DefaultCRMBusinessunit.Name);
        FilterTeam(DefaultCRMBusinessunit.BusinessUnitId, TeamName, DefaultCRMTeam);
        if not DefaultCRMTeam.FindFirst() then
            exit;

        // assign the roles of the previous integration user to the current (newly set up) integration user and to the default owning team
        // if one of those roles is System Administrator, ignore it
        CRMSystemUserRoles.SetRange(SystemUserId, PreviousIntegrationUserId);
        if CRMSystemUserRoles.FindSet() then
            repeat
                if PreviousIntegrationUserRole.Get(CRMSystemUserRoles.RoleId) then
                    if PreviousIntegrationUserRole.RoleTemplateId <> GetSystemAdminRoleTemplateId() then begin
                        if not TryAssignUserRole(CrmHelper, CurrentIntegrationUserId, CRMSystemUserRoles.RoleId) then
                            Session.LogMessage('0000D4C', CannotAssignRoleToUserTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

                        CRMRole.SetRange(ParentRoleId, CRMSystemUserRoles.RoleId);
                        CRMRole.SetRange(BusinessUnitId, DefaultCRMBusinessunit.BusinessUnitId);
                        if not CRMRole.FindFirst() then
                            Session.LogMessage('0000D4D', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
                        else
                            if not AssignTeamRole(CrmHelper, DefaultCRMTeam.TeamId, CRMRole.RoleId) then
                                Session.LogMessage('0000D4E', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
                    end;
            until CRMSystemUserRoles.Next() = 0;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
        Session.LogMessage('0000D4F', PreviousIntegrationUserRolesAddedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [NonDebuggable]
    local procedure AssignPreviousIntegrationUserRoles(var CrmHelper: DotNet CrmHelper; PreviousIntegrationUserName: Text[250]; var CDSConnectionSetup: Record "CDS Connection Setup"; AccessToken: Text)
    var
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        CRMSystemUserRoles: Record "CRM Systemuserroles";
        PreviousIntegrationUserRole: Record "CRM Role";
        TempConnectionName: Text;
        PreviousIntegrationUserId: Guid;
        CurrentIntegrationUserId: Guid;
    begin
        if CDSConnectionSetup."User Name" = PreviousIntegrationUserName then
            exit;

        if not TryGetUserId(CrmHelper, PreviousIntegrationUserName, PreviousIntegrationUserId) then begin
            Session.LogMessage('0000D4A', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not TryGetUserId(CrmHelper, CDSConnectionSetup."User Name", CurrentIntegrationUserId) then begin
            Session.LogMessage('0000D4B', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        ResetCache();

        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, '', '', AccessToken, '');
        TempConnectionName := GetTempConnectionName();
        RegisterConnection(TempAdminCDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        // Table connection is scoped, therefore all manipulations with CDS tables must be placed
        // in this procedure between SetDefaultTableConnection and UnregisterConnection

        // assign the roles of the previous integration user to the current (newly set up) integration user
        CRMSystemUserRoles.SetRange(SystemUserId, PreviousIntegrationUserId);
        if CRMSystemUserRoles.FindSet() then
            repeat
                if PreviousIntegrationUserRole.Get(CRMSystemUserRoles.RoleId) then
                    if not TryAssignUserRole(CrmHelper, CurrentIntegrationUserId, CRMSystemUserRoles.RoleId) then
                        Session.LogMessage('0000D4C', CannotAssignRoleToUserTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            until CRMSystemUserRoles.Next() = 0;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
        Session.LogMessage('0000D4F', PreviousIntegrationUserRolesAddedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [Scope('OnPrem')]
    procedure AssignIntegrationRole(var CrmHelper: DotNet CrmHelper; UserName: Text)
    var
        UserId: Guid;
        RoleId: Guid;
    begin
        if not TryGetUserId(CrmHelper, UserName, UserId) then begin
            Session.LogMessage('0000ATT', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserDoesNotExistErr, UserName);
        end;
        if IsNullGuid(UserId) then begin
            Session.LogMessage('0000ATU', UserNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserDoesNotExistErr, UserName);
        end;
        RoleId := GetIntegrationRoleId();
        if not AssignUserRole(CrmHelper, UserId, RoleId) then begin
            Session.LogMessage('0000ATV', CannotAssignRoleToUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotAssignRoleToIntegrationUserErr);
        end;
        Session.LogMessage('0000ATW', RoleAssignedToUserTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    procedure AssignTeamRole(var CrmHelper: DotNet CrmHelper; TeamId: Guid;
                                                RoleId: Guid): Boolean
    begin
        if CheckRoleAssignedToTeam(CrmHelper, TeamId, RoleId) then
            exit(true);

        if not TryAssignTeamRole(CrmHelper, TeamId, RoleId) then begin
            Session.LogMessage('0000ATX', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if CheckRoleAssignedToTeam(CrmHelper, TeamId, RoleId) then
            exit(true);

        Session.LogMessage('0000ATY', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [TryFunction]
    local procedure TryAssignTeamRole(var CrmHelper: DotNet CrmHelper; TeamId: Guid;
                                                         RoleId: Guid)
    begin
        CrmHelper.AssociateTeamWithRole(TeamId, RoleId);
    end;

    local procedure CheckRoleAssignedToTeam(var CrmHelper: DotNet CrmHelper; TeamId: Guid;
                                                               RoleId: Guid): Boolean
    begin
        exit(CrmHelper.CheckRoleAssignedToTeam(TeamId, RoleId));
    end;

    local procedure AddUserToTeam(var CrmHelper: DotNet CrmHelper; UserId: Guid;
                                                     TeamId: Guid): Boolean
    begin
        if CrmHelper.CheckUserAssociatedWithTeam(UserId, TeamId) then
            exit(false);

        if not TryAddUserToTeam(CrmHelper, UserId, TeamId) then begin
            Session.LogMessage('0000C97', CannotAddUserToTeamTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if CrmHelper.CheckUserAssociatedWithTeam(UserId, TeamId) then begin
            Session.LogMessage('0000C9Q', UserAddedToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        Session.LogMessage('0000C98', CannotAddUserToTeamTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [TryFunction]
    local procedure TryAddUserToTeam(var CrmHelper: DotNet CrmHelper; UserId: Guid;
                                                        TeamId: Guid)
    begin
        CrmHelper.AssociateUserWithTeam(UserId, TeamId);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure ImportAndConfigureIntegrationSolution(var CDSConnectionSetup: Record "CDS Connection Setup"; RenewSolution: Boolean): Boolean
    begin
        exit(ImportAndConfigureIntegrationSolution(CDSConnectionSetup, RenewSolution, false));
    end;

    [NonDebuggable]
    internal procedure ImportAndConfigureIntegrationSolution(var CDSConnectionSetup: Record "CDS Connection Setup"; RenewSolution: Boolean; GetTokenFromCache: Boolean): Boolean
    var
        CrmHelper: DotNet CrmHelper;
        AdminAccessToken: Text;
        AdminUserName: Text;
        AdminPassword: Text;
        AdminADDomain: Text;
    begin
        Session.LogMessage('0000ATZ', ConfigureSolutionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        CheckCredentials(CDSConnectionSetup);
        SignInCDSAdminUser(CDSConnectionSetup, CrmHelper, AdminUserName, AdminPassword, AdminAccessToken, AdminADDomain, GetTokenFromCache);
        JITProvisionFirstPartyApp(CrmHelper);
        Sleep(5000);
        ImportIntegrationSolution(CDSConnectionSetup, CrmHelper, AdminUserName, AdminPassword, AdminAccessToken, AdminADDomain, RenewSolution);
        ConfigureIntegrationSolution(CDSConnectionSetup, CrmHelper, AdminUserName, AdminPassword, AdminAccessToken, AdminADDomain, false);
        if not RenewSolution then
            if CheckIntegrationRequirements(CDSConnectionSetup, true) then begin
                Session.LogMessage('0000AU0', IntegrationRequirementsMetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;
        exit(true);
    end;

    [Scope('OnPrem')]
    [TryFunction]
    [NonDebuggable]
    procedure SignInCDSAdminUser(var CDSConnectionSetup: Record "CDS Connection Setup"; var CrmHelper: DotNet CrmHelper; var AdminUser: Text; var AdminPassword: Text; var AccessToken: Text; var AdminADDomain: Text; GetTokenFromCache: Boolean)
    var
        TempConnectionString: Text;
    begin
        if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then begin
            if not PromptForAdminCredentials(CDSConnectionSetup, AdminUser, AdminPassword, AdminADDomain) then begin
                Session.LogMessage('0000AU1', InvalidAdminCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(AdminUserPasswordWrongErr);
            end;

            case CDSConnectionSetup."Authentication Type" of
                CDSConnectionSetup."Authentication Type"::AD:
                    TempConnectionString := StrSubstNo(ConnectionStringFormatTok, CDSConnectionSetup."Server Address", AdminUser, AdminPassword, CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup, AdminADDomain));
                CDSConnectionSetup."Authentication Type"::OAuth:
                    TempConnectionString := ReplaceUserNamePasswordInConnectionstring(CDSConnectionSetup, AdminUser, AdminPassword);
                else
                    TempConnectionString := StrSubstNo(ConnectionStringFormatTok, CDSConnectionSetup."Server Address", AdminUser, AdminPassword, CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup));
            end
        end else begin
            GetAccessToken(CDSConnectionSetup."Server Address", GetTokenFromCache, AccessToken);
            TempConnectionString := StrSubstNo(OAuthConnectionStringFormatTxt, CDSConnectionSetup."Server Address", AccessToken, CDSConnectionSetup."Proxy Version", GetAuthenticationTypeToken(CDSConnectionSetup));
        end;

        if not InitializeConnection(CrmHelper, TempConnectionString) then begin
            Session.LogMessage('0000AU2', ConnectionNotRegisteredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ProcessConnectionFailures();
        end;
    end;


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure ReplaceUserNamePasswordInConnectionstring(CDSConnectionSetup: Record "CDS Connection Setup"; NewUserName: Text; NewPassword: Text): Text
    var
        PasswordPlaceHolderPos: Integer;
        UserNameTokenPos: Integer;
        NewConnectionString: Text;
        LeftPart: Text;
        RightPart: Text;
        UserNameTok: Text;
    begin
        UserNameTok := 'UserName=';
        PasswordPlaceHolderPos := StrPos(CDSConnectionSetup."Connection String", MissingPasswordTok);

        // first replace the password
        NewConnectionString :=
            CopyStr(CDSConnectionSetup."Connection String", 1, PasswordPlaceHolderPos - 1) + NewPassword +
            CopyStr(CDSConnectionSetup."Connection String", PasswordPlaceHolderPos + StrLen(MissingPasswordTok));

        // then replace the user name
        UserNameTokenPos := StrPos(NewConnectionString, UserNameTok);
        LeftPart := CopyStr(NewConnectionString, 1, UserNameTokenPos - 1);
        RightPart := CopyStr(NewConnectionString, UserNameTokenPos);
        if RightPart.IndexOf(';') > 0 then
            NewConnectionString := LeftPart + UserNameTok + NewUserName + CopyStr(RightPart, RightPart.IndexOf(';'))
        else
            NewConnectionString := LeftPart + UserNameTok + NewUserName;

        exit(NewConnectionString);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAccessToken(ResourceURL: Text; GetTokenFromCache: Boolean; var AccessToken: Text)
    var
        OAuth2: Codeunit OAuth2;
        PromptInteraction: Enum "Prompt Interaction";
        ClientId: Text;
        ClientSecret: Text;
        FirstPartyAppId: Text;
        FirstPartyAppCertificate: Text;
        RedirectUrl: Text;
        AuthCodeError: Text;
    begin
        ClientId := GetCDSConnectionClientId();
        ClientSecret := GetCDSConnectionClientSecret();
        FirstPartyAppId := GetCDSConnectionFirstPartyAppId();
        FirstPartyAppCertificate := GetCDSConnectionFirstPartyAppCertificate();

        if (FirstPartyAppId = '') or (FirstPartyAppCertificate = '') then
            if (ClientId = '') or (ClientSecret = '') then
                Error(GetMissingClientIdOrSecretErr());

        RedirectUrl := GetRedirectURL();
        if GetTokenFromCache then
            if (FirstPartyAppId <> '') and (FirstPartyAppCertificate <> '') then begin
                Session.LogMessage('0000EI9', AttemptingAuthCodeTokenFromCacheWithCertTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                OAuth2.AcquireAuthorizationCodeTokenFromCacheWithCertificate(FirstPartyAppId, FirstPartyAppCertificate, RedirectUrl, OAuthAuthorityUrlTxt, ResourceURL, AccessToken)
            end else begin
                Session.LogMessage('0000EIA', AttemptingAuthCodeTokenFromCacheWithClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectUrl, OAuthAuthorityUrlTxt, ResourceURL, AccessToken);
            end;
        if AccessToken = '' then begin
            if not GuiAllowed then begin
                Session.LogMessage('0000DNV', GuiNotAllowedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;

            if (FirstPartyAppId <> '') and (FirstPartyAppCertificate <> '') then begin
                Session.LogMessage('0000EIB', AttemptingAuthCodeTokenWithCertTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                OAuth2.AcquireTokenByAuthorizationCodeWithCertificate(
                    FirstPartyAppId,
                    FirstPartyAppCertificate,
                    OAuthAuthorityUrlTxt,
                    RedirectUrl,
                    ResourceURL,
                    PromptInteraction::Consent,
                    AccessToken,
                    AuthCodeError)
            end else begin
                Session.LogMessage('0000EIC', AttemptingAuthCodeTokenWithClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                OAuth2.AcquireTokenByAuthorizationCode(
                    ClientId,
                    ClientSecret,
                    OAuthAuthorityUrlTxt,
                    RedirectUrl,
                    ResourceURL,
                    PromptInteraction::Consent,
                    AccessToken,
                    AuthCodeError)
            end;
        end;
        if AccessToken = '' then begin
            if AuthCodeError <> '' then
                Session.LogMessage('0000C10', AuthCodeError, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                Session.LogMessage('0000C11', AuthTokenOrCodeNotReceivedErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(AccessTokenNotReceivedErr, ResourceURL);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetRedirectURL(): Text
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            exit('');

        if CDSConnectionSetup.Get() then
            exit(CDSConnectionSetup."Redirect URL");

        exit('');
    end;


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCDSConnectionClientId(): Text
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        AzureKeyVault: Codeunit "Azure Key Vault";
        ClientId: Text;
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(CDSConnectionClientIdAKVSecretNameLbl, ClientId) then
                Session.LogMessage('0000C0Y', MissingClientIdOrSecretTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                exit(ClientId);

        if CDSConnectionSetup.Get() then
            ClientId := CDSConnectionSetup."Client Id";

        if ClientId = '' then
            OnGetCDSConnectionClientId(ClientId);

        exit(ClientId);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCDSConnectionFirstPartyAppId(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        ClientId: Text;
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(CDSConnectionFirstPartyAppIdAKVSecretNameLbl, ClientId) then
                Session.LogMessage('0000EBU', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                exit(ClientId);
        exit(ClientId);
    end;

    local procedure GetMissingClientIdOrSecretErr(): Text
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            exit(MissingClientIdOrSecretErr);

        exit(MissingClientIdOrSecretOnPremErr);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCDSConnectionClientSecret(): Text
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        AzureKeyVault: Codeunit "Azure Key Vault";
        ClientSecret: Text;
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(CDSConnectionClientSecretAKVSecretNameLbl, ClientSecret) then
                Session.LogMessage('0000C0Z', MissingClientIdOrSecretTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                exit(ClientSecret);

        if CDSConnectionSetup.Get() then
            ClientSecret := CDSConnectionSetup.GetClientSecret();

        if ClientSecret = '' then
            OnGetCDSConnectionClientSecret(ClientSecret);

        exit(ClientSecret);
    end;


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCDSConnectionFirstPartyAppCertificate(): Text;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Certificate: Text;
        CertificateName: Text;
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(CDSConnectionFirstPartyAppCertificateNameAKVSecretNameLbl, CertificateName) then begin
                Session.LogMessage('0000EBV', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(Certificate);
            end;

        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then
            Session.LogMessage('0000EC2', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        exit(Certificate);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure ImportIntegrationSolution(var CDSConnectionSetup: Record "CDS Connection Setup"; var CrmHelper: DotNet CrmHelper; AdminUsername: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text; RenewSolution: Boolean)
    var
        TempAdminCDSConnectionSetup: Record "CDS Connection Setup" temporary;
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        Version: DotNet Version;
        SolutionVersion: Text;
        SolutionInstalled: Boolean;
        SolutionOutdated: Boolean;
        ImportSolution: Boolean;
    begin
        GetTempAdminConnectionSetup(TempAdminCDSConnectionSetup, CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);

        if GetSolutionVersion(TempAdminCDSConnectionSetup, GetBaseSolutionUniqueName(), SolutionVersion) then
            if Version.TryParse(SolutionVersion, Version) then begin
                SolutionInstalled := true;
                SolutionOutdated := Version.CompareTo(NavTenantSettingsHelper.GetPlatformVersion()) < 0;
            end;

        if RenewSolution then
            ImportSolution := (not SolutionInstalled) or SolutionOutdated
        else
            ImportSolution := not SolutionInstalled;

        if ImportSolution then begin
            Session.LogMessage('0000AU4', ImportSolutionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if not ImportDefaultCdsSolution(CrmHelper) then
                ProcessConnectionFailures();
        end;
    end;

    [TryFunction]
    local procedure ImportDefaultCdsSolution(var CRMHelper: DotNet CrmHelper)
    begin
        CrmHelper.ImportDefaultCdsSolution();
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure ConfigureIntegrationSolution(var CDSConnectionSetup: Record "CDS Connection Setup"; var CrmHelper: DotNet CrmHelper; AdminUserName: Text; AdminPassword: Text; AccessToken: Text; AdminADDomain: Text; IsSilent: Boolean)
    begin
        FindOrCreateIntegrationUser(CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken);
        AssignIntegrationRole(CrmHelper, CDSConnectionSetup."User Name");

        // if Authentication Type is Office365 we don't need to set the user as integration user or non-interactive user
        // in this case we have injected a non-licensed application user that is bound to the Azure AD application used to connect to CDS
        if CDSConnectionSetup."Authentication Type" <> CDSConnectionSetup."Authentication Type"::Office365 then begin
            SetUserAsIntegrationUser(CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
            if SetAccessModeToNonInteractive(CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain) then
                if not IsSilent then
                    Message(AccessModeSetToNonInteractiveMsg);
        end;

        SyncCompany(CDSConnectionSetup, AdminUserName, AdminPassword, AccessToken, AdminADDomain);
        AssignPreviousIntegrationUserRoles(CrmHelper, CDSConnectionSetup, AccessToken);

        Session.LogMessage('0000AU5', SolutionConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure JITProvisionFirstPartyApp(var CrmHelper: DotNet CrmHelper)
    var
        CDSConnectionFirstPartyAppIdTxt: Text;
        CDSConnectionFirstPartyAppCertificateTxt: Text;
        JITProvisioningTelemetryMessageTxt: Text;
    begin
        CDSConnectionFirstPartyAppIdTxt := GetCDSConnectionFirstPartyAppId();
        CDSConnectionFirstPartyAppCertificateTxt := GetCDSConnectionFirstPartyAppCertificate();
        if (CDSConnectionFirstPartyAppIdTxt = '') or (CDSConnectionFirstPartyAppCertificateTxt = '') then
            exit;

        JITProvisioningTelemetryMessageTxt := CrmHelper.ProvisionServicePrincipal(CDSConnectionFirstPartyAppIdTxt, CDSConnectionFirstPartyAppCertificateTxt);
        if JITProvisioningTelemetryMessageTxt <> '' then
            if JITProvisioningTelemetryMessageTxt.Contains(SuccessfulJITProvisioningTelemetryMsg) then
                Session.LogMessage('0000ENK', JITProvisioningTelemetryMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                Session.LogMessage('0000F0A', JITProvisioningTelemetryMessageTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [Scope('OnPrem')]
    procedure HasCompanyIdField(TableId: Integer): Boolean
    var
        HasField: Boolean;
    begin
        CDSIntegrationMgt.OnHasCompanyIdField(TableId, HasField);
        exit(HasField);
    end;

    [Scope('OnPrem')]
    procedure CheckCompanyId(var RecRef: RecordRef): Boolean
    begin
        exit(TrySetAndCheckCompany(RecRef, true));
    end;

    [Scope('OnPrem')]
    procedure SetCompanyId(var RecRef: RecordRef): Boolean
    begin
        exit(TrySetAndCheckCompany(RecRef, false));
    end;

    [Scope('OnPrem')]
    procedure CheckCompanyIdNoTelemetry(var RecRef: RecordRef): Boolean
    var
        CompanyIdFldRef: FieldRef;
        ActualCompanyId: Guid;
        SavedCompanyId: Guid;
    begin
        if not FindCompanyIdField(RecRef, CompanyIdFldRef) then
            exit(false);

        ActualCompanyId := GetCachedCompanyId();
        SavedCompanyId := CompanyIdFldRef.Value();

        exit(ActualCompanyId = SavedCompanyId);
    end;

    [TryFunction]
    local procedure TrySetAndCheckCompany(var RecRef: RecordRef; CheckOnly: Boolean)
    var
        CompanyIdFldRef: FieldRef;
        ActualCompanyId: Guid;
        SavedCompanyId: Guid;
        IsCorrectCompany: Boolean;
    begin
        if CheckOnly then
            Session.LogMessage('0000AVL', CheckCompanyIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            Session.LogMessage('0000AVM', SetCompanyIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if not FindCompanyIdField(RecRef, CompanyIdFldRef) then begin
            Session.LogMessage('0000AVN', EntityHasNoCompanyIdFieldTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotFindCompanyIdFieldErr, RecRef.Number(), RecRef.Name());
        end;

        ActualCompanyId := GetCachedCompanyId();
        SavedCompanyId := CompanyIdFldRef.Value();
        IsCorrectCompany := SavedCompanyId = ActualCompanyId;

        if CheckOnly then begin
            if not IsCorrectCompany then begin
                Session.LogMessage('0000AVO', CompanyIdDiffersFromExpectedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(OwnerDiffersFromExpectedErr);
            end;
            Session.LogMessage('0000AVP', CompanyIdCheckedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not IsCorrectCompany then
            CompanyIdFldRef.Value := ActualCompanyId;

        Session.LogMessage('0000AVT', CompanyIdSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [Scope('OnPrem')]
    procedure ResetCompanyId(var RecRef: RecordRef): Boolean
    var
        Changed: Boolean;
    begin
        if TryResetCompanyId(RecRef, Changed) then
            exit(Changed);
        exit(false);
    end;

    [TryFunction]
    local procedure TryResetCompanyId(var RecRef: RecordRef; var Changed: Boolean)
    var
        CRMSalesorder: Record "CRM Salesorder";
        CompanyIdFldRef: FieldRef;
        ActualCompanyId: Guid;
        SavedCompanyId: Guid;
        EmptyCompanyId: Guid;
    begin
        if RecRef.Number() = Database::"CRM Salesorder" then begin
            RecRef.SetTable(CRMSalesorder);
            if TryResetCompanyId(CRMSalesorder, Changed) then
                RecRef.GetTable(CRMSalesorder);
            exit;
        end;

        if not FindCompanyIdField(RecRef, CompanyIdFldRef) then begin
            Session.LogMessage('0000DDK', EntityHasNoCompanyIdFieldTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        ActualCompanyId := GetCachedCompanyId();
        SavedCompanyId := CompanyIdFldRef.Value();
        if SavedCompanyId = ActualCompanyId then begin
            CompanyIdFldRef.Value := EmptyCompanyId;
            Changed := true;
        end;
    end;

    [TryFunction]
    local procedure TryResetCompanyId(var CRMSalesorder: Record "CRM Salesorder"; var Changed: Boolean)
    var
        ActualCompanyId: Guid;
    begin
        ActualCompanyId := GetCachedCompanyId();
        if CRMSalesorder.CompanyId <> ActualCompanyId then
            exit;

        case CRMSalesorder.StateCode of
            CRMSalesorder.StateCode::Submitted:
                begin
                    CRMSalesorder.StateCode := CRMSalesorder.StateCode::Active;
                    CRMSalesorder.Modify(true);
                    Clear(CRMSalesorder.CompanyId);
                    CRMSalesorder.Modify(true);
                    CRMSalesorder.StateCode := CRMSalesorder.StateCode::Submitted;
                    CRMSalesorder.Modify(true);
                    Changed := IsNullGuid(CRMSalesorder.CompanyId);
                end;
            CRMSalesorder.StateCode::Active:
                begin
                    Clear(CRMSalesorder.CompanyId);
                    CRMSalesorder.Modify(true);
                    Changed := IsNullGuid(CRMSalesorder.CompanyId);
                end;
        end;
    end;

    [Scope('OnPrem')]
    procedure CheckOwningTeam(var RecRef: RecordRef): Boolean
    begin
        exit(CheckOwningTeam(RecRef, false));
    end;

    [Scope('OnPrem')]
    procedure CheckOwningTeam(var RecRef: RecordRef; SkipBusinessUnitCheck: Boolean): Boolean
    var
        EmptyGuid: Guid;
    begin
        exit(CheckOwningTeam(RecRef, EmptyGuid, SkipBusinessUnitCheck));
    end;

    [Scope('OnPrem')]
    procedure CheckOwningTeam(var RecRef: RecordRef; TeamId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    var
        TempCDSCompany: Record "CDS Company" temporary;
    begin
        exit(SetAndCheckOwner(RecRef, TempCDSCompany.OwnerIdType::team, TeamId, true, SkipBusinessUnitCheck));
    end;

    [Scope('OnPrem')]
    procedure CheckOwningUser(var RecRef: RecordRef; UserId: Guid): Boolean
    begin
        exit(CheckOwningUser(RecRef, UserId, false));
    end;

    [Scope('OnPrem')]
    procedure CheckOwningUser(var RecRef: RecordRef; UserId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    var
        TempCDSCompany: Record "CDS Company" temporary;
    begin
        exit(SetAndCheckOwner(RecRef, TempCDSCompany.OwnerIdType::systemuser, UserId, true, SkipBusinessUnitCheck));
    end;

    [Scope('OnPrem')]
    procedure SetOwningTeam(var RecRef: RecordRef): Boolean
    var
        EmptyGuid: Guid;
    begin
        exit(SetOwningTeam(RecRef, EmptyGuid, false));
    end;

    [Scope('OnPrem')]
    procedure SetOwningTeam(var RecRef: RecordRef; TeamId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    var
        TempCDSCompany: Record "CDS Company" temporary;
    begin
        exit(SetAndCheckOwner(RecRef, TempCDSCompany.OwnerIdType::team, TeamId, false, SkipBusinessUnitCheck));
    end;

    [Scope('OnPrem')]
    procedure SetOwningUser(var RecRef: RecordRef; UserId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    var
        TempCDSCompany: Record "CDS Company" temporary;
    begin
        exit(SetAndCheckOwner(RecRef, TempCDSCompany.OwnerIdType::systemuser, UserId, false, SkipBusinessUnitCheck));
    end;

    local procedure SetAndCheckOwner(var RecRef: RecordRef; OwnerIdType: Option; OwnerId: Guid; CheckOnly: Boolean; SkipBusinessUnitCheck: Boolean): Boolean
    begin
        exit(TrySetAndCheckOwner(RecRef, OwnerIdType, OwnerId, CheckOnly, SkipBusinessUnitCheck));
    end;

    [TryFunction]
    local procedure TrySetAndCheckOwner(var RecRef: RecordRef; OwnerIdType: Option; OwnerId: Guid; CheckOnly: Boolean; SkipBusinessUnitCheck: Boolean)
    var
        TempCDSCompany: Record "CDS Company" temporary;
        OwnerIdTypeFldRef: FieldRef;
        OwnerIdFldRef: FieldRef;
        SavedOwnerIdType: Option;
        SavedOwnerId: Guid;
        IsCorrectOwner: Boolean;
    begin
        if CheckOnly then
            Session.LogMessage('0000AU6', CheckOwnerTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            Session.LogMessage('0000AU7', SetOwnerTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if IsNullGuid(OwnerId) and (OwnerIdType = TempCDSCompany.OwnerIdType::team) then begin
            Session.LogMessage('0000AU8', SetDefaultOwningTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            OwnerId := GetCachedDefaultOwningTeamId();
        end;

        if not FindOwnerIdField(RecRef, OwnerIdFldRef) then begin
            Session.LogMessage('0000AU9', EntityHasNoOwnerIdFieldTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotFindOwnerIdFieldErr, RecRef.Number(), RecRef.Name());
        end;

        if not FindOwnerTypeField(RecRef, OwnerIdTypeFldRef) then begin
            Session.LogMessage('0000B2L', EntityHasNoOwnerTypeFieldTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CannotFindOwnerTypeFieldErr, RecRef.Number(), RecRef.Name());
        end;

        SavedOwnerIdType := OwnerIdTypeFldRef.Value();
        SavedOwnerId := OwnerIdFldRef.Value();
        IsCorrectOwner := (SavedOwnerIdType = OwnerIdType) and (SavedOwnerId = OwnerId);

        if CheckOnly then
            if not IsCorrectOwner then begin
                Session.LogMessage('0000AUA', OwnerDiffersFromExpectedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(OwnerDiffersFromExpectedErr);
            end;

        case OwnerIdType of
            TempCDSCompany.OwnerIdType::team:
                CheckOwningTeam(OwnerId, SkipBusinessUnitCheck);
            TempCDSCompany.OwnerIdType::systemuser:
                CheckOwningUser(OwnerId, SkipBusinessUnitCheck);
            else begin
                    Session.LogMessage('0000AUC', UnsupportedOwnerTypeTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    Error(OwnerIdTypeErr);
                end;
        end;

        if CheckOnly then begin
            Session.LogMessage('0000AUB', OwnerCheckedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not IsCorrectOwner then begin
            OwnerIdTypeFldRef.Value := OwnerIdType;
            OwnerIdFldRef.Value := OwnerId;
        end;

        Session.LogMessage('0000AUG', OwnerSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure CheckOwningTeam(TeamId: Guid; SkipBusinessUnitCheck: Boolean)
    var
        OwningCRMTeam: Record "CRM Team";
    begin
        if TeamId = GetCachedDefaultOwningTeamId() then
            exit;
        if GetCachedOwningTeamCheck(TeamId, SkipBusinessUnitCheck) then
            exit;
        if not OwningCRMTeam.Get(TeamId) then begin
            Session.LogMessage('0000AUH', TeamNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(TeamNotFoundErr, TeamId);
        end;
        CheckTeamHasIntegrationRole(OwningCRMTeam);
        if not SkipBusinessUnitCheck then
            If OwningCRMTeam.BusinessUnitId <> GetCachedOwningBusinessUnitId() then begin
                Session.LogMessage('0000AUI', TeamBusinessUnitDiffersFromSelectedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(TeamBusinessUnitDiffersFromSelectedErr);
            end;
        SetCachedOwningTeamCheck(TeamId, SkipBusinessUnitCheck);
    end;

    local procedure CheckOwningUser(UserId: Guid; SkipBusinessUnitCheck: Boolean)
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        if GetCachedOwningUserCheck(UserId, SkipBusinessUnitCheck) then
            exit;
        if not CRMSystemuser.Get(UserId) then begin
            Session.LogMessage('0000AUJ', UserNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(UserNotFoundErr, UserId);
        end;
        if not SkipBusinessUnitCheck then
            If CRMSystemuser.BusinessUnitId <> GetCachedOwningBusinessUnitId() then begin
                Session.LogMessage('0000AUL', UserBusinessUnitDiffersFromSelectedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(UserBusinessUnitDiffersFromSelectedErr);
            end;
        SetCachedOwningUserCheck(UserId, SkipBusinessUnitCheck);
    end;

    local procedure CheckTeamHasIntegrationRole(var CRMTeam: Record "CRM Team")
    var
        CRMRole: Record "CRM Role";
        CDSTeamroles: Record "CDS Teamroles";
    begin
        CRMRole.SetRange(BusinessUnitId, CRMTeam.BusinessUnitId);
        CRMRole.SetRange(ParentRoleId, GetIntegrationRoleId());
        if not CRMRole.FindFirst() then begin
            Session.LogMessage('0000AUM', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(IntegrationRoleNotFoundErr, GetIntegrationRoleName(), GetBusinessUnitName(CRMTeam.BusinessUnitId));
        end;
        CDSTeamroles.SetRange(TeamId, CRMTeam.TeamId);
        CDSTeamroles.SetRange(RoleId, CRMRole.RoleId);
        if CDSTeamroles.IsEmpty() then begin
            Session.LogMessage('0000AUN', IntegrationRoleNotAssignedToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(TeamRolesErr, CRMTeam.Name, GetBusinessUnitName(CRMTeam.BusinessUnitId), GetIntegrationRoleName());
        end;
    end;

    local procedure GetBusinessUnitName(BusinesUnitId: Guid) BusinessunitName: Text
    var
        CRMBusinessUnit: Record "CRM Businessunit";
    begin
        if CRMBusinessunit.Get(BusinesUnitId) then
            BusinessunitName := CRMBusinessunit.Name
        else
            BusinessunitName := Format(BusinesUnitId);
    end;

    local procedure GetIntegrationRoleName() IntegrationRoleName: Text
    var
        CRMRole: Record "CRM Role";
    begin
        if CRMRole.Get(GetIntegrationRoleId()) then
            IntegrationRoleName := CRMRole.Name
        else
            IntegrationRoleName := Format(GetIntegrationRoleId());
    end;

    internal procedure FindCompanyIdField(var RecRef: RecordRef; var CompanyIdFldRef: FieldRef): Boolean
    var
        Field: Record "Field";
        TableNo: Integer;
        FieldNo: Integer;
    begin
        TableNo := RecRef.Number();
        if CachedCompanyIdFieldNo.ContainsKey(TableNo) then
            FieldNo := CachedCompanyIdFieldNo.Get(TableNo)
        else begin
            Field.SetRange(TableNo, TableNo);
            Field.SetRange(Type, Field.Type::GUID);
            Field.SetRange(FieldName, 'CompanyId');
            if Field.FindFirst() then
                FieldNo := Field."No."
            else
                FieldNo := 0;
            CachedCompanyIdFieldNo.Add(TableNo, FieldNo);
        end;
        if FieldNo = 0 then
            exit(false);
        CompanyIdFldRef := RecRef.Field(FieldNo);
        exit(true);
    end;

    local procedure FindOwnerIdField(var RecRef: RecordRef; var OwnerIdFldRef: FieldRef): Boolean
    var
        Field: Record "Field";
        TableNo: Integer;
        FieldNo: Integer;
    begin
        TableNo := RecRef.Number();
        if CachedOwnerIdFieldNo.ContainsKey(TableNo) then
            FieldNo := CachedOwnerIdFieldNo.Get(TableNo)
        else begin
            Field.SetRange(TableNo, TableNo);
            Field.SetRange(Type, Field.Type::GUID);
            Field.SetRange(FieldName, 'OwnerId');
            if Field.FindFirst() then
                FieldNo := Field."No."
            else
                FieldNo := 0;
            CachedOwnerIdFieldNo.Add(TableNo, FieldNo);
        end;
        if FieldNo = 0 then
            exit(false);
        OwnerIdFldRef := RecRef.Field(FieldNo);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure FindOwnerTypeField(var RecRef: RecordRef; var OwnerIdTypeFldRef: FieldRef): Boolean
    var
        Field: Record "Field";
        TableNo: Integer;
        FieldNo: Integer;
    begin
        TableNo := RecRef.Number();

        if CachedOwnerTypeFieldNo.ContainsKey(TableNo) then
            FieldNo := CachedOwnerTypeFieldNo.Get(TableNo)
        else begin
            Field.SetRange(TableNo, TableNo);
            Field.SetRange(Type, Field.Type::Option);
            Field.SetRange(FieldName, 'OwnerIdType');
            Field.SetRange(OptionString, ' ,systemuser,team');
            if Field.FindFirst() then
                FieldNo := Field."No."
            else
                FieldNo := 0;
            CachedOwnerTypeFieldNo.Add(TableNo, FieldNo);
        end;
        if FieldNo = 0 then
            exit(false);
        OwnerIdTypeFldRef := RecRef.Field(FieldNo);
        exit(true);
    end;

    local procedure GetCachedOwningTeamCheck(TeamId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    begin
        if SkipBusinessUnitCheck then begin
            if CachedOwningTeamCheckWithoutBusinessUnit.ContainsKey(TeamId) then
                exit(true);
        end else
            if CachedOwningTeamCheckWithBusinessUnit.ContainsKey(TeamId) then
                exit(true);
        exit(false);
    end;

    local procedure SetCachedOwningTeamCheck(TeamId: Guid; SkipBusinessUnitCheck: Boolean)
    begin
        Session.LogMessage('0000B2M', StrSubstNo(SetCachedOwningTeamCheckTxt, TeamId, SkipBusinessUnitCheck), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        if SkipBusinessUnitCheck then begin
            if not CachedOwningTeamCheckWithoutBusinessUnit.ContainsKey(TeamId) then
                CachedOwningTeamCheckWithoutBusinessUnit.Add(TeamId, true);
        end else
            if not CachedOwningTeamCheckWithBusinessUnit.ContainsKey(TeamId) then
                CachedOwningTeamCheckWithBusinessUnit.Add(TeamId, true);
    end;

    local procedure GetCachedOwningUserCheck(UserId: Guid; SkipBusinessUnitCheck: Boolean): Boolean
    begin
        if SkipBusinessUnitCheck then begin
            if CachedOwningUserCheckWithoutBusinessUnit.ContainsKey(UserId) then
                exit(true);
        end else
            if CachedOwningUserCheckWithBusinessUnit.ContainsKey(UserId) then
                exit(true);
        exit(false);
    end;

    local procedure SetCachedOwningUserCheck(UserId: Guid; SkipBusinessUnitCheck: Boolean)
    begin
        Session.LogMessage('0000B2N', StrSubstNo(SetCachedOwningUserCheckTxt, UserId, SkipBusinessUnitCheck), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        if SkipBusinessUnitCheck then begin
            if not CachedOwningUserCheckWithoutBusinessUnit.ContainsKey(UserId) then
                CachedOwningUserCheckWithoutBusinessUnit.Add(UserId, true);
        end else
            if not CachedOwningUserCheckWithBusinessUnit.ContainsKey(UserId) then
                CachedOwningUserCheckWithBusinessUnit.Add(UserId, true);
    end;

    local procedure GetCachedCompanyId(): Guid
    begin
        InitializeCompanyCache();
        exit(CachedCompanyId);
    end;

    local procedure GetCachedDefaultOwningTeamId(): Guid
    begin
        InitializeCompanyCache();
        exit(CachedDefaultOwningTeamId);
    end;

    local procedure GetCachedOwningBusinessUnitId(): Guid
    begin
        InitializeCompanyCache();
        exit(CachedOwningBusinessUnitId);
    end;

    local procedure InitializeCompanyCache()
    var
        CDSCompany: Record "CDS Company";
        CRMTeam: Record "CRM Team";
    begin
        if AreCompanyValuesCached then
            exit;

        Session.LogMessage('0000B2O', InitializeCompanyCacheTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        CDSCompany.SetRange(ExternalId, GetCompanyExternalId());
        if not CDSCompany.FindFirst() then begin
            Session.LogMessage('0000B2P', CompanyNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CompanyNotFoundErr, GetCompanyExternalId());
        end;

        if not CRMTeam.Get(CDSCompany.DefaultOwningTeam) then begin
            Session.LogMessage('0000B2Q', TeamNotFoundTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(TeamNotFoundErr, CDSCompany.DefaultOwningTeam);
        end;

        CachedCompanyId := CDSCompany.CompanyId;
        CachedDefaultOwningTeamId := CDSCompany.DefaultOwningTeam;
        CachedOwningBusinessUnitId := CRMTeam.BusinessUnitId;
        AreCompanyValuesCached := true;
    end;

    [Scope('OnPrem')]
    procedure ResetCache()
    begin
        Session.LogMessage('0000B2R', ClearCacheTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Clear(AreCompanyValuesCached);
        Clear(CachedCompanyId);
        Clear(CachedDefaultOwningTeamId);
        Clear(CachedOwningBusinessUnitId);
        Clear(CachedOwningTeamCheckWithoutBusinessUnit);
        Clear(CachedOwningTeamCheckWithBusinessUnit);
        Clear(CachedOwningUserCheckWithoutBusinessUnit);
        Clear(CachedOwningUserCheckWithBusinessUnit);
    end;

    [Scope('OnPrem')]
    procedure GetIntegrationSolutions(var SolutionUniqueNameList: List of [Text])
    begin
        CDSIntegrationMgt.OnGetIntegrationSolutions(SolutionUniqueNameList);
        SolutionUniqueNameList.Insert(1, GetBaseSolutionUniqueName())
    end;

    [Scope('OnPrem')]
    procedure GetIntegrationRequiredRoles(var RequiredRoleIdList: List of [Guid])
    begin
        CDSIntegrationMgt.OnGetIntegrationRequiredRoles(RequiredRoleIdList);
        RequiredRoleIdList.Insert(1, GetIntegrationRoleId());
    end;

    [Scope('OnPrem')]
    procedure CheckModifyConnectionURL(var ServerAddress: Text[250])
    var
        UriHelper: DotNet Uri;
        UriHelper2: DotNet Uri;
        UriKindHelper: DotNet UriKind;
        UriPartialHelper: DotNet UriPartial;
        ProposedUri: Text[250];
    begin
        if (ServerAddress = '') or (ServerAddress = TestServerAddressTok) then
            exit;

        ServerAddress := DelChr(ServerAddress, '<>');

        if not UriHelper.TryCreate(ServerAddress, UriKindHelper.Absolute, UriHelper2) then
            if not UriHelper.TryCreate('https://' + ServerAddress, UriKindHelper.Absolute, UriHelper2) then
                Error(InvalidUriErr);

        if UriHelper2.Scheme() <> 'https' then
            Error(MustUseHttpsErr);

        ProposedUri := UriHelper2.GetLeftPart(UriPartialHelper.Authority);

        // Test that a specific port number is given
        if ((UriHelper2.Port() = 443) or (UriHelper2.Port() = 80)) and (LowerCase(ServerAddress) <> LowerCase(ProposedUri)) then
            if Confirm(StrSubstNo(ReplaceServerAddressQst, ServerAddress, ProposedUri)) then
                ServerAddress := ProposedUri;
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InitializeConnection(var CrmHelper: DotNet CrmHelper): Boolean
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AUO', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        exit(InitializeConnection(CrmHelper, CDSConnectionSetup));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InitializeConnection(var CrmHelper: DotNet CrmHelper;

    var
        CDSConnectionSetup: Record "CDS Connection Setup"): Boolean
    begin
        exit(InitializeConnection(CrmHelper, GetConnectionStringWithCredentials(CDSConnectionSetup)));
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure InitializeConnection(var CrmHelper: DotNet CrmHelper; ConnectionString: Text)
    begin
        CrmHelper := CrmHelper.CrmHelper(ConnectionString);
    end;

    local procedure ProcessConnectionFailures()
    var
        DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
        FaultException: DotNet FaultException;
        FileNotFoundException: DotNet FileNotFoundException;
        ArgumentNullException: DotNet ArgumentNullException;
        CrmHelper: DotNet CrmHelper;
        ErrorMessage: Text;
    begin
        DotNetExceptionHandler.Collect();

        if DotNetExceptionHandler.TryCastToType(GetDotNetType(FaultException)) then begin
            Session.LogMessage('0000AUP', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(GeneralFailureErr);
        end;
        if DotNetExceptionHandler.TryCastToType(GetDotNetType(FileNotFoundException)) then begin
            Session.LogMessage('0000AUQ', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(SolutionFileNotFoundErr);
        end;
        if DotNetExceptionHandler.TryCastToType(CrmHelper.OrganizationServiceFaultExceptionType()) then begin
            Session.LogMessage('0000AUR', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(OrganizationServiceFailureErr);
        end;
        if DotNetExceptionHandler.TryCastToType(CrmHelper.SystemNetWebException()) then begin
            Session.LogMessage('0000AUS', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(CDSConnectionURLWrongErr);
        end;
        if DotNetExceptionHandler.CastToType(ArgumentNullException, GetDotNetType(ArgumentNullException)) then
            case ArgumentNullException.ParamName() of
                'cred':
                    begin
                        Session.LogMessage('0000AUT', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        Error(AdminUserPasswordWrongErr);
                    end;
                'Organization Name':
                    begin
                        Session.LogMessage('0000AUU', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        Error(CDSConnectionURLWrongErr);
                    end;
            end;

        ErrorMessage := DotNetExceptionHandler.GetMessage();
        if ErrorMessage <> '' then
            if ErrorMessage.ToLower().Contains(TimeoutTxt) then begin
                Session.LogMessage('0000EJ6', ConnectionFailureTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(RetryAfterTimeoutErr, ErrorMessage);
            end;

        DotNetExceptionHandler.Rethrow();
    end;

    local procedure GetSystemAdminRoleTemplateId(): Guid
    begin
        exit(TextToGuid(SystemAdminRoleTemplateIdTxt));
    end;

    local procedure GetSystemCustomizerRoleTemplateId(): Guid
    begin
        exit(TextToGuid(SystemCustomizerRoleTemplateIdTxt));
    end;

    local procedure GetIntegrationRoleId(): Guid
    begin
        exit(TextToGuid(IntegrationRoleIdTxt));
    end;

    local procedure GetErrorNotificationId(): Guid
    begin
        exit(TextToGuid(ErrorNotificationIdTxt));
    end;

    local procedure GetConnectionDisabledNotificationId(): Guid
    begin
        exit(TextToGuid(ConnectionDisabledNotificationIdTxt));
    end;

    local procedure TextToGuid(TextVar: Text): Guid
    var
        GuidVar: Guid;
    begin
        if not Evaluate(GuidVar, TextVar) then;
        exit(GuidVar);
    end;

    [Scope('OnPrem')]
    procedure SendConnectionDisabledNotification(DisableReason: Text[250])
    var
        Notification: Notification;
    begin
        Notification.Id := GetConnectionDisabledNotificationId();
        Notification.Message := StrSubstNo(ConnectionDisabledNotificationMsg, DisableReason);
        Notification.Scope := NOTIFICATIONSCOPE::LocalScope;
        Notification.Send();
    end;

    local procedure ShowError(ActivityDescription: Text[128]; ErrorMessage: Text)
    var
        MyNotifications: Record "My Notifications";
        SystemInitialization: Codeunit "System Initialization";
    begin
        if (not SystemInitialization.IsInProgress()) and (GetExecutionContext() = ExecutionContext::Normal) then
            Error(ErrorMessage);

        MyNotifications.InsertDefault(GetErrorNotificationId(), ActivityDescription, ErrorMessage, true);
    end;

    [Scope('OnPrem')]
    procedure InsertBusinessUnitCoupling(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        Company: Record Company;
        CDSCoupledBusinessUnit: Record "CDS Coupled Business Unit";
    begin
        if IsNullGuid(CDSConnectionSetup."Business Unit Id") then
            exit;

        if not Company.Get(CompanyName()) then
            exit;

        CDSCoupledBusinessUnit.Validate("Company Id", Company.SystemId);
        CDSCoupledBusinessUnit.Validate("Business Unit Id", CDSConnectionSetup."Business Unit Id");
        CDSCoupledBusinessUnit.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure ModifyBusinessUnitCoupling(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        Company: Record Company;
        CDSCoupledBusinessUnit: Record "CDS Coupled Business Unit";
    begin
        if not Company.Get(CompanyName()) then
            exit;

        CDSCoupledBusinessUnit.SetRange("Company Id", Company.SystemId);
        CDSCoupledBusinessUnit.DeleteAll(true);

        if IsNullGuid(CDSConnectionSetup."Business Unit Id") then
            exit;

        CDSCoupledBusinessUnit.Init();
        CDSCoupledBusinessUnit.Validate("Company Id", Company.SystemId);
        CDSCoupledBusinessUnit.Validate("Business Unit Id", CDSConnectionSetup."Business Unit Id");
        CDSCoupledBusinessUnit.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure DeleteBusinessUnitCoupling(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        Company: Record Company;
        CDSCoupledBusinessUnit: Record "CDS Coupled Business Unit";
    begin
        if not Company.Get(CompanyName()) then
            exit;

        CDSCoupledBusinessUnit.SetRange("Company Id", Company.SystemId);
        CDSCoupledBusinessUnit.SetRange("Business Unit Id", CDSConnectionSetup."Business Unit Id");
        CDSCoupledBusinessUnit.DeleteAll(true);
    end;

    [Scope('OnPrem')]
    procedure TestConnection(var CDSConnectionSetup: Record "CDS Connection Setup"): Boolean
    begin
        if TryTestConnection(CDSConnectionSetup) then
            exit(true);

        exit(TryCheckCredentials(CDSConnectionSetup));
    end;

    [TryFunction]
    local procedure TryTestConnection(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMSystemuser: Record "CRM Systemuser";
        TempConnectionName: Text;
        Id: Guid;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);

        TempConnectionName := GetTempConnectionName();
        RegisterConnection(CDSConnectionSetup, TempConnectionName);
        SetDefaultTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName, true);

        if CRMSystemuser.FindFirst() then
            Id := CRMSystemuser.SystemUserId;

        UnregisterTableConnection(TABLECONNECTIONTYPE::CRM, TempConnectionName);
    end;

    [Scope('OnPrem')]
    [TryFunction]
    procedure TryCheckCredentials(var CDSConnectionSetup: Record "CDS Connection Setup")
    begin
        CheckCredentials(CDSConnectionSetup);
    end;

    [Scope('OnPrem')]
    procedure CheckCredentials(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CrmHelper: DotNet CrmHelper;
    begin
        CheckConnectionRequiredFields(CDSConnectionSetup, false);
        if (CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::Office365) or (CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::AD) then
            exit;

        if not InitializeConnection(CrmHelper, CDSConnectionSetup) then begin
            Session.LogMessage('0000BO2', ConnectionNotRegisteredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ProcessConnectionFailures();
        end;
        if not CheckCredentials(CrmHelper) then begin
            Session.LogMessage('0000BO3', InvalidUserCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(IntegrationUserPasswordWrongErr);
        end;
    end;

    [TryFunction]
    local procedure CheckCredentials(var CrmHelper: DotNet CrmHelper)
    begin
        CrmHelper.CheckCredentials();
    end;

    [Scope('OnPrem')]
    [TryFunction]
    procedure GetCDSVersion(var CDSConnectionSetup: Record "CDS Connection Setup"; var CDSVersion: Text)
    var
        CrmHelper: DotNet CrmHelper;
    begin
        if InitializeConnection(CrmHelper, CDSConnectionSetup) then
            CDSVersion := CrmHelper.GetConnectedCrmVersion()
    end;

    [Scope('OnPrem')]
    procedure InitializeProxyVersionList(var TempStack: Record TempStack temporary)
    var
        CrmHelper: DotNet CrmHelper;
        IList: DotNet GenericList1;
        i: Integer;
        ProxyCount: Integer;
    begin
        IList := CrmHelper.GetProxyIdList();
        ProxyCount := IList.Count();
        for i := 0 to ProxyCount - 1 do begin
            TempStack.StackOrder := IList.Item(i);
            TempStack.Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure GetLastProxyVersionItem(): Integer
    var
        TempStack: Record TempStack temporary;
    begin
        InitializeProxyVersionList(TempStack);
        TempStack.FindLast();
        exit(TempStack.StackOrder);
    end;

    [Scope('OnPrem')]
    procedure ClearConnectionDisableReason(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        Notification: Notification;
    begin
        if CDSConnectionSetup."Disable Reason" = '' then
            exit;
        Session.LogMessage('0000AUV', ClearDisabledReasonTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Notification.Id := GetConnectionDisabledNotificationId();
        Notification.Recall();
        Clear(CDSConnectionSetup."Disable Reason");
        CDSConnectionSetup.Modify();
    end;

    local procedure DisableConnection()
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        LastError: Text;
    begin
        Session.LogMessage('0000AUW', DisableIntegrationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        LastError := GetLastErrorText();
        LastError := CopyStr(LastError, StrPos(Format(LastError), ':') + 1, StrLen(LastError));
        Message(StrSubstNo(ConnectionBrokenMsg, LastError));
        if not CDSConnectionSetup.Get() then begin
            Session.LogMessage('0000AUX', IntegrationNotConfiguredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;
        CDSConnectionSetup.Validate("Is Enabled", false);
        CDSConnectionSetup.Validate(
          "Disable Reason",
          CopyStr(LastError, 1, MaxStrLen(CDSConnectionSetup."Disable Reason")));
        CDSConnectionSetup.Modify();

        Session.LogMessage('0000AUY', IntegrationDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [Scope('OnPrem')]
    procedure UpdateDomainName(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        UserName: Text;
    begin
        UserName := CDSConnectionSetup."User Name";
        if UserName <> '' then
            if StrPos(UserName, '\') > 0 then
                CDSConnectionSetup.Validate(Domain, CopyStr(UserName, 1, StrPos(UserName, '\') - 1))
            else
                CDSConnectionSetup.Domain := '';
    end;

    [Scope('OnPrem')]
    procedure CheckUserName(var CDSConnectionSetup: Record "CDS Connection Setup")
    var
        UserName: Text;
    begin
        UserName := CDSConnectionSetup."User Name";
        if UserName <> '' then
            case CDSConnectionSetup."Authentication Type" of
                CDSConnectionSetup."Authentication Type"::AD:
                    if StrPos(UserName, '\') = 0 then
                        Error(UserNameMustIncludeDomainErr);
                CDSConnectionSetup."Authentication Type"::Office365:
                    if StrPos(UserName, '@') = 0 then
                        Error(UserNameMustBeEmailErr);
            end;
    end;

    local procedure GetDomainToken(var CDSConnectionSetup: Record "CDS Connection Setup"): Text
    begin
        if CDSConnectionSetup.Domain <> '' then
            exit(StrSubstNo('Domain=%1;', CDSConnectionSetup.Domain));
    end;

    [Scope('OnPrem')]
    procedure GetAuthenticationTypeToken(var CDSConnectionSetup: Record "CDS Connection Setup"): Text
    begin
        exit(GetAuthenticationTypeToken(CDSConnectionSetup, ''));
    end;

    [Scope('OnPrem')]
    procedure GetAuthenticationTypeToken(var CDSConnectionSetup: Record "CDS Connection Setup"; Domain: Text): Text
    begin
        case CDSConnectionSetup."Authentication Type" of
            CDSConnectionSetup."Authentication Type"::Office365:
                exit('AuthType=Office365;');
            CDSConnectionSetup."Authentication Type"::AD:
                if Domain = '' then
                    exit('AuthType=AD;' + GetDomainToken(CDSConnectionSetup))
                else
                    exit('AuthType=AD; Domain=' + Domain + ';');
            CDSConnectionSetup."Authentication Type"::IFD:
                exit('AuthType=IFD;' + GetDomainToken(CDSConnectionSetup) + 'HomeRealmUri= ;');
            CDSConnectionSetup."Authentication Type"::OAuth:
                exit('AuthType=OAuth;' + 'AppId= ;' + 'RedirectUri= ;' + 'TokenCacheStorePath= ;' + 'LoginPrompt=Auto;');
        end;
    end;

    [Scope('OnPrem')]
    procedure IsCDSVersionValid(CDSVersion: Text): Boolean
    var
        Version: DotNet Version;
    begin
        if CDSVersion <> '' then
            if Version.TryParse(CDSVersion, Version) then
                exit((Version.Major() > 6) and not ((Version.Major() = 7) and (Version.Minor() = 1)));
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure IsSolutionVersionValid(SolutionVersion: Text): Boolean
    var
        Version: DotNet Version;
    begin
        if SolutionVersion <> '' then
            if Version.TryParse(SolutionVersion, Version) then
                exit(Version.Major() >= 1);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure UpdateConnectionSetupFromWizard(var SourceCDSConnectionSetup: Record "CDS Connection Setup"; PasswordText: Text)
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        Session.LogMessage('0000AUZ', UpdateSetupTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if not CDSConnectionSetup.Get() then begin
            CDSConnectionSetup.Init();
            CDSConnectionSetup.Insert();
        end;
        CDSConnectionSetup.Validate("Server Address", SourceCDSConnectionSetup."Server Address");
        CDSConnectionSetup.Validate("Authentication Type", SourceCDSConnectionSetup."Authentication Type");
        CDSConnectionSetup.Validate("User Name", SourceCDSConnectionSetup."User Name");
        CDSConnectionSetup.SetPassword(PasswordText);
        if not EnvironmentInfo.IsSaaSInfrastructure() then begin
            CDSConnectionSetup.Validate("Client Id", SourceCDSConnectionSetup."Client Id");
            CDSConnectionSetup.SetClientSecret(SourceCDSConnectionSetup.GetClientSecret());
            CDSConnectionSetup.Validate("Redirect URL", SourceCDSConnectionSetup."Redirect URL");
        end;
        CDSConnectionSetup.Validate("Proxy Version", SourceCDSConnectionSetup."Proxy Version");
        CDSConnectionSetup.Validate("Business Unit Id", SourceCDSConnectionSetup."Business Unit Id");
        CDSConnectionSetup.Validate("Business Unit Name", SourceCDSConnectionSetup."Business Unit Name");
        CDSConnectionSetup.Validate("Is Enabled", SourceCDSConnectionSetup."Is Enabled");
        CDSConnectionSetup.Validate(CurrencyDecimalPrecision, SourceCDSConnectionSetup.CurrencyDecimalPrecision);
        CDSConnectionSetup.Validate(BaseCurrencyId, SourceCDSConnectionSetup.BaseCurrencyId);
        CDSConnectionSetup.Validate(BaseCurrencyPrecision, SourceCDSConnectionSetup.BaseCurrencyPrecision);
        CDSConnectionSetup.Validate(BaseCurrencySymbol, SourceCDSConnectionSetup.BaseCurrencySymbol);
        if SourceCDSConnectionSetup."Ownership Model" in [CDSConnectionSetup."Ownership Model"::Person, CDSConnectionSetup."Ownership Model"::Team] then
            CDSConnectionSetup.Validate("Ownership Model", SourceCDSConnectionSetup."Ownership Model")
        else
            CDSConnectionSetup.Validate("Ownership Model", CDSConnectionSetup."Ownership Model"::Team);
        SetConnectionString(CDSConnectionSetup, SourceCDSConnectionSetup."Connection String");

        Session.LogMessage('0000AV0', SetupUpdatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure PromptForAdminCredentials(var CDSConnectionSetup: Record "CDS Connection Setup"; var AdminUser: Text; var AdminPassword: Text; var AdminADDomain: Text): Boolean
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
        BackslashPos: Integer;
    begin
        TempOfficeAdminCredentials.Endpoint := CDSConnectionSetup."Server Address";
        TempOfficeAdminCredentials.Insert();
        Commit();
        if Page.RunModal(Page::"Dynamics CRM Admin Credentials", TempOfficeAdminCredentials) <> Action::LookupOK then begin
            Session.LogMessage('0000AV1', IgnoredAdminCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if (TempOfficeAdminCredentials.Email = '') or (TempOfficeAdminCredentials.Password = '') then begin
            Session.LogMessage('0000AV2', InvalidAdminCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::AD then begin
            BackslashPos := StrPos(TempOfficeAdminCredentials.Email, '\');
            if (BackslashPos <= 1) or (BackslashPos = StrLen(TempOfficeAdminCredentials.Email)) then
                Error(UserNameMustIncludeDomainErr);
            AdminADDomain := CopyStr(TempOfficeAdminCredentials.Email, 1, BackslashPos - 1);
            AdminUser := CopyStr(TempOfficeAdminCredentials.Email, BackslashPos + 1);
            AdminPassword := TempOfficeAdminCredentials.Password;
            exit(true);
        end;
        AdminUser := TempOfficeAdminCredentials.Email;
        AdminPassword := TempOfficeAdminCredentials.Password;
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetTempConnectionName(): Text
    begin
        if TemporaryConnectionName = '' then
            TemporaryConnectionName := StrSubstNo('%1%2', TemporaryConnectionPrefixTok, CreateGuid());
        exit(TemporaryConnectionName);
    end;

    [Scope('OnPrem')]
    procedure GetDefaultBusinessUnitName(): Text[160]
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        exit(GetDefaultBusinessUnitName(Company.Name, GetCompanyExternalId(Company)));
    end;

    local procedure GetDefaultBusinessUnitName(CompanyName: Text; CompanyId: Text) BusinessUnitName: Text[160]
    begin
        BusinessUnitName := CopyStr(StrSubstNo(BusinessUnitNameTemplateTok, CompanyName, CompanyId), 1, MaxStrLen(BusinessUnitName));
    end;

    local procedure GetOwningTeamName(BusinessUnitName: Text) TeamName: Text[160]
    begin
        TeamName := CopyStr(StrSubstNo(TeamNameTemplateTok, BusinessUnitName), 1, MaxStrLen(TeamName));
    end;

    [Scope('OnPrem')]
    procedure GetCompanyExternalId() ExternalId: Text[36]
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        ExternalId := GetCompanyExternalId(Company);
    end;

    local procedure GetCompanyExternalId(Company: Record Company) ExternalId: Text[36]
    begin
        ExternalId := CopyStr(Format(Company.SystemId).ToLower().Replace('{', '').Replace('}', ''), 1, MaxStrLen(ExternalId));
    end;

    [Scope('OnPrem')]
    procedure ShowIntegrationUser(CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        IntegrationUserId: Guid;
    begin
        IntegrationUserId := GetIntegrationUserId(CDSConnectionSetup);
        Hyperlink(CRMIntegrationManagement.GetCRMEntityUrlFromCRMID(Database::"CRM Systemuser", IntegrationUserId));
    end;

    [Scope('OnPrem')]
    procedure ShowOwningTeam(CDSConnectionSetup: Record "CDS Connection Setup")
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        OwningTeamId: Guid;
    begin
        OwningTeamId := GetOwningTeamId(CDSConnectionSetup);
        Hyperlink(CRMIntegrationManagement.GetCRMEntityUrlFromCRMID(Database::"CRM Team", OwningTeamId));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure HandleOnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        RecRef: RecordRef;
    begin
        if not CDSConnectionSetup.Get() then begin
            if not CDSConnectionSetup.WritePermission() then begin
                Session.LogMessage('0000AV4', NoPermissionsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;
            CDSConnectionSetup.Init();
            CDSConnectionSetup.Insert();
        end;

        RecRef.GetTable(CDSConnectionSetup);
        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        if not CDSConnectionSetup."Is Enabled" then
            ServiceConnection.Status := ServiceConnection.Status::Disabled
        else
            if TryCheckEntitiesAvailability(CDSConnectionSetup) then
                ServiceConnection.Status := ServiceConnection.Status::Connected
            else
                ServiceConnection.Status := ServiceConnection.Status::Error;
        ServiceConnection.InsertServiceConnectionExtended(
          ServiceConnection, RecRef.RecordId(),
          CDSConnectionSetup.TableCaption(), CDSConnectionSetup."Server Address",
          PAGE::"CDS Connection Setup", PAGE::"CDS Connection Setup Wizard");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDS Integration Mgt.", 'OnEnableIntegration', '', true, true)]
    local procedure HandleOnEnableIntegration()
    begin
        Session.LogMessage('0000AV5', OnEnableIntegrationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDS Integration Mgt.", 'OnDisableIntegration', '', true, true)]
    local procedure HandleOnDisableIntegration()
    begin
        Session.LogMessage('0000AV6', OnDisableIntegrationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Synch. Job Errors", 'OnIsDataIntegrationEnabled', '', false, false)]
    local procedure IsDataIntegrationEnabled(var IsIntegrationEnabled: Boolean)
    begin
        if not IsIntegrationEnabled then
            IsIntegrationEnabled := CDSIntegrationMgt.IsIntegrationEnabled();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCDSConnectionClientId(var ClientId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCDSConnectionClientSecret(var ClientSecret: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIntegrationEnabled()
    begin
    end;
}