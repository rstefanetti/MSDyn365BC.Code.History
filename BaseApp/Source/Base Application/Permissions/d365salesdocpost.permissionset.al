permissionset 9977 "D365 SALES DOC, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Dynamics 365 Post sales doc.';

    IncludedPermissionSets = "D365 SALES DOC, EDIT";

    Permissions = tabledata "Analysis View" = rimd,
                  tabledata "Analysis View Entry" = rim,
                  tabledata "Analysis View Filter" = r,
                  tabledata "Avg. Cost Adjmt. Entry Point" = RIM,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Batch Processing Session Map" = Rimd,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata "CRM Post Buffer" = RIM,
                  tabledata "Currency for Reminder Level" = r,
                  tabledata "Customer Posting Group" = RM,
                  tabledata "Detailed Cust. Ledg. Entry" = Rimd,
                  tabledata "G/L Account" = IM,
                  tabledata "G/L - Item Ledger Relation" = RIMD,
                  tabledata "G/L Entry - VAT Entry Link" = Ri,
                  tabledata "G/L Entry" = Rimd,
                  tabledata "G/L Register" = Rimd,
                  tabledata "Interaction Log Entry" = Rimd,
                  tabledata "Interaction Template" = R,
                  tabledata "Interaction Tmpl. Language" = R,
                  tabledata "Item Charge" = R,
                  tabledata "Item Charge Assignment (Purch)" = RIMD,
                  tabledata "Item Charge Assignment (Sales)" = RIMD,
                  tabledata "Item Cross Reference" = RIMD,
                  tabledata "Item Entry Relation" = R,
                  tabledata "Item Ledger Entry" = Rimd,
                  tabledata "Item Register" = Rimd,
                  tabledata "Job Planning Line" = R,
                  tabledata "Jobs Setup" = R,
                  tabledata "Line Fee Note on Report Hist." = rim,
                  tabledata "Notification Entry" = RIMD,
                  tabledata "Order Promising Line" = RiMD,
                  tabledata "Post Value Entry to G/L" = i,
                  tabledata "Posted Whse. Shipment Header" = R,
                  tabledata "Posted Whse. Shipment Line" = R,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Price Worksheet Line" = RIMD,
                  tabledata "Purch. Rcpt. Header" = i,
                  tabledata "Purch. Rcpt. Line" = i,
                  tabledata "Reminder Level" = r,
                  tabledata "Reservation Entry" = I,
                  tabledata "Sent Notification Entry" = RIMD,
                  tabledata "Stockkeeping Unit" = R,
                  tabledata "VAT Entry" = Rimd,
                  tabledata "VAT Business Posting Group" = RM,
                  tabledata "VAT Registration No. Format" = R,
                  tabledata "Warehouse Request" = RIMD,
                  tabledata "Whse. Pick Request" = RIMD;
}
