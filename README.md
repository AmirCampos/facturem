#Facturem
An easy Facturae generator for invoincing to the Spanish Administration

For generating and signing an invoice, a CSV file must be uploaded. See below CSV file format required.

#Input CSV Input file format. Version 1.0
####Input files for the app must follow these guidelines
# Description
Every file represents an unique invoice. 
First cell in file must define version of format. Any file without this first row will be rejected.
Currently value for this cell is &ldquo;v1.0&rdquo;. Rest of cells in first row will be ignored.
There are different kind of rows for representing:

1.  Invoice header
2.  Invoice detail (items)
3.  TAX amounts and rates
4.  Invoice totals
5.  (optional) Payment schedule

For representing every row kind, the first column will be a number between 1 and 5.
Other columns can act as a headers or comments and will be ignored.

## Ranges

* 1 and only 1 row per file:
 * Invoice header
 * Invoice totals
* At least 1 row per file
 *   Invoice detail
 *   TAX amounts and rates
* Optional
 *   Payment schedule

## File Format

* Codification UTF-8
* Field separator: comma &ldquo;,&rdquo;
* Quotes. If a field contains separator, it must be surrounded with double quotes.

## Field Formats

*   Dates:
 *   yyyy-mm-dd.*   Example: 2015-12-31
*   Quantities. Positive:
 *   No thousands separator.
 *   Decimal separator (if needed) is dot.*   Example: 1.23
*   Quantities. Negative:
 *   Minus sign follows first digit.
 *   No thousands separator.
 *   Decimal separator (if needed) is dot.*   Example: -1.23
*   Currency. Positive:
 *   No thousands separator.
 *   No currency sign.
 *   Decimal separator (if needed) is dot.
 *   From 2 to 6 decimals.
 *   Example 99.99
*   Currency. Negative:
 *   Minus sign follows first digit.
 *   No thousands separator.
 *   No currency sign.
 *   Decimal separator (if needed) is dot.
 *   From 2 to 6 decimals.
 *   Example: -50.00
*   Tax rates.
 *   Up to 2 decimals.
 *   Decimal separator (if needed) is dot.
 *   Example: 21.00
*   Discount rates.
 *   Up to 4 decimals.
 *   Decimal separator (if needed) is dot.
 *   No % sign
 *   Example: 10.00

# Row 1. Invoice header

1.  Fixed value 1
2.  Issuer TAX ID. Must match with configuration.
3.  Customer ID
4.  Customer TAX ID
5.  Customer name
6.  Customer accounting service (oficina contable). Role type = 01
7.  Customer management unit &nbsp;(&oacute;rgano gestor). Role type = 02
8.  Customer processing unit (unidad tramitadora). Role type = 03
9.  Customer address
10.  Customer postal code
11.  Customer town
12.  Customer province
13.  Invoice serie
14.  Invoice number
15.  Invoice date
16.  Invoice subject

# Row 2. Invoice detail

1.  Fixed value 2
2.  Article code
3.  Delivery note number. Optional.
4.  Delivery note date. Optional.
5.  Item description
6.  Quantity
7.  Unit price without tax
8.  Total line
9.  Discount reason (text)
10.  Discount rate
11.  Discount amount
12.  Tax rate
13.  Tax base
14.  Tax amount

# Row 3. Tax amount and rates

1.  Fixed value 3
2.  Tax rate
3.  Tax base
4.  Tax amount

# Row 4. Invoice totals

1.  Fixed value 4
2.  Total gross amount
3.  General discount reason
4.  General discount rate
5.  Total general discount
6.  Total amount before taxes
7.  Total invoice

# Row 5. Payment schedule. One row for installment.

Only transfer to issuer account is supported

1.  Fixed value 5
2.  Installment due date
3.  Installment due amount
4.  Payment means. Fixed 04 (credit transfer)
5.  Account number to be credited (IBAN)