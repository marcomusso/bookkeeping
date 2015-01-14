# BookKeeping

Current status: work in progress!

A simple Mojolicious application to keep track of your invoices (receivable, payable).

Basically an example app to learn/try/use some old & new technologies:

* Bootstrap
* MongoDB (via the official MongoDB Perl driver)
* I18N (via the Mojolicious & JS plugin)
* D3js
* REST API

## Database

See script/dbinit.js for a (very) basic model/collections description. Create a new database and its collections in mongo by giving this command:

    mongo <scripts/dbinit.js

# How to start

You need a few things:

* a recent Perl installation (let's say >=5.18.4), if you are not an admin on your computer I suggest ``perlbrew`` to create your own Perl (+modules) local installation; in this case you need quite a lot of space in your home dir (let's say a few hundreds MB)
* then fire up `cpan` to install the required modules in a breeze:

    cpan Mojolicious Mojolicious::Plugin::I18N MongoDB DateTime

After a while you should have everything to try to start the app... In the cloned directory type:

    morbo -v script/book_keeping

Which starts the development server for a Mojolicious app, it should respond with:

    Server available at http://127.0.0.1:3000.

Open your browser and... well, you know (probably you'll want to take a look at `script/dbinit.js` for the login credentials :).

# TODO

A lot!

But for sure:

* proper I18N for javascript files (probably via [i18next](http://i18next.com))

# Prerequisites/included libraries

  - [Bootstrap](http:///getbootstrap.com) (3.3.1)
  - [D3](http://d3js.org) (3.4.13)
  - [jquery (>=2.0.3)](http://jquery.com) (2.1.1)
  - [DataTables.net](http://datatables.net) (1.10.2)
  - [DateTime Picker](http://www.malot.fr/bootstrap-datetimepicker/) (2.3.1)
  - [intro.js](http://usablica.github.io/intro.js/) v0.9.0 for the help text
  - [bootstrap-growl](http://bootstrap-growl.remabledesigns.com/) v2.0.1
    - [Animate.css](http://daneden.github.io/animate.css/) (github master @ 11/12/2014, v3.1.0)
