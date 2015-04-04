# Lexicon
package BookKeeping::I18N::it;

use Mojo::Base 'BookKeeping::I18N';

use utf8;

our %Lexicon = (
  # Misc
    'TBD' => 'Funzione non ancora disponibile.',
    'To be implemented' => 'In corso di implementazione',
    'Some help on the current page' => 'Spiegazione delle funzionalità di questa pagina',
  # LOGIN
    'Please login' => 'Effettuare l\'accesso',
    'Login' => 'Accedi',
  # PAGE: HOME
    'Profile' => 'Profilo',
    'Messages' => 'Messaggi',
    'Company summary' => 'Riepilogo società',
    'Company name' => 'Nome',
    'Company type' => 'Tipo',
  # TOP NAVBAR MENU
    'Invoice' => 'Fattura',
    'Invoices' => 'Fatture',
    'Invoice receivable' => 'Fattura attiva',
    'Receivable' => 'Attive',
    'Invoice payable' => 'Fattura passiva',
    'Payable' => 'Passive',
    'Customers' => 'Clienti',
    'Preferences' => 'Impostazioni',
    'Main' => 'Menù',
    'Logout' => 'Esci',
  # ADMIN MENU
    # 'Backoffice' => 'Backoffice',
    'Configuration' => 'Configurazione',
    'Manage books' => 'Gestione contabilità',
  # PAGE: BOOKS
    'Receivable invoices' => 'Fatture attive',
    'Payable invoices' => 'Fatture passive',
    'Add receivable invoice' => 'Aggiungi fattura attiva',
    'Add payable invoice' => 'Aggiungi fattura passiva',
    'VAT %' => 'IVA %',
    'Edit' => 'Modifica',
  # Footer
    'Contact us' => 'Contattaci',
    'Help' => 'Aiuto',
    'Info' => 'Informazioni',
  # PAGE: Invoices receivable
    'Invoice ID' => 'Ident. fattura',
    'Invoice date' => 'Data fattura',
    'Workorder' => 'Commessa',
    'Total (ex. VAT)' => 'Totale (IVA escl.)',
      'Total before VAT and down payment' => 'Totale prima di IVA e ritenuta d\'acconto', # tooltip
    'VAT' => 'P.IVA',
    'Bank transfer' => 'Bonifico',
      'Expected amount' => 'Importo atteso', # tooltip
    'Due date' => 'Scadenza fattura',
    'Paid date' => 'Data pagamento',
  # PREFERENCES
    'These settings are common to all pages' => 'Le impostazioni sono comuni a tutte le pagine',
    'Presets' => 'Intervallo',
    'Time range from' => 'Da',
    'to' => 'a',
    'Theme' => 'Tema',
    'default' => 'predefinito',
    'custom' => 'personalizzato',
    'previous year' => 'anno precedente',
    'current year' => 'anno corrente'
);

"Vai";
