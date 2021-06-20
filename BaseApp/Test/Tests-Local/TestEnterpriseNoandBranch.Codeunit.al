codeunit 144025 "Test Enterprise No and Branch"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Enterprise No]
    end;

    var
        LibraryBEHelper: Codeunit "Library - BE Helper";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryXMLRead: Codeunit "Library - XML Read";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        BillToNameMustHaveValueErr: Label 'Bill-to Name must have a value';

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoMustBe10Digits()
    var
        CompanyInformation: Record "Company Information";
    begin
        Initialize;

        CompanyInformation.Init;
        CompanyInformation.FindFirst;
        asserterror CompanyInformation.Validate("Enterprise No.", '200.068.636');
        CompanyInformation.Validate("Enterprise No.", '0200.068.636');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoIsResetWhenEnterpriseNoIsSet()
    var
        CompanyInformation: Record "Company Information";
    begin
        Initialize;

        CompanyInformation.Init;
        CompanyInformation.FindFirst;
        CompanyInformation.Validate("Enterprise No.", '');
        CompanyInformation."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('BE');

        Assert.AreNotEqual('', CompanyInformation."VAT Registration No.", '');
        CompanyInformation.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.AreEqual('', CompanyInformation."VAT Registration No.", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotSetNonMod7NumberAsEnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
    begin
        Initialize;

        CompanyInformation.Init;
        CompanyInformation.FindFirst;

        asserterror CompanyInformation.Validate("Enterprise No.", '0123456789');
        Assert.ExpectedError('Enterprise');

        asserterror CompanyInformation.Validate("Enterprise No.", 'SampleEnNo');
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldBeSetOnBelgianCustomer()
    var
        Customer: Record Customer;
        EnterpriseNo: Code[20];
    begin
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", 'BE');
        Customer.Modify;

        asserterror Customer.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('BE'));
        Assert.ExpectedError('Enterprise');

        EnterpriseNo := LibraryBEHelper.CreateEnterpriseNo;
        Customer.Validate("Enterprise No.", EnterpriseNo);

        Assert.AreEqual(EnterpriseNo, Customer."Enterprise No.", 'Enterprise number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoIsResetWhenEnterpriseNoIsSetOnBelgianCustomer()
    var
        Customer: Record Customer;
    begin
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", 'BE');
        Customer.Modify;

        Customer.Validate("Enterprise No.", '');
        Customer."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('BE');

        Assert.AreNotEqual('', Customer."VAT Registration No.", '');
        Customer.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.AreEqual('', Customer."VAT Registration No.", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotSetNonMod7NumberAsEnterpriseNoOnBelgianCustomer()
    var
        Customer: Record Customer;
    begin
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", 'BE');
        Customer.Modify;

        asserterror Customer.Validate("Enterprise No.", '0123456789');
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldNotBeSetOnNonBelgianCustomer()
    var
        Customer: Record Customer;
    begin
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", 'GB');
        Customer.Modify;

        Customer.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('GB'));

        asserterror Customer.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.ExpectedError('Enterprise');

        // a string can be set as the enterprise no.
        Customer.Validate("Enterprise No.", 'junk');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoCanBeSetOnNonBelgianCustomer()
    var
        Customer: Record Customer;
        VATNo: Code[20];
    begin
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", 'GB');
        Customer.Modify;

        VATNo := LibraryBEHelper.CreateVatRegNo('GB');
        Customer.Validate("VAT Registration No.", VATNo);

        Assert.AreEqual(VATNo, Customer."VAT Registration No.", 'VAT Registration number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldBeSetOnBelgianVendor()
    var
        Vendor: Record Vendor;
        EnterpriseNo: Code[20];
    begin
        Initialize;

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", 'BE');
        Vendor.Modify;

        asserterror Vendor.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('BE'));
        Assert.ExpectedError('Enterprise');

        EnterpriseNo := LibraryBEHelper.CreateEnterpriseNo;
        Vendor.Validate("Enterprise No.", EnterpriseNo);

        Assert.AreEqual(EnterpriseNo, Vendor."Enterprise No.", 'Enterprise number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoIsResetWhenEnterpriseNoIsSetOnBelgianVendor()
    var
        Vendor: Record Vendor;
    begin
        Initialize;

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", 'BE');
        Vendor.Modify;

        Vendor.Validate("Enterprise No.", '');
        Vendor."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('BE');

        Assert.AreNotEqual('', Vendor."VAT Registration No.", '');
        Vendor.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.AreEqual('', Vendor."VAT Registration No.", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotSetNonMod7NumberAsEnterpriseNoOnBelgianVendor()
    var
        Vendor: Record Vendor;
    begin
        Initialize;

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", 'BE');
        Vendor.Modify;

        asserterror Vendor.Validate("Enterprise No.", '0123456789');
        Assert.ExpectedError('Enterprise');

        asserterror Vendor.Validate("Enterprise No.", 'SampleEnNo');
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldNotBeSetOnNonBelgianVendor()
    var
        Vendor: Record Vendor;
    begin
        Initialize;

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", 'GB');
        Vendor.Modify;

        Vendor.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('GB'));

        asserterror Vendor.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoCanBeSetOnNonBelgianVendor()
    var
        Vendor: Record Vendor;
        VATNo: Code[20];
    begin
        Initialize;

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", 'GB');
        Vendor.Modify;

        VATNo := LibraryBEHelper.CreateVatRegNo('GB');
        Vendor.Validate("VAT Registration No.", VATNo);

        Assert.AreEqual(VATNo, Vendor."VAT Registration No.", 'VAT Registration number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldBeSetOnBelgianContact()
    var
        Contact: Record Contact;
        EnterpriseNo: Code[20];
    begin
        Initialize;

        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", 'BE');
        Contact.Modify;

        asserterror Contact.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('BE'));
        Assert.ExpectedError('Enterprise');

        EnterpriseNo := LibraryBEHelper.CreateEnterpriseNo;
        Contact.Validate("Enterprise No.", EnterpriseNo);

        Assert.AreEqual(EnterpriseNo, Contact."Enterprise No.", 'Enterprise number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoIsResetWhenEnterpriseNoIsSetOnBelgianContact()
    var
        Contact: Record Contact;
    begin
        Initialize;

        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", 'BE');
        Contact.Modify;

        Contact.Validate("Enterprise No.", '');
        Contact."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('BE');

        Assert.AreNotEqual('', Contact."VAT Registration No.", '');
        Contact.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.AreEqual('', Contact."VAT Registration No.", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotSetNonMod7NumberAsEnterpriseNoOnBelgianContact()
    var
        Contact: Record Contact;
    begin
        Initialize;

        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", 'BE');
        Contact.Modify;

        asserterror Contact.Validate("Enterprise No.", '0123456789');
        Assert.ExpectedError('Enterprise');

        asserterror Contact.Validate("Enterprise No.", 'SampleEnNo');
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EnterpriseNoShouldNotBeSetOnNonBelgianContact()
    var
        Contact: Record Contact;
    begin
        Initialize;

        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", 'GB');
        Contact.Modify;

        Contact.Validate("VAT Registration No.", LibraryBEHelper.CreateVatRegNo('GB'));

        asserterror Contact.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Assert.ExpectedError('Enterprise');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATNoCanBeSetOnNonBelgianContact()
    var
        Contact: Record Contact;
        VATNo: Code[20];
    begin
        Initialize;

        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", 'GB');
        Contact.Modify;

        VATNo := LibraryBEHelper.CreateVatRegNo('GB');
        Contact.Validate("VAT Registration No.", VATNo);

        Assert.AreEqual(VATNo, Contact."VAT Registration No.", 'VAT Registration number is not set.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceHeaderContainsEnterpriseNoOfBelgianCustomer()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
    begin
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60105
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Enterprise No.", LibraryBEHelper.CreateEnterpriseNo);
        Customer.Modify;

        ServiceHeader.Init;
        ServiceHeader.Validate("Customer No.", Customer."No.");
        Assert.AreEqual(Customer."Enterprise No.", ServiceHeader."Enterprise No.", 'Enterprise No. is not as expected.');
    end;

    [Test]
    [HandlerFunctions('ServiceInvoicePrintRequestHandler')]
    [Scope('OnPrem')]
    procedure ServiceInvoiceReportHasEnterpriseNumbers()
    var
        Customer: Record Customer;
        ServiceInvoiceHeader: Record "Service Invoice Header";
        CompanyInfo: Record "Company Information";
        VATEntry: Record "VAT Entry";
        PostedServiceInvoicesPage: TestPage "Posted Service Invoices";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo";
    begin
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60106
        Initialize;

        LibraryBEHelper.CreateDomesticCustomerResourceServiceDocumentAndPost(Customer, DocumentType::Invoice);

        VATEntry.SetRange("Bill-to/Pay-to No.", Customer."No.");
        VATEntry.FindFirst;

        Assert.AreEqual(VATEntry."VAT Registration No.", '', '');

        ServiceInvoiceHeader.SetRange("Customer No.", Customer."No.");
        ServiceInvoiceHeader.FindFirst;

        PostedServiceInvoicesPage.OpenView;
        PostedServiceInvoicesPage.GotoRecord(ServiceInvoiceHeader);

        LibraryReportDataset.Reset;
        PostedServiceInvoicesPage."&Print".Invoke;

        // Validation
        CompanyInfo.FindFirst;
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('CompanyInfoEnterpriseNo', CompanyInfo."Enterprise No.");
        LibraryReportDataset.AssertElementWithValueExists('NoText', Customer."Enterprise No.");
    end;

    [Test]
    [HandlerFunctions('ServiceInvoicePrintRequestHandler')]
    [Scope('OnPrem')]
    procedure ServiceInvoiceReportHasVATNumberForNonDomesticCust()
    var
        Customer: Record Customer;
        ServiceInvoiceHeader: Record "Service Invoice Header";
        CompanyInfo: Record "Company Information";
        VATEntry: Record "VAT Entry";
        PostedServiceInvoicesPage: TestPage "Posted Service Invoices";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo";
    begin
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60106
        Initialize;

        LibraryBEHelper.CreateForeignCustomerResourceServiceDocumentAndPost(Customer, DocumentType::Invoice);

        VATEntry.SetRange("Bill-to/Pay-to No.", Customer."No.");
        VATEntry.FindFirst;

        Assert.AreEqual(Customer."VAT Registration No.", VATEntry."VAT Registration No.", '');

        ServiceInvoiceHeader.SetRange("Customer No.", Customer."No.");
        ServiceInvoiceHeader.FindFirst;

        PostedServiceInvoicesPage.OpenView;
        PostedServiceInvoicesPage.GotoRecord(ServiceInvoiceHeader);

        LibraryReportDataset.Reset;
        PostedServiceInvoicesPage."&Print".Invoke;

        // Validation
        CompanyInfo.FindFirst;
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('CompanyInfoEnterpriseNo', CompanyInfo."Enterprise No.");
        LibraryReportDataset.AssertElementWithValueExists('NoText', Customer."VAT Registration No.");
    end;

    [Test]
    [HandlerFunctions('ServiceCreditMemoPrintRequestHandler')]
    [Scope('OnPrem')]
    procedure ServiceCreditMemoReportHasEnterpriseNumbers()
    var
        Customer: Record Customer;
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CompanyInfo: Record "Company Information";
        VATEntry: Record "VAT Entry";
        PostedServiceCreditMemosPage: TestPage "Posted Service Credit Memos";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo";
    begin
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60106
        Initialize;

        LibraryBEHelper.CreateDomesticCustomerResourceServiceDocumentAndPost(Customer, DocumentType::"Credit Memo");

        VATEntry.SetRange("Bill-to/Pay-to No.", Customer."No.");
        VATEntry.FindFirst;

        Assert.AreEqual(VATEntry."VAT Registration No.", '', '');

        ServiceCrMemoHeader.SetRange("Customer No.", Customer."No.");
        ServiceCrMemoHeader.FindFirst;

        PostedServiceCreditMemosPage.OpenView;
        PostedServiceCreditMemosPage.GotoRecord(ServiceCrMemoHeader);

        LibraryReportDataset.Reset;
        PostedServiceCreditMemosPage."&Print".Invoke;

        // Validation
        CompanyInfo.FindFirst;
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('CompanyInfoEnterpriseNo', CompanyInfo."Enterprise No.");
        LibraryReportDataset.AssertElementWithValueExists('NoText', Customer."Enterprise No.");
    end;

    [Test]
    [HandlerFunctions('ServiceCreditMemoPrintRequestHandler')]
    [Scope('OnPrem')]
    procedure ServiceCreditMemoReportHasVATNumberForNonDomesticCust()
    var
        Customer: Record Customer;
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CompanyInfo: Record "Company Information";
        VATEntry: Record "VAT Entry";
        PostedServiceCreditMemosPage: TestPage "Posted Service Credit Memos";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo";
    begin
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60106
        Initialize;

        LibraryBEHelper.CreateForeignCustomerResourceServiceDocumentAndPost(Customer, DocumentType::"Credit Memo");

        VATEntry.SetRange("Bill-to/Pay-to No.", Customer."No.");
        VATEntry.FindFirst;

        Assert.AreEqual(Customer."VAT Registration No.", VATEntry."VAT Registration No.", '');

        ServiceCrMemoHeader.SetRange("Customer No.", Customer."No.");
        ServiceCrMemoHeader.FindFirst;

        PostedServiceCreditMemosPage.OpenView;
        PostedServiceCreditMemosPage.GotoRecord(ServiceCrMemoHeader);

        LibraryReportDataset.Reset;
        PostedServiceCreditMemosPage."&Print".Invoke;

        // Validation
        CompanyInfo.FindFirst;
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('CompanyInfoEnterpriseNo', CompanyInfo."Enterprise No.");
        LibraryReportDataset.AssertElementWithValueExists('NoText', Customer."VAT Registration No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure BillToBelgianCustomerUpdatesEntNoOnServiceHeader()
    var
        CustomerBelgian: Record Customer;
        CustomerNonBelgian: Record Customer;
        ServiceHeader: Record "Service Header";
    begin
        Initialize;

        LibraryBEHelper.CreateDomesticCustomer(CustomerBelgian);
        LibraryBEHelper.CreateCustomer(CustomerNonBelgian, 'GB');

        ServiceHeader.Init;
        ServiceHeader."Document Type" := ServiceHeader."Document Type"::Invoice;
        ServiceHeader.Validate("Customer No.", CustomerNonBelgian."No.");
        ServiceHeader.Validate("Bill-to Customer No.", CustomerBelgian."No.");

        Assert.AreEqual(CustomerBelgian."Enterprise No.", ServiceHeader."Enterprise No.", '');
        Assert.AreEqual('', ServiceHeader."VAT Registration No.", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingSupplierPartyTaxScheme_EnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CompanyID: Text;
        CompanyIDSchemeID: Text;
        TaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1605 "PEPPOL Management".GetAccountingSupplierPartyTaxScheme() returns "Enterprise No." when "VAT Registration No." is empty
        Initialize;
        CompanyInformation.Get;

        CompanyInformation.TestField("Enterprise No.");
        CompanyInformation.TestField("VAT Registration No.", '');

        PEPPOLManagement.GetAccountingSupplierPartyTaxScheme(CompanyID, CompanyIDSchemeID, TaxSchemeID);
        Assert.AreEqual(CompanyInformation."Enterprise No.", CompanyID, '');
        Assert.AreEqual(GetVATScheme, CompanyIDSchemeID, '');
        Assert.AreEqual('VAT', TaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingSupplierPartyTaxScheme_VATRegNo()
    var
        CompanyInformation: Record "Company Information";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CompanyID: Text;
        CompanyIDSchemeID: Text;
        TaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1605 "PEPPOL Management".GetAccountingSupplierPartyTaxScheme() returns "VAT Registration No." when "Enterprise No." is empty
        Initialize;
        UpdateCompanyInfo(CompanyInformation, '', LibraryBEHelper.CreateVatRegNo('BE'), '');

        CompanyInformation.TestField("Enterprise No.", '');
        CompanyInformation.TestField("VAT Registration No.");

        PEPPOLManagement.GetAccountingSupplierPartyTaxScheme(CompanyID, CompanyIDSchemeID, TaxSchemeID);
        Assert.AreEqual(CompanyInformation."VAT Registration No.", CompanyID, '');
        Assert.AreEqual(GetVATScheme, CompanyIDSchemeID, '');
        Assert.AreEqual('VAT', TaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingSupplierPartyTaxScheme_EnterpriseNoVATRegNo()
    var
        CompanyInformation: Record "Company Information";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CompanyID: Text;
        CompanyIDSchemeID: Text;
        TaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1605 "PEPPOL Management".GetAccountingSupplierPartyTaxScheme() returns "Enterprise No." when "VAT Registration No." is not empty
        Initialize;
        CompanyInformation.Get;

        CompanyInformation.TestField("Enterprise No.");
        CompanyInformation.TestField("VAT Registration No.");

        PEPPOLManagement.GetAccountingSupplierPartyTaxScheme(CompanyID, CompanyIDSchemeID, TaxSchemeID);
        Assert.AreEqual(CompanyInformation."Enterprise No.", CompanyID, '');
        Assert.AreEqual(GetVATScheme, CompanyIDSchemeID, '');
        Assert.AreEqual('VAT', TaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingSupplierPartyTaxScheme_Empty()
    var
        CompanyInformation: Record "Company Information";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CompanyID: Text;
        CompanyIDSchemeID: Text;
        TaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1605 "PEPPOL Management".GetAccountingSupplierPartyTaxScheme() returns empty result when "Enterprise No." and "VAT Registration No." are empty
        Initialize;
        UpdateCompanyInfo(CompanyInformation, '', '', '');

        CompanyInformation.TestField("Enterprise No.", '');
        CompanyInformation.TestField("VAT Registration No.", '');

        PEPPOLManagement.GetAccountingSupplierPartyTaxScheme(CompanyID, CompanyIDSchemeID, TaxSchemeID);
        Assert.AreEqual('', CompanyID, '');
        Assert.AreEqual('', CompanyIDSchemeID, '');
        Assert.AreEqual('', TaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingCustomerPartyTaxScheme_EnterpriseNo()
    var
        SalesHeader: Record "Sales Header";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CustPartyTaxSchemeCompanyID: Text;
        CustPartyTaxSchemeCompIDSchID: Text;
        CustTaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] COD 1605 "PEPPOL Management".CustPartyTaxSchemeCompanyID() returns "Enterprise No." when "VAT Registration No." is empty
        Initialize;
        SalesHeader."Enterprise No." := LibraryUtility.GenerateGUID;
        SalesHeader."VAT Registration No." := '';

        PEPPOLManagement.GetAccountingCustomerPartyTaxScheme(
          SalesHeader, CustPartyTaxSchemeCompanyID, CustPartyTaxSchemeCompIDSchID, CustTaxSchemeID);

        Assert.AreEqual(SalesHeader."Enterprise No.", CustPartyTaxSchemeCompanyID, '');
        Assert.AreEqual('BE:VAT', CustPartyTaxSchemeCompIDSchID, '');
        Assert.AreEqual('VAT', CustTaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingCustomerPartyTaxScheme_VATRegNo()
    var
        SalesHeader: Record "Sales Header";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CustPartyTaxSchemeCompanyID: Text;
        CustPartyTaxSchemeCompIDSchID: Text;
        CustTaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] COD 1605 "PEPPOL Management".CustPartyTaxSchemeCompanyID() returns "VAT Registration No." when "Enterprise No." is empty
        Initialize;
        SalesHeader."Enterprise No." := '';
        SalesHeader."VAT Registration No." := LibraryUtility.GenerateGUID;

        PEPPOLManagement.GetAccountingCustomerPartyTaxScheme(
          SalesHeader, CustPartyTaxSchemeCompanyID, CustPartyTaxSchemeCompIDSchID, CustTaxSchemeID);

        Assert.AreEqual(SalesHeader."VAT Registration No.", CustPartyTaxSchemeCompanyID, '');
        Assert.AreEqual('BE:VAT', CustPartyTaxSchemeCompIDSchID, '');
        Assert.AreEqual('VAT', CustTaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingCustomerPartyTaxScheme_EnterpriseNoVATRegNo()
    var
        SalesHeader: Record "Sales Header";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CustPartyTaxSchemeCompanyID: Text;
        CustPartyTaxSchemeCompIDSchID: Text;
        CustTaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] COD 1605 "PEPPOL Management".CustPartyTaxSchemeCompanyID() returns "Enterprise No." when "VAT Registration No." is not empty
        Initialize;
        SalesHeader."Enterprise No." := LibraryUtility.GenerateGUID;
        SalesHeader."VAT Registration No." := LibraryUtility.GenerateGUID;

        PEPPOLManagement.GetAccountingCustomerPartyTaxScheme(
          SalesHeader, CustPartyTaxSchemeCompanyID, CustPartyTaxSchemeCompIDSchID, CustTaxSchemeID);

        Assert.AreEqual(SalesHeader."Enterprise No.", CustPartyTaxSchemeCompanyID, '');
        Assert.AreEqual('BE:VAT', CustPartyTaxSchemeCompIDSchID, '');
        Assert.AreEqual('VAT', CustTaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLMgt_GetAccountingCustomerPartyTaxScheme_Empty()
    var
        SalesHeader: Record "Sales Header";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        CustPartyTaxSchemeCompanyID: Text;
        CustPartyTaxSchemeCompIDSchID: Text;
        CustTaxSchemeID: Text;
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] COD 1605 "PEPPOL Management".CustPartyTaxSchemeCompanyID() returns empty result when "Enterprise No." and "VAT Registration No." are empty
        Initialize;
        SalesHeader."Enterprise No." := '';
        SalesHeader."VAT Registration No." := '';

        PEPPOLManagement.GetAccountingCustomerPartyTaxScheme(
          SalesHeader, CustPartyTaxSchemeCompanyID, CustPartyTaxSchemeCompIDSchID, CustTaxSchemeID);

        Assert.AreEqual('', CustPartyTaxSchemeCompanyID, '');
        Assert.AreEqual('', CustPartyTaxSchemeCompIDSchID, '');
        Assert.AreEqual('', CustTaxSchemeID, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_YouMustSpecifyEnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1620 "PEPPOL Validation" throws an error "You must specify either GLN or VAT Registration No. or Enterprise No. in Company Information." in case of empty fields
        Initialize;
        UpdateCompanyInfo(CompanyInformation, '', '', '');

        CompanyInformation.TestField("Enterprise No.", '');
        CompanyInformation.TestField("VAT Registration No.", '');
        CompanyInformation.TestField(GLN, '');

        asserterror CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(
          'You must fill in either the GLN, VAT Registration No., or Enterprise No. field in the Company Information window.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_EnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1620 "PEPPOL Validation" throws an error "Bill-to Name must have a value" for an empty Sales Header and filled "Enterprise No."
        Initialize;
        CompanyInformation.Get;
        UpdateCompanyInfo(CompanyInformation, CompanyInformation."Enterprise No.", '', '');

        CompanyInformation.TestField("Enterprise No.");
        CompanyInformation.TestField("VAT Registration No.", '');
        CompanyInformation.TestField(GLN, '');

        asserterror CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(BillToNameMustHaveValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_VATRegNo()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1620 "PEPPOL Validation" throws an error "Bill-to Name must have a value" for an empty Sales Header and filled "VAT Registration No."
        Initialize;
        UpdateCompanyInfo(CompanyInformation, '', LibraryBEHelper.CreateVatRegNo('BE'), '');

        CompanyInformation.TestField("Enterprise No.", '');
        CompanyInformation.TestField("VAT Registration No.");
        CompanyInformation.TestField(GLN, '');

        asserterror CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(BillToNameMustHaveValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_GLN()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT]
        // [SCENARIO 201964] COD 1620 "PEPPOL Validation" throws an error "Bill-to Name must have a value" for an empty Sales Header and filled "GLN"
        Initialize;
        UpdateCompanyInfo(CompanyInformation, '', '', '1234567890128');

        CompanyInformation.TestField("Enterprise No.", '');
        CompanyInformation.TestField("VAT Registration No.", '');
        CompanyInformation.TestField(GLN);

        asserterror CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(BillToNameMustHaveValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_Customer_YouMustSpecifyEnterpriseNo()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] COD 1620 "PEPPOL Validation" throws an error "You must fill in either the GLN, VAT Registration No., or Enterprise No. field in the Customer..." in case of empty  customer's fields
        Initialize;
        UpdateCompanySwiftCode;

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Validate("Sell-to Customer No.", CreateCustomerNo('', '', ''));

        SalesHeader.TestField("Enterprise No.", '');
        SalesHeader.TestField("VAT Registration No.", '');

        asserterror CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(
          StrSubstNo('You must fill in either the GLN, VAT Registration No., or Enterprise No. field for customer %1.',
            SalesHeader."Bill-to Customer No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_Customer_EnterpriseNo()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] Sales Invoice is validated successfully with COD 1620 "PEPPOL Validation" when Customer."Enterprise No." has value
        Initialize;
        UpdateCompanySwiftCode;

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Validate("Sell-to Customer No.", CreateCustomerNo('', LibraryUtility.GenerateGUID, ''));

        SalesHeader.TestField("Enterprise No.");
        SalesHeader.TestField("VAT Registration No.", '');

        CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_Customer_VATRegNo()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] Sales Invoice is validated successfully with COD 1620 "PEPPOL Validation" when Customer."VAT Registration No." has value
        Initialize;
        UpdateCompanySwiftCode;

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Validate("Sell-to Customer No.", CreateCustomerNo(LibraryUtility.GenerateGUID, '', ''));

        SalesHeader.TestField("Enterprise No.", '');
        SalesHeader.TestField("VAT Registration No.");

        CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOLValidation_Customer_GLN()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [PEPPOL] [UT] [Customer]
        // [SCENARIO 205111] Sales Invoice is validated successfully with COD 1620 "PEPPOL Validation" when Customer."GLN" has value
        Initialize;
        UpdateCompanySwiftCode;

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Validate("Sell-to Customer No.", CreateCustomerNo('', '', LibraryUtility.GenerateGUID));

        SalesHeader.TestField("Enterprise No.", '');
        SalesHeader.TestField("VAT Registration No.", '');

        CODEUNIT.Run(CODEUNIT::"PEPPOL Validation", SalesHeader);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOL20_XMLExport_EnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        XMLFilePath: Text;
    begin
        // [FEATURE] [PEPPOL] [XML] [Sales] [Invoice]
        // [SCENARIO 201964] PEPPOL 2.0 xml exports "Enterprise No." into "CompanyID" tag under "AccountingSupplierParty" and "AccountingCustomerParty" nodes
        Initialize;
        UpdateCompanySwiftCode;

        // [GIVEN] "Company Informatiion"."Enterprise No." = "X"
        CompanyInformation.Get;
        CompanyInformation.TestField("Enterprise No.");
        CompanyInformation.TestField("SWIFT Code");
        // [GIVEN] Posted sales invoice for the customer with "Enterprise No." = "Y"
        CreatePostSalesInvoice(SalesInvoiceHeader);

        // [WHEN] Send the invoice electronically with PEPPOL 2.0 format
        XMLFilePath := PEPPOLXMLExport(SalesInvoiceHeader, 'PEPPOL 2.0');

        // [THEN] XML has been exported with tag "AccountingSupplierParty\Party\PartyTaxScheme\CompanyID" = "X"
        LibraryXMLRead.Initialize(XMLFilePath);
        LibraryXMLRead.VerifyNodeValueInSubtree('cac:PartyTaxScheme', 'cbc:CompanyID', CompanyInformation."Enterprise No.");
        LibraryXMLRead.VerifyAttributeValueInSubtree('cac:PartyTaxScheme', 'cbc:CompanyID', 'schemeID', 'BE:VAT');
        LibraryXMLRead.VerifyNodeValueInSubtree('cac:PartyTaxScheme', 'cbc:ID', 'VAT');

        // [THEN] XML has been exported with tag "AccountingCustomerParty\Party\PartyTaxScheme\CompanyID" = "Y" (TFS 205111)
        Assert.AreEqual(
          SalesInvoiceHeader."Enterprise No.",
          LibraryXMLRead.GetNodeValueAtIndex('cbc:CompanyID', 1), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PEPPOL21_XMLExport_EnterpriseNo()
    var
        CompanyInformation: Record "Company Information";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        XMLFilePath: Text;
    begin
        // [FEATURE] [PEPPOL] [XML] [Sales] [Invoice]
        // [SCENARIO 201964] PEPPOL 2.1 xml exports "Enterprise No." into "CompanyID" tag under "AccountingSupplierParty" and "AccountingCustomerParty" nodes
        Initialize;
        UpdateCompanySwiftCode;

        // [GIVEN] "Company Informatiion"."Enterprise No." = "X"
        CompanyInformation.Get;
        CompanyInformation.TestField("Enterprise No.");
        CompanyInformation.TestField("SWIFT Code");
        // [GIVEN] Posted sales invoice for the customer with "Enterprise No." = "Y"
        CreatePostSalesInvoice(SalesInvoiceHeader);

        // [WHEN] Send the invoice electronically with PEPPOL 2.1 format
        XMLFilePath := PEPPOLXMLExport(SalesInvoiceHeader, 'PEPPOL 2.1');

        // [THEN] XML has been exported with tag "AccountingSupplierParty\Party\PartyTaxScheme\CompanyID" = "X"
        LibraryXMLRead.Initialize(XMLFilePath);
        LibraryXMLRead.VerifyNodeValueInSubtree('cac:PartyTaxScheme', 'cbc:CompanyID', CompanyInformation."Enterprise No.");
        LibraryXMLRead.VerifyAttributeValueInSubtree('cac:PartyTaxScheme', 'cbc:CompanyID', 'schemeID', 'BE:VAT');
        LibraryXMLRead.VerifyNodeValueInSubtree('cac:PartyTaxScheme', 'cbc:ID', 'VAT');

        // [THEN] XML has been exported with tag "AccountingCustomerParty\Party\PartyTaxScheme\CompanyID" = "Y" (TFS 205111)
        Assert.AreEqual(
          SalesInvoiceHeader."Enterprise No.",
          LibraryXMLRead.GetNodeValueAtIndex('cbc:CompanyID', 1), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CompanyInfoGetVatRegNoReturnsEnterpriseNoForBE()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 297251] Company Information GetVATRegistrationNumber returns Enterprise No if company is BE
        Initialize;

        CompanyInformation.Get;

        // [GIVEN] Current company's Country Code is BE
        CompanyInformation.Validate("Country/Region Code", 'BE');

        // [GIVEN] Enterprise No is set
        CompanyInformation.Validate("Enterprise No.", '0200.068.636');

        // [THEN] GetVATRegistrationNumber returns Enterprise No
        Assert.AreEqual(
          CompanyInformation."Enterprise No.",
          CompanyInformation.GetVATRegistrationNumber, 'Numbers must be equal');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CompanyInfoGetVatRegNoLblReturnsEnterpriseNoLblForBE()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 297251] Company Information GetVATRegistrationNumberLbl returns Enterprise No text label if company is BE
        Initialize;

        CompanyInformation.Get;

        // [GIVEN] Current company's Country Code is BE
        CompanyInformation.Validate("Country/Region Code", 'BE');

        // [GIVEN] Enterprise No is set
        CompanyInformation.Validate("Enterprise No.", '0200.068.636');

        // [THEN] GetVATRegistrationNumberLbl returns Enterprise No label
        Assert.AreEqual(
          CompanyInformation.FieldCaption("Enterprise No."),
          CompanyInformation.GetVATRegistrationNumberLbl, 'Labels must be equal');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CompanyInfoGetVatRegNoReturnsVATRegNoForNonBE()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 297251] Company Information GetVATRegistrationNumber returns VAT Registration No. if company is non-BE
        Initialize;

        CompanyInformation.Get;

        // [GIVEN] Current company's Country Code is BE
        CompanyInformation.Validate("Country/Region Code", 'DE');

        // [GIVEN] VAT Registration No. is set
        CompanyInformation.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo('DE'));

        // [THEN] GetVATRegistrationNumber returns Enterprise No
        Assert.AreEqual(
          CompanyInformation."VAT Registration No.",
          CompanyInformation.GetVATRegistrationNumber, 'Numbers must be equal');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CompanyInfoGetVatRegNoLblReturnVATRegNoLblForNonBE()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 297251] Company Information GetVATRegistrationNumberLbl returns VAT Registration No. text label if company is non-BE
        Initialize;

        CompanyInformation.Get;

        // [GIVEN] Current company's Country Code is BE
        CompanyInformation.Validate("Country/Region Code", 'DE');

        // [GIVEN] VAT Registration No. is set
        CompanyInformation.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo('DE'));

        // [THEN] GetVATRegistrationNumberLbl returns Enterprise No label
        Assert.AreEqual(
          CompanyInformation.FieldCaption("VAT Registration No."),
          CompanyInformation.GetVATRegistrationNumberLbl, 'Labels must be equal');
    end;

    [Test]
    [HandlerFunctions('ReminderRequestPageHandler')]
    [Scope('OnPrem')]
    procedure ReminderReportCustomerEnterpriseNo()
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        // [FEATURE] [UT] [Reminder]
        // [SCENARIO 315402] Report Reminder prints Enterprise No. for the local customer
        Initialize;

        // [GIVEN] Issued reminder for the local customer with Enterprise No. = "ENO"
        MockIssuedReminder(IssuedReminderHeader, 'BE');
        IssuedReminderHeader."Enterprise No." := LibraryBEHelper.CreateEnterpriseNo();
        IssuedReminderHeader.Modify();

        // [WHEN] Reminder is being printed
        IssuedReminderHeader.SetRecFilter;
        Commit;
        REPORT.Run(REPORT::Reminder, true, false, IssuedReminderHeader);

        // [THEN] Enterprise No. caption and number "ENO" printed
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('VATNoText', IssuedReminderHeader.FieldCaption("Enterprise No."));
        LibraryReportDataset.AssertElementWithValueExists('VatRegNo_IssueReminderHdr', IssuedReminderHeader."Enterprise No.");
    end;

    [Test]
    [HandlerFunctions('ReminderRequestPageHandler')]
    [Scope('OnPrem')]
    procedure ReminderReportCustomerVATRegistrationNo()
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        // [FEATURE] [UT] [Reminder]
        // [SCENARIO 315402] Report Reminder prints VAT Registration No. for the foreign customer
        Initialize;

        // [GIVEN] Issued reminder for the foreign customer with VAT Registration No. = "VATREGNO"
        MockIssuedReminder(IssuedReminderHeader, 'GB');
        IssuedReminderHeader."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('GB');
        IssuedReminderHeader.Modify();

        // [WHEN] Reminder is being printed
        IssuedReminderHeader.SetRecFilter;
        Commit;
        REPORT.Run(REPORT::Reminder, true, false, IssuedReminderHeader);

        // [THEN] VAT Registration No. caption and number "VATREGNO" printed
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('VATNoText', IssuedReminderHeader.FieldCaption("VAT Registration No."));
        LibraryReportDataset.AssertElementWithValueExists('VatRegNo_IssueReminderHdr', IssuedReminderHeader."VAT Registration No.");
    end;

    [Test]
    [HandlerFunctions('FinanceChargeMemoRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FinanceChargeMemoReportCustomerEnterpriseNo()
    var
        IssuedFinanceChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        // [FEATURE] [UT] [Finance Charge Memo]
        // [SCENARIO 315402] Report Finance Charge Memo prints Enterprise No. for the local customer
        Initialize;

        // [GIVEN] Issued Finance Charge Memo for the local customer with Enterprise No. = "ENO"
        MockIssuedFinanceChargeMemo(IssuedFinanceChargeMemoHeader, 'BE');
        IssuedFinanceChargeMemoHeader."Enterprise No." := LibraryBEHelper.CreateEnterpriseNo();
        IssuedFinanceChargeMemoHeader.Modify();

        // [WHEN] Finance Charge Memo is being printed
        IssuedFinanceChargeMemoHeader.SetRecFilter;
        Commit;
        REPORT.Run(REPORT::"Finance Charge Memo", true, false, IssuedFinanceChargeMemoHeader);

        // [THEN] Enterprise No. caption and number "ENO" printed
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('VATNoText', IssuedFinanceChargeMemoHeader.FieldCaption("Enterprise No."));
        LibraryReportDataset.AssertElementWithValueExists('VatRNo_IssuFinChrgMemoHr', IssuedFinanceChargeMemoHeader."Enterprise No.");
    end;

    [Test]
    [HandlerFunctions('FinanceChargeMemoRequestPageHandler')]
    [Scope('OnPrem')]
    procedure FinanceChargeMemoReportCustomerVATRegistrationNo()
    var
        IssuedFinanceChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        // [FEATURE] [UT] [Finance Charge Memo]
        // [SCENARIO 315402] Report Finance Charge Memo prints VAT Registration No. for the foreign customer
        Initialize;

        // [GIVEN] Issued Finance Charge Memo for the foreign customer with VAT Registration No. = "VATREGNO"
        MockIssuedFinanceChargeMemo(IssuedFinanceChargeMemoHeader, 'GB');
        IssuedFinanceChargeMemoHeader."VAT Registration No." := LibraryBEHelper.CreateVatRegNo('GB');
        IssuedFinanceChargeMemoHeader.Modify();

        // [WHEN] Finance Charge Memo is being printed
        IssuedFinanceChargeMemoHeader.SetRecFilter;
        Commit;
        REPORT.Run(REPORT::"Finance Charge Memo", true, false, IssuedFinanceChargeMemoHeader);

        // [THEN] VAT Registration No. caption and number "VATREGNO" printed
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('VATNoText', IssuedFinanceChargeMemoHeader.FieldCaption("VAT Registration No."));
        LibraryReportDataset.AssertElementWithValueExists('VatRNo_IssuFinChrgMemoHr', IssuedFinanceChargeMemoHeader."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostServIvoiceWithEnterpriseNo()
    var
        Customer: Record Customer;
        VATEntry: Record "VAT Entry";
        ServiceInvoiceNo: Code[20];
    begin
        // [FEATURE] [Customer] [Service]
        // [SCENARIO 322818] VAT Entry's "Enterprise No." has a value after a Service Invoice for a Customer with "Enterprise No." is posted
        Initialize;

        // [GIVEN] Created a Customer with "Enterprise No."
        CreateCustomerWithEnterpriseNo(Customer);

        // [WHEN] Post a Service Invoice
        ServiceInvoiceNo := CreatePostServiceInvoice(Customer."No.");

        // [THEN] VAT Entry related to the posted Service Invoice has its "Enterprise No."
        FindVATEntry(VATEntry, VATEntry."Document Type"::Invoice, ServiceInvoiceNo);
        VATEntry.TestField("Enterprise No.", Customer."Enterprise No.");
    end;
    
    local procedure Initialize()
    begin
        LibraryBEHelper.InitializeCompanyInformation;
    end;

    local procedure UpdateCompanyInfo(var CompanyInformation: Record "Company Information"; EnterpriseNo: Text[50]; VATRegNo: Text[20]; GLNNo: Text[13])
    begin
        with CompanyInformation do begin
            Get;
            Validate("Enterprise No.", EnterpriseNo);
            "VAT Registration No." := VATRegNo;
            Validate(GLN, GLNNo);
            Modify(true);
        end;
    end;

    local procedure UpdateCompanySwiftCode()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get;
            Validate("SWIFT Code", Format(LibraryRandom.RandIntInRange(1000000, 9999999)));
            Modify(true);
        end;
    end;

    local procedure CreatePostSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(
          SalesHeader, SalesHeader."Document Type"::Invoice,
          CreateCustomerNo(LibraryBEHelper.CreateVatRegNo('BE'), LibraryUtility.GenerateGUID, ''));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup, 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(1000, 2000, 2));
        SalesLine.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        SalesInvoiceHeader.SetRange("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        SalesInvoiceHeader.FindFirst;
    end;

    local procedure CreateCustomerNo(VATRegNo: Text[20]; EnterpriseNo: Text[50]; GLNNo: Code[13]): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."VAT Registration No." := VATRegNo;
        Customer."Enterprise No." := EnterpriseNo;
        Customer.GLN := GLNNo;
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateCustomerWithEnterpriseNo(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        with Customer do begin
            Validate("Enterprise No.", LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen("Enterprise No."), 1));
            Modify(true);
        end;
    end;

    local procedure CreatePostServiceInvoice(CustomerNo: Code[20]): Code[20]
    var
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CustomerNo);
        CreateServiceLine(ServiceHeader);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        exit(ServiceInvoiceHeader."No.");
    end;

    local procedure CreateServiceLine(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItemNo);
        ServiceLine.Validate(Quantity, LibraryRandom.RandDec(100, 2));
        ServiceLine.Modify(true);
    end;

    local procedure FindServiceInvoiceHeader(var ServiceInvoiceHeader: Record "Service Invoice Header"; PreAssignedNo: Code[20])
    begin
        ServiceInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        ServiceInvoiceHeader.FindFirst;
    end;

    local procedure FindVATEntry(var VATEntry: Record "VAT Entry"; DocumentType: Option; DocumentNo: Code[20])
    begin
        with VATEntry do begin
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            FindFirst;
        end;
    end;

    local procedure GetVATScheme(): Text
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get;
        CountryRegion.Get(CompanyInformation."Country/Region Code");
        exit(CountryRegion."VAT Scheme");
    end;

    local procedure MockIssuedReminder(var IssuedReminderHeader: Record "Issued Reminder Header"; CountryCode: Code[10])
    var
        IssuedReminderLine: Record "Issued Reminder Line";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        IssuedReminderHeader.Init;
        IssuedReminderHeader."No." :=
          LibraryUtility.GenerateRandomCode(IssuedReminderHeader.FieldNo("No."), DATABASE::"Issued Reminder Header");
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        CustomerPostingGroup."Additional Fee Account" := '';
        CustomerPostingGroup.Modify;
        IssuedReminderHeader."Customer Posting Group" := CustomerPostingGroup.Code;
        IssuedReminderHeader."Due Date" := LibraryRandom.RandDate(LibraryRandom.RandIntInRange(10, 100));
        IssuedReminderHeader."Country/Region Code" := CountryCode;
        IssuedReminderHeader.Insert;
        IssuedReminderLine.Init;
        IssuedReminderLine."Line No." := LibraryUtility.GetNewRecNo(IssuedReminderLine, IssuedReminderLine.FieldNo("Line No."));
        IssuedReminderLine."Line Type" := IssuedReminderLine."Line Type"::"Reminder Line";
        IssuedReminderLine."Reminder No." := IssuedReminderHeader."No.";
        IssuedReminderLine."Due Date" := IssuedReminderHeader."Due Date";
        IssuedReminderLine."Remaining Amount" := LibraryRandom.RandIntInRange(10, 100);
        IssuedReminderLine.Amount := IssuedReminderLine."Remaining Amount";
        IssuedReminderLine.Type := IssuedReminderLine.Type::"G/L Account";
        IssuedReminderLine.Insert;
    end;

    local procedure MockIssuedFinanceChargeMemo(var IssuedFinanceChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; CountryCode: Code[10])
    var
        IssuedFinanceChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        IssuedFinanceChargeMemoHeader.Init;
        IssuedFinanceChargeMemoHeader."No." :=
          LibraryUtility.GenerateRandomCode(IssuedFinanceChargeMemoHeader.FieldNo("No."), DATABASE::"Issued Fin. Charge Memo Header");
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        CustomerPostingGroup."Additional Fee Account" := '';
        CustomerPostingGroup.Modify;
        IssuedFinanceChargeMemoHeader."Customer Posting Group" := CustomerPostingGroup.Code;
        IssuedFinanceChargeMemoHeader."Due Date" := LibraryRandom.RandDate(LibraryRandom.RandIntInRange(10, 100));
        IssuedFinanceChargeMemoHeader."Country/Region Code" := CountryCode;
        IssuedFinanceChargeMemoHeader.Insert;
        IssuedFinanceChargeMemoLine.Init;
        IssuedFinanceChargeMemoLine."Line No." := LibraryUtility.GetNewRecNo(IssuedFinanceChargeMemoLine, IssuedFinanceChargeMemoLine.FieldNo("Line No."));
        IssuedFinanceChargeMemoLine."Finance Charge Memo No." := IssuedFinanceChargeMemoHeader."No.";
        IssuedFinanceChargeMemoLine."Due Date" := IssuedFinanceChargeMemoHeader."Due Date";
        IssuedFinanceChargeMemoLine."Remaining Amount" := LibraryRandom.RandIntInRange(10, 100);
        IssuedFinanceChargeMemoLine.Amount := IssuedFinanceChargeMemoLine."Remaining Amount";
        IssuedFinanceChargeMemoLine.Type := IssuedFinanceChargeMemoLine.Type::"G/L Account";
        IssuedFinanceChargeMemoLine.Insert;
    end;

    local procedure PEPPOLXMLExport(SalesInvoiceHeader: Record "Sales Invoice Header"; FormatCode: Code[20]): Text
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        ServerFileName: Text[250];
        ClientFileName: Text[250];
    begin
        SalesInvoiceHeader.SetRecFilter;
        ElectronicDocumentFormat.SendElectronically(ServerFileName, ClientFileName, SalesInvoiceHeader, FormatCode);
        exit(ServerFileName);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure ServiceInvoicePrintRequestHandler(var RequestPage: TestRequestPage "Service - Invoice")
    begin
        RequestPage.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure ServiceCreditMemoPrintRequestHandler(var RequestPage: TestRequestPage "Service - Credit Memo")
    begin
        RequestPage.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure ReminderRequestPageHandler(var Reminder: TestRequestPage Reminder)
    begin
        Reminder.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure FinanceChargeMemoRequestPageHandler(var FinanceChargeMemo: TestRequestPage "Finance Charge Memo")
    begin
        FinanceChargeMemo.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;
}
