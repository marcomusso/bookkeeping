// use db bookkeeping
db = new Mongo().getDB("bookkeeping");
// create users collection
admin = { email: "admin", password: "adpexzg3FUZAk", last_login: new Date(), role: "admin", firstname: "", lastname: "" };
// create default admin user (password admin)
db.users.insert(admin);
// Other collections  with one sample obj
// invoice_receivable: money that you expect
invoice_receivable = {
  "invoice_date": "28/11/2014",
  "invoice_id": "0012-14",
  "workorder": "SAMPLE workorder (you can delete this entire obj)",
  "units": 17,
  "cost_per_unit": 300,
  "resource": "Resource/person name",
  "notes": "",
  "total": "5100,00",
  "vat": "22,00%",
  "bank_transfer": "5.202,00",
  "due_date": "31/12/2014",
  "paid_date": ""
};
// invoice_payable: money that you own to others
invoice_payable = {
  "invoice_date": "28/11/2014",
  "invoice_id": "347A382",
  "supplier": "SAMPLE payable supplier",
  "notes": "Some note on this invoice",
  "total": "5100,00",
  "due_date": "31/12/2014",
  "paid_date": ""
};
// let's insert those sample records and create the collections!
db.invoice_receivable.insert(invoice_receivable);
db.invoice_payable.insert(invoice_payable);
