// use db bookkeeping
db = new Mongo().getDB("bookkeeping");
// create users collection
admin = { email: "admin", password: "adpexzg3FUZAk", last_login: new Date(), role: "admin", firstname: "Admin", lastname: "" };
// create default admin user (password admin)
db.users.insert(admin);
///////////////////////////////////////////////
// Other collections with one sample obj each
///////////////////////////////////////////////
// invoice_receivable: money that you expect
sample_invoice_receivable1 = {
  "invoice_date": new Date("2014-12-28T00:00:00+0100"),
  "invoice_id": "0012-14",
  "workorder": "SAMPLE workorder (you can delete this entire obj)",
  "units": 17,
  "cost_per_unit": 300,
  "resource": "Resource/person name",
  "notes": "",
  "total": "5100,00",
  "vat": "22,00%",
  "bank_transfer": "5100,00",
  "due_date": new Date("2015-01-31T00:00:00+0100"),
  "paid_date": ""
};
sample_invoice_receivable2 = {
  "invoice_date": new Date("2014-11-28T00:00:00+0100"),
  "invoice_id": "0011-14",
  "workorder": "SAMPLE workorder (you can delete this entire obj)",
  "units": 17,
  "cost_per_unit": 300,
  "resource": "Resource/person name",
  "notes": "",
  "total": "5100,00",
  "vat": "22,00%",
  "bank_transfer": "5.202,00",
  "due_date": new Date("2014-12-31T00:00:00+0100"),
  "paid_date": ""
};
sample_invoice_receivable3 = {
  "invoice_date": new Date("2014-11-28T00:00:00+0100"),
  "invoice_id": "0012-14",
  "workorder": "SAMPLE workorder (you can delete this entire obj)",
  "units": 17,
  "cost_per_unit": 300,
  "resource": "Resource/person name",
  "notes": "",
  "total": "5100,00",
  "vat": "22,00%",
  "bank_transfer": "5.202,00",
  "due_date": new Date("2014-12-31T00:00:00+0100"),
  "paid_date": ""
};
// invoice_payable: money that you own to others
sample_invoice_payable = {
  "invoice_date": new Date("2014-10-28T00:00:00+0100"),
  "invoice_id": "347A382",
  "supplier": "SAMPLE payable supplier",
  "notes": "Some note on this invoice",
  "total": "5100,00",
  "due_date": new Date("2014-12-31T00:00:00+0100"),
  "paid_date": ""
};
// customers
sample_customer = {
  // #@TODO add sample customer
};
// workorders
sample_workorder = {
  // #@TODO add sample workorder
};
// companies
sample_company = {
  "company_name": "Sample company name",
  "birthdate": new Date("2005-06-05T00:00:00+0100"),
  "type": "Limited"
};
// let's insert those sample records and create the collections!
db.invoice_receivable.insert(sample_invoice_receivable1);
db.invoice_receivable.insert(sample_invoice_receivable2);
db.invoice_receivable.insert(sample_invoice_receivable3);
db.invoice_payable.insert(sample_invoice_payable);
db.customers.insert(sample_customer);
db.workorders.insert(sample_workorder);
db.companies.insert(sample_company);
